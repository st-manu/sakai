<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>

<f:view>
<sakai:view>

	<h:form id="msgForum" styleClass="sakai-forums">

	<!--jsp/discussionForum/message/dfFlatView.jsp-->
		<script>includeLatestJQuery("msgcntr");</script>
		<script src="/messageforums-tool/js/sak-10625.js"></script>
		<script src="/messageforums-tool/js/forum.js"></script>
		<script src="/messageforums-tool/js/threadScrollEvent.js"></script>
		<script src="/messageforums-tool/js/dialog.js"></script>
		<script type="module" src="/webcomponents/bundles/rubric-association-requirements.js<h:outputText value="#{ForumTool.CDNQuery}" />"></script>
        <script>
            $(document).ready(function(){
                setupMessageNav('messageNew');
                setupMessageNav('messagePending');
            });
			var markAsNotReadText = "<h:outputText value="#{msgs.cdfm_mark_as_not_read}"/>";
			var showThreadChanges = "<h:outputText value="#{ForumTool.showThreadChanges}"/>";
			var statRead = "<h:outputText value="#{msgs.stat_forum_read}"/>";
			var newFlag = "<h:outputText value="#{msgs.cdfm_newflag}"/>";
			var isMarkAsNotReadValue = "<h:outputText value="#{ForumTool.selectedTopic.isMarkAsNotRead}"/>";
        </script>
		<% request.setAttribute("dfHeaderView", "flat"); %>
		<% request.setAttribute("dfHeaderBack", "forum"); %>
		<%@ include file="/jsp/discussionForum/menu/forumsHeader.jsp" %>

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

		<div class="sakai-segmented-control">
			<h:commandLink immediate="true" action="#{ForumTool.processActionDisplayThreadedView}" styleClass="sakai-segmented-control__btn">
				<h:outputText value="#{msgs.msg_view_threaded}"/>
			</h:commandLink>
			<span class="sakai-segmented-control__btn is-active" aria-current="page"><h:outputText value="#{msgs.cdfm_flat_view_label}"/></span>
		</div>

		<div class="sakai-forums__forum-header">
			<div class="sakai-forums__forum-identity">
				<h:outputText id="draft" styleClass="sakai-forums__status sakai-forums__status--draft"
						value="#{msgs.cdfm_draft}" rendered="#{ForumTool.selectedTopic.topic.draft == 'true'}"/>
				<h:panelGroup styleClass="sakai-forums__status" rendered="#{ForumTool.selectedTopic.topic.availability == 'false'}">
					<span class="si si-calendar-x" aria-hidden="true"></span>
					<h:outputText value="#{msgs.topic_restricted_message}"/>
				</h:panelGroup>
				<h:panelGroup styleClass="sakai-forums__status" rendered="#{ForumTool.selectedForum.locked == 'true'}">
					<span class="si si-locked" aria-hidden="true"></span>
					<span class="visually-hidden"><h:outputText value="#{msgs.cdfm_forum_locked}"/></span>
				</h:panelGroup>
				<h:panelGroup styleClass="sakai-forums__status" rendered="#{ForumTool.selectedForum.locked != 'true' && ForumTool.selectedTopic.locked == 'true'}">
					<span class="si si-locked" aria-hidden="true"></span>
					<span class="visually-hidden">
						<h:outputFormat value="#{msgs.cdfm_topic_locked}">
							<f:param value="#{ForumTool.selectedTopic.topic.title}"/>
						</h:outputFormat>
					</span>
				</h:panelGroup>
				<h:panelGroup rendered="#{ForumTool.selectedTopic.hasRubric == 'true'}">
					<sakai-rubric-student-preview-button
						site-id='<h:outputText value="#{ForumTool.siteId}" />'
						display="icon"
						tool-id="sakai.gradebookng"
						entity-id="<h:outputText value="#{ForumTool.selectedTopic.gradeAssign}" />">
					</sakai-rubric-student-preview-button>
				</h:panelGroup>
				<h:outputText id="topic_moderated" value="#{msgs.cdfm_forum_moderated_flag}" styleClass="sakai-forums__meta"
						rendered="#{ForumTool.selectedTopic.moderated == 'true'}"/>
			</div>
			<h:outputText value="#{ForumTool.selectedTopic.topic.shortDescription}" styleClass="sakai-forums__description"
					rendered="#{!empty ForumTool.selectedTopic.topic.shortDescription}"/>
			<f:subview id="longDesc" rendered="#{!empty ForumTool.selectedTopic.attachList || (ForumTool.selectedTopic.topic.extendedDescription != '' && ForumTool.selectedTopic.topic.extendedDescription != null && ForumTool.selectedTopic.topic.extendedDescription != '<br/>')}">
				<h:panelGroup layout="block" id="openLinkBlock" styleClass="toggleParent openLinkBlock">
					<a href="#" id="showMessage" class="toggle show">
						<span class="si si-chevron-down" aria-hidden="true"></span>
						<h:outputText value=" #{msgs.cdfm_read_full_description}"/>
						<h:outputText value=" #{msgs.cdfm_and}" rendered="#{!empty ForumTool.selectedTopic.attachList}"/>
						<h:outputText value=" #{msgs.cdfm_attach}" rendered="#{!empty ForumTool.selectedTopic.attachList}"/>
					</a>
				</h:panelGroup>
				<h:panelGroup layout="block" id="hideLinkBlock" styleClass="toggleParent hideLinkBlock display-none">
					<a href="#" id="hideMessage" class="toggle show">
						<span class="si si-chevron-up" aria-hidden="true"></span>
						<h:outputText value=" #{msgs.cdfm_hide_full_description}"/>
						<h:outputText value=" #{msgs.cdfm_and}" rendered="#{!empty ForumTool.selectedTopic.attachList}"/>
						<h:outputText value=" #{msgs.cdfm_attach}" rendered="#{!empty ForumTool.selectedTopic.attachList}"/>
					</a>
				</h:panelGroup>
				<h:panelGroup layout="block" id="fullTopicDescription" styleClass="textPanel fullTopicDescription display-none">
					<h:outputText escape="false" value="#{ForumTool.selectedTopic.topic.extendedDescription}"/>
					<h:dataTable styleClass="sakai-table sakai-table--stack attachListTable" value="#{ForumTool.selectedTopic.attachList}"
							var="eachAttach" rendered="#{!empty ForumTool.selectedTopic.attachList}">
						<h:column>
							<sakai:contentTypeMap fileType="#{eachAttach.attachment.attachmentType}" mapType="image" var="imagePath" pathPrefix="/library/image/"/>
							<h:graphicImage id="exampleFileIcon" value="#{imagePath}" alt=""/>
						</h:column>
						<h:column>
							<h:outputLink value="#{eachAttach.url}" target="_blank">
								<h:outputText value="#{eachAttach.attachment.attachmentName}"/>
							</h:outputLink>
						</h:column>
					</h:dataTable>
				</h:panelGroup>
			</f:subview>
		</div>

	<span class="skip" id="firstNewItemTitleHolder"><h:outputText value="#{msgs.cdfm_gotofirstnewtitle}" /></span>
	<span class="skip" id="firstPendingItemTitleHolder"><h:outputText value="#{msgs.cdfm_gotofirstpendingtitle}" /></span>
	<span class="skip" id="nextPendItemTitleHolder"><h:outputText value="#{msgs.cdfm_gotopendtitle}" /></span>
	<span class="skip" id="lastPendItemTitleHolder"><h:outputText value="#{msgs.cdfm_lastpendtitle}" /></span>
	<span class="skip" id="nextNewItemTitleHolder"><h:outputText value="#{msgs.cdfm_gotonewtitle}" /></span>
	<span class="skip" id="lastNewItemTitleHolder"><h:outputText value="#{msgs.cdfm_lastnewtitle}" /></span>

		<div id="messNavHolder" class="sakai-actions sakai-no-print">
				<h:commandLink action="#{ForumTool.processActionMarkAllAsNotRead}" rendered="#{ForumTool.selectedTopic.isMarkAsNotRead and not ForumTool.selectedTopic.topic.autoMarkThreadsRead}" styleClass="sakai-btn sakai-btn-secondary">
					<h:outputText value="#{msgs.cdfm_mark_all_as_not_read}" />
				</h:commandLink>
		</div>

		<div id="gradesSavedDiv" class="sakai-banner sakai-banner--success" style="display:none" role="alert" aria-live="assertive">
			<h:outputText value="#{msgs.cdfm_grade_successful}"/>
		</div>

		<h:panelGroup layout="block" styleClass="sakai-forums__empty" rendered="#{empty ForumTool.messages}">
			<p class="sakai-forums__empty-text"><h:outputText value="#{msgs.cdfm_no_messages}"/></p>
			<h:commandLink immediate="true" action="#{ForumTool.processAddMessage}" styleClass="sakai-btn sakai-btn-primary"
					rendered="#{ForumTool.selectedTopic != null && ForumTool.selectedTopic.isNewResponse && !ForumTool.selectedTopic.locked && !ForumTool.selectedForum.locked}">
				<h:outputText value="" styleClass="si si-add" escape="false"/>
				<h:outputText value="#{msgs.cdfm_container_title_thread}"/>
			</h:commandLink>
		</h:panelGroup>
		<h:panelGroup layout="block" rendered="#{!empty ForumTool.messages}">
			<mf:hierDataTable id="expandedThreadedMessages" value="#{ForumTool.messages}" var="message"
	   	 		noarrows="true" styleClass="sakai-table sakai-table--hover sakai-table--stack messagesThreaded" columnClasses="bogus">
				<h:column id="_msg_subject">
					<%@ include file="dfViewThreadBodyInclude.jsp" %>
				</h:column>
			</mf:hierDataTable>
		</h:panelGroup>

		<h:panelGroup layout="block" styleClass="sakai-actions sakai-forums__pager sakai-no-print">
			<h:panelGroup styleClass="sakai-btn sakai-btn-secondary is-disabled" rendered="#{!ForumTool.selectedTopic.hasPreviousTopic}">
				<h:outputText value="#{msgs.cdfm_previous_topic}"/>
			</h:panelGroup>
			<h:commandLink styleClass="sakai-btn sakai-btn-secondary" action="#{ForumTool.processActionDisplayPreviousTopic}" rendered="#{ForumTool.selectedTopic.hasPreviousTopic}" title="#{msgs.cdfm_previous_topic}">
				<h:outputText value="#{msgs.cdfm_previous_topic}"/>
				<f:param value="#{ForumTool.selectedTopic.previousTopicId}" name="previousTopicId"/>
				<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
			</h:commandLink>
			<h:panelGroup styleClass="sakai-btn sakai-btn-secondary is-disabled" rendered="#{!ForumTool.selectedTopic.hasNextTopic}">
				<h:outputText value="#{msgs.cdfm_next_topic}"/>
			</h:panelGroup>
			<h:commandLink styleClass="sakai-btn sakai-btn-secondary" action="#{ForumTool.processActionDisplayNextTopic}" rendered="#{ForumTool.selectedTopic.hasNextTopic}" title="#{msgs.cdfm_next_topic}">
				<h:outputText value="#{msgs.cdfm_next_topic}"/>
				<f:param value="#{ForumTool.selectedTopic.nextTopicId}" name="nextTopicId"/>
				<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
			</h:commandLink>
		</h:panelGroup>

		<h:inputHidden id="mainOrForumOrTopic" value="dfFlatView" />
<%
  String thisId = request.getParameter("panel");
  if (thisId == null)
  {
    thisId = "Main" + org.sakaiproject.tool.cover.ToolManager.getCurrentPlacement().getId();
  }
%>
			<script>
			function resize(){
  				mySetMainFrameHeight('<%= org.sakaiproject.util.Web.escapeJavascript(thisId)%>');
  			}
			</script>
	</h:form>

</sakai:view>
</f:view>
