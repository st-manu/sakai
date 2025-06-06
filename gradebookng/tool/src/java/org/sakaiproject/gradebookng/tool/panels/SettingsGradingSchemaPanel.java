/**
 * Copyright (c) 2003-2017 The Apereo Foundation
 *
 * Licensed under the Educational Community License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *             http://opensource.org/licenses/ecl2
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.sakaiproject.gradebookng.tool.panels;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import lombok.Getter;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics;
import org.apache.wicket.AttributeModifier;
import org.apache.wicket.ajax.AjaxEventBehavior;
import org.apache.wicket.ajax.AjaxRequestTarget;
import org.apache.wicket.ajax.form.AjaxFormComponentUpdatingBehavior;
import org.apache.wicket.ajax.markup.html.form.AjaxButton;
import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.form.ChoiceRenderer;
import org.apache.wicket.markup.html.form.DropDownChoice;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.form.IFormModelUpdateListener;
import org.apache.wicket.markup.html.form.TextField;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;
import org.apache.wicket.model.ResourceModel;
import org.sakaiproject.gradebookng.business.FirstNameComparatorGbUser;
import org.sakaiproject.gradebookng.business.model.GbUser;
import org.sakaiproject.gradebookng.business.util.SettingsHelper;
import org.sakaiproject.gradebookng.tool.chart.CourseGradeChart;
import org.sakaiproject.gradebookng.tool.component.GbAjaxButton;
import org.sakaiproject.gradebookng.tool.model.GbGradingSchemaEntry;
import org.sakaiproject.gradebookng.tool.model.GbSettings;
import org.sakaiproject.gradebookng.tool.stats.CourseGradeStatistics;
import org.sakaiproject.grading.api.CourseGradeTransferBean;
import org.sakaiproject.grading.api.GradeMappingDefinition;

public class SettingsGradingSchemaPanel extends BasePanel implements IFormModelUpdateListener {

	private static final long serialVersionUID = 1L;

	IModel<GbSettings> model;

	WebMarkupContainer schemaWrap;
	WebMarkupContainer statsWrap;
	CourseGradeStatistics stats;
	ListView<GbGradingSchemaEntry> schemaView;
	private List<GradeMappingDefinition> gradeMappings;
	@Getter
    boolean expanded;
	String gradingSchemaName;
	DescriptiveStatistics statistics;
	Label modifiedSchema;
	Label unsavedSchema;
	Label duplicateEntries;

	CourseGradeChart chart;

	/**
	 * This is the currently PERSISTED grade mapping id that is persisted for this gradebook
	 */
	String configuredGradeMappingId;

	/**
	 * This is the currently SELECTED grade mapping, from the dropdown
	 */
	String currentGradeMappingId;

	/**
	 * List of {@link CourseGrade} cached here as it is used by a few components
	 */
	private Map<String, CourseGradeTransferBean> courseGradeMap;

	/**
	 * Count of grades for the chart
	 */
	int total;

	/**
	 * Has the schema been modified from the default percentages?
	 */
	boolean schemaModifiedFromDefault;

	/**
	 * Are there unsaved changes?
	 */
	boolean dirty;
	


	public SettingsGradingSchemaPanel(final String id, final IModel<GbSettings> model, final boolean expanded) {
		super(id, model);
		this.model = model;
		this.expanded = expanded;
	}

	@Override
	public void onInitialize() {
		super.onInitialize();

		// get all mappings available for this gradebook
		this.gradeMappings = this.model.getObject().getGradebookInformation().getGradeMappings();

		// get current one
		this.configuredGradeMappingId = this.model.getObject().getGradebookInformation().getSelectedGradeMappingId();

		// set the value for the dropdown
		this.currentGradeMappingId = this.configuredGradeMappingId;

		// setup the grading scale schema entries
		this.model.getObject().setGradingSchemaEntries(getGradingSchemaEntries());

		// get the course grade map
		this.courseGradeMap = getCourseGrades();

		// get the total number of course grades
		this.total = getTotalCourseGrades(this.courseGradeMap);

		// is the schema modified from the defaults?
		this.schemaModifiedFromDefault = isModified();

		// create map of grading scales to use for the dropdown
		final Map<String, String> gradeMappingMap = new LinkedHashMap<>();
		for (final GradeMappingDefinition gradeMapping : this.gradeMappings) {
			gradeMappingMap.put(gradeMapping.getId(), gradeMapping.getName());
		}

		final WebMarkupContainer settingsGradingSchemaAccordionButton = new WebMarkupContainer("settingsGradingSchemaAccordionButton");
		final WebMarkupContainer settingsGradingSchemaPanel = new WebMarkupContainer("settingsGradingSchemaPanel");
		
		// Set up accordion behavior
		setupAccordionBehavior(settingsGradingSchemaAccordionButton, settingsGradingSchemaPanel, this.expanded, 
			new AccordionStateUpdater() {
				@Override
				public void updateState(boolean newState) {
					SettingsGradingSchemaPanel.this.expanded = newState;
				}
				
				@Override
				public boolean getState() {
					return SettingsGradingSchemaPanel.this.expanded;
				}
			});
		
		add(settingsGradingSchemaPanel);
		add(settingsGradingSchemaAccordionButton);

		// grading scale type chooser
		final List<String> gradingSchemaList = new ArrayList<>(gradeMappingMap.keySet());
		final DropDownChoice<String> typeChooser = new DropDownChoice<>("type",
				new PropertyModel<String>(this.model, "gradebookInformation.selectedGradeMappingId"), gradingSchemaList,
				new ChoiceRenderer<String>() {
					private static final long serialVersionUID = 1L;

					@Override
					public Object getDisplayValue(final String gradeMappingId) {
						return gradeMappingMap.get(gradeMappingId);
					}

					@Override
					public String getIdValue(final String gradeMappingId, final int index) {
						return gradeMappingId;
					}
				});
		typeChooser.setNullValid(false);
		typeChooser.setModelObject(this.currentGradeMappingId);
		settingsGradingSchemaPanel.add(typeChooser);

		// add warning if the schema has been modified
		this.modifiedSchema = new Label("modifiedSchema", new ResourceModel("settingspage.gradingschema.modified.note"));
		this.modifiedSchema.setVisible(SettingsGradingSchemaPanel.this.schemaModifiedFromDefault);
		this.modifiedSchema.setOutputMarkupPlaceholderTag(true);
		settingsGradingSchemaPanel.add(this.modifiedSchema);

		// add warning if the schema is dirty. hidden by default
		this.unsavedSchema = new Label("unsavedSchema", new ResourceModel("settingspage.gradingschema.modified.warning"));
		this.unsavedSchema.setVisible(false);
		this.unsavedSchema.setOutputMarkupPlaceholderTag(true);
		settingsGradingSchemaPanel.add(this.unsavedSchema);

		// warning for duplicates
		this.duplicateEntries = new Label("duplicateEntries", new ResourceModel("settingspage.gradingschema.duplicates.warning"));
		this.duplicateEntries.setVisible(false);
		this.duplicateEntries.setOutputMarkupPlaceholderTag(true);
		settingsGradingSchemaPanel.add(this.duplicateEntries);

		// render the grading schema table
		this.schemaWrap = new WebMarkupContainer("schemaWrap");
		this.schemaView = new ListView<GbGradingSchemaEntry>("schemaView",
				new PropertyModel<List<GbGradingSchemaEntry>>(this.model, "gradingSchemaEntries")) {

			private static final long serialVersionUID = 1L;

			@Override
			protected void populateItem(final ListItem<GbGradingSchemaEntry> item) {

				final GbGradingSchemaEntry entry = item.getModelObject();

				// grade
				final TextField<Double> grade = new TextField<>("grade", new PropertyModel<Double>(entry, "grade"));
				item.add(grade);

				// minpercent
				final TextField<Double> minPercent = new TextField<>("minPercent", new PropertyModel<Double>(entry, "minPercent"));
				item.add(minPercent);

				// attach the onchange behaviours
				minPercent.add(new GradingSchemaChangeBehaviour(GradingSchemaChangeBehaviour.ONCHANGE));
				grade.add(new GradingSchemaChangeBehaviour(GradingSchemaChangeBehaviour.ONCHANGE));

				// remove button
				final AjaxButton remove = new AjaxButton("remove") {
					private static final long serialVersionUID = 1L;

					@Override
					public void onSubmit(final AjaxRequestTarget target) {

						// remove this entry from the model data
						final GbGradingSchemaEntry current = item.getModelObject();
						SettingsGradingSchemaPanel.this.model.getObject().getGradingSchemaEntries().remove(current);

						// repaint table
						target.add(SettingsGradingSchemaPanel.this.schemaWrap);

						// repaint chart
						refreshCourseGradeChart(target);
					}

				};
				remove.setDefaultFormProcessing(false);
				item.add(remove);
			}
		};
		this.schemaView.setOutputMarkupId(true);
		this.schemaWrap.setOutputMarkupId(true);
		this.schemaWrap.add(this.schemaView);
		settingsGradingSchemaPanel.add(this.schemaWrap);

		// handle updates on the schema type chooser
		typeChooser.add(new AjaxFormComponentUpdatingBehavior("change") {
			private static final long serialVersionUID = 1L;

			@Override
			protected void onUpdate(final AjaxRequestTarget target) {

				// set current selection
				SettingsGradingSchemaPanel.this.currentGradeMappingId = (String) typeChooser.getDefaultModelObject();

				// refresh data
				SettingsGradingSchemaPanel.this.model.getObject().setGradingSchemaEntries(getGradingSchemaEntries());

				// repaint table
				target.add(SettingsGradingSchemaPanel.this.schemaWrap);

				// set the warning if required
				SettingsGradingSchemaPanel.this.schemaModifiedFromDefault = isModified();
				SettingsGradingSchemaPanel.this.modifiedSchema.setVisible(SettingsGradingSchemaPanel.this.schemaModifiedFromDefault);
				target.add(SettingsGradingSchemaPanel.this.modifiedSchema);

				// refresh chart
				refreshCourseGradeChart(target);

				// refresh stats
				refreshStats(target);
			}
		});

		// button to add a mapping
		final GbAjaxButton addMapping = new GbAjaxButton("addMapping") {
			private static final long serialVersionUID = 1L;

			@Override
			protected void onSubmit(final AjaxRequestTarget target) {

				// add a new empty mapping to the model data
				final List<GbGradingSchemaEntry> entries = getGradingSchemaList();
				entries.add(stubGradingSchemaMapping());
				SettingsGradingSchemaPanel.this.model.getObject().setGradingSchemaEntries(entries);

				// repaint table
				target.add(SettingsGradingSchemaPanel.this.schemaWrap);

				// focus the new grading schema input
				target.appendJavaScript("sakai.gradebookng.settings.gradingschemas.focusLastRow();");
			}
		};
		addMapping.setDefaultFormProcessing(false);
		this.schemaWrap.add(addMapping);

		// if there are no grades, display message instead of chart
		settingsGradingSchemaPanel
				.add(new Label("noStudentsWithGradesMessage", new ResourceModel("settingspage.gradingschema.emptychart")) {
					private static final long serialVersionUID = 1L;

					@Override
					public boolean isVisible() {
						return SettingsGradingSchemaPanel.this.total == 0;
					}
				});

		// stats
		this.statsWrap = new WebMarkupContainer("statsWrap");
		this.statsWrap.setOutputMarkupId(true);
		settingsGradingSchemaPanel.add(this.statsWrap);

		this.stats = new CourseGradeStatistics("stats", getStatsData());
		this.statsWrap.add(this.stats);

		// if there are course grade overrides, add the list of students
		final List<GbUser> usersWithOverrides = getStudentsWithCourseGradeOverrides();
		settingsGradingSchemaPanel.add(new ListView<GbUser>("studentsWithCourseGradeOverrides", getStudentsWithCourseGradeOverrides()) {
			private static final long serialVersionUID = 1L;

			@Override
			protected void populateItem(final ListItem<GbUser> item) {
				item.add(new Label("name", new PropertyModel<String>(item.getModel(), "displayName")));
			}

			@Override
			public boolean isVisible() {
				return !usersWithOverrides.isEmpty();
			}
		});

		// chart
		this.chart = new CourseGradeChart("gradingSchemaChart", null);
		chart.setCurrentGradebookAndSite(currentGradebookUid, currentSiteId);
		settingsGradingSchemaPanel.add(this.chart);
	}

	/**
	 * Sync up the custom list we are using for the list view, back into the GradebookInformation object
	 */
	@Override
	public void updateModel() {

		final List<GbGradingSchemaEntry> schemaEntries = this.schemaView.getModelObject();

		final Map<String, Double> bottomPercents = new HashMap<>();
		for (final GbGradingSchemaEntry schemaEntry : schemaEntries) {
			bottomPercents.put(schemaEntry.getGrade(), schemaEntry.getMinPercent());
		}

		this.model.getObject().getGradebookInformation().setSelectedGradingScaleBottomPercents(bottomPercents);

		this.configuredGradeMappingId = this.currentGradeMappingId;
	}

	/**
	 * Helper to determine and return the applicable grading schema entries, depending on current state
	 *
	 * @return the list of {@link GbGradingSchemaEntry} for the currently selected grading schema id
	 */
	private List<GbGradingSchemaEntry> getGradingSchemaEntries() {
		return SettingsHelper.asList(getBottomPercents());
	}

	/**
	 * Helper to determine and return the applicable grading schema bottom percents, depending on current state
	 *
	 * @return the mappings
	 */
	private Map<String, Double> getBottomPercents() {

		// get configured values or defaults
		// need to retain insertion order
		Map<String, Double> bottomPercents;

		// note that we sort based on name so we need to pull the right name out of the list of mappings, for both cases
		this.gradingSchemaName = getGradingSchema(this.currentGradeMappingId).getName();

		if (StringUtils.equals(this.currentGradeMappingId, this.configuredGradeMappingId)) {
			// get the values from the configured grading scale (sorted by the service)
			bottomPercents = this.model.getObject().getGradebookInformation().getSelectedGradingScaleBottomPercents();
		} else {
			// get the default values for the chosen grading scale and sort them
			bottomPercents = GradeMappingDefinition.sortGradeMapping(
					getGradingSchema(this.currentGradeMappingId).getDefaultBottomPercents());
		}

		return bottomPercents;
	}

    /**
	 * Get a List of {@link GbUser}'s with course grade overrides.
	 *
	 * @return
	 */
	private List<GbUser> getStudentsWithCourseGradeOverrides() {

		// get all users with course grade overrides
		final List<String> userUuids = this.courseGradeMap.entrySet().stream()
				.filter(c -> StringUtils.isNotBlank(c.getValue().getEnteredGrade()))
				.map(c -> c.getKey())
				.collect(Collectors.toList());

		final List<GbUser> users = this.businessService.getGbUsers(currentSiteId, userUuids);
		users.sort(new FirstNameComparatorGbUser());

		return users;
	}

	/**
	 * Get the map of userId to {@link CourseGrade} for the students in this gradebook
	 *
	 * @return
	 */
	private Map<String, CourseGradeTransferBean> getCourseGrades() {

		final List<String> studentUuids = this.businessService.getGradeableUsers(currentGradebookUid, currentSiteId, null);
		return this.businessService.getCourseGrades(currentGradebookUid, currentSiteId, studentUuids, null);
	}

	/**
	 * Get the total number of course grades, excluding empty grades
	 *
	 * @param map
	 * @return
	 */
	private int getTotalCourseGrades(final Map<String, CourseGradeTransferBean> map) {
		return (int) map.values().stream().filter(c -> StringUtils.isNotBlank(c.getMappedGrade())).count();
	}

	/**
	 * Find a {@link GradeMappingDefinition} in the list of {@link GradeMappingDefinition} based on the id
	 *
	 * @param mappingId the id of the schema we want to pick out
	 * @return {@ link GradeMappingDefinition} or null
	 */
	private GradeMappingDefinition getGradingSchema(final String mappingId) {
		return this.gradeMappings
				.stream()
				.filter(gradeMapping -> StringUtils.equals(gradeMapping.getId(), mappingId))
				.findFirst()
				.get();
	}

	/**
	 * Has the stored grade mapping been modified from the defaults?
	 *
	 * @return
	 */
	private boolean isModified() {
		final GradeMappingDefinition gradeMapping = getGradingSchema(this.currentGradeMappingId);
		return gradeMapping.isModified();
	}

	/**
	 * Class to encapsulate the refresh of components when a change is made to the grading schema
	 */
	class GradingSchemaChangeBehaviour extends AjaxFormComponentUpdatingBehavior {

		private static final long serialVersionUID = 1L;

		private transient AjaxRequestTarget target;

		public static final String ONCHANGE = "change";

		public GradingSchemaChangeBehaviour(final String event) {
			super(event);
		}

		@Override
		protected void onUpdate(final AjaxRequestTarget t) {
			this.target = t;
			this.target.prependJavaScript("sakai.gradebookng.settings.gradingschemas.getFocusedCell();");
			refreshGradingSchemaTable();
			refreshCourseGradeChart(this.target);
			refreshMessages();
			this.target.appendJavaScript("sakai.gradebookng.settings.gradingschemas.focusPreviousCell();");
			this.target.appendJavaScript("sakai.gradebookng.settings.gradingschemas.addCategoryFunction();");
		}

		/**
		 * Refresh the grading schema table
		 */
		private void refreshGradingSchemaTable() {
			// fetch current data from model, sort and refresh the table
			final List<GbGradingSchemaEntry> schemaList = getGradingSchemaList();

			SettingsGradingSchemaPanel.this.model.getObject().setGradingSchemaEntries(schemaList);
			this.target.add(SettingsGradingSchemaPanel.this.schemaWrap);
		}

		/**
		 * Refresh messages
		 */
		private void refreshMessages() {

			// check if schema has changed from the persistent values and show the warning
			SettingsGradingSchemaPanel.this.unsavedSchema.setVisible(isDirty());
			this.target.add(SettingsGradingSchemaPanel.this.unsavedSchema);
		}

		/**
		 * Has the page model's grade mapping been changed from the stored one?
		 *
		 * @return
		 */
		private boolean isDirty() {

			// Note that the maps must be HashMaps for the comparison to work properly due to TreeMap.equals() != HashMap.equals().

			// get current values
			final List<GbGradingSchemaEntry> currentValues = SettingsGradingSchemaPanel.this.model.getObject().getGradingSchemaEntries();
			final Map<String, Double> currentGradeMapping = new HashMap<>(SettingsHelper.asMap(currentValues));

			// get stored values
			final GradeMappingDefinition storedValues = getGradingSchema(SettingsGradingSchemaPanel.this.currentGradeMappingId);
			final Map<String, Double> storedGradeMapping = new HashMap<>(storedValues.getGradeMap());

			return !currentGradeMapping.equals(storedGradeMapping);
		}

	}

	/**
	 * Helper to get the gradingschema list from the model
	 *
	 * @return
	 */
	private List<GbGradingSchemaEntry> getGradingSchemaList() {
		final List<GbGradingSchemaEntry> schemaList = SettingsGradingSchemaPanel.this.model.getObject().getGradingSchemaEntries();
		schemaList.sort(Collections.reverseOrder());
		return schemaList;
	}

	/**
	 * Create a new grading schema entry stub
	 *
	 * @return {@link GbGradingSchemaEntry}
	 */
	private GbGradingSchemaEntry stubGradingSchemaMapping() {
		return new GbGradingSchemaEntry(null, null);
	}

	/**
	 * Refresh the course grade chart
	 *
	 * @param target
	 */
	private void refreshCourseGradeChart(final AjaxRequestTarget target) {
		// we need the current data from model
		final List<GbGradingSchemaEntry> schemaList = getGradingSchemaList();

		// add warning for duplicates
		this.duplicateEntries.setVisible(SettingsHelper.hasDuplicates(schemaList));
		target.add(this.duplicateEntries);

		// refresh the chart
		Map<String, Double> schemaMap = SettingsHelper.asMap(schemaList);
		schemaMap = GradeMappingDefinition.sortGradeMapping(schemaMap);
		this.chart.refresh(target, schemaMap);
	}

	/**
	 * Get the stats data we need for {@link CourseGradeStatistics}
	 *
	 * @return Model of data
	 */
	private IModel<Map<String, Object>> getStatsData() {
		final Map<String, Object> data = new HashMap<>();
		data.put("courseGradeMap", this.courseGradeMap);
		data.put("gradingSchemaName", this.gradingSchemaName);
		data.put("bottomPercents", getBottomPercents());
		return Model.ofMap(data);
	}

	/**
	 * Refresh the stats (replace the panels)
	 *
	 * @param target
	 */
	private void refreshStats(final AjaxRequestTarget target) {
		final CourseGradeStatistics newStats = new CourseGradeStatistics("stats", getStatsData());
		this.stats.replaceWith(newStats);
		target.add(newStats);
		this.stats = newStats;
	}

}
