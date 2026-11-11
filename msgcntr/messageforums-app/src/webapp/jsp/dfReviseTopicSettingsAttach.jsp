<%@ page import="java.util.*, jakarta.faces.context.*, jakarta.faces.application.*,
                 jakarta.faces.el.*, org.sakaiproject.tool.messageforums.*"%>
<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://myfaces.apache.org/tomahawk" prefix="t"%>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>
<f:view>
<sakai:view title="#{msgs.cdfm_discussion_topic_settings}">
	<script>includeLatestJQuery("msgcntr");</script>
	<script>includeWebjarLibrary("momentjs");</script>
	<script src="/messageforums-tool/js/sak-10625.js"></script>
	<script src="/messageforums-tool/js/jquery.charcounter.js"> </script>
	<script src="/messageforums-tool/js/permissions_header.js"></script>
	<script src="/messageforums-tool/js/forum.js"></script>
	<script src="/messageforums-tool/js/messages.js"></script>
	<script src="/messageforums-tool/js/datetimepicker.js"></script>
	<script src="/library/js/lang-datepicker/lang-datepicker.js"></script>
	<script type="module" src="/webcomponents/bundles/gradebook-item-selector.js<h:outputText value="#{ForumTool.CDNQuery}" />"></script>
	<link href="/library/webjars/jquery-ui/1.12.1/jquery-ui.min.css" rel="stylesheet" type="text/css" />
	<script type="module" src="/webcomponents/bundles/rubric-association-requirements.js<h:outputText value="#{ForumTool.CDNQuery}" />"></script>
	
	<%
		String thisId = request.getParameter("panel");
		if (thisId == null) {
    		thisId = "Main" + org.sakaiproject.tool.cover.ToolManager.getCurrentPlacement().getId();
  		}
	%>
	<script>
		function resize() {
  			mySetMainFrameHeight('<%= org.sakaiproject.util.Web.escapeJavascript(thisId)%>');
  		}
	</script>
	<script type="text/javascript">
		var isGradebookGroupEnabled = <h:outputText value="#{ForumTool.gradebookGroupEnabled}"/>;
		
		function setDatesEnabled(radioButton){
			$(".calWidget, .lockForumAfterCloseDateSpan").fadeToggle('slow');
		}

		window.onload = function(){
			const sendCheckbox = document.getElementById("revise:sendOpenCloseDateToCalendar");
			sendCheckbox?.disabled && (sendCheckbox.checked = false);	//make sure that Calendar sending is not checked when it's disabled/when the site has no calendar
		};

		function openDateCal() {
			NewCal('revise:openDate','MMDDYYYY',true,12, '<h:outputText value="#{ForumTool.defaultAvailabilityTime}"/>');
		}

		function closeDateCal() {
			NewCal('revise:closeDate','MMDDYYYY',true,12, '<h:outputText value="#{ForumTool.defaultAvailabilityTime}"/>');
		}

		function updateGradeAssignment() {
			const topicAssignments = isGradebookGroupEnabled
					? document.getElementById("revise:group_view:topic_assignments")
					: document.getElementById("revise:non_group_view:topic_assignments");

			if (topicAssignments?.value === undefined || topicAssignments.value === "Default_0") return;

			const associations = document.querySelectorAll('sakai-rubric-association');
			const createTaskGroup = document.getElementById("revise:createTaskGroup");
			const createTaskEmptyPanel = document.getElementById("revise:createTaskEmptyPanel");
			if (!!document.querySelector("sakai-tasks")) {
				associations.forEach(a => {
					a.setAttribute("entity-id", topicAssignments.value);
					a.style.display = 'inline';
				});
				createTaskGroup && (createTaskGroup.style.display = 'inline');
				createTaskEmptyPanel && (createTaskEmptyPanel.style.display = 'inline');
			} else {
				associations.forEach(a => a.style.display = 'none');
				createTaskGroup && (createTaskGroup.style.display = 'none');
				createTaskEmptyPanel && (createTaskEmptyPanel.style.display = 'none');
			}
		}

		function setAutoCreatePanel(radioButton) {

			$(".createOneTopicPanel").slideToggle("fast");
			$(".createTopicsForGroupsPanel").slideToggle("fast");
		}

		function togglePostAnonymousOption(checked) {

			var revealIDsToRoles = $("#revise\\:revealIDsToRolesContainer");
			if (checked) {
				revealIDsToRoles.css("display", "");
			} else {
				revealIDsToRoles.css("display", "none");
			}
		}

		function toggleIncludeContentsInEmailsOption(checked) {

			var includeContentsInEmails = $("#revise\\:includeContentsInEmailsContainer");
			if (checked) {
				includeContentsInEmails.css("display", "");
			} else {
				includeContentsInEmails.css("display", "none");
			}
		}

		function disableFieldsBeforeSubmit() {
			if (isGradebookGroupEnabled) {
				$('select[id^="revise\\:perm"]').each(function() {
					let elementId = $(this).attr("id");
					let rowIndex = elementId.split(":")[2];

					const element = $("#revise\\:perm\\" + ":" + rowIndex + "\\:level");

					if (element) {
						element.prop("disabled", false);
					}
				});
			}
		}
	</script>
	<!-- RUBRICS VARIABLES -->
	<%
		FacesContext fcontext = FacesContext.getCurrentInstance();
		Application appl = fcontext.getApplication();
		ValueBinding vbinding = appl.createValueBinding("#{ForumTool}");
		DiscussionForumTool forumTool = (DiscussionForumTool) vbinding.getValue(fcontext);
		String entityId = "top." + forumTool.getSelectedTopic().getTopic().getId();
	%>
	<!-- END RUBRICS VARIABLES -->

	<!--jsp/dfReviseTopicSettingsAttach.jsp-->
	<h:form id="revise" styleClass="sakai-forums" onsubmit="disableFieldsBeforeSubmit()">
		<% request.setAttribute("dfHeaderView", "topicSettings"); %>
