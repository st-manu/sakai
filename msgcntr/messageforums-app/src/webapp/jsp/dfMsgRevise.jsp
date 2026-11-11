<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>

<f:view>
	<sakai:view title="#{msgs.cdfm_revise_forum_msg}">
		<script>includeLatestJQuery("msgcntr");</script>
		<script src="/messageforums-tool/js/sak-10625.js"></script>
		<script src="/messageforums-tool/js/forum.js"></script>
		<script src="/messageforums-tool/js/messages.js"></script>

		<h:form id="dfCompose" styleClass="sakai-forums">
			<f:verbatim><input type="hidden" id="ckeditor-autosave-context" name="ckeditor-autosave-context" value="forums_dfMsgRevise" /></f:verbatim>
			<h:panelGroup rendered="#{ForumTool.selectedMessage.message.id!=null}"><f:verbatim><input type="hidden" id="ckeditor-autosave-entity-id" name="ckeditor-autosave-entity-id" value="</f:verbatim><h:outputText value="#{ForumTool.selectedMessage.message.id}"/><f:verbatim>"/></f:verbatim></h:panelGroup>
			<f:verbatim><input type="hidden" id="currentMessageId" name="currentMessageId" value="</f:verbatim><h:outputText value="#{ForumTool.selectedMessage.message.id}"/><f:verbatim>"/></f:verbatim>
			<f:verbatim><input type="hidden" id="currentTopicId" name="currentTopicId" value="</f:verbatim><h:outputText value="#{ForumTool.selectedTopic.topic.id}"/><f:verbatim>"/></f:verbatim>
			<f:verbatim><input type="hidden" id="currentForumId" name="currentForumId" value="</f:verbatim><h:outputText value="#{ForumTool.selectedForum.forum.id}"/><f:verbatim>"/></f:verbatim>

			<% request.setAttribute("dfHeaderView", "revise"); %>
			<% request.setAttribute("dfHeaderTitleKey", "cdfm_revise_forum_msg"); %>
			<% request.setAttribute("dfHeaderBack", "message"); %>
			<%@ include file="/jsp/discussionForum/menu/forumsHeader.jsp" %>

			<div class="sakai-forums__forum-header">
				<div class="sakai-forums__forum-identity">
					<span class="sakai-forums__meta">
						<h:outputText value="#{ForumTool.selectedForum.forum.title}"/>
						<h:outputText value=" / "/>
						<h:outputText value="#{ForumTool.selectedTopic.topic.title}"/>
					</span>
				</div>
				<h:outputText value="#{ForumTool.selectedTopic.topic.shortDescription}" styleClass="sakai-forums__description"
						rendered="#{!empty ForumTool.selectedTopic.topic.shortDescription}"/>
			</div>

			<p class="sakai-form-section__intro">
				<h:outputText value="#{msgs.cdfm_required}"/>
			</p>

			<h:messages styleClass="sakai-banner sakai-banner--error" id="errorMessages" rendered="#{! empty facesContext.maximumSeverity}"/>

			<div class="sakai-form-section">
				<div class="sakai-form-field">
					<h:outputLabel for="df_compose_title" styleClass="sakai-form-label required">
						<h:outputText value="#{msgs.cdfm_title}"/>
					</h:outputLabel>
					<h:inputText value="#{ForumTool.composeTitle}" required="true" id="df_compose_title"
							styleClass="sakai-form-control">
						<f:validator validatorId="MessageTitle"/>
						<f:validateLength minimum="1" maximum="255"/>
					</h:inputText>
				</div>
				<div class="sakai-form-field">
					<h:outputLabel for="df_compose_body" styleClass="sakai-form-label">
						<h:outputText value="#{msgs.cdfm_message}"/>
					</h:outputLabel>
					<sakai:inputRichText textareaOnly="#{PrivateMessagesTool.mobileSession}" value="#{ForumTool.composeBody}"
							id="df_compose_body" rows="#{ForumTool.editorRows}" cols="132">
					</sakai:inputRichText>
				</div>
			</div>

			<div class="sakai-form-section">
				<h:outputText value="#{msgs.cdfm_att}" styleClass="sakai-form-section__title"/>
				<h:panelGroup layout="block" styleClass="sakai-form-section__intro" rendered="#{empty ForumTool.attachments}">
					<h:outputText value="#{msgs.cdfm_no_attachments}"/>
				</h:panelGroup>
				<h:dataTable styleClass="sakai-table sakai-table--stack" id="attmsg" value="#{ForumTool.attachments}"
						var="eachAttach" rendered="#{!empty ForumTool.attachments}">
					<h:column>
						<f:facet name="header"><h:outputText value="#{msgs.cdfm_title}"/></f:facet>
						<sakai:contentTypeMap fileType="#{eachAttach.attachment.attachmentType}" mapType="image" var="imagePath" pathPrefix="/library/image/"/>
						<h:graphicImage id="exampleFileIcon" value="#{imagePath}" alt=""/>
						<h:outputText value="#{eachAttach.attachment.attachmentName}"/>
					</h:column>
					<h:column>
						<h:commandLink action="#{ForumTool.processDeleteAttachRevise}" immediate="true"
								onfocus="document.forms[0].onsubmit();" title="#{msgs.cdfm_remove}">
							<h:outputText value="#{msgs.cdfm_remove}"/>
							<f:param value="#{eachAttach.attachment.attachmentId}" name="dfmsg_current_attach"/>
						</h:commandLink>
					</h:column>
					<h:column>
						<f:facet name="header"><h:outputText value="#{msgs.cdfm_attsize}"/></f:facet>
						<h:outputText value="#{ForumTool.getAttachmentReadableSize(eachAttach.attachment.attachmentSize)}"/>
					</h:column>
					<h:column>
						<f:facet name="header"><h:outputText value="#{msgs.cdfm_atttype}"/></f:facet>
						<h:outputText value="#{eachAttach.attachment.attachmentType}"/>
					</h:column>
				</h:dataTable>
				<div class="sakai-actions">
					<h:commandButton rendered="#{empty ForumTool.attachments && empty facesContext.maximumSeverity}"
							action="#{ForumTool.processAddAttachmentRedirect}"
							value="#{msgs.cdfm_button_bar_add_attachment_redirect}" accesskey="a"
							styleClass="sakai-btn sakai-btn-secondary"/>
					<h:commandButton rendered="#{not empty ForumTool.attachments && empty facesContext.maximumSeverity}"
							action="#{ForumTool.processAddAttachmentRedirect}"
							value="#{msgs.cdfm_button_bar_add_attachment_more_redirect}" accesskey="a"
							styleClass="sakai-btn sakai-btn-secondary"/>
				</div>
			</div>

			<div class="sakai-actions">
				<h:commandButton action="#{ForumTool.processDfMsgRevisedPost}" value="#{msgs.cdfm_button_bar_post_revised_msg}"
						rendered="#{empty facesContext.maximumSeverity}" accesskey="s"
						styleClass="sakai-btn sakai-btn-primary blockMeOnClick"/>
				<h:commandButton action="#{ForumTool.processDfMsgRevisedCancel}" value="#{msgs.cdfm_button_bar_cancel}"
						accesskey="x" styleClass="sakai-btn sakai-btn-ghost"/>
				<h:outputText styleClass="sakai-banner sakai-banner--info" style="display:none"
						value="#{msgs.cdfm_processing_submit_message}"/>
			</div>
		</h:form>
	</sakai:view>
</f:view>
