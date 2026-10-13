/**********************************************************************************
 * $URL: https://source.sakaiproject.org/svn/sam/trunk/samigo-app/src/java/org/sakaiproject/tool/assessment/ui/bean/evaluation/DownloadFileSubmissions.java $
 * $Id: DownloadFileSubmissions.java 29431 2007-04-22 05:20:55Z ktsao@stanford.edu $
 ***********************************************************************************
 *
 * Copyright (c) 2007, 2008, 2009 The Sakai Foundation
 *
 * Licensed under the Educational Community License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.osedu.org/licenses/ECL-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 **********************************************************************************/

package org.sakaiproject.tool.assessment.ui.bean.evaluation;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

import jakarta.faces.bean.SessionScoped;
import jakarta.faces.context.FacesContext;
import jakarta.faces.event.ActionEvent;
import jakarta.faces.model.SelectItem;
import jakarta.faces.bean.ManagedBean;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpServletRequest;

import lombok.extern.slf4j.Slf4j;

import org.apache.commons.lang3.StringUtils;
import org.sakaiproject.section.api.coursemanagement.EnrollmentRecord;
import org.sakaiproject.tool.assessment.data.ifc.assessment.ItemDataIfc;
import org.sakaiproject.tool.assessment.facade.AgentFacade;
import org.sakaiproject.tool.assessment.ui.listener.util.ContextUtil;
import org.sakaiproject.tool.assessment.util.DownloadFileUtil;
import org.sakaiproject.util.ResourceLoader;

/* For evaluation: Download File Submissions backing bean */
@Slf4j
@ManagedBean(name="downloadFileSubmissions")
@SessionScoped
public class DownloadFileSubmissionsBean implements Serializable {

	private static final ResourceLoader rb = new ResourceLoader("org.sakaiproject.tool.assessment.bundle.EvaluationMessages");
	private String assessmentId;
	private String assessmentName;
	private String firstTargetSelected;
	private List<String> sectionsSelected;
	private ArrayList<ItemDataIfc> fileUploadQuestionList;
	private HashMap<Long, ItemDataIfc> fileUploadQuestionMap;
	private List<SelectItem> availableSectionItems;
	private String publishedAssessmentId;
	private HashMap<String, String> sectionUuidNameMap;
	public static final String SELECTED_SECTIONS_GROUPS = "sections";
	public static final String ONE_SECTION_GROUP = "one";
	public static final String SITE = "site";

	/**
	 * Creates a new TotalScoresBean object.
	 */
	public DownloadFileSubmissionsBean() {
		log.debug("Creating a new DownloadFileSubmissionsBean");
	}

	public List<String> getSectionsSelected() {
		return sectionsSelected;
	}

	public void setSectionsSelected(List<String> groupSetected) {
		this.sectionsSelected = groupSetected;
	}

	public List<SelectItem> getAvailableSectionItems() {
		return availableSectionItems;
	}

	public void setAvailableSectionItems(List<SelectItem> availableSectionItems) {
		this.availableSectionItems = availableSectionItems;
	}

	public int getAvailableSectionSize() {
		return availableSectionItems == null ? 0 : availableSectionItems.size();
	}

	public SelectItem[] getSiteSectionItems(){
		TotalScoresBean totalScores = (TotalScoresBean) ContextUtil.lookupBean("totalScores");
		List sectionList = totalScores.getSectionFilterSelectItems();
		int numSection = availableSectionItems.size();
		SelectItem[] target = new SelectItem[2];

		target[0] = new SelectItem(this.SITE, rb.getString("for_all_sections_groups"));

		if (numSection == 1) {
			SelectItem sectionItem = (SelectItem) availableSectionItems.get(0);
			target[1] = new SelectItem(this.ONE_SECTION_GROUP, sectionItem.getLabel());
		}
		else if (numSection > 1) {
			target[1] = new SelectItem(this.SELECTED_SECTIONS_GROUPS, rb.getString("for_selected_sections_groups"));
		}
		return target;
	}

	public void setFirstTargetSelected(String firstTargetSelected){
		this.firstTargetSelected = firstTargetSelected.trim();
	}

	public String getFirstTargetSelected(){
		return firstTargetSelected;
	}

	public void setFileUploadQuestionList(ArrayList<ItemDataIfc> fileUploadQuestionList){
		this.fileUploadQuestionList = fileUploadQuestionList;
		this.fileUploadQuestionList.sort(new Comparator<ItemDataIfc>() {
			//We need to compare to order sections and, in each section its questions
			@Override
			public int compare(ItemDataIfc it1, ItemDataIfc it2) {
				if(it1 == null) return -1;
				if(it2 == null) return 1;
				if(it1 == it2 ) return 0;
				if(it1.getSection().getSequence() > it2.getSection().getSequence()) return 1;
				else if(it1.getSection().getSequence().equals(it2.getSection().getSequence())) {
					return it1.getSequence().compareTo(it2.getSequence());
				}
				return -1;
			}
		});
	}

	public ArrayList<ItemDataIfc> getFileUploadQuestionList(){
		return fileUploadQuestionList;
	}

	public void setFileUploadQuestionMap(HashMap<Long, ItemDataIfc> fileUploadQuestionMap){
		this.fileUploadQuestionMap = fileUploadQuestionMap;
	}

	public HashMap<Long, ItemDataIfc> getFileUploadQuestionMap(){
		return fileUploadQuestionMap;
	}

	public int getFileUploadQuestionListSize(){
		return fileUploadQuestionList == null ? 0 : fileUploadQuestionList.size();
	}

	public String getPublishedAssessmentId(){
		return publishedAssessmentId;
	}

	public void setPublishedAssessmentId(String publishedAssessmentId){
		this.publishedAssessmentId = publishedAssessmentId;
	}