<% request.setAttribute("dfHeaderBack", "forum"); %>
<%@ include file="/jsp/discussionForum/menu/forumsHeader.jsp" %>

		<p class="sakai-form-section__intro">
			<h:outputText id="instruction" value="#{msgs.cdfm_settings_instruction}"/>
		</p>
		<h:messages styleClass="sakai-banner sakai-banner--error" id="errorMessages" rendered="#{! empty facesContext.maximumSeverity}"/>

		<div class="sakai-form-section">
			<h:outputText value="#{msgs.cdfm_discussion_topic_settings}" styleClass="sakai-form-section__title"/>
			<div class="sakai-form-field">
				<h:outputLabel id="outputLabel" for="topic_title" styleClass="sakai-form-label required">
					<h:outputText value="#{msgs.cdfm_topic_title}"/>
				</h:outputLabel>
				<h:inputText size="50" id="topic_title" maxlength="250" styleClass="sakai-form-control"
						value="#{ForumTool.selectedTopic.topic.title}" validatorMessage="#{msgs.topics_revise_title_validation}">
					<f:validateLength minimum="1" maximum="255"/>
				</h:inputText>
			</div>
			<h:panelGroup layout="block" styleClass="sakai-form-field" rendered="#{ForumTool.showTopicShortDescription}">
				<h:outputLabel id="outputLabel1" for="topic_shortDescription" value="#{msgs.cdfm_shortDescription}" styleClass="sakai-form-label"/>
				<h:outputText value="#{msgs.cdfm_shortDescriptionCharsRem}" styleClass="charRemFormat display-none"/>
				<span class="charsRemaining sakai-forums__meta"></span>
				<h:inputTextarea rows="3" cols="45" id="topic_shortDescription"
						value="#{ForumTool.selectedTopic.topic.shortDescription}"
						styleClass="sakai-form-control forum_shortDescriptionClass"/>
			</h:panelGroup>
			<h:panelGroup layout="block" styleClass="sakai-form-field" rendered="#{! ForumTool.disableLongDesc}">
				<f:verbatim><input type="hidden" id="ckeditor-autosave-context" name="ckeditor-autosave-context" value="forums_dfReviseTopicSettingsAttach" /></f:verbatim>
				<h:panelGroup rendered="#{ForumTool.selectedTopic.topic.id!=null}"><f:verbatim><input type="hidden" id="ckeditor-autosave-entity-id" name="ckeditor-autosave-entity-id" value="</f:verbatim><h:outputText value="#{ForumTool.selectedTopic.topic.id}"/><f:verbatim>"/></f:verbatim></h:panelGroup>
				<h:outputText id="outputLabel2" value="#{msgs.cdfm_fullDescription}" styleClass="sakai-form-label"/>
				<sakai:inputRichText textareaOnly="#{PrivateMessagesTool.mobileSession}"
						rows="#{ForumTool.editorRows}" cols="132" id="topic_description"
						value="#{ForumTool.selectedTopic.topic.extendedDescription}">
				</sakai:inputRichText>
			</h:panelGroup>
		</div>

		<div class="sakai-form-section">
			<h:outputText value="#{msgs.cdfm_att}" styleClass="sakai-form-section__title"/>
			<h:dataTable styleClass="sakai-table sakai-table--stack" id="attmsg" value="#{ForumTool.attachments}" var="eachAttach"
					rendered="#{!empty ForumTool.attachments}">
				<h:column>
					<f:facet name="header"><h:outputText escape="false" value="&nbsp;"/></f:facet>
					<sakai:contentTypeMap fileType="#{eachAttach.attachment.attachmentType}" mapType="image" var="imagePath" pathPrefix="/library/image/"/>
					<h:graphicImage id="exampleFileIcon" value="#{imagePath}" alt=""/>
				</h:column>
				<h:column>
					<f:facet name="header"><h:outputText value="#{msgs.cdfm_title}"/></f:facet>
					<h:outputText value="#{eachAttach.attachment.attachmentName}"/>
				</h:column>
				<h:column>
					<f:facet name="header"><h:outputText escape="false" value="&nbsp;"/></f:facet>
					<h:commandLink action="#{ForumTool.processDeleteAttachSetting}" immediate="true" title="#{msgs.cdfm_remove}">
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
			<h:panelGroup layout="block" styleClass="sakai-form-section__intro" rendered="#{empty ForumTool.attachments}">
				<h:outputText value="#{msgs.cdfm_no_attachments}"/>
			</h:panelGroup>
			<div class="sakai-actions">
				<h:commandButton action="#{ForumTool.processAddAttachmentRedirect}"
						value="#{msgs.cdfm_button_bar_add_attachment_more_redirect}" accesskey="a"
						styleClass="sakai-btn sakai-btn-secondary"
						rendered="#{!empty ForumTool.attachments}"/>
				<h:commandButton action="#{ForumTool.processAddAttachmentRedirect}"
						value="#{msgs.cdfm_button_bar_add_attachment_redirect}" accesskey="a"
						styleClass="sakai-btn sakai-btn-secondary"
						rendered="#{empty ForumTool.attachments}"/>
			</div>
		</div>

		<div class="sakai-form-section">
			<h:outputText id="topic_posting_head" value="#{msgs.cdfm_topic_posting}" styleClass="sakai-form-section__title"/>
			<div class="sakai-form-field">
				<div class="sakai-form-choice-group">
					<div class="sakai-form-choice">
						<h:selectBooleanCheckbox title="topicLocked" value="#{ForumTool.selectedTopic.topicLocked}" id="topic_locked"/>
						<h:outputLabel for="topic_locked" id="topic_locked_label" value="#{msgs.cdfm_lock_topic}"/>
					</div>
					<div class="sakai-form-choice">
						<h:selectBooleanCheckbox title="Moderated" value="#{ForumTool.selectedTopic.topicModerated}" id="topic_moderated"/>
						<h:outputLabel for="topic_moderated" id="topic_moderated_label" value="#{msgs.cdfm_moderate_topic}"/>
					</div>
					<div class="sakai-form-choice">
						<h:selectBooleanCheckbox title="postFirst" value="#{ForumTool.selectedTopic.topicPostFirst}" id="topic_postFirst"/>
						<h:outputLabel for="topic_postFirst" id="topic_postFirst_label" value="#{msgs.cdfm_postFirst}"/>
					</div>
					<t:htmlTag value="div" styleClass="sakai-form-choice anonTopic" rendered="#{ForumTool.anonymousEnabled}">
						<h:selectBooleanCheckbox title="postAnonymous" value="#{ForumTool.selectedTopic.topicPostAnonymous}"
								id="topic_postAnonymous" onclick="togglePostAnonymousOption(this.checked);"
								disabled="#{!ForumTool.newTopicOrPostAnonymousRevisable}"/>
						<h:outputLabel escape="false" for="topic_postAnonymous" value="#{msgs.cdfm_postAnonymous} &nbsp;" id="topic_postAnonymous_label">
							<h:outputText value="#{msgs.cdfm_noReviseAfter}" styleClass="sakai-banner sakai-banner--warning" rendered="#{!ForumTool.postAnonymousRevisable && !ForumTool.existingTopic}"/>
							<h:outputText value="#{msgs.cdfm_noRevise}" styleClass="sakai-banner sakai-banner--warning" rendered="#{!ForumTool.postAnonymousRevisable && ForumTool.existingTopic}"/>
						</h:outputLabel>
					</t:htmlTag>
				</div>
			</div>
			<t:htmlTag value="div" id="revealIDsToRolesContainer"
					style="display: #{ForumTool.selectedTopic.topicPostAnonymous ? '' : 'none'}"
					styleClass="sakai-form-field anonTopic" rendered="#{ForumTool.anonymousEnabled}">
				<div class="sakai-form-choice">
					<h:selectBooleanCheckbox title="revealIDsToRoles" value="#{ForumTool.selectedTopic.topicRevealIDsToRoles}"
							id="topic_revealIDsToRoles" disabled="#{!ForumTool.newTopicOrRevealIDsToRolesRevisable}"/>
					<h:outputLabel escape="false" for="topic_revealIDsToRoles" value="#{msgs.cdfm_revealIDsToRoles} &nbsp;">
						<h:outputText value="#{msgs.cdfm_noReviseAfter}" styleClass="sakai-banner sakai-banner--warning" rendered="#{!ForumTool.revealIDsToRolesRevisable && !ForumTool.existingTopic}"/>
						<h:outputText value="#{msgs.cdfm_noRevise}" styleClass="sakai-banner sakai-banner--warning" rendered="#{!ForumTool.revealIDsToRolesRevisable && ForumTool.existingTopic}"/>
					</h:outputLabel>
				</div>
			</t:htmlTag>
		</div>

		<div class="sakai-form-section">
			<h:outputText value="#{msgs.cdfm_forum_availability}" id="forumAvailabilityLabel3" styleClass="sakai-form-section__title"/>
			<div class="sakai-form-field">
				<h:selectOneRadio layout="pageDirection" onclick="this.blur()" onchange="setDatesEnabled(this);"
						disabled="#{not ForumTool.editMode}" id="availabilityRestricted"
						value="#{ForumTool.selectedTopic.availabilityRestricted}"
						styleClass="sakai-form-choice-group">
					<f:selectItem itemValue="false" itemLabel="#{msgs.cdfm_forum_avail_show}"/>
					<f:selectItem itemValue="true" itemLabel="#{msgs.cdfm_forum_avail_date}"/>
				</h:selectOneRadio>
			</div>
			<h:panelGroup id="openDateSpan" layout="block" styleClass="sakai-form-field openDateSpan calWidget"
					style="display: #{ForumTool.selectedTopic.availabilityRestricted ? 'block' : 'none'}">
				<h:outputLabel value="#{msgs.openDate}" for="openDate" styleClass="sakai-form-label"/>
				<h:inputText id="openDate" styleClass="sakai-form-control openDate" value="#{ForumTool.selectedTopic.openDate}"/>
			</h:panelGroup>
			<h:panelGroup id="closeDateSpan" layout="block" styleClass="sakai-form-field openDateSpan calWidget"
					style="display: #{ForumTool.selectedTopic.availabilityRestricted ? '' : 'none'}">
				<h:outputLabel value="#{msgs.closeDate}" for="closeDate" styleClass="sakai-form-label"/>
				<h:inputText id="closeDate" styleClass="sakai-form-control closeDate" value="#{ForumTool.selectedTopic.closeDate}"/>
			</h:panelGroup>
			<h:panelGroup layout="block" styleClass="sakai-form-field" style="display: #{ForumTool.doesSiteHaveCalendar ? '' : 'none'}">
				<h:panelGroup id="sendOpenCloseDateToCalendarSpan" layout="block"
						styleClass="sakai-form-choice lockForumAfterCloseDateSpan calWidget"
						style="display: #{ForumTool.selectedTopic.availabilityRestricted ? '' : 'none'}">
					<h:selectBooleanCheckbox id="sendOpenCloseDateToCalendar"
							disabled="#{not ForumTool.doesSiteHaveCalendar}"
							value="#{ForumTool.selectedTopic.topic.sendOpenCloseToCalendar}"/>
					<h:outputLabel for="sendOpenCloseDateToCalendar" value="#{msgs.sendOpenCloseToCalendar}"/>
				</h:panelGroup>
			</h:panelGroup>
			<h:panelGroup id="lockForumAfterCloseDateSpan" layout="block" styleClass="sakai-form-field lockForumAfterCloseDateSpan"
					style="display: #{ForumTool.selectedTopic.availabilityRestricted ? '' : 'none'}">
				<div class="sakai-form-choice">
					<h:selectBooleanCheckbox id="lockForumAfterCloseDate" value="#{ForumTool.selectedTopic.topic.lockedAfterClosed}"/>
					<h:outputLabel for="lockForumAfterCloseDate" value="#{msgs.lockForumAfterCloseDate}"/>
				</div>
			</h:panelGroup>
		</div>

		<script>
			// Initialize datepickers
			localDatePicker({
				input:'[id="revise:openDate"]',
				allowEmptyDate: true,
				ashidden: { iso8601: 'openDateISO8601' },
				value:'[id="revise:openDate"]',
				useTime:1
			});

			localDatePicker({
				input:'[id="revise:closeDate"]',
				allowEmptyDate: true,
				ashidden: { iso8601: 'closeDateISO8601' },
				value: '[id="revise:closeDate"]',
				useTime:1
			});
		</script>

		<div class="sakai-form-section">
			<h:outputText value="#{msgs.cdfm_forum_notifications}" styleClass="sakai-form-section__title"/>
			<div class="sakai-form-field">
				<div class="sakai-form-choice">
					<h:selectBooleanCheckbox title="allowEmailNotifications"
							value="#{ForumTool.selectedTopic.topicAllowEmailNotifications}"
							id="topic_allow_email_notifications"
							onclick="toggleIncludeContentsInEmailsOption(this.checked);resizeFrame();"/>
					<h:outputLabel for="topic_allow_email_notifications" value="#{msgs.cdfm_allowEmailNotifications}"/>
				</div>
			</div>
			<h:panelGroup layout="block" id="includeContentsInEmailsContainer"
					style="display: #{ForumTool.selectedTopic.topicAllowEmailNotifications ? '' : 'none'}"
					styleClass="sakai-form-field">
				<div class="sakai-form-choice">
					<h:selectBooleanCheckbox title="includeContentsInEmails"
							value="#{ForumTool.selectedTopic.topicIncludeContentsInEmails}"
							id="topic_includeContentsInEmails"/>
					<h:outputLabel for="topic_includeContentsInEmails" value="#{msgs.cdfm_includeContentsInEmails}"/>
				</div>
			</h:panelGroup>
		</div>

		<div class="sakai-form-section">
			<h:outputText value="#{msgs.cdfm_forum_mark_read}" styleClass="sakai-form-section__title"/>
			<div class="sakai-form-field">
				<div class="sakai-form-choice">
					<h:selectBooleanCheckbox title="autoMarkThreadsRead"
							value="#{ForumTool.selectedTopic.topicAutoMarkThreadsRead}"
							id="autoMarkThreadsRead"/>
					<h:outputLabel for="autoMarkThreadsRead" value="#{msgs.cdfm_auto_mark_threads_read}"/>
				</div>
			</div>
		</div>

		<h:panelGroup layout="block" styleClass="sakai-form-section" rendered="#{ForumTool.gradebookExist && !ForumTool.selectedForum.markForDeletion}">
			<h:outputText value="#{msgs.perm_choose_assignment_head}" styleClass="sakai-form-section__title"/>
			<h:panelGroup layout="block" rendered="#{ForumTool.discussionGeneric}">
				<h:outputText styleClass="sakai-banner sakai-banner--info" value="#{msgs.group_sitegradebook_simple_forum}"/>
			</h:panelGroup>
			<h:panelGroup layout="block" styleClass="sakai-form-field" id="topic_grading" rendered="#{not ForumTool.discussionGeneric}">
				<h:outputLabel for="topic_assignments" value="#{msgs.perm_choose_assignment}" styleClass="sakai-form-label"/>
				<f:subview id="non_group_view" rendered="#{!ForumTool.gradebookGroupEnabled}">
					<h:panelGroup styleClass="gradeSelector">
						<h:selectOneMenu value="#{ForumTool.selectedTopic.gradeAssign}" onchange="updateGradeAssignment()"
								id="topic_assignments" disabled="#{not ForumTool.editMode}"
								styleClass="sakai-form-control">
							<f:selectItems value="#{ForumTool.assignments}"/>
						</h:selectOneMenu>
						<p class="sakai-form-help instrWOGrades display-none">
							<h:outputText value="#{msgs.perm_choose_assignment_none_t}"/>
						</p>
						<p class="sakai-form-help instrWithGrades">
							<h:outputText value="#{msgs.perm_choose_instruction_topic}"/>
							<h:outputLink value="#" styleClass="sakai-btn sakai-btn-icon" title="#{msgs.perm_choose_instruction_topic_more}" onclick="return false;">
								<span class="si si-info" aria-hidden="true"></span>
								<span class="visually-hidden"><h:outputText value="#{msgs.perm_choose_instruction_more_link}"/></span>
							</h:outputLink>
						</p>
					</h:panelGroup>
				</f:subview>
				<f:subview id="group_view" rendered="#{ForumTool.gradebookGroupEnabled}">
					<sakai-gradebook-item-selector
							id="gb-selector" input-id="revise:group_view:topic_assignments"
							app-name="sakai.forums"
							site-id='<h:outputText value="#{ForumTool.siteId}" />'
							user-id='<h:outputText value="#{ForumTool.userId}" />'
							group-id='<h:outputText value="#{ForumTool.groupId}" />'
							selected-temp='<h:outputText value="#{ForumTool.selectedTopic.gradeAssign}" />'>
					</sakai-gradebook-item-selector>
					<h:inputHidden id="topic_assignments" value="#{ForumTool.selectedTopic.gradeAssign}"/>
				</f:subview>
				<h:panelGroup id="createTaskEmptyPanel" layout="block"
						styleClass="#{((ForumTool.selectedTopic.gradeAssign != null && ForumTool.selectedTopic.gradeAssign != 'Default_0') ? '' : 'display-none')}"/>
				<h:panelGroup id="createTaskGroup" layout="block" styleClass="sakai-form-choice #{((ForumTool.selectedTopic.gradeAssign != null && ForumTool.selectedTopic.gradeAssign != 'Default_0') ? '' : 'display-none')}">
					<h:selectBooleanCheckbox id="createTask" title="createTask" value="#{ForumTool.selectedTopic.createTask}"/>
					<h:outputLabel for="createTask" value="#{msgs.perm_create_task_topic}"/>
				</h:panelGroup>
			</h:panelGroup>
			<sakai-rubric-association class="display-none"
					site-id='<h:outputText value="#{ForumTool.siteId}" />'
					dont-associate-label='<h:outputText value="#{msgs.topic_dont_associate_label}" />'
					associate-label='<h:outputText value="#{msgs.topic_associate_label}" />'
					read-only="true"
					tool-id="sakai.gradebookng"
					fine-tune-points='<h:outputText value="#{msgs.option_pointsoverride}" />'
					hide-student-preview='<h:outputText value="#{msgs.option_studentpreview}" />'>
			</sakai-rubric-association>
		</h:panelGroup>

		<h:panelGroup layout="block" styleClass="sakai-form-section"
				rendered="#{ForumTool.selectedTopic.topic.id==null && !empty ForumTool.siteGroups}">
			<h:outputText value="#{msgs.cdfm_autocreate_topics_header}" styleClass="sakai-form-section__title"/>
			<div class="sakai-form-field">
				<h:panelGroup rendered="#{!ForumTool.selectedForum.restrictPermissionsForGroups}">
					<h:selectOneRadio layout="pageDirection" onclick="this.blur()" onchange="setAutoCreatePanel(this);"
							disabled="#{not ForumTool.editMode}" id="createTopicsForGroups"
							value="#{ForumTool.selectedTopic.restrictPermissionsForGroups}"
							styleClass="sakai-form-choice-group">
						<f:selectItem itemValue="false" itemLabel="#{msgs.cdfm_create_one_topic}"/>
						<f:selectItem itemValue="true" itemLabel="#{msgs.cdfm_autocreate_topics_for_groups}"/>
					</h:selectOneRadio>
				</h:panelGroup>
				<h:panelGroup layout="block" styleClass="display-none" rendered="#{ForumTool.selectedForum.restrictPermissionsForGroups}">
					<h:selectOneRadio layout="pageDirection" onclick="this.blur()" onchange="setAutoCreatePanel(this);"
							disabled="#{not ForumTool.editMode}" id="createTopicsForGroups2"
							value="#{ForumTool.selectedTopic.restrictPermissionsForGroups}"
							styleClass="sakai-form-choice-group">
						<f:selectItem itemValue="false" itemLabel="#{msgs.cdfm_create_one_topic}"/>
					</h:selectOneRadio>
				</h:panelGroup>
			</div>
		</h:panelGroup>

		<div id="createOneTopicPanel" class="createOneTopicPanel sakai-form-section">
			<%@ include file="/jsp/discussionForum/permissions/permissions_include.jsp"%>
		</div>

		<div id="createTopicsForGroupsPanel" class="createTopicsForGroupsPanel sakai-form-section display-none">
			<h:panelGroup rendered="#{ForumTool.selectedTopic.topic.id==null && !empty ForumTool.siteGroups && !ForumTool.selectedForum.restrictPermissionsForGroups}">
				<p class="sakai-form-help">
					<h:outputText value="#{msgs.cdfm_autocreate_topics_desc}"/>
					<h:outputText value=" #{msgs.cdfm_autocreate_topics_desc_more}"/>
					<h:outputText value="#{ForumTool.autoRolesNoneDesc}"/>
					<h:outputText value="#{ForumTool.autoGroupsDesc}"/>
				</p>
				<div class="sakai-form-choice-group sakai-form-choice-group--scroll">
					<h:dataTable value="#{ForumTool.siteGroups}" var="siteGroup"
							styleClass="sakai-table sakai-table--stack"
							rendered="#{ForumTool.selectedTopic.topic.id==null}">
						<h:column>
							<div class="sakai-form-choice">
								<h:selectBooleanCheckbox value="#{siteGroup.createTopicForGroup}" id="topic_siteGroupCheck"/>
								<h:outputText value="#{siteGroup.group.title}" id="topic_siteGroupCheck_label"/>
							</div>
						</h:column>
					</h:dataTable>
				</div>
			</h:panelGroup>
		</div>

		<script>
			setPanelId('<%= org.sakaiproject.util.Web.escapeJavascript(thisId)%>');
			$(function () {
				if (<h:outputText value="#{ForumTool.selectedTopic.topic.id==null && !empty ForumTool.siteGroups && ForumTool.selectedTopic.restrictPermissionsForGroups}" />) {
					$("#createOneTopicPanel").hide();
					$("#createTopicsForGroupsPanel").show();
				}
			});
		</script>
		<div class="sakai-actions">
			<h:commandButton action="#{ForumTool.processActionSaveTopicSettings}" value="#{msgs.cdfm_button_bar_save_setting}" accesskey="s"
					rendered="#{!ForumTool.selectedTopic.markForDeletion}" styleClass="sakai-btn sakai-btn-primary blockMeOnClick">
				<f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId"/>
				<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
			</h:commandButton>
			<h:commandButton action="#{ForumTool.processActionSaveTopicAsDraft}" value="#{msgs.cdfm_button_bar_save_draft}" accesskey="v"
					rendered="#{!ForumTool.selectedTopic.markForDeletion}" styleClass="sakai-btn sakai-btn-secondary blockMeOnClick">
				<f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId"/>
				<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
			</h:commandButton>
			<h:commandButton action="#{ForumTool.processActionSaveTopicAndAddTopic}" value="#{msgs.cdfm_button_bar_save_setting_add_topic}" accesskey="t"
					rendered="#{!ForumTool.selectedTopic.markForDeletion}" styleClass="sakai-btn sakai-btn-secondary blockMeOnClick">
				<f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId"/>
				<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
			</h:commandButton>
			<h:commandButton action="#{ForumTool.processActionDeleteTopicConfirm}" id="delete_confirm"
					value="#{msgs.cdfm_button_bar_delete_topic}" accesskey="d"
					rendered="#{!ForumTool.selectedTopic.markForDeletion && ForumTool.displayTopicDeleteOption}"
					styleClass="sakai-btn sakai-btn-ghost blockMeOnClick">
				<f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId"/>
			</h:commandButton>
			<h:commandButton action="#{ForumTool.processActionDeleteTopic}" id="delete" accesskey="d"
					value="#{msgs.cdfm_button_bar_delete_topic}" rendered="#{ForumTool.selectedTopic.markForDeletion}"
					styleClass="sakai-btn sakai-btn-primary blockMeOnClick">
				<f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId"/>
			</h:commandButton>
			<h:commandButton immediate="true" action="#{ForumTool.processActionHome}" value="#{msgs.cdfm_button_bar_cancel}"
					accesskey="x" styleClass="sakai-btn sakai-btn-ghost"/>
			<h:outputText styleClass="sakai-banner sakai-banner--info display-none" value="#{msgs.cdfm_processing_submit_message}"/>
		</div>
	</h:form>
	<script>
		$(document).ready(function () {
			if ($('.gradeSelector').find('option').length ===1){
				$('.gradeSelector').find('select').hide();
				$('.gradeSelector').find('.instrWithGrades').hide();
				$('.gradeSelector').find('.instrWOGrades').show();
			}
			updateGradeAssignment();
			var charRemFormat = $('.charRemFormat').text();
			$(".forum_shortDescriptionClass").charCounter(255, {
				container: ".charsRemaining",
				format: charRemFormat
			});
			$('#revise\\:topic_locked, #revise\\:topic_moderated, #revise\\:topic_postFirst').each(function() {
                $(this).attr('aria-labelledby', 'topic_posting_head ' + $(this).attr('id') + '_label');
            });
            if($('#revise\\:topic_postAnonymous').length){
                $('#revise\\:topic_postAnonymous').attr('aria-labelledby', 'topic_posting_head revise:topic_postAnonymous_label');
            }
            $('#revise\\:availabilityRestricted\\:0, #revise\\:availabilityRestricted\\:1').each(function() {
               let label = $('#revise\\:forumAvailabilityLabel3').text() + " " + $(this).next().text();
               $(this).attr('aria-label', label);
            });
            $('input[id*="topic_siteGroupCheck"]').each(function() {
                 $(this).attr('aria-labelledby', 'revise:createTopicsForGroups:1 ' + $(this).attr('id') + '_label');
            });

		 });
	</script>
</sakai:view>
</f:view>
