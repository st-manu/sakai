<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
	<jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>

<f:view>
	<sakai:view title="#{msgs.cdfm_container_title}">
		<script>includeLatestJQuery("msgcntr");</script>
		<script src="/messageforums-tool/js/sak-10625.js"></script>
		<script src="/messageforums-tool/js/forum.js"></script>

		<h:form id="dfCompose" styleClass="sakai-forums">
			<f:verbatim><input type="hidden" id="currentMessageId" name="currentMessageId" value="</f:verbatim><h:outputText value="#{ForumTool.selectedMessage.message.id}"/><f:verbatim>"/></f:verbatim>
			<f:verbatim><input type="hidden" id="currentTopicId" name="currentTopicId" value="</f:verbatim><h:outputText value="#{ForumTool.selectedTopic.topic.id}"/><f:verbatim>"/></f:verbatim>
			<f:verbatim><input type="hidden" id="currentForumId" name="currentForumId" value="</f:verbatim><h:outputText value="#{ForumTool.selectedForum.forum.id}"/><f:verbatim>"/></f:verbatim>

			<% request.setAttribute("dfHeaderView", "compose"); %>
			<% request.setAttribute("dfHeaderTitleKey", "cdfm_tool_bar_message"); %>
			<% request.setAttribute("dfHeaderBack", "topic"); %>
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

			<div class="sakai-form-section">
				<div class="sakai-form-field">
					<h:outputLabel for="df_compose_title" styleClass="sakai-form-label required">
						<h:outputText value="#{msgs.cdfm_title}"/>
					</h:outputLabel>
					<h:message for="df_compose_title" warnStyle="WARN" styleClass="sakai-form-error"/>
					<h:inputText value="#{ForumTool.composeTitle}" styleClass="sakai-form-control" maxlength="250" required="true" id="df_compose_title">
						<f:validator validatorId="MessageTitle" />
						<f:validateLength minimum="1" maximum="255"/>
					</h:inputText>
				</div>
				<div class="sakai-form-field">
					<h:outputLabel for="df_compose_body" styleClass="sakai-form-label">
						<h:outputText value="#{msgs.cdfm_message}" />
					</h:outputLabel>
					<h:message for="df_compose_body" styleClass="sakai-form-error" id="bodyErrorMessages" />
					<sakai:inputRichText value="#{ForumTool.composeBody}" id="df_compose_body" rows="22" cols="132">
					</sakai:inputRichText>
				</div>
			</div>

			<div class="sakai-form-section">
				<h:outputText value="#{msgs.cdfm_att}" styleClass="sakai-form-section__title"/>
				<h:panelGroup layout="block" styleClass="sakai-form-section__intro" rendered="#{empty ForumTool.attachments}">
					<h:outputText value="#{msgs.cdfm_no_attachments}"/>
				</h:panelGroup>
				<h:dataTable styleClass="sakai-table sakai-table--stack" id="attmsg" value="#{ForumTool.attachments}"
						rendered="#{!empty ForumTool.attachments}" var="eachAttach">
					<h:column rendered="#{!empty ForumTool.attachments}">
						<f:facet name="header"><h:outputText value="#{msgs.cdfm_title}"/></f:facet>
						<sakai:contentTypeMap fileType="#{eachAttach.attachment.attachmentType}" mapType="image" var="imagePath" pathPrefix="/library/image/"/>
						<h:graphicImage id="exampleFileIcon" value="#{imagePath}" alt="" />
						<h:outputText value="#{eachAttach.attachment.attachmentName}"/>
					</h:column>
					<h:column>
						<h:commandLink action="#{ForumTool.processDeleteAttach}" immediate="true"
								onfocus="document.forms[0].onsubmit();" title="#{msgs.cdfm_remove}">
							<h:outputText value="#{msgs.cdfm_remove}"/>
							<f:param value="#{eachAttach.attachment.attachmentId}" name="dfmsg_current_attach"/>
						</h:commandLink>
					</h:column>
					<h:column rendered="#{!empty ForumTool.attachments}">
						<f:facet name="header"><h:outputText value="#{msgs.cdfm_attsize}" /></f:facet>
						<h:outputText value="#{ForumTool.getAttachmentReadableSize(eachAttach.attachment.attachmentSize)}"/>
					</h:column>
					<h:column rendered="#{!empty ForumTool.attachments}">
						<f:facet name="header"><h:outputText value="#{msgs.cdfm_atttype}" /></f:facet>
						<h:outputText value="#{eachAttach.attachment.attachmentType}"/>
					</h:column>
				</h:dataTable>
				<div class="sakai-actions">
					<h:commandButton action="#{ForumTool.processAddAttachmentRedirect}" value="#{msgs.cdfm_button_bar_add_attachment_redirect}"
							immediate="true" accesskey="a" styleClass="sakai-btn sakai-btn-secondary" rendered="#{empty ForumTool.attachments}"/>
					<h:commandButton action="#{ForumTool.processAddAttachmentRedirect}" value="#{msgs.cdfm_button_bar_add_attachment_more_redirect}"
							immediate="true" accesskey="a" styleClass="sakai-btn sakai-btn-secondary" rendered="#{!empty ForumTool.attachments}"/>
				</div>
			</div>

			<div class="sakai-actions">
				<h:commandButton action="#{ForumTool.processDfMsgPost}" value="#{msgs.cdfm_button_bar_post_message}" accesskey="s" styleClass="sakai-btn sakai-btn-primary"/>
				<h:commandButton action="#{ForumTool.processDfMsgCancel}" value="#{msgs.cdfm_button_bar_cancel}" immediate="true" accesskey="x" styleClass="sakai-btn sakai-btn-ghost" />
			</div>
		</h:form>
	</sakai:view>
</f:view>