	public HashMap getSectionUuidNameMap(){
		return sectionUuidNameMap;
	}

	public void setSectionUuidNameMap(HashMap<String, String> sectionUuidNameMap){
		this.sectionUuidNameMap = sectionUuidNameMap;
	}

	/**
	 * Stream selected file/audio submissions as a ZIP
	 *
	 * @param siteId site that owns the published assessment (tool placement may be absent in the servlet)
	 */
	public void downloadFiles(HttpServletRequest req, HttpServletResponse res, String siteId) {
		TotalScoresBean totalScores = (TotalScoresBean) ContextUtil.lookupBean("totalScores");
		DownloadFileUtil downloadFileUtil = new DownloadFileUtil();

		if (StringUtils.isBlank(siteId)) {
			siteId = AgentFacade.getCurrentSiteId();
		}

		ArrayList<ItemDataIfc> fileUploadQuestions = getFileUploadQuestionList();
		ArrayList<ItemDataIfc> idataList = new ArrayList<ItemDataIfc>();

		if (fileUploadQuestions != null && fileUploadQuestions.size() == 1) {
			idataList.add(fileUploadQuestions.get(0));
		} else {
			List<String> selectedQuestions = getRequestParamValuesContaining(req, "questionCheckbox");
			for (String selectedQuestion : selectedQuestions) {
				ItemDataIfc item = fileUploadQuestionMap.get(Long.valueOf(selectedQuestion));
				if (item != null) {
					idataList.add(item);
				}
			}
		}

		String targetSelected = StringUtils.trimToNull(getRequestParamValueContaining(req, "siteSection"));
		if (targetSelected == null) {
			targetSelected = firstTargetSelected;
		}

		List<String> selectedSections = getRequestParamValuesContaining(req, "sectionsForSite");
		if (selectedSections.isEmpty() && sectionsSelected != null) {
			selectedSections = sectionsSelected;
		}

		if (getAvailableSectionSize() == 0) {
			ArrayList<String> userUidList = getUserUidList(totalScores, null, siteId);
			downloadFileUtil.processWholeSiteOrOneSection(req, res, idataList, userUidList);
		} else if (this.SITE.equals(targetSelected)) {
			ArrayList<String> userUidList = getUserUidList(totalScores, null, siteId);
			downloadFileUtil.processWholeSiteOrOneSection(req, res, idataList, userUidList);
		} else if (this.SELECTED_SECTIONS_GROUPS.equals(targetSelected)) {
			if (selectedSections.size() == 1) {
				String sectionUuid = selectedSections.get(0);
				String sectionName = (String) sectionUuidNameMap.get(sectionUuid);
				ArrayList<String> userUidList = getUserUidList(totalScores, sectionUuid, siteId);
				downloadFileUtil.processWholeSiteOrOneSection(req, res, idataList, userUidList, sectionName);
			} else {
				HashMap sectionUsersMap = getSectionUsersMap(totalScores, selectedSections, siteId);
				downloadFileUtil.processMultipleSection(req, res, idataList, sectionUsersMap);
			}
		} else {
			SelectItem item = availableSectionItems.get(0);
			if (item != null) {
				ArrayList<String> userUidList = getUserUidList(totalScores, (String) item.getValue(), siteId);
				downloadFileUtil.processWholeSiteOrOneSection(req, res, idataList, userUidList, item.getLabel());
			}
		}
	}

	private String getRequestParamValueContaining(HttpServletRequest req, String paramPart) {
		List<String> values = getRequestParamValuesContaining(req, paramPart);
		return values.isEmpty() ? null : values.get(0);
	}

	private List<String> getRequestParamValuesContaining(HttpServletRequest req, String paramPart) {
		List<String> values = new ArrayList<String>();
		Enumeration<String> parameterNames = req.getParameterNames();
		while (parameterNames.hasMoreElements()) {
			String parameterName = parameterNames.nextElement();
			if (parameterName != null && parameterName.indexOf(paramPart) > -1) {
				String[] parameterValues = req.getParameterValues(parameterName);
				if (parameterValues != null) {
					for (String parameterValue : parameterValues) {
						if (StringUtils.isNotBlank(parameterValue)) {
							values.add(parameterValue);
						}
					}
				}
			}
		}
		return values;
	}

	private ArrayList<String> getUserUidList(TotalScoresBean totalScores, String sectionUuid, String siteId) {
		List<EnrollmentRecord> enrollments = null;
		ArrayList<String> userUidList = new ArrayList<String>();
		if (sectionUuid != null) {
			enrollments = totalScores.getSectionEnrollments(sectionUuid, siteId);
			for (Iterator iter = enrollments.iterator(); iter.hasNext(); ) {
				EnrollmentRecord enr = (EnrollmentRecord)iter.next();
				userUidList.add(enr.getUser().getUserUid());
			}
		}
		else {
			enrollments = totalScores.getAvailableEnrollments(false, siteId);
			for (Iterator iter = enrollments.iterator(); iter.hasNext(); ) {
				EnrollmentRecord enr = (EnrollmentRecord)iter.next();
				userUidList.add(enr.getUser().getUserUid());
			}
		}
		return userUidList;
	}

	private HashMap getSectionUsersMap(TotalScoresBean totalScores, List sectionList, String siteId) {
		HashMap<String, List<String>> sectionUsersMap = new HashMap<String, List<String>>();
		if (sectionList != null) {
			Iterator iter = sectionList.iterator();
			while (iter.hasNext()) {
				String sectionUuid = (String) iter.next();
				sectionUsersMap.put(sectionUuid, getUserUidList(totalScores, sectionUuid, siteId));
			}
		}
		return sectionUsersMap;
	}

}
