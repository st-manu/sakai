<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
	<jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>
<f:view>
	<sakai:view>
		<h:form id="dfStatisticsForm" styleClass="sakai-forums">
			<!-- discussionForum/statistics/dfStatisticsDisplayInThread.jsp -->
			<script>includeLatestJQuery("msgcntr");</script>
			<script src="/messageforums-tool/js/sak-10625.js"></script>
			<script src="/messageforums-tool/js/forum.js"></script>
			<script src="/messageforums-tool/js/messages.js"></script>
			<script>
				$(document).ready(function() {
					$(".messageBody").each(function(){
						let msgBody = $(this).html();
						msgBody = msgBody.replace(/\n/g,',').replace(/\s/g,' ').replace(/  ,/g,',');
						const wordCountId = $(this).attr('id').substring(11, $(this).attr('id').length);
						$("#wordCountSpan" + wordCountId).html(getWordCount(msgBody));
					});
				});
			</script>
			<% request.setAttribute("dfHeaderView", "statisticsThread"); %>
			<% request.setAttribute("dfHeaderBack", "statisticsUser"); %>
			<%@ include file="/jsp/discussionForum/menu/forumsHeader.jsp" %>

			<div class="sakai-table-toolbar sakai-no-print">
				<div class="sakai-table-toolbar__actions">
					<h:outputLink styleClass="sakai-btn sakai-btn-ghost" id="print" value="javascript:printFriendly('#{ForumTool.printFriendlyDisplayInThread}');" title="#{msgs.cdfm_print}">
						<span class="si si-print" aria-hidden="true"></span>
						<span class="visually-hidden"><h:outputText value="#{msgs.print_friendly}" /></span>
					</h:outputLink>
				</div>
			</div>

			<mf:hierDataTable id="allMessagesForOneTopic" value="#{ForumTool.messages}" var="msgDecorateBean" noarrows="true" styleClass="messagesThreaded">
				<h:column id="_msg_subject">
					<h:panelGroup layout="block" styleClass="sakai-forums__message#{ForumTool.selectedMsgId==msgDecorateBean.message.id ? ' sakai-forums__message--focus' : ''}">
						<h:panelGroup rendered="#{ForumTool.selectedMsgId==msgDecorateBean.message.id}">
							<span id="boldMsg"></span>
							<f:verbatim><span id="messageBody</f:verbatim><h:outputText value="#{msgDecorateBean.message.id}"/><f:verbatim>" class="messageBody display-none"></f:verbatim>
								<h:outputText escape="false" value="#{msgDecorateBean.message.body}"/>
							<f:verbatim></span></f:verbatim>
						</h:panelGroup>

						<h:panelGroup rendered="#{msgDecorateBean.message.deleted}" layout="block" styleClass="sakai-forums__message-header">
							<div class="sakai-forums__message-identity">
								<h:outputText value="#{msgs.cdfm_msg_deleted_label}" styleClass="sakai-forums__status"/>
							</div>
						</h:panelGroup>

						<h:panelGroup rendered="#{!msgDecorateBean.message.deleted}" layout="block" styleClass="sakai-forums__message-header">
							<div class="sakai-forums__message-identity">
								<h:outputText value="#{msgDecorateBean.message.title}" styleClass="sakai-forums__title title"/>
							</div>
							<div class="sakai-forums__message-meta">
								<h:outputText rendered="#{mfStatisticsBean.pureAnon}" styleClass="anonymousAuthor" value="#{msgDecorateBean.anonAwareAuthor}" />
								<h:outputText rendered="#{!mfStatisticsBean.pureAnon}" value="#{msgDecorateBean.anonAwareAuthor}" />
								<h:outputText rendered="#{mfStatisticsBean.pureAnon && msgDecorateBean.currentUserAndAnonymous}" value="#{msgs.cdfm_me}" />
								<h:outputText value="#{msgDecorateBean.message.created}">
									<f:convertDateTime pattern="#{msgs.date_format_paren}" timeZone="#{ForumTool.userTimeZone}" locale="#{ForumTool.userLocale}"/>
								</h:outputText>
								<h:panelGroup rendered="#{ForumTool.selectedMsgId==msgDecorateBean.message.id}">
									<h:outputText value="#{msgs.cdfm_message_count}" />
									<h:outputText value=": " />
									<f:verbatim><span id="wordCountSpan</f:verbatim><h:outputText value="#{msgDecorateBean.message.id}"/><f:verbatim>"></span></f:verbatim>
								</h:panelGroup>
							</div>
						</h:panelGroup>

						<h:panelGroup rendered="#{!msgDecorateBean.message.deleted}" layout="block" styleClass="sakai-forums__message-body">
							<mf:htmlShowArea value="#{msgDecorateBean.message.body}" hideBorder="true" />
						</h:panelGroup>

						<h:panelGroup layout="block" rendered="#{!empty msgDecorateBean.attachList}">
							<h:dataTable value="#{msgDecorateBean.attachList}" var="eachAttach" styleClass="sakai-table sakai-table--stack attachListJSF">
								<h:column>
									<sakai:contentTypeMap fileType="#{eachAttach.attachment.attachmentType}" mapType="image" var="imagePath" pathPrefix="/library/image/"/>
									<h:graphicImage id="exampleFileIcon" value="#{imagePath}" alt="" />
									<h:outputLink value="#{eachAttach.url}" target="_blank">
										<h:outputText value="#{eachAttach.attachment.attachmentName}" />
									</h:outputLink>
								</h:column>
							</h:dataTable>
						</h:panelGroup>
					</h:panelGroup>
				</h:column>
			</mf:hierDataTable>

			<div class="sakai-actions">
				<h:commandButton action="#{mfStatisticsBean.processActionBackToUser}" value="#{mfStatisticsBean.buttonUserName}"
					title="#{mfStatisticsBean.buttonUserName}" styleClass="sakai-btn sakai-btn-ghost"/>
			</div>

			<%
				String thisId = request.getParameter("panel");
				if (thisId == null) {
					thisId = "Main"	+ org.sakaiproject.tool.cover.ToolManager.getCurrentPlacement().getId();
				}
			%>
			<script>
				function resize(){
					mySetMainFrameHeight('<%=org.sakaiproject.util.Web.escapeJavascript(thisId)%>');
				}
			</script>
			<script>
				resize();
				document.location.href=document.location.href + "#boldMsg";
				document.body.setAttribute("onload", "setFocus(focus_path)");
			</script>
		</h:form>
	</sakai:view>
</f:view>
