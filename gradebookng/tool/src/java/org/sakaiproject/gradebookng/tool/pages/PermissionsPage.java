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
package org.sakaiproject.gradebookng.tool.pages;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.apache.commons.lang3.StringUtils;
import org.apache.wicket.ajax.AjaxRequestTarget;
import org.apache.wicket.ajax.form.AjaxFormComponentUpdatingBehavior;
import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.form.Button;
import org.apache.wicket.markup.html.form.CheckBox;
import org.apache.wicket.markup.html.form.ChoiceRenderer;
import org.apache.wicket.markup.html.form.DropDownChoice;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;
import org.apache.wicket.model.ResourceModel;
import org.apache.wicket.model.StringResourceModel;
import org.apache.wicket.request.mapper.parameter.PageParameters;
import org.sakaiproject.gradebookng.business.model.GbGroup;
import org.sakaiproject.gradebookng.business.model.GbUser;
import org.sakaiproject.gradebookng.tool.component.GbAjaxButton;
import org.sakaiproject.grading.api.CategoryDefinition;
import org.sakaiproject.grading.api.GraderPermission;
import org.sakaiproject.grading.api.PermissionDefinition;

import lombok.Getter;
import lombok.Setter;

/**
 * Permissions page
 *
 * @author Steve Swinsburg (steve.swinsburg@gmail.com)
 *
 */
public class PermissionsPage extends BasePage {

	private static final long serialVersionUID = 1L;

	private GbUser taSelected;

	// these are magic strings we use as ids for the all groups/all categories options
	// they should not conflict with any real values that might be passed in
	// and they are parsed out on save
	private final String ALL_GROUPS = "-1";
	private final Long ALL_CATEGORIES = (long) -1;

	private String gradebookUid;
	private String siteId;

	public PermissionsPage() {

		defaultRoleChecksForInstructorOnlyPage();

		disableLink(this.permissionsPageLink);

		gradebookUid = getCurrentGradebookUid();
		siteId = getCurrentSiteId();
	}

