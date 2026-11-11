<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
	<jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>

<%
	String thisId = request.getParameter("panel");
	if (thisId == null) {
		thisId = "Main" + org.sakaiproject.tool.cover.ToolManager.getCurrentPlacement().getId();
	}
%>

<f:view>
	<sakai:view>
		<h:form id="dfStatisticsForm" styleClass="sakai-forums">
			<script>includeLatestJQuery("msgcntr");</script>
			<script src="/messageforums-tool/js/dialog.js"></script>
			<script src="/messageforums-tool/js/forum.js"></script>
			<script>
				function dialogLinkClick() {
					dialogutil.openDialog('dialogDiv', 'dialogFrame');
				}
			</script>

			<% request.setAttribute("dfHeaderView", "statisticsUser"); %>
			<% request.setAttribute("dfHeaderBack", "statistics"); %>
			<%@ include file="/jsp/discussionForum/menu/forumsHeader.jsp" %>

			<div class="modal fade sakai-forums__grade-modal" id="dialogDiv" data-dialog-frame="dialogFrame" tabindex="-1" role="dialog" aria-modal="true" aria-hidden="true" aria-labelledby="dialogDivLabel">
				<div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
					<div class="modal-content">
						<div class="modal-header">
							<h2 class="modal-title" id="dialogDivLabel">
								<h:outputText value="#{msgs.cdfm_grade_msg}" />
							</h2>
							<button type="button" class="btn-close" data-bs-dismiss="modal">
								<span class="visually-hidden"><h:outputText value="#{msgs.close_window}" /></span>
							</button>
						</div>
						<div class="modal-body">
							<f:verbatim><iframe id="dialogFrame" name="dialogFrame" class="grade-modal-frame" title="</f:verbatim><h:outputText value="#{msgs.cdfm_grade_msg}" /><f:verbatim>"></iframe></f:verbatim>
						</div>
					</div>
				</div>
			</div>

			<h:panelGroup layout="block" styleClass="sakai-table-toolbar sakai-no-print" rendered="#{ForumTool.instructor}">
				<div class="sakai-table-toolbar__actions">
					<h:commandButton action="#{mfStatisticsBean.processDisplayPreviousParticipant}" value="#{msgs.stat_forum_prev_participant}"
							rendered="#{!mfStatisticsBean.isFirstParticipant}" title="#{msgs.stat_forum_prev_participant}" styleClass="sakai-btn sakai-btn-ghost"/>
					<h:commandButton action="#{mfStatisticsBean.processDisplayPreviousParticipant}" value="#{msgs.stat_forum_prev_participant}"
							rendered="#{mfStatisticsBean.isFirstParticipant}" title="#{msgs.stat_forum_prev_participant}" disabled="true" styleClass="sakai-btn sakai-btn-ghost"/>
					<h:commandButton action="#{mfStatisticsBean.processDisplayNextParticipant}" value="#{msgs.stat_forum_next_participant}"
							rendered="#{!mfStatisticsBean.isLastParticipant}" title="#{msgs.stat_forum_next_participant}" styleClass="sakai-btn sakai-btn-ghost"/>
					<h:commandButton action="#{mfStatisticsBean.processDisplayNextParticipant}" value="#{msgs.stat_forum_next_participant}"
							rendered="#{mfStatisticsBean.isLastParticipant}" title="#{msgs.stat_forum_next_participant}" disabled="true" styleClass="sakai-btn sakai-btn-ghost"/>
				</div>
			</h:panelGroup>

			<div class="sakai-banner sakai-banner--success" id="gradesSavedDiv" style="display:none">
				<h:outputText value="#{msgs.cdfm_grade_successful}"/>
			</div>

			<h:outputText rendered="#{ForumTool.anonymousEnabled && ForumTool.siteHasAnonymousTopics && !mfStatisticsBean.pureAnon}" value="#{msgs.stat_forum_anonymous_omitted}" styleClass="sakai-banner sakai-banner--info" />

			<div class="sakai-forums__stats-summary">
				<p>
					<h:outputText value="#{msgs.stat_percent_read_user}" escape="false" />
					<h:outputText value="#{mfStatisticsBean.getPercentRead()}">
						<f:convertNumber type="percent" />
					</h:outputText>
				</p>
				<p>
					<h:outputFormat value="#{msgs.stat_num_authored_user}" escape="false">
						<f:param value="#{mfStatisticsBean.userAuthoredStatistics.size()}" />
					</h:outputFormat>
				</p>
			</div>

			<section class="sakai-forums__stats-section">
				<div class="sakai-table-toolbar sakai-no-print">
					<h2 class="sakai-form-section__title"><h:outputText value="#{msgs.stat_forum_authored}" /></h2>
					<div class="sakai-table-toolbar__actions">
						<h:commandLink action="#{ForumTool.processActionShowFullTextForAll}" styleClass="sakai-btn sakai-btn-secondary" title="#{msgs.stat_show_all}" rendered="#{!empty mfStatisticsBean.userAuthoredStatistics}">
							<h:outputText value="#{msgs.stat_show_all}"/>
						</h:commandLink>
					</div>
				</div>
				<h:outputText rendered="#{empty mfStatisticsBean.userAuthoredStatistics}" value="#{msgs.stat_no_authored_message}" styleClass="sakai-banner sakai-banner--info"/>
				<div class="sakai-table-wrap">
					<h:dataTable styleClass="sakai-table sakai-table--hover sakai-table--stack" id="members" value="#{mfStatisticsBean.userAuthoredStatistics}" var="stat" rendered="#{!empty mfStatisticsBean.userAuthoredStatistics}"
							columnClasses="sakai-table__nowrap,sakai-table__nowrap,sakai-table__nowrap,sakai-table__primary,sakai-table__actions" cellpadding="0" cellspacing="0">
						<h:column>
							<f:facet name="header">
								<h:commandLink action="#{mfStatisticsBean.toggleForumTitleSort}" title="#{msgs.stat_forum_title}">
									<h:outputText value="#{msgs.stat_forum_title}" />
									<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.forumTitleSort && mfStatisticsBean.ascendingForUser}"/>
									<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.forumTitleSort && !mfStatisticsBean.ascendingForUser}"/>
								</h:commandLink>
							</f:facet>
							<h:outputText value="#{stat.forumTitle}" />
						</h:column>
						<h:column>
							<f:facet name="header">
								<h:commandLink action="#{mfStatisticsBean.toggleTopicTitleSort}" title="#{msgs.stat_topic_title}">
									<h:outputText value="#{msgs.stat_topic_title}" />
									<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.topicTitleSort && mfStatisticsBean.ascendingForUser}"/>
									<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.topicTitleSort && !mfStatisticsBean.ascendingForUser}"/>
								</h:commandLink>
							</f:facet>
							<h:outputText value="#{stat.topicTitle}" />
						</h:column>
						<h:column>
							<f:facet name="header">
								<h:commandLink action="#{mfStatisticsBean.toggleDateSort}" title="#{msgs.stat_forum_date}">
									<h:outputText value="#{msgs.stat_forum_date}" />
									<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.forumDateSort && mfStatisticsBean.ascendingForUser}"/>
									<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.forumDateSort && !mfStatisticsBean.ascendingForUser}"/>
								</h:commandLink>
							</f:facet>
							<h:outputText value="#{stat.forumDate}">
								<f:convertDateTime pattern="#{msgs.date_format}" timeZone="#{ForumTool.userTimeZone}" locale="#{ForumTool.userLocale}"/>
							</h:outputText>
						</h:column>
						<h:column>
							<f:facet name="header">
								<h:commandLink action="#{mfStatisticsBean.toggleSubjectSort}" title="#{msgs.stat_forum_subject}">
									<h:outputText value="#{msgs.stat_forum_subject}" />
									<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.forumSubjectSort && mfStatisticsBean.ascendingForUser}"/>
									<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.forumSubjectSort && !mfStatisticsBean.ascendingForUser}"/>
								</h:commandLink>
							</f:facet>
							<h:commandLink action="#{mfStatisticsBean.processActionDisplayMsgBody}" value="#{stat.forumSubject}">
								<f:param value="#{stat.msgId}" name="msgId"/>
							</h:commandLink>
						</h:column>
						<h:column rendered="#{ForumTool.instructor}">
							<f:facet name="header">
								<h:outputText value="#{msgs.pvt_more_actions}" styleClass="visually-hidden"/>
							</f:facet>
							<h:panelGroup layout="block" styleClass="sakai-row-actions">
								<details class="sakai-overflow-menu">
									<summary class="sakai-overflow-menu__toggle">
										<span class="si si-three-dots" aria-hidden="true"></span>
										<span class="visually-hidden"><h:outputText value="#{msgs.pvt_more_actions}"/></span>
									</summary>
									<div class="sakai-overflow-menu__panel">
										<h:outputLink value="/tool/#{ForumTool.currentToolId}/discussionForum/message/dfMsgGrade" target="dialogFrame"
												onclick="dialogLinkClick(this);">
											<f:param value="#{stat.forumId}" name="forumId"/>
											<f:param value="#{stat.topicId}" name="topicId"/>
											<f:param value="#{stat.msgId}" name="messageId"/>
											<f:param value="#{mfStatisticsBean.selectedSiteUserId}" name="userId"/>
											<f:param value="dialogDiv" name="dialogDivId"/>
											<f:param value="dialogFrame" name="frameId"/>
											<f:param value="gradesSavedDiv" name="gradesSavedDiv"/>
											<h:outputText value="#{msgs.cdfm_button_bar_grade}" />
										</h:outputLink>
										<h:commandLink action="#{ForumTool.processActionDisplayInThread}" title="#{msgs.stat_display_in_thread}">
											<f:param value="#{stat.topicId}" name="topicId"/>
											<f:param value="#{stat.forumId}" name="forumId"/>
											<f:param value="#{stat.msgId}" name="msgId"/>
											<h:outputText value="#{msgs.stat_display_in_thread}" />
										</h:commandLink>
									</div>
								</details>
							</h:panelGroup>
						</h:column>
					</h:dataTable>
				</div>
			</section>

			<section class="sakai-forums__stats-section">
				<h2 class="sakai-form-section__title"><h:outputText value="#{msgs.stat_forum_read}" /></h2>
				<h:outputText rendered="#{empty mfStatisticsBean.userReadStatistics}" value="#{msgs.stat_no_read_message}" styleClass="sakai-banner sakai-banner--info"/>
				<div class="sakai-table-wrap">
					<h:dataTable styleClass="sakai-table sakai-table--hover sakai-table--stack" id="members2" value="#{mfStatisticsBean.userReadStatistics}" var="stat2" rendered="#{!empty mfStatisticsBean.userReadStatistics}"
							columnClasses="sakai-table__nowrap,sakai-table__nowrap,sakai-table__nowrap,sakai-table__primary" cellpadding="0" cellspacing="0">
						<h:column>
							<f:facet name="header">
								<h:commandLink action="#{mfStatisticsBean.toggleForumTitleSort2}" title="#{msgs.stat_forum_title}">
									<h:outputText value="#{msgs.stat_forum_title}" />
									<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.forumTitleSort2 && mfStatisticsBean.ascendingForUser2}"/>
									<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.forumTitleSort2 && !mfStatisticsBean.ascendingForUser2}"/>
								</h:commandLink>
							</f:facet>
							<h:outputText value="#{stat2.forumTitle}" />
						</h:column>
						<h:column>
							<f:facet name="header">
								<h:commandLink action="#{mfStatisticsBean.toggleTopicTitleSort2}" title="#{msgs.stat_topic_title}">
									<h:outputText value="#{msgs.stat_topic_title}" />
									<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.topicTitleSort2 && mfStatisticsBean.ascendingForUser2}"/>
									<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.topicTitleSort2 && !mfStatisticsBean.ascendingForUser2}"/>
								</h:commandLink>
							</f:facet>
							<h:outputText value="#{stat2.topicTitle}" />
						</h:column>
						<h:column>
							<f:facet name="header">
								<h:commandLink action="#{mfStatisticsBean.toggleDateSort2}" title="#{msgs.stat_forum_date}">
									<h:outputText value="#{msgs.stat_forum_date}" />
									<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.forumDateSort2 && mfStatisticsBean.ascendingForUser2}"/>
									<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.forumDateSort2 && !mfStatisticsBean.ascendingForUser2}"/>
								</h:commandLink>
							</f:facet>
							<h:outputText value="#{stat2.forumDate}">
								<f:convertDateTime pattern="#{msgs.date_format}" timeZone="#{ForumTool.userTimeZone}" locale="#{ForumTool.userLocale}"/>
							</h:outputText>
						</h:column>
						<h:column>
							<f:facet name="header">
								<h:commandLink action="#{mfStatisticsBean.toggleSubjectSort2}" title="#{msgs.stat_forum_subject}">
									<h:outputText value="#{msgs.stat_forum_subject}" />
									<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.forumSubjectSort2 && mfStatisticsBean.ascendingForUser2}"/>
									<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.forumSubjectSort2 && !mfStatisticsBean.ascendingForUser2}"/>
								</h:commandLink>
							</f:facet>
							<h:outputText value="#{stat2.forumSubject}" />
						</h:column>
					</h:dataTable>
				</div>
			</section>
		</h:form>
	</sakai:view>
</f:view>
