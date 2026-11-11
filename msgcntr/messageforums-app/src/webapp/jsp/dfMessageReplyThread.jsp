<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>
<f:view>
	<sakai:view title="#{msgs.cdfm_reply_tool_bar_message}">
		<script>includeLatestJQuery("msgcntr");</script>
		<script src="/messageforums-tool/js/sak-10625.js"></script>
		<script src="/messageforums-tool/js/forum.js"></script>
		<script src="/messageforums-tool/js/messages.js"></script>
		<script>
			$(document).ready(function () {
				$('#openLinkBlock').hide();
				jQuery('.toggle').click(function(e) {
					$('#replytomessage').toggle('slow');
					$('.toggleParent').toggle();
					resizeFrame('grow');
				});
			});
		</script>

		<h:form id="dfCompose" styleClass="sakai-forums">
			<f:verbatim><input type="hidden" id="currentMessageId" name="currentMessageId" value="</f:verbatim><h:outputText value="#{ForumTool.selectedMessage.message.id}"/><f:verbatim>"/></f:verbatim>
			<f:verbatim><input type="hidden" id="currentTopicId" name="currentTopicId" value="</f:verbatim><h:outputText value="#{ForumTool.selectedTopic.topic.id}"/><f:verbatim>"/></f:verbatim>
			<f:verbatim><input type="hidden" id="currentForumId" name="currentForumId" value="</f:verbatim><h:outputText value="#{ForumTool.selectedForum.forum.id}"/><f:verbatim>"/></f:verbatim>
			<f:verbatim><input type="hidden" id="ckeditor-autosave-context" name="ckeditor-autosave-context" value="forums_dfMessageReplyThread" /></f:verbatim>
			<h:panelGroup rendered="#{ForumTool.selectedMessage.message.id!=null}"><f:verbatim><input type="hidden" id="ckeditor-autosave-entity-id" name="ckeditor-autosave-entity-id" value="</f:verbatim><h:outputText value="#{ForumTool.selectedMessage.message.id}"/><f:verbatim>"/></f:verbatim></h:panelGroup>

			<% request.setAttribute("dfHeaderView", "replyThread"); %>
			<% request.setAttribute("dfHeaderTitleKey", "cdfm_reply_thread_tool_bar_message"); %>
			<% request.setAttribute("dfHeaderBack", "thread"); %>
			<%@ include file="/jsp/discussionForum/menu/forumsHeader.jsp" %>

			<h:outputText styleClass="sakai-banner sakai-banner--error" value="#{msgs.cdfm_reply_deleted}" rendered="#{ForumTool.errorSynch}"/>

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

			<div class="sakai-banner sakai-banner--info">
				<div class="sakai-forums__forum-identity">
					<span class="sakai-forums__meta">
						<h:outputText value="#{msgs.cdfm_reply_message_pref}"/>
						<h:outputText value=" #{ForumTool.selectedMessage.message.title}"/>
					</span>
					<span class="sakai-forums__description">
						<h:outputText value="#{ForumTool.selectedMessage.anonAwareAuthor}" styleClass="#{ForumTool.selectedMessage.useAnonymousId ? 'anonymousAuthor' : ''}"/>
						<h:outputText value=" #{msgs.cdfm_me}" rendered="#{ForumTool.selectedMessage.currentUserAndAnonymous}"/>
						<h:outputText value=" #{msgs.cdfm_openb}"/>
						<h:outputText value="#{ForumTool.selectedMessage.message.created}">
							<f:convertDateTime pattern="#{msgs.date_format}" timeZone="#{ForumTool.userTimeZone}" locale="#{ForumTool.userLocale}"/>
						</h:outputText>
						<h:outputText value=" #{msgs.cdfm_closeb}"/>
					</span>
				</div>
				<p id="openLinkBlock" class="toggleParent">
					<a href="#" id="showMessage" class="toggle show">
						<span class="si si-chevron-down" aria-hidden="true"></span>
						<h:outputText value=" #{msgs.cdfm_read_full_rep_tomessage}"/>
					</a>
				</p>
				<p id="hideLinkBlock" class="toggleParent">
					<a href="#" id="hideMessage" class="toggle show">
						<span class="si si-chevron-up" aria-hidden="true"></span>
						<h:outputText value=" #{msgs.cdfm_hide_full_rep_tomessage}"/>
					</a>
				</p>
				<div id="replytomessage">
					<mf:htmlShowArea value="#{ForumTool.selectedMessage.message.body}" hideBorder="true"/>
					<h:dataTable value="#{ForumTool.selectedMessage.message.attachments}" var="eachAttach"
							rendered="#{!empty ForumTool.selectedMessage.message.attachments}"
							styleClass="sakai-table sakai-table--stack">
						<h:column rendered="#{!empty ForumTool.selectedMessage.message.attachments}">
							<sakai:contentTypeMap fileType="#{eachAttach.attachmentType}" mapType="image" var="imagePath" pathPrefix="/library/image/"/>
							<h:graphicImage id="exampleFileIcon" value="#{imagePath}" alt=""/>
							<h:outputText value="#{eachAttach.attachmentName}"/>
						</h:column>
					</h:dataTable>
				</div>
			</div>

			<h:panelGroup layout="block" styleClass="sakai-banner sakai-banner--info"
					rendered="#{ForumTool.anonymousEnabled && ForumTool.selectedTopic.topic.postAnonymous}">
				<h:outputText value="#{ForumTool.selectedTopic.topic.revealIDsToRoles ? msgs.cdfm_revealIDsToRoles_blurb : msgs.cdfm_anonymous_blurb}"/>
			</h:panelGroup>

			<p class="sakai-form-section__intro">
				<h:outputText value="#{msgs.cdfm_required}"/>
			</p>

			<div class="sakai-form-section">
				<div class="sakai-form-field">
					<h:messages globalOnly="true" infoClass="sakai-banner sakai-banner--success" errorClass="sakai-banner sakai-banner--error"
							rendered="#{! empty facesContext.maximumSeverity}"/>
					<h:outputLabel for="df_compose_title" styleClass="sakai-form-label required">
						<h:outputText value="#{msgs.cdfm_reply_title}"/>
					</h:outputLabel>
					<h:message for="df_compose_title" styleClass="sakai-form-error" id="errorMessages"/>
					<h:inputText value="#{ForumTool.composeTitle}" maxlength="250" required="true" id="df_compose_title"
							styleClass="sakai-form-control" requiredMessage="#{msgs.cdfm_empty_title_error}">
						<f:validateLength minimum="1" maximum="255"/>
					</h:inputText>
				</div>
				<div class="sakai-form-field">
					<h:outputLabel for="df_compose_body" styleClass="sakai-form-label">
						<h:outputText value="#{msgs.cdfm_message}"/>
					</h:outputLabel>
					<h:message for="df_compose_body" styleClass="sakai-form-error" id="bodyErrorMessage"/>
					<h:inputHidden id="msgHidden" value="#{ForumTool.selectedMessage.message.body}"/>
					<h:inputHidden id="titleHidden" value="#{ForumTool.selectedMessage.message.title}"/>
					<p>
						<span class="si si-clipboard" aria-hidden="true"></span>
						<a href="javascript:void(0)" onclick="InsertHTML('<b><i><h:outputText value="#{msgs.cdfm_insert_original_text_comment}"/></i></b><br/><b><i><h:outputText value="#{msgs.cdfm_from}" /></i></b> <i><h:outputText value="#{ForumTool.selectedTopic.topic.postAnonymous ? ForumTool.selectedMessage.anonId : ForumTool.selectedMessage.message.authorEscaped}" /><h:outputText value=" #{msgs.cdfm_openb}" /><h:outputText value="#{ForumTool.selectedMessage.message.created}" ><f:convertDateTime pattern="#{msgs.date_format_static}" locale="#{ForumTool.userLocale}" timeZone="#{ForumTool.userTimeZone}"/></h:outputText><h:outputText value="#{msgs.cdfm_closeb}" /></i><br/><b><i><h:outputText value="#{msgs.cdfm_subject}" /></i></b>');">
							<h:outputText value="#{msgs.cdfm_message_insert}"/>
						</a>
					</p>
					<sakai:inputRichText textareaOnly="#{PrivateMessagesTool.mobileSession}" value="#{ForumTool.composeBody}"
							id="df_compose_body" rows="#{ForumTool.editorRows}" cols="132">
					</sakai:inputRichText>
					<script>
					const textarea = document.currentScript.previousElementSibling?.querySelector('textarea');
					const rteId = textarea ? textarea.id : "dfCompose:df_compose_body_inputRichText";
					var messagetext = document.forms['dfCompose'].elements['dfCompose:msgHidden'].value;
					var titletext = document.forms['dfCompose'].elements['dfCompose:titleHidden'].value;
					</script>
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
						<h:graphicImage id="exampleFileIcon" value="#{imagePath}" alt=""/>
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
						<f:facet name="header"><h:outputText value="#{msgs.cdfm_attsize}"/></f:facet>
						<h:outputText value="#{ForumTool.getAttachmentReadableSize(eachAttach.attachment.attachmentSize)}"/>
					</h:column>
					<h:column rendered="#{!empty ForumTool.attachments}">
						<f:facet name="header"><h:outputText value="#{msgs.cdfm_atttype}"/></f:facet>
						<h:outputText value="#{eachAttach.attachment.attachmentType}"/>
					</h:column>
				</h:dataTable>
				<div class="sakai-actions">
					<h:commandButton action="#{ForumTool.processAddAttachmentRedirect}"
							value="#{msgs.cdfm_button_bar_add_attachment_redirect}" accesskey="a"
							styleClass="sakai-btn sakai-btn-secondary" rendered="#{empty ForumTool.attachments}"/>
					<h:commandButton action="#{ForumTool.processAddAttachmentRedirect}"
							value="#{msgs.cdfm_button_bar_add_attachment_more_redirect}" accesskey="a"
							styleClass="sakai-btn sakai-btn-secondary" rendered="#{!empty ForumTool.attachments}"/>
				</div>
			</div>

			<h:panelGroup layout="block" styleClass="sakai-banner sakai-banner--info"
					rendered="#{ForumTool.selectedTopic.moderated == 'true'}">
				<h:outputText value="#{msgs.cdfm_reply_message_note}"/>
				<h:outputText value="#{msgs.cdfm_reply_message_mod_inst}"/>
			</h:panelGroup>

			<div class="sakai-actions">
				<h:commandButton id="post" action="#{ForumTool.processDfReplyMsgPost}" value="#{msgs.cdfm_button_bar_post_message}"
						accesskey="s" styleClass="sakai-btn sakai-btn-primary blockMeOnClick"/>
				<h:commandButton action="#{ForumTool.processDfReplyThreadCancel}" value="#{msgs.cdfm_button_bar_cancel}"
						accesskey="x" styleClass="sakai-btn sakai-btn-ghost"/>
				<h:outputText styleClass="sakai-banner sakai-banner--info" style="display:none"
						value="#{msgs.cdfm_processing_submit_message}"/>
			</div>

			<script>
			setTimeout(function(){
				var _div = document.getElementsByTagName('div');
				for (i = 0; i < _div.length; i++) {
					if (_div[i].className == 'htmlarea') {
						var children = _div[i].childNodes;
						for (j = 0; j < children.length; j++) {
							if (children.item(j).tagName == 'IFRAME') {
								children.item(j).contentWindow.focus();
							}
						}
					}
				}
			}, 800);
			</script>
		</h:form>
	</sakai:view>
</f:view>
