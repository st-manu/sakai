<%@ page import="java.util.*, jakarta.faces.context.*, jakarta.faces.application.*,
                 jakarta.faces.el.*, org.sakaiproject.tool.messageforums.*"%>
<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>
<%
String thisId = request.getParameter("panel");
if (thisId == null)
{
	thisId = "Main" + org.sakaiproject.tool.cover.ToolManager.getCurrentPlacement().getId();
}
%>
<f:view>
	<sakai:view>
		<script>includeLatestJQuery("msgcntr");</script>
		<script src="/messageforums-tool/js/forum.js"></script>
		<script src="/messageforums-tool/js/sak-10625.js"></script>
		<script src="/messageforums-tool/js/messages.js"></script>
		<script>
			$(document).ready(function(){
				$('a#hide').hide();
				$('#toggle').hide();
				$('a#show,a#hide').click(function(){
					$('#toggle,a#hide,a#show').toggle();
					resizeFrame('grow');
					return false;
				});
			});
		</script>
		<h:form id="revise" styleClass="sakai-forums">
			<% request.setAttribute("dfHeaderView", "forumSettings"); %>
			<% request.setAttribute("dfHeaderBack", "forum"); %>
			<%@ include file="/jsp/discussionForum/menu/forumsHeader.jsp" %>

			<h:outputText id="alert-delete" styleClass="sakai-banner sakai-banner--warning" value="#{msgs.cdfm_delete_forum}"
					rendered="#{ForumTool.selectedForum.markForDeletion}"/>
			<h:outputText styleClass="sakai-banner sakai-banner--warning" value="#{msgs.cdfm_duplicate_forum_confirm}"
					rendered="#{ForumTool.selectedForum.markForDuplication}"/>
			<h:messages styleClass="sakai-banner sakai-banner--error" id="errorMessages" rendered="#{! empty facesContext.maximumSeverity}"/>

			<div class="sakai-forums__forum-header">
				<div class="sakai-forums__forum-identity">
					<h:panelGroup styleClass="sakai-forums__status" rendered="#{ForumTool.selectedForum.locked=='true'}">
						<span class="si si-locked" aria-hidden="true"></span>
						<span class="visually-hidden"><h:outputText value="#{msgs.cdfm_forum_locked}"/></span>
					</h:panelGroup>
					<h:outputText value="#{ForumTool.selectedForum.forum.title}" styleClass="sakai-forums__title"
							rendered="#{!ForumTool.selectedForum.markForDuplication}"/>
					<h:panelGroup layout="block" styleClass="sakai-form-field" rendered="#{ForumTool.selectedForum.markForDuplication}">
						<h:outputLabel for="forum_title" styleClass="sakai-form-label required">
							<h:outputText value="#{msgs.cdfm_forum_title}"/>
						</h:outputLabel>
						<h:inputText size="50" value="#{ForumTool.selectedForum.forum.title}" id="forum_title" styleClass="sakai-form-control">
							<f:validateLength minimum="1" maximum="255"/>
						</h:inputText>
					</h:panelGroup>
					<h:outputText value="#{msgs.cdfm_moderated}" styleClass="sakai-forums__meta"
							rendered="#{ForumTool.selectedForum.moderated=='true'}"/>
					<h:outputText value="#{msgs.cdfm_notmoderated}" styleClass="sakai-forums__meta"
							rendered="#{ForumTool.selectedForum.moderated=='false'}"/>
				</div>
				<h:outputText id="forum_shortDescription" styleClass="sakai-forums__description"
						value="#{ForumTool.selectedForum.forum.shortDescription}"
						rendered="#{!empty ForumTool.selectedForum.forum.shortDescription}"/>

				<h:panelGroup>
					<h:panelGroup layout="block" id="openLinkBlock" styleClass="toggleParent openLinkBlock">
						<a href="#" id="showMessage" class="toggle show">
							<span class="si si-chevron-down" aria-hidden="true"></span>
							<h:outputText value=" #{msgs.cdfm_read_full_description}"/>
						</a>
					</h:panelGroup>
					<h:panelGroup layout="block" id="hideLinkBlock" styleClass="toggleParent hideLinkBlock display-none">
						<a href="#" id="hideMessage" class="toggle show">
							<span class="si si-chevron-up" aria-hidden="true"></span>
							<h:outputText value=" #{msgs.cdfm_hide_full_description}"/>
						</a>
					</h:panelGroup>
				</h:panelGroup>

				<h:panelGroup layout="block" id="fullTopicDescription" styleClass="textPanel fullTopicDescription display-none">
					<h:outputText escape="false" value="#{ForumTool.selectedForum.forum.extendedDescription}"/>
					<h:dataTable value="#{ForumTool.selectedForum.attachList}" var="eachAttach"
							rendered="#{!empty ForumTool.selectedForum.attachList}"
							styleClass="sakai-table sakai-table--stack">
						<h:column>
							<sakai:contentTypeMap fileType="#{eachAttach.attachment.attachmentType}" mapType="image" var="imagePath" pathPrefix="/library/image/"/>
							<h:graphicImage id="exampleFileIcon" value="#{imagePath}" alt=""/>
							<h:outputLink value="#{eachAttach.url}" target="_blank">
								<h:outputText value="#{eachAttach.attachment.attachmentName}"/>
							</h:outputLink>
						</h:column>
					</h:dataTable>
				</h:panelGroup>
			</div>

			<div class="sakai-actions">
				<h:commandButton id="revise" rendered="#{!ForumTool.selectedForum.markForDeletion && !ForumTool.selectedForum.markForDuplication}"
						immediate="true" action="#{ForumTool.processActionReviseForumSettings}"
						value="#{msgs.cdfm_button_bar_revise}" accesskey="r"
						styleClass="sakai-btn sakai-btn-primary">
					<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
				</h:commandButton>
				<h:commandButton id="delete_confirm" action="#{ForumTool.processActionDeleteForumConfirm}"
						value="#{msgs.cdfm_button_bar_delete_forum}"
						rendered="#{!ForumTool.selectedForum.markForDeletion && !ForumTool.selectedForum.markForDuplication}"
						styleClass="sakai-btn sakai-btn-ghost blockMeOnClick">
					<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
				</h:commandButton>
				<h:commandButton id="delete" action="#{ForumTool.processActionDeleteForum}"
						value="#{msgs.cdfm_button_bar_delete_forum}" rendered="#{ForumTool.selectedForum.markForDeletion}"
						styleClass="sakai-btn sakai-btn-primary blockMeOnClick">
					<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
				</h:commandButton>
				<h:commandButton id="duplicate" action="#{ForumTool.processActionDuplicateForum}"
						value="#{msgs.cdfm_duplicate_forum}" rendered="#{ForumTool.selectedForum.markForDuplication}"
						accesskey="s" styleClass="sakai-btn sakai-btn-primary blockMeOnClick">
					<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
				</h:commandButton>
				<h:commandButton id="cancel" immediate="true" action="#{ForumTool.processReturnToOriginatingPage}"
						value="#{msgs.cdfm_button_bar_cancel}" accesskey="x"
						styleClass="sakai-btn sakai-btn-ghost"/>
				<h:outputText styleClass="sakai-banner sakai-banner--info" style="display:none"
						value="#{msgs.cdfm_processing_submit_message}"/>
			</div>
		</h:form>
	</sakai:view>
</f:view>
