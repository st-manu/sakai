<%@ page import="jakarta.faces.context.*, jakarta.faces.application.*,
                 jakarta.faces.el.*,
                 org.sakaiproject.tool.messageforums.ui.MessageForumStatisticsBean" %>
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

	FacesContext context = FacesContext.getCurrentInstance();
	Application app = context.getApplication();
	ValueBinding binding = app.createValueBinding("#{mfStatisticsBean}");
	MessageForumStatisticsBean statsBean = (MessageForumStatisticsBean) binding.getValue(context);

	String selectedUserId = request.getParameter("siteUserId");
	String frameId = request.getParameter("frameId");
	String dialogDivId = request.getParameter("dialogDivId");
	boolean isDialogBox = false;

	if (selectedUserId != null && !"".equals(selectedUserId)) {
		isDialogBox = true;
		statsBean.processActionStatisticsUser();
	}
%>

<f:view>
	<sakai:view>
		<h:form id="dfStatisticsForm" styleClass="sakai-forums">
			<script>includeLatestJQuery("msgcntr");</script>
			<script src="/messageforums-tool/js/sak-10625.js"></script>
			<script src="/messageforums-tool/js/forum.js"></script>
			<script src="/messageforums-tool/js/messages.js"></script>
			<script src="/messageforums-tool/js/dialog.js"></script>
			<script>
				function dialogLinkClick() {
					dialogutil.openDialog('dialogDiv', 'dialogFrame');
				}
				$(document).ready(function () {
					$(".messageBody").each(function () {
						if (typeof getWordCount !== 'function') {
							return;
						}
						let msgBody = $(this).html();
						msgBody = msgBody.replace(/\n/g, ',').replace(/\s/g, ' ').replace(/  ,/g, ',');
						const wordCountId = $(this).attr('id').substring(11, $(this).attr('id').length);
						$("#wordCountSpan" + wordCountId).html(getWordCount(msgBody));
					});
				});
			</script>

			<% if (isDialogBox) { %>
				<h1 class="sakai-tool-header__title"><h:outputText value="#{mfStatisticsBean.selectedSiteUser}"/></h1>
			<% } else { %>
				<% request.setAttribute("dfHeaderView", "statisticsAuthored"); %>
				<% request.setAttribute("dfHeaderBack", "statisticsUser"); %>
				<%@ include file="/jsp/discussionForum/menu/forumsHeader.jsp" %>
			<% } %>

			<div class="sakai-banner sakai-banner--success" id="gradesSavedDiv" style="display:none">
				<h:outputText value="#{msgs.cdfm_grade_successful}"/>
			</div>

			<div class="modal fade sakai-forums__grade-modal" id="dialogDiv" data-dialog-frame="dialogFrame" tabindex="-1" role="dialog" aria-modal="true" aria-hidden="true" aria-labelledby="dialogDivLabel">
				<div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
					<div class="modal-content">
						<div class="modal-header">
							<h2 class="modal-title" id="dialogDivLabel">
								<h:outputText value="#{msgs.cdfm_grade_msg}" />
							</h2>
							<button type="button" class="btn-close" data-bs-dismiss="modal">
								<span class="visually-hidden">
									<h:outputText value="#{msgs.close_window}" />
								</span>
							</button>
						</div>
						<div class="modal-body">
							<f:verbatim>
								<iframe id="dialogFrame" name="dialogFrame" class="grade-modal-frame" title="</f:verbatim><h:outputText value="#{msgs.cdfm_grade_msg}" /><f:verbatim>"></iframe>
							</f:verbatim>
						</div>
					</div>
				</div>
			</div>

			<div class="sakai-table-toolbar sakai-no-print">
				<div class="sakai-table-toolbar__filters" role="group">
					<h:commandLink action="#{mfStatisticsBean.toggleTopicTitleSort3}" title="#{msgs.stat_sort_by_topic}" styleClass="sakai-btn sakai-btn-ghost">
						<h:outputText value="#{msgs.stat_sort_by_topic}" />
						<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.topicTitleSort3 && mfStatisticsBean.ascendingForUser3}"/>
						<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.topicTitleSort3 && !mfStatisticsBean.ascendingForUser3}"/>
					</h:commandLink>
					<h:commandLink action="#{mfStatisticsBean.toggleDateSort3}" title="#{msgs.stat_sort_by_date}" styleClass="sakai-btn sakai-btn-ghost">
						<h:outputText value="#{msgs.stat_sort_by_date}" />
						<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.forumDateSort3 && mfStatisticsBean.ascendingForUser3}"/>
						<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.forumDateSort3 && !mfStatisticsBean.ascendingForUser3}"/>
					</h:commandLink>
				</div>
				<div class="sakai-table-toolbar__actions">
					<h:outputLink styleClass="sakai-btn sakai-btn-ghost" id="print" value="javascript:printFriendly('#{ForumTool.printFriendlyAllAuthoredMsg}');" title="#{msgs.cdfm_print}">
						<span class="si si-print" aria-hidden="true"></span>
						<span class="visually-hidden"><h:outputText value="#{msgs.print_friendly}" /></span>
					</h:outputLink>
				</div>
			</div>

			<h:dataTable id="staticAllMessages" value="#{mfStatisticsBean.userAuthoredStatistics2}" var="stat" styleClass="messagesFlat">
				<h:column>
					<h:panelGroup rendered="#{!stat.msgDeleted}" layout="block" styleClass="sakai-forums__message">
						<f:verbatim><span id="messageBody</f:verbatim><h:outputText value="#{stat.msgId}"/><f:verbatim>" class="messageBody display-none"></f:verbatim>
							<h:outputText escape="false" value="#{stat.message}"/>
						<f:verbatim></span></f:verbatim>

						<div class="sakai-forums__message-header">
							<div class="sakai-forums__message-identity">
								<h:outputText value="#{stat.forumSubject}" styleClass="sakai-forums__title title"/>
							</div>
							<div class="sakai-forums__message-meta">
								<h:outputText value="#{stat.forumTitle}" />
								<h:outputText value=" / " />
								<h:outputText value="#{stat.topicTitle}" />
								<h:outputText value="#{stat.forumDate}">
									<f:convertDateTime pattern="#{msgs.date_format_paren}" timeZone="#{ForumTool.userTimeZone}" locale="#{ForumTool.userLocale}"/>
								</h:outputText>
								<span>
									<h:outputText value="#{msgs.cdfm_message_count}" />
									<h:outputText value=": " />
									<f:verbatim><span id="wordCountSpan</f:verbatim><h:outputText value="#{stat.msgId}"/><f:verbatim>"></span></f:verbatim>
								</span>
							</div>
						</div>

						<div class="sakai-forums__message-body">
							<mf:htmlShowArea value="#{stat.message}" hideBorder="true" />
						</div>

						<h:panelGroup layout="block" rendered="#{!empty stat.decoAttachmentsList}">
							<h:dataTable value="#{stat.decoAttachmentsList}" var="eachAttach" styleClass="sakai-table sakai-table--stack attachListJSF">
								<h:column>
									<sakai:contentTypeMap fileType="#{eachAttach.attachment.attachmentType}" mapType="image" var="imagePath" pathPrefix="/library/image/"/>
									<h:graphicImage id="exampleFileIcon" value="#{imagePath}" alt="" />
									<h:outputLink value="#{eachAttach.url}" target="_blank">
										<h:outputText value="#{eachAttach.attachment.attachmentName}" />
									</h:outputLink>
								</h:column>
							</h:dataTable>
						</h:panelGroup>

						<% if (!isDialogBox) { %>
						<h:panelGroup layout="block" styleClass="sakai-forums__message-actions sakai-no-print" rendered="#{ForumTool.instructor}">
							<details class="sakai-overflow-menu">
								<summary class="sakai-btn sakai-btn-icon sakai-overflow-menu__toggle">
									<span class="si si-three-dots" aria-hidden="true"></span>
									<span class="visually-hidden"><h:outputText value="#{msgs.pvt_more_actions}"/></span>
								</summary>
								<div class="sakai-overflow-menu__panel">
									<h:outputLink value="/tool/#{ForumTool.currentToolId}/discussionForum/message/dfMsgGrade" target="dialogFrame"
											onclick="dialogLinkClick(this);">
										<f:param value="#{stat.forumId}" name="forumId"/>
										<f:param value="#{stat.topicId}" name="topicId"/>
										<f:param value="#{stat.msgId}" name="messageId"/>
										<f:param value="dialogDiv" name="dialogDivId"/>
										<f:param value="dialogFrame" name="frameId"/>
										<f:param value="gradesSavedDiv" name="gradesSavedDiv"/>
										<f:param value="#{mfStatisticsBean.selectedSiteUserId}" name="userId"/>
										<h:outputText value="#{msgs.cdfm_button_bar_grade}" />
									</h:outputLink>
									<h:commandLink action="#{ForumTool.processActionDisplayInThread}" title="#{msgs.stat_display_in_thread}">
										<f:param value="#{stat.forumId}" name="forumId"/>
										<f:param value="#{stat.topicId}" name="topicId"/>
										<f:param value="#{stat.msgId}" name="msgId"/>
										<h:outputText value="#{msgs.stat_display_in_thread}" />
									</h:commandLink>
								</div>
							</details>
						</h:panelGroup>
						<% } %>
					</h:panelGroup>

					<h:panelGroup rendered="#{stat.msgDeleted}" layout="block" styleClass="sakai-forums__message">
						<div class="sakai-forums__message-header">
							<div class="sakai-forums__message-identity">
								<h:outputText value="#{msgs.cdfm_msg_deleted_label}" styleClass="sakai-forums__status"/>
							</div>
						</div>
						<% if (!isDialogBox) { %>
						<div class="sakai-forums__message-actions sakai-no-print">
							<h:commandLink action="#{ForumTool.processActionDisplayInThread}" title="#{msgs.stat_display_in_thread}" styleClass="sakai-btn sakai-btn-secondary">
								<f:param value="#{stat.forumId}" name="forumId"/>
								<f:param value="#{stat.topicId}" name="topicId"/>
								<f:param value="#{stat.msgId}" name="msgId"/>
								<h:outputText value="#{msgs.stat_display_in_thread}" />
							</h:commandLink>
						</div>
						<% } %>
					</h:panelGroup>
				</h:column>
			</h:dataTable>

			<% if (!isDialogBox) { %>
			<div class="sakai-actions">
				<h:commandButton action="#{mfStatisticsBean.processActionBackToUser}" value="#{mfStatisticsBean.buttonUserName}"
					title="#{mfStatisticsBean.buttonUserName}" styleClass="sakai-btn sakai-btn-ghost"/>
			</div>
			<% } %>

			<% if (isDialogBox) { %>
			<input type="hidden" id="siteUserId" name="siteUserId" value="<%= selectedUserId %>"/>
			<input type="hidden" id="frameId" name="frameId" value="<%= frameId %>"/>
			<input type="hidden" id="dialogDivId" name="dialogDivId" value="<%= dialogDivId %>"/>
			<% } %>
		</h:form>
	</sakai:view>
</f:view>
