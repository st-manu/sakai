<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
	<jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>
<f:view>
	<sakai:view>
		<h:form id="dfStatisticsForm" styleClass="sakai-forums" rendered="#{ForumTool.instructor || mfStatisticsBean.isAuthor}">
			<!-- discussionForum/statistics/dfStatisticsFullTextForOne.jsp -->
			<script>includeLatestJQuery("msgcntr");</script>
			<script src="/messageforums-tool/js/sak-10625.js"></script>
			<script src="/messageforums-tool/js/forum.js"></script>
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
			<% request.setAttribute("dfHeaderView", "statisticsMessage"); %>
			<% request.setAttribute("dfHeaderBack", "statisticsUser"); %>
			<%@ include file="/jsp/discussionForum/menu/forumsHeader.jsp" %>

			<div class="sakai-table-toolbar sakai-no-print">
				<div class="sakai-table-toolbar__actions">
					<h:outputLink styleClass="sakai-btn sakai-btn-ghost" id="print" value="javascript:printFriendly('#{ForumTool.printFriendlyFullTextForOne}');" title="#{msgs.cdfm_print}">
						<span class="si si-print" aria-hidden="true"></span>
						<span class="visually-hidden"><h:outputText value="#{msgs.print_friendly}" /></span>
					</h:outputLink>
				</div>
			</div>

			<h:dataTable id="subjectBody" value="#{mfStatisticsBean.userSubjectMsgBody}" var="stat" styleClass="messagesFlat">
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

						<h:panelGroup layout="block" styleClass="sakai-forums__message-actions sakai-no-print" rendered="#{ForumTool.instructor}">
							<h:commandLink action="#{ForumTool.processActionDisplayInThread}" title="#{msgs.stat_display_in_thread}" styleClass="sakai-btn sakai-btn-secondary">
								<f:param value="#{stat.forumId}" name="forumId"/>
								<f:param value="#{stat.topicId}" name="topicId"/>
								<f:param value="#{stat.msgId}" name="msgId"/>
								<h:outputText value="#{msgs.stat_display_in_thread}" />
							</h:commandLink>
						</h:panelGroup>
					</h:panelGroup>

					<h:panelGroup rendered="#{stat.msgDeleted}" layout="block" styleClass="sakai-forums__message">
						<div class="sakai-forums__message-header">
							<div class="sakai-forums__message-identity">
								<h:outputText value="#{msgs.cdfm_msg_deleted_label}" styleClass="sakai-forums__status"/>
							</div>
						</div>
						<div class="sakai-forums__message-actions sakai-no-print">
							<h:commandLink action="#{ForumTool.processActionDisplayInThread}" title="#{msgs.stat_display_in_thread}" styleClass="sakai-btn sakai-btn-secondary">
								<f:param value="#{stat.forumId}" name="forumId"/>
								<f:param value="#{stat.topicId}" name="topicId"/>
								<f:param value="#{stat.msgId}" name="msgId"/>
								<h:outputText value="#{msgs.stat_display_in_thread}" />
							</h:commandLink>
						</div>
					</h:panelGroup>
				</h:column>
			</h:dataTable>

			<div class="sakai-actions">
				<h:commandButton action="#{mfStatisticsBean.processActionBackToUser}" value="#{mfStatisticsBean.buttonUserName}"
					title="#{mfStatisticsBean.buttonUserName}" styleClass="sakai-btn sakai-btn-ghost"/>
			</div>
		</h:form>
	</sakai:view>
</f:view>
