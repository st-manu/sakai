<%-- Display single message in threaded/flat expanded view. --%>
<%
  	String thisId = request.getParameter("panel");
  	if (thisId == null)
  	{
    	thisId = "Main" + org.sakaiproject.tool.cover.ToolManager.getCurrentPlacement().getId();
 		 }
%>
<script>
	var iframeId = '<%= org.sakaiproject.util.Web.escapeJavascript(thisId)%>';

	function resize(){
		mySetMainFrameHeight('<%= org.sakaiproject.util.Web.escapeJavascript(thisId)%>');
	}

	function dialogLinkClick(link){
		dialogutil.openDialog('dialogDiv', 'dialogFrame');
	}
</script>

<h:outputText escape="false" value="<a id=\"#{message.message.id}\" name=\"#{message.message.id}\"></a>" />
<div class="sakai-forums__message" id="<h:outputText value="mi-#{message.message.id}ti-#{ForumTool.selectedTopic.topic.id}fi-#{ForumTool.selectedTopic.topic.baseForum.id}"/>">

	<h:panelGroup rendered="#{!message.deleted && ForumTool.showProfileInfo && !message.useAnonymousId}" styleClass="authorImage sakai-forums__message-avatar">
		<sakai-user-photo profile-popup="on" user-id="<h:outputText value="#{message.message.authorId}"/>" />
	</h:panelGroup>

	<h:panelGroup styleClass="sakai-forums__status" rendered="#{message.deleted}">
		<h:outputText value="#{msgs.cdfm_msg_deleted_label}" />
	</h:panelGroup>

	<h:panelGroup rendered="#{!message.deleted}" layout="block" styleClass="sakai-forums__message-header">
		<h:panelGroup layout="block" styleClass="sakai-forums__message-identity">
			<h:outputText styleClass="messageNew" value="#{msgs.cdfm_newflag}" rendered="#{!message.read}"/>
			<h:outputText value="#{msgs.cdfm_msg_pending_label}" rendered="#{message.msgPending}" styleClass="messagePending"/>
			<h:outputText value="#{msgs.cdfm_msg_denied_label}" rendered="#{message.msgDenied}" styleClass="messageDenied" />
			<h:commandLink action="#{ForumTool.processActionDisplayMessage}" immediate="true" title=" #{message.message.title}" styleClass="sakai-forums__title title">
				<h:outputText value="#{message.message.title}" rendered="#{message.read}" />
				<h:outputText styleClass="unreadMsg" value="#{message.message.title}" rendered="#{!message.read}" />
				<f:param value="#{message.message.id}" name="messageId" />
				<f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId" />
				<f:param value="#{ForumTool.selectedTopic.topic.baseForum.id}" name="forumId" />
			</h:commandLink>
		</h:panelGroup>

		<div class="messageMetadata sakai-forums__message-meta">
			<h:outputText value="#{message.anonAwareAuthor}" rendered="#{!ForumTool.instructor || message.useAnonymousId}" styleClass="#{message.read ? '' : 'unreadMsg'} #{message.useAnonymousId ? 'anonymousAuthor' : ''}"/>
			<h:commandLink action="#{mfStatisticsBean.processActionStatisticsUser}" immediate="true" title=" #{message.anonAwareAuthor }" rendered="#{ForumTool.instructor && !message.useAnonymousId}" styleClass="#{message.read ? '' : 'unreadMsg'} #{message.useAnonymousId ? 'anonymousAuthor' : ''}">
				<f:param value="#{message.authorEid}" name="siteUserId"/>
				<h:outputText value="#{message.anonAwareAuthor}"/>
			</h:commandLink>
			<h:outputText value=" #{msgs.cdfm_me}" rendered="#{message.currentUserAndAnonymous}" styleClass="#{message.read ? '' : 'unreadMsg'}" />
			<h:outputText value="#{message.message.created}" rendered="#{message.read}">
				<f:convertDateTime pattern="#{msgs.date_format_paren}" timeZone="#{ForumTool.userTimeZone}" locale="#{ForumTool.userLocale}"/>
			</h:outputText>
			<h:outputText value="#{message.message.created}" rendered="#{!message.read}" styleClass="unreadMsg">
				<f:convertDateTime pattern="#{msgs.date_format_paren}" timeZone="#{ForumTool.userTimeZone}" locale="#{ForumTool.userLocale}"/>
			</h:outputText>
			<h:outputText value="#{msgs.cdfm_readby}" />
			<h:outputText styleClass="messageNewNumReaders" value="#{message.message.numReaders}" />
		</div>

		<h:panelGroup rendered="#{message.authorRank != null}" layout="block" styleClass="forumsRank sakai-forums__message-rank">
			<h:outputText escape="false" rendered="#{not empty message.authorRank.rankImage.attachmentId}" value="<img src=\"#{message.authorRank.rankImage.attachmentUrl}\" class=\"rankImage\" alt=\"\" height=\"35\" width=\"35\" />" />
			<h:panelGroup layout="block" styleClass="forumsRankNameContainer">
				<h:outputText value="#{message.authorRank.title}" styleClass="forumsRankName"/>
				<h:outputText value="#{msgs.num_of_posts} #{message.authorPostCount}" styleClass="forumsRankName" rendered="#{message.authorRank.type == 2}"/>
			</h:panelGroup>
		</h:panelGroup>
	</h:panelGroup>

	<h:panelGroup rendered="#{!message.deleted}" layout="block" styleClass="sakai-forums__message-body textPanel">
		<mf:htmlShowArea value="#{message.message.body}" hideBorder="true" />
		<h:dataTable value="#{message.attachList}" var="eachAttach" styleClass="sakai-table sakai-table--stack attachListJSF" rendered="#{!empty message.attachList}">
			<h:column rendered="#{!empty message.message.attachments}">
				<sakai:contentTypeMap fileType="#{eachAttach.attachment.attachmentType}" mapType="image" var="imagePath" pathPrefix="/library/image/"/>
				<h:graphicImage id="exampleFileIcon" value="#{imagePath}" alt=""/>
				<h:outputLink value="#{eachAttach.url}" target="_blank">
					<h:outputText value="#{eachAttach.attachment.attachmentName}" />
				</h:outputLink>
			</h:column>
		</h:dataTable>
	</h:panelGroup>

	<h:panelGroup rendered="#{!message.deleted}" layout="block" styleClass="sakai-forums__message-actions sakai-no-print">
		<h:commandLink action="#{ForumTool.processDfMsgReplyMsgFromEntire}" title="#{msgs.cdfm_reply}" styleClass="sakai-btn sakai-btn-primary"
				rendered="#{ForumTool.selectedTopic.isNewResponseToResponse && message.msgApproved && !ForumTool.selectedTopic.locked && !ForumTool.selectedForum.locked == 'true'}">
			<span class="si si-reply-fill" aria-hidden="true"></span>
			<h:outputText value=" #{msgs.cdfm_reply}" />
			<f:param value="#{message.message.id}" name="messageId" />
			<f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId" />
			<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId" />
		</h:commandLink>
		<details class="sakai-overflow-menu">
			<summary class="sakai-btn sakai-btn-icon sakai-overflow-menu__toggle">
				<span class="si si-three-dots" aria-hidden="true"></span>
				<h:outputText value="#{msgs.pvt_more_actions}" styleClass="visually-hidden"/>
			</summary>
			<div class="sakai-overflow-menu__panel">
				<h:outputLink value="javascript:void(0);"
						title="#{msgs.cdfm_mark_as_not_read}"
						rendered="#{message.read and ForumTool.selectedTopic.isMarkAsNotRead and not ForumTool.selectedTopic.topic.autoMarkThreadsRead}"
						styleClass="markAsNotReadIcon"
						onclick="doAjax(#{message.message.id}, #{ForumTool.selectedTopic.topic.id}, this); return false;">
					<h:outputText value="#{msgs.cdfm_mark_as_not_read}"/>
				</h:outputLink>
				<h:outputLink id="createEmail1" value="mailto:#{message.authorEmail}" rendered="#{message.userCanEmail}">
					<f:param value="#{msgs.cdfm_feedback_on} #{message.message.title}" name="subject" />
					<h:outputText value="#{msgs.cdfm_button_bar_email}"/>
				</h:outputLink>
				<h:outputLink value="/tool/#{ForumTool.currentToolId}/discussionForum/message/dfMsgGrade" target="dialogFrame"
						rendered="#{ForumTool.selectedTopic.isPostToGradebook && ForumTool.gradebookExist}"
						onclick="dialogLinkClick(this);">
					<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
					<f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId"/>
					<f:param value="#{message.message.id}" name="messageId"/>
					<f:param value="dialogDiv" name="dialogDivId"/>
					<f:param value="dialogFrame" name="frameId"/>
					<f:param value="gradesSavedDiv" name="gradesSavedDiv"/>
					<f:param value="#{message.message.createdBy}" name="userId"/>
					<h:outputText value="#{msgs.cdfm_button_bar_grade}" />
				</h:outputLink>
				<h:commandLink action="#{ForumTool.processDfMsgRvsFromThread}" value="#{msgs.cdfm_button_bar_revise}" rendered="#{message.revise}">
					<f:param value="#{message.message.id}" name="messageId" />
					<f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId" />
					<f:param value="#{ForumTool.selectedTopic.topic.baseForum.id}" name="forumId" />
				</h:commandLink>
				<h:commandLink action="#{ForumTool.processDfMsgDeleteConfirm}" value="#{msgs.cdfm_button_bar_delete_message}" rendered="#{message.userCanDelete}">
					<f:param value="#{message.message.id}" name="messageId" />
					<f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId" />
					<f:param value="#{ForumTool.selectedTopic.topic.baseForum.id}" name="forumId" />
					<f:param value="dfViewThread" name="fromPage" />
				</h:commandLink>
				<h:commandLink action="#{ForumTool.processActionDisplayMessage}" immediate="true" title=" #{msgs.cdfm_moderate}" value="#{msgs.cdfm_moderate}"
						rendered="#{ForumTool.selectedTopic.isModeratedAndHasPerm}">
					<f:param value="#{message.message.id}" name="messageId" />
					<f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId" />
					<f:param value="#{ForumTool.selectedTopic.topic.baseForum.id}" name="forumId" />
				</h:commandLink>
			</div>
		</details>
	</h:panelGroup>
</div>
