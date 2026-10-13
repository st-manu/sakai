/**
 * Copyright (c) 2007-2026 The Apereo Foundation
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
package org.sakaiproject.tool.assessment.ui.servlet.evaluation;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang3.StringUtils;
import org.sakaiproject.tool.assessment.data.ifc.assessment.PublishedAssessmentIfc;
import org.sakaiproject.tool.assessment.services.assessment.PublishedAssessmentService;
import org.sakaiproject.tool.assessment.ui.bean.authz.AuthorizationBean;
import org.sakaiproject.tool.assessment.ui.bean.evaluation.DownloadFileSubmissionsBean;
import org.sakaiproject.tool.assessment.ui.bean.evaluation.TotalScoresBean;
import org.sakaiproject.tool.assessment.ui.listener.util.ContextUtil;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public class DownloadFileSubmissionsServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	@Override
	public void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		doPost(req, res);
	}

	@Override
	public void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		DownloadFileSubmissionsBean downloadBean = (DownloadFileSubmissionsBean) ContextUtil
				.lookupBeanFromExternalServlet("downloadFileSubmissions", req, res);
		TotalScoresBean totalScores = (TotalScoresBean) ContextUtil.lookupBeanFromExternalServlet("totalScores", req, res);
		AuthorizationBean authzBean = (AuthorizationBean) ContextUtil.lookupBeanFromExternalServlet("authorization", req, res);

		String publishedId = StringUtils.trimToNull(req.getParameter("downloadFileSubmissions:publishedId"));
		if (publishedId == null) {
			publishedId = StringUtils.trimToNull(downloadBean.getPublishedAssessmentId());
		}
		if (publishedId == null) {
			publishedId = StringUtils.trimToNull(totalScores.getPublishedId());
		}

		if (publishedId == null) {
			res.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing published assessment id");
			return;
		}

		PublishedAssessmentService publishedAssessmentService = new PublishedAssessmentService();
		PublishedAssessmentIfc publishedAssessment = totalScores.getPublishedAssessment();
		if (publishedAssessment == null
				|| publishedAssessment.getPublishedAssessmentId() == null
				|| !publishedId.equals(publishedAssessment.getPublishedAssessmentId().toString())) {
			publishedAssessment = publishedAssessmentService.getPublishedAssessment(publishedId);
		}

		if (publishedAssessment == null) {
			res.sendError(HttpServletResponse.SC_NOT_FOUND, "Published assessment not found");
			return;
		}

		String currentSiteId = publishedAssessmentService
				.getPublishedAssessmentOwner(publishedAssessment.getPublishedAssessmentId());
		boolean allowed = authzBean.isUserAllowedToGradeAssessment(
				publishedId, publishedAssessment.getCreatedBy(), true, currentSiteId);

		if (!allowed) {
			String path = "/jsf/delivery/mediaAccessDenied.faces";
			RequestDispatcher dispatcher = req.getRequestDispatcher(path);
			dispatcher.forward(req, res);
			return;
		}

		try {
			downloadBean.downloadFiles(req, res, currentSiteId);
		} catch (Exception e) {
			log.error("Failed to download file submissions for published assessment {}", publishedId, e);
			if (!res.isCommitted()) {
				res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to download file submissions");
			}
		}
	}
}
