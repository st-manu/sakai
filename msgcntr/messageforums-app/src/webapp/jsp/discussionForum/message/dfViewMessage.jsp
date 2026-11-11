<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>

<f:view>
	<sakai:view>
		<h:form id="msgForum" styleClass="sakai-forums specialLink" prependId = "false">
			<h:inputHidden id="currentMessageId" value="#{ForumTool.selectedMessage.message.id}"/>
			<h:inputHidden id="currentTopicId" value="#{ForumTool.selectedTopic.topic.id}"/>
			<h:inputHidden id="currentForumId" value="#{ForumTool.selectedForum.forum.id}"/>
			<h:inputHidden id="deletedMessage" value="#{ForumTool.selectedMessage.message.deleted}"/>
			<script>includeLatestJQuery("msgcntr");</script>
			<script src="/messageforums-tool/js/forum.js"></script>
			<script src="/messageforums-tool/js/sak-10625.js"></script>
			<script src="/messageforums-tool/js/messages.js"></script>

			<!--jsp/discussionForum/message/dfViewMessage.jsp-->
			<script>
				$(document).ready(function() {
					if ($('.sakai-forums__message-actions .sakai-overflow-menu__panel > *').length === 0) {
						$('.sakai-forums__message-actions').hide();
					}
					$('.permaLink').on('click', function(event){
						event.preventDefault();
						const url = this.getAttribute('href') || this.href;
						const status = document.getElementById('permalinkHolder');
						const copy = () => {
							if (!status) return;
							status.classList.remove('display-none');
							status.hidden = false;
							window.clearTimeout(status._permalinkTimer);
							status._permalinkTimer = window.setTimeout(() => {
								status.classList.add('display-none');
								status.hidden = true;
							}, 4000);
						};
						if (navigator.clipboard?.writeText) {
							navigator.clipboard.writeText(url).then(copy).catch(copy);
						} else {
							copy();
						}
					});
					const delMessage = document.getElementById("deletedMessage");
					if (delMessage?.value === "false"){
						var msgBody = document.getElementById("messageBody").innerHTML;
						msgBody = msgBody.replace(/\n/g,',').replace(/\s/g,' ').replace(/  ,/g,',');
						msgcntr_word_count(msgBody);
					}
				});
			</script>
			<% request.setAttribute("dfHeaderView", "message"); %>
			<% request.setAttribute("dfHeaderBack", "thread"); %>
			<%@ include file="/jsp/discussionForum/menu/forumsHeader.jsp" %>

			<div class="sakai-forums__forum-header">
				<div class="sakai-forums__forum-identity">
					<h:panelGroup styleClass="sakai-forums__status" rendered="#{ForumTool.selectedTopic.availability == 'false'}">
						<span class="si si-calendar-x" aria-hidden="true"></span>
						<span class="visually-hidden"><h:outputText value="#{msgs.topic_restricted_message}"/></span>
					</h:panelGroup>
					<h:panelGroup styleClass="sakai-forums__status" rendered="#{ForumTool.selectedTopic.locked =='true'}">
						<span class="si si-locked" aria-hidden="true"></span>
						<span class="visually-hidden"><h:outputText value="#{msgs.cdfm_topic_locked}"/></span>
					</h:panelGroup>
					<h:outputText value="#{ForumTool.selectedForum.forum.title} / #{ForumTool.selectedTopic.topic.title}" styleClass="sakai-forums__meta"/>
				</div>
				<h:outputText value="#{ForumTool.selectedTopic.topic.shortDescription}" styleClass="sakai-forums__description"
						rendered="#{!empty ForumTool.selectedTopic.topic.shortDescription}"/>
				<h:panelGroup layout="block" rendered="#{!empty ForumTool.selectedTopic.topic.extendedDescription && ForumTool.selectedTopic.topic.extendedDescription != '<br/>'}">
					<p id="openLinkBlock" class="toggleParent openLinkBlock">
						<a href="#" id="showMessage" class="toggle show">
							<span class="si si-chevron-down" aria-hidden="true"></span>
							<h:outputText value=" #{msgs.cdfm_read_full_description}" />
						</a>
					</p>
					<p id="hideLinkBlock" class="toggleParent hideLinkBlock display-none">
						<a href="#" id="hideMessage" class="toggle show">
							<span class="si si-chevron-up" aria-hidden="true"></span>
							<h:outputText value=" #{msgs.cdfm_hide_full_description}"/>
						</a>
					</p>
					<h:panelGroup id="fullTopicDescription" layout="block" styleClass="textPanel fullTopicDescription display-none">
						<h:outputText escape="false" value="#{ForumTool.selectedTopic.topic.extendedDescription}" />
					</h:panelGroup>
				</h:panelGroup>
			</div>

			<h:messages globalOnly="true" infoClass="sakai-banner sakai-banner--success" errorClass="sakai-banner sakai-banner--error" rendered="#{! empty facesContext.maximumSeverity}"/>

			<div id="permalinkHolder" class="sakai-banner sakai-banner--success sakai-forums__permalink display-none" role="status" hidden="hidden">
				<h:outputText value="#{msgs.cdfm_button_bar_permalink_message}"/>
			</div>

			<div class="sakai-forums__message">
				<h:outputText rendered="#{ForumTool.selectedMessage.message.deleted && !ForumTool.needToPostFirst}" value="#{msgs.cdfm_msg_deleted_label}" styleClass="instruction"/>
				<h:outputText value="#{msgs.cdfm_postFirst_warning}" rendered="#{ForumTool.needToPostFirst}" styleClass="messageAlert"/>
				<h:panelGroup rendered="#{!ForumTool.selectedMessage.message.deleted}" layout="block" styleClass="sakai-forums__message-header">
					<h:panelGroup styleClass="authorImage sakai-forums__message-avatar" rendered="#{ForumTool.showProfileInfo && !ForumTool.selectedMessage.useAnonymousId}">
						<sakai-user-photo profile-popup="on" user-id="<h:outputText value="#{ForumTool.selectedMessage.message.authorId}"/>" />
					</h:panelGroup>
					<div class="sakai-forums__message-identity">
						<h:outputText rendered="#{ForumTool.selectedMessage.msgDenied}" value="#{msgs.cdfm_msg_denied_label}" styleClass="messageDenied"/>
						<h:outputText rendered="#{ForumTool.allowedToApproveMsg && ForumTool.allowedToDenyMsg}" value="#{msgs.cdfm_msg_pending_label}" styleClass="messagePending"/>
						<h:outputText value="#{ForumTool.selectedMessage.message.title}" styleClass="sakai-forums__title title"/>
					</div>
					<div class="sakai-forums__message-meta">
						<h:outputText value="#{ForumTool.selectedMessage.anonAwareAuthor}" styleClass="#{ForumTool.selectedMessage.useAnonymousId ? 'anonymousAuthor' : ''}" rendered="#{!ForumTool.instructor || ForumTool.selectedMessage.useAnonymousId}"/>
						<h:outputText value=" #{msgs.cdfm_me}" rendered="#{ForumTool.selectedMessage.currentUserAndAnonymous}" />
						<h:commandLink action="#{mfStatisticsBean.processActionStatisticsUser}" immediate="true" title=" #{ForumTool.selectedMessage.anonAwareAuthor }" styleClass="#{ForumTool.selectedMessage.useAnonymousId ? 'anonymousAuthor' : ''}" rendered="#{ForumTool.instructor && !ForumTool.selectedMessage.useAnonymousId}">
							<f:param value="#{ForumTool.selectedMessage.authorEid}" name="siteUserId"/>
							<h:outputText value="#{ForumTool.selectedMessage.anonAwareAuthor}"/>
						</h:commandLink>
						<h:outputText value="#{ForumTool.selectedMessage.message.created}">
							<f:convertDateTime pattern="#{msgs.date_format}" timeZone="#{ForumTool.userTimeZone}" locale="#{ForumTool.userLocale}"/>
						</h:outputText>
						<span>
							<h:outputText value="#{msgs.cdfm_message_count}: " />
							<h:panelGroup id="counttotal"></h:panelGroup>
						</span>
					</div>
					<h:panelGroup rendered="#{ForumTool.selectedMessage.authorRank != null}" layout="block" styleClass="forumsRank sakai-forums__message-rank">
						<h:outputText escape="false" rendered="#{not empty ForumTool.selectedMessage.authorRank.rankImage.attachmentId}" value="<img src=\"#{ForumTool.selectedMessage.authorRank.rankImage.attachmentUrl}\" class=\"rankImage\" alt=\"\" height=\"35\" width=\"35\" />" />
						<h:panelGroup layout="block" styleClass="forumsRankNameContainer">
							<h:outputText value="#{ForumTool.selectedMessage.authorRank.title}" styleClass="forumsRankName"/>
							<h:outputText value="#{msgs.num_of_posts} #{ForumTool.selectedMessage.authorPostCount}" styleClass="forumsRankName" rendered="#{ForumTool.selectedMessage.authorRank.type == 2}"/>
						</h:panelGroup>
					</h:panelGroup>
				</h:panelGroup>

				<h:panelGroup layout="block" styleClass="sakai-forums__message-body textPanel">
					<h:outputText escape="false" value="#{ForumTool.selectedMessage.message.body}" id="messageBody"
							rendered="#{!ForumTool.selectedMessage.message.deleted}" />
				</h:panelGroup>
				<h:dataTable value="#{ForumTool.selectedMessage.attachList}" var="eachAttach" styleClass="sakai-table sakai-table--stack"
						rendered="#{!empty ForumTool.selectedMessage.attachList && !ForumTool.selectedMessage.message.deleted}">
					<h:column rendered="#{!empty ForumTool.selectedMessage.message.attachments}">
						<sakai:contentTypeMap fileType="#{eachAttach.attachment.attachmentType}" mapType="image" var="imagePath" pathPrefix="/library/image/"/>
						<h:graphicImage id="exampleFileIcon" value="#{imagePath}" alt=""/>
						<h:outputLink value="#{eachAttach.url}" target="_blank">
							<h:outputText value="#{eachAttach.attachment.attachmentName}"/>
						</h:outputLink>
					</h:column>
				</h:dataTable>
				<h:panelGroup layout="block" styleClass="sakai-forums__message-actions sakai-no-print"
						rendered="#{!ForumTool.deleteMsg && !ForumTool.selectedMessage.message.deleted}">
					<details class="sakai-overflow-menu">
						<summary class="sakai-btn sakai-btn-icon sakai-overflow-menu__toggle">
							<span class="si si-three-dots" aria-hidden="true"></span>
							<span class="visually-hidden"><h:outputText value="#{msgs.pvt_more_actions}"/></span>
						</summary>
						<div class="sakai-overflow-menu__panel">
							<h:commandLink action="#{ForumTool.processDfMsgDeleteConfirm}" rendered="#{ForumTool.selectedMessage.userCanDelete}">
								<h:outputText value="#{msgs.cdfm_button_bar_delete_msg}" />
							</h:commandLink>
							<h:commandLink action="#{ForumTool.processDfMsgRvs}" rendered="#{ForumTool.selectedMessage.revise}">
								<h:outputText value="#{msgs.cdfm_button_bar_revise}" />
							</h:commandLink>
							<h:commandLink action="#{ForumTool.processDfMsgGrd}"
									rendered="#{ForumTool.selectedTopic.isPostToGradebook && ForumTool.gradebookExist}">
								<h:outputText value="#{msgs.cdfm_button_bar_grade}" />
							</h:commandLink>
							<h:outputLink id="createEmail1" value="mailto:#{ForumTool.selectedMessage.authorEmail}"
									rendered="#{ForumTool.selectedMessage.userCanEmail && ForumTool.selectedMessage.authorEmail != '' && ForumTool.selectedMessage.authorEmail != null}">
								<f:param value="#{msgs.cdfm_feedback_on} #{ForumTool.selectedMessage.message.title}" name="subject" />
								<h:outputText value="#{msgs.cdfm_button_bar_email}"/>
							</h:outputLink>
							<h:outputLink id="permalink1" value="#{ForumTool.messageURL}" styleClass="permaLink">
								<h:outputText value="#{msgs.cdfm_button_bar_permalink}"/>
							</h:outputLink>
							<h:commandLink action="#{ForumTool.processDfMsgDeny}" rendered="#{ForumTool.allowedToDenyMsg}">
								<h:outputText value="#{msgs.cdfm_button_bar_deny}" />
							</h:commandLink>
							<h:commandLink action="#{ForumTool.processDfMsgAddComment}"
									rendered="#{ForumTool.allowedToApproveMsg && ForumTool.selectedMessage.msgDenied}">
								<h:outputText value="#{msgs.cdfm_button_bar_add_comment}" />
							</h:commandLink>
							<h:commandLink action="#{ForumTool.processDfMsgApprove}" rendered="#{ForumTool.allowedToApproveMsg}">
								<h:outputText value="#{msgs.cdfm_button_bar_approve}" />
							</h:commandLink>
						</div>
					</details>
				</h:panelGroup>
			</div>

			<h:panelGroup rendered="#{ForumTool.deleteMsg && ForumTool.errorSynch}">
				<h:outputText styleClass="sakai-banner sakai-banner--error" value="#{msgs.cdfm_msg_del_has_reply}" />
			</h:panelGroup>

			<h:inputHidden value="#{ForumTool.fromPage}" />

			<h:panelGroup layout="block" styleClass="sakai-actions" rendered="#{ForumTool.deleteMsg && ForumTool.selectedMessage.userCanDelete}">
				<h:commandButton id="post" action="#{ForumTool.processDfMsgDeleteConfirmYes}" value="#{msgs.cdfm_button_bar_delete}" accesskey="x" styleClass="sakai-btn sakai-btn-primary blockMeOnClick" />
				<h:outputText styleClass="sakai-banner sakai-banner--info" style="display:none" value="#{msgs.cdfm_processing_submit_message}" />
			</h:panelGroup>

			<h:panelGroup layout="block" styleClass="sakai-actions sakai-forums__pager sakai-no-print"
					rendered="#{!ForumTool.deleteMsg}">
				<h:commandLink styleClass="sakai-btn sakai-btn-secondary"
						action="#{ForumTool.processDisplayPreviousMsg}"
						rendered="#{ForumTool.selectedMessage != null && ForumTool.selectedMessage.hasPre}"
						title=" #{msgs.cdfm_prev_msg}">
					<h:outputText value="#{msgs.cdfm_prev_msg}" />
				</h:commandLink>
				<h:panelGroup styleClass="sakai-btn sakai-btn-secondary is-disabled"
						rendered="#{!ForumTool.selectedMessage.hasPre}">
					<h:outputText value="#{msgs.cdfm_prev_msg}" />
				</h:panelGroup>
				<h:commandLink styleClass="sakai-btn sakai-btn-secondary"
						action="#{ForumTool.processDfDisplayNextMsg}"
						rendered="#{ForumTool.selectedMessage != null && ForumTool.selectedMessage.hasNext}"
						title=" #{msgs.cdfm_next_msg}">
					<h:outputText value="#{msgs.cdfm_next_msg}" />
				</h:commandLink>
				<h:panelGroup styleClass="sakai-btn sakai-btn-secondary is-disabled"
						rendered="#{!ForumTool.selectedMessage.hasNext}">
					<h:outputText value="#{msgs.cdfm_next_msg}" />
				</h:panelGroup>
			</h:panelGroup>

			<h:panelGroup layout="block" styleClass="sakai-actions sakai-forums__pager sakai-no-print"
					rendered="#{!ForumTool.deleteMsg}">
				<h:panelGroup styleClass="sakai-btn sakai-btn-secondary is-disabled" rendered="#{!ForumTool.selectedThreadHead.hasPreThread}">
					<h:outputText value="#{msgs.cdfm_previous_thread}" />
				</h:panelGroup>
				<h:commandLink styleClass="sakai-btn sakai-btn-secondary" action="#{ForumTool.processActionDisplayThread}" value="#{msgs.cdfm_previous_thread}" rendered="#{ForumTool.selectedThreadHead.hasPreThread}">
					<f:param value="#{ForumTool.selectedThreadHead.preThreadId}" name="messageId"/>
					<f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId"/>
					<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
				</h:commandLink>
				<h:panelGroup styleClass="sakai-btn sakai-btn-secondary is-disabled" rendered="#{!ForumTool.selectedThreadHead.hasNextThread}">
					<h:outputText value="#{msgs.cdfm_next_thread}" />
				</h:panelGroup>
				<h:commandLink styleClass="sakai-btn sakai-btn-secondary" action="#{ForumTool.processActionDisplayThread}" value="#{msgs.cdfm_next_thread}" rendered="#{ForumTool.selectedThreadHead.hasNextThread}">
					<f:param value="#{ForumTool.selectedThreadHead.nextThreadId}" name="messageId"/>
					<f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId"/>
					<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
				</h:commandLink>
			</h:panelGroup>
		</h:form>
	</sakai:view>
</f:view>