	@Override
	public void onInitialize() {
		super.onInitialize();

		// grab the selected parameter (if provided)
		final PageParameters params = getPageParameters();
		final String taUuid = params.get("selected").toOptionalString();

		// get the list of TAs
		final List<GbUser> teachingAssistants = this.businessService.getTeachingAssistants(gradebookUid, siteId);
		teachingAssistants.sort(Comparator.nullsLast(GbUser::compareTo));

		// get the TA GbUser for selected (if provided)
		if (StringUtils.isNotBlank(taUuid)) {
			for (final GbUser gbUser : teachingAssistants) {
				if (taUuid.equals(gbUser.getUserUuid())) {
					this.taSelected = gbUser;
					break;
				}
			}
		}

		// get list of categories
		final List<CategoryDefinition> categories = this.businessService.getGradebookCategories(gradebookUid, siteId);

		final boolean categoriesEnabled = this.businessService.categoriesAreEnabled(gradebookUid, siteId);

		// add the default 'all' category
		categories.add(0, new CategoryDefinition(this.ALL_CATEGORIES, getString("categories.all")));

		final Map<Long, String> categoryMap = new LinkedHashMap<>();
		for (final CategoryDefinition category : categories) {
			categoryMap.put(category.getId(), category.getName());
		}

		// get list of groups
		// note that for the permissions we need to use the group references not the ids
		final List<GbGroup> groups = this.businessService.getSiteSectionsAndGroups(gradebookUid, siteId);

		// add the default 'all' group
		groups.add(0, new GbGroup(this.ALL_GROUPS, getString("groups.all"), this.ALL_GROUPS, GbGroup.Type.ALL));

		final Map<String, String> groupMap = new LinkedHashMap<>();
		for (final GbGroup group : groups) {
			groupMap.put(group.getReference(), group.getTitle());
		}

		// get list of permissions that can be assigned (skip the course grade permissions as handle it differently)
		final List<String> assignablePermissions = new ArrayList<>();
		assignablePermissions.add(GraderPermission.VIEW.toString());
		assignablePermissions.add(GraderPermission.GRADE.toString());

		// determine text for instructions panel
		String instructions = null;
		if (teachingAssistants.isEmpty()) {
			instructions = getString("permissionspage.instructions.noteachingassistants");
		} else if (categories.isEmpty() && groups.isEmpty()) {
			instructions = getString("permissionspage.instructions.nocategoriesorsections");
		} else {
			instructions = getString("permissionspage.instructions.ok");
		}

		add(new Label("instructions", instructions).setEscapeModelStrings(false));

		// TA chooser
		final DropDownChoice<GbUser> taChooser = new DropDownChoice<GbUser>("ta", new Model<GbUser>(), teachingAssistants,
				new ChoiceRenderer<GbUser>() {
					private static final long serialVersionUID = 1L;

					@Override
					public Object getDisplayValue(final GbUser u) {
						return new StringResourceModel("permissionspage.label.tausername")
								.setParameters(u.getSortName(), u.getDisplayId()).getString();
					}

					@Override
					public String getIdValue(final GbUser u, final int index) {
						return u.getUserUuid();
					}

				});

		// hide if no ta's, which will hide the whole section
		if (teachingAssistants.isEmpty()) {
			taChooser.setVisible(false);
		}

		// add the onchange to the chooser
		taChooser.add(new AjaxFormComponentUpdatingBehavior("change") {
			private static final long serialVersionUID = 1L;

			@Override
			protected void onUpdate(final AjaxRequestTarget target) {

				// set the selection
				final GbUser selection = (GbUser) taChooser.getDefaultModelObject();

				// refresh with the selected user
				final PageParameters pageParameters = new PageParameters();
				pageParameters.add("selected", selection.getUserUuid());
				setResponsePage(PermissionsPage.class, pageParameters);
			}

		});

		taChooser.setNullValid(false);
		if (this.taSelected != null) {
			taChooser.setModelObject(this.taSelected);
		}

		add(taChooser);

		// setup the backing object
		final PermissionsPageModel pageModel = new PermissionsPageModel();

		// If we have chosen a user, get the permissions
		// Need to parse the permission list to process the view_course_grade permission
		if (this.taSelected != null) {
			final List<PermissionDefinition> permissions = this.businessService.getPermissionsForUser(this.taSelected.getUserUuid(), gradebookUid, siteId);

			final Iterator<PermissionDefinition> iter = permissions.iterator();
			while (iter.hasNext()) {
				final PermissionDefinition p = iter.next();
				if (StringUtils.equals(p.getFunctionName(), GraderPermission.VIEW_COURSE_GRADE.toString())) {
					pageModel.setViewCourseGrade(true);
					iter.remove();
				}
			}

			// Clear all permissions if the only one on the stack is "none"
			if (permissions.size() == 1 && StringUtils.equals(permissions.get(0).getFunctionName(), GraderPermission.NONE.toString())) {
				permissions.clear();
			}

			pageModel.setPermissions(permissions);

		}

		// if no permissions defined yet
		final Label noPermissions = new Label("noPermissions", new ResourceModel("permissionspage.instructions.norules")) {
			private static final long serialVersionUID = 1L;

			@Override
			public boolean isVisible() {
				return (PermissionsPage.this.taSelected != null && pageModel.getPermissions().isEmpty());
			}
		};
		add(noPermissions);

		// FORM
		final Form form = new Form<>("form", Model.of(pageModel)) {
			private static final long serialVersionUID = 1L;

			@Override
			public boolean isVisible() {
				return PermissionsPage.this.taSelected != null;
			}
		};

		// submit button
		final Button submit = new Button("submit") {
			private static final long serialVersionUID = 1L;

			@Override
			public void onSubmit() {
				final Form<?> form = getForm();

				final PermissionsPageModel model = (PermissionsPageModel) form.getModelObject();
				final List<PermissionDefinition> permissions = model.getPermissions();

				// parse out the magic strings back to nulls for persisting
				for (final PermissionDefinition permission : permissions) {
					if (StringUtils.equals(permission.getGroupReference(), PermissionsPage.this.ALL_GROUPS)) {
						permission.setGroupReference(null);
					}
					if (permission.getCategoryId().equals(PermissionsPage.this.ALL_CATEGORIES)) {
						permission.setCategoryId(null);
					}
				}

				// if we have permissions AND the checkbox is ticked, create a new permission for it
				if (!permissions.isEmpty() && model.getViewCourseGrade()) {
					final PermissionDefinition viewCourseGradePermission = new PermissionDefinition();
					viewCourseGradePermission.setUserId(PermissionsPage.this.taSelected.getUserUuid());
					viewCourseGradePermission.setGroupReference(null);
					viewCourseGradePermission.setCategoryId(null);
					viewCourseGradePermission.setFunctionName(GraderPermission.VIEW_COURSE_GRADE.toString());
					permissions.add(viewCourseGradePermission);
				}

				// remove any dupes - we also present a message if dupes were removed
				final List<PermissionDefinition> distinctPermissions = permissions.stream().distinct().collect(Collectors.toList());

				PermissionsPage.this.businessService.updatePermissionsForUser(gradebookUid, taSelected.getUserUuid(),
						distinctPermissions);

				getSession().success(getString("permissionspage.update.success"));

				if (distinctPermissions.size() < permissions.size()) {
					getSession().success(getString("permissionspage.update.dupes"));
				}

				refreshPage(PermissionsPage.this.taSelected.getUserUuid());
			}

			@Override
			public boolean isVisible() {
				return (PermissionsPage.this.taSelected != null);
			}
		};
		form.add(submit);

		// clear button
		final Button clear = new Button("clear") {
			private static final long serialVersionUID = 1L;

			@Override
			public void onSubmit() {
				refreshPage(PermissionsPage.this.taSelected.getUserUuid());
			}

			@Override
			public boolean isVisible() {
				return (PermissionsPage.this.taSelected != null);
			}
		};
		clear.setDefaultFormProcessing(false);
		form.add(clear);

		// reset to defaults button
		final Button defaults = new Button("defaults") {
			private static final long serialVersionUID = 1L;

			@Override
			public void onSubmit() {
				String userUUID = PermissionsPage.this.taSelected.getUserUuid();
				businessService.clearPermissionsForUser(gradebookUid, userUUID);

				getSession().success(getString("permissionspage.update.success"));

				// refresh page
				refreshPage(userUUID);
			}

			@Override
			public boolean isVisible() {
				return (PermissionsPage.this.taSelected != null);
			}
		};
		defaults.setDefaultFormProcessing(false);
		form.add(defaults);

		// coursegrade checkbox
		form.add(new CheckBox("viewCourseGrade", new PropertyModel<Boolean>(pageModel, "viewCourseGrade")) {
			private static final long serialVersionUID = 1L;

			@Override
			public boolean isVisible() {
				return (PermissionsPage.this.taSelected != null && !pageModel.getPermissions().isEmpty());
			}
		});

		// render view for list of permissions
		final ListView<PermissionDefinition> permissionsView = new ListView<PermissionDefinition>("permissions",
				pageModel.getPermissions()) {

			private static final long serialVersionUID = 1L;

			@Override
			protected void populateItem(final ListItem<PermissionDefinition> item) {

				final PermissionDefinition permission = item.getModelObject();

				// can
				item.add(new Label("can", new ResourceModel("permissionspage.item.can")));

				// function list
				final DropDownChoice<String> functionChooser = new DropDownChoice<String>("functionName",
						new PropertyModel<String>(permission, "functionName"), assignablePermissions, new ChoiceRenderer<String>() {
							private static final long serialVersionUID = 1L;

							@Override
							public Object getDisplayValue(final String functionName) {
								return getString("permissionspage.function." + functionName);
							}

							@Override
							public String getIdValue(final String functionName, final int index) {
								return functionName;
							}

						});
				functionChooser.setNullValid(false);
				item.add(functionChooser);

				// categories list
				final List<Long> categoryIdList = new ArrayList<Long>(categoryMap.keySet());
				final DropDownChoice<Long> categoryChooser = new DropDownChoice<Long>("category",
						new PropertyModel<Long>(permission, "categoryId"), categoryIdList, new ChoiceRenderer<Long>() {
							private static final long serialVersionUID = 1L;

							@Override
							public Object getDisplayValue(final Long l) {
								return categoryMap.get(l);
							}

							@Override
							public String getIdValue(final Long l, final int index) {
								if (l == null) {
									return ""; // to match what the service stores
								}
								return l.toString();
							}
						});
				// set selected or first item
				categoryChooser.setModelObject((permission.getCategoryId() != null) ? permission.getCategoryId() : categoryIdList.get(0));
				categoryChooser.setNullValid(false);
				categoryChooser.setVisible(categoriesEnabled);
				item.add(categoryChooser);

				item.add(new WebMarkupContainer("allGradeItems").setVisible(!categoriesEnabled));

				// in
				item.add(new Label("in", new ResourceModel("permissionspage.item.in")));

				// groups list
				final List<String> groupRefList = new ArrayList<String>(groupMap.keySet());
				final DropDownChoice<String> groupChooser = new DropDownChoice<String>("group",
						new PropertyModel<String>(permission, "groupReference"), groupRefList, new ChoiceRenderer<String>() {
							private static final long serialVersionUID = 1L;

							@Override
							public Object getDisplayValue(final String groupRef) {
								return groupMap.get(groupRef);
							}

							@Override
							public String getIdValue(final String groupRef, final int index) {
								return groupRef;
							}
						});
				// set selected or first item
				groupChooser
						.setModelObject((permission.getGroupReference() != null) ? permission.getGroupReference() : groupRefList.get(0));
				groupChooser.setNullValid(false);
				item.add(groupChooser);

				// remove button
				final GbAjaxButton remove = new GbAjaxButton("remove") {
					private static final long serialVersionUID = 1L;

					@Override
					public void onSubmit(final AjaxRequestTarget target) {

						// remove current item
						final PermissionDefinition current = item.getModelObject();
						pageModel.getPermissions().remove(current);

						target.add(form);
					}
				};
				remove.setDefaultFormProcessing(false);
				item.add(remove);

			}

			@Override
			public boolean isVisible() {
				return (PermissionsPage.this.taSelected != null);
			}

		};
		form.add(permissionsView);

		// 'add a rule' button
		final GbAjaxButton addRule = new GbAjaxButton("addRule") {
			private static final long serialVersionUID = 1L;

			@Override
			public void onSubmit(final AjaxRequestTarget target) {

				// add a new entry with default values so the dropdowns are sane
				final PermissionDefinition newDef = new PermissionDefinition();
				newDef.setUserId(PermissionsPage.this.taSelected.getUserUuid());
				newDef.setGroupReference(PermissionsPage.this.ALL_GROUPS);
				newDef.setCategoryId(PermissionsPage.this.ALL_CATEGORIES);
				newDef.setFunctionName(GraderPermission.VIEW.toString());
				pageModel.getPermissions().add(newDef);

				target.add(form);
			}

			@Override
			public boolean isVisible() {
				return (PermissionsPage.this.taSelected != null);
			}
		};
		form.add(addRule);

		add(form);
		// save changes

	}

	/**
	 * Adds the selected user to the page params and refreshes the page.
	 * @param userUUID the UUID of the currently selected TA
	 */
	private void refreshPage(String userUUID) {
		final PageParameters pageParameters = new PageParameters();
		pageParameters.add("selected", userUUID);
		setResponsePage(PermissionsPage.class, pageParameters);
	}

	/**
	 * Class for wrapping up the data used by this page
	 */
	@Setter
    @Getter
    private class PermissionsPageModel implements Serializable {

		private static final long serialVersionUID = 1L;

		private List<PermissionDefinition> permissions;

		private Boolean viewCourseGrade;

		public PermissionsPageModel() {
			this.permissions = new ArrayList<>();
		}

	}
}
