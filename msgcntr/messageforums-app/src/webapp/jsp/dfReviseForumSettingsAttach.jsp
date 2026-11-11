<%@ page import="java.util.*, jakarta.faces.context.*, jakarta.faces.application.*,
                 jakarta.faces.el.*, org.sakaiproject.tool.messageforums.*"%>
<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>
<f:view>
	<sakai:view title="#{msgs.cdfm_discussion_forum_settings}">
	<script>includeLatestJQuery("msgcntr");</script>
	<script>includeWebjarLibrary("momentjs");</script>
	<script src="/messageforums-tool/js/jquery.charcounter.js"> </script>
	<script src="/messageforums-tool/js/sak-10625.js"></script>
	<script src="/messageforums-tool/js/forum.js"></script>
	<script src="/messageforums-tool/js/messages.js"></script>
	<script src="/messageforums-tool/js/permissions_header.js"></script>
	<script src="/library/js/lang-datepicker/lang-datepicker.js"></script>
	<script type="module" src="/webcomponents/bundles/gradebook-item-selector.js<h:outputText value="#{ForumTool.CDNQuery}" />"></script>
	<script type="module" src="/webcomponents/bundles/rubric-association-requirements.js<h:outputText value="#{ForumTool.CDNQuery}" />"></script>
	<link href="/library/webjars/jquery-ui/1.12.1/jquery-ui.min.css" rel="stylesheet" type="text/css" />
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
	<script>
		var isGradebookGroupEnabled = <h:outputText value="#{ForumTool.gradebookGroupEnabled}"/>;
	
	$(document).ready(function() {
		const radioButtonRestrictedAvailability = document.getElementById('revise:availabilityRestricted:1');
		if (radioButtonRestrictedAvailability.checked && $(".calWidget")[0].style['display'] === 'none') {
			setDatesEnabled(radioButtonRestrictedAvailability);
		}
	});

	function setDatesEnabled(radioButton){
		$(".calWidget, .lockForumAfterCloseDateSpan").fadeToggle('slow');
	}

	function updateGradeAssignment(){
	const forumAssignments = isGradebookGroupEnabled
			? document.getElementById("revise:group_view:forum_assignments")
			: document.getElementById("revise:non_group_view:forum_assignments");
    if (forumAssignments?.value === undefined || forumAssignments.value === "Default_0") return;

    const elems = document.getElementsByTagName('sakai-rubric-association');
    const createTaskGroup = document.getElementById("revise:createTaskGroup");
    const isTasksWidgetAvailable = !!document.querySelector("sakai-tasks");

    if (isTasksWidgetAvailable) {
			for (var i = 0; i < elems.length; i++) {
				elems[i].setAttribute("entity-id", forumAssignments.value);
				elems[i].style.display = 'inline';
			}
			createTaskGroup.style.display = 'inline';
    } else {
			for (var i = 0; i < elems.length; i++) {
				elems[i].style.display = 'none';
			}
			createTaskGroup.style.display = 'none';
    }
	}

	window.onload = function(){
		const sendCheckbox = document.getElementById("revise:sendOpenCloseDateToCalendar");
		sendCheckbox?.disabled && (sendCheckbox.checked = false);	//make sure that Calendar sending is not checked when it's disabled/when the site has no calendar
	};

	function setAutoCreatePanel() {
		$(".createOneForumPanel").slideToggle("fast");
		$(".createForumsForGroupsPanel").slideToggle("fast", function() {
			if ($('#createForumsForGroupsPanel').is(':hidden')) {
			   document.getElementById("revise:saveandadd").disabled = false;
			}
			else {
			   document.getElementById("revise:saveandadd").disabled = true;
			}
		});
	};

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

    <h:form id="revise" styleClass="sakai-forums" onsubmit="disableFieldsBeforeSubmit()">
		  <script>
            $(document).ready(function(){
				var errorMessages = $('#revise\\:errorMessages');
				if (errorMessages !== undefined) {
					errorMessages.attr("role", "alert");
					errorMessages.find('td').each(function() {
						$(this).attr('title', $(this).html());
					});
				}

				$('#revise\\:forum_locked, #revise\\:moderated, #revise\\:postFirst').each(function() {
					$(this).attr('aria-labelledby', 'forum_posting_head ' + $(this).attr('id') + '_label');
				});

                $('#revise\\:availabilityRestricted\\:0, #revise\\:availabilityRestricted\\:1').each(function() {
                   let label = $('#revise\\:forumAvailabilityLabel2').text() + " " + $(this).next().text();
                   $(this).attr('aria-label', label);
                });
                $('input[id*="forum_siteGroupCheck"]').each(function() {
                      $(this).attr('aria-labelledby', 'revise:createForumsForGroups:1 ' + $(this).attr('id') + '_label');
                });
				if ($('.gradeSelector').find('option').length ===1){
					$('.gradeSelector').find('select').hide();
					$('.gradeSelector').find('.instrWithGrades').hide();
					$('.gradeSelector').find('.instrWOGrades').show();
				}
				var charRemFormat = $('.charRemFormat').text();
				$(".forum_shortDescriptionClass").charCounter(255, {
					container: ".charsRemaining",
					format: charRemFormat
				 });
				 updateGradeAssignment();

                if(document.getElementById("revise:createForumsForGroups:1") && document.getElementById("revise:createForumsForGroups:1").checked) {
                    setAutoCreatePanel();
                }

			 });
        </script>
		<% request.setAttribute("dfHeaderView", "forumSettings"); %>
<% request.setAttribute("dfHeaderBack", "discussions"); %>
<%@ include file="/jsp/discussionForum/menu/forumsHeader.jsp" %>

		<p class="sakai-form-section__intro">
		  <h:outputText id="instruction" value="#{msgs.cdfm_settings_instruction}"/>
		</p>
		<h:messages styleClass="sakai-banner sakai-banner--error" id="errorMessages" rendered="#{! empty facesContext.maximumSeverity}"/>

		<div class="sakai-form-section">
			<h:outputText value="#{msgs.cdfm_discussion_forum_settings}" styleClass="sakai-form-section__title"/>
			<div class="sakai-form-field">
				<h:outputLabel id="outputLabel" for="forum_title" styleClass="sakai-form-label required">
					<h:outputText value="#{msgs.cdfm_forum_title}"/>
				</h:outputLabel>
				<h:inputText size="50" id="forum_title" maxlength="250" styleClass="sakai-form-control"
						value="#{ForumTool.selectedForum.forum.title}" validatorMessage="#{msgs.forums_revise_title_validation}">
					<f:validateLength minimum="1" maximum="255"/>
				</h:inputText>
			</div>
			<h:panelGroup layout="block" styleClass="sakai-form-field" rendered="#{ForumTool.showForumShortDescription}">
				<h:outputLabel id="outputLabel1" for="forum_shortDescription" value="#{msgs.cdfm_shortDescription}" styleClass="sakai-form-label"/>
				<h:outputText value="#{msgs.cdfm_shortDescriptionCharsRem}" styleClass="charRemFormat display-none"/>
				<span class="charsRemaining sakai-forums__meta"></span>
				<h:inputTextarea rows="3" cols="45" id="forum_shortDescription"
						value="#{ForumTool.selectedForum.forum.shortDescription}"
						styleClass="sakai-form-control forum_shortDescriptionClass"/>
			</h:panelGroup>
			<h:panelGroup layout="block" styleClass="sakai-form-field" rendered="#{! ForumTool.disableLongDesc}">
				<f:verbatim><input type="hidden" id="ckeditor-autosave-context" name="ckeditor-autosave-context" value="forums_dfReviseForumSettingsAttach" /></f:verbatim>
				<h:panelGroup rendered="#{ForumTool.selectedForum.forum.id!=null}"><f:verbatim><input type="hidden" id="ckeditor-autosave-entity-id" name="ckeditor-autosave-entity-id" value="</f:verbatim><h:outputText value="#{ForumTool.selectedForum.forum.id}"/><f:verbatim>"/></f:verbatim></h:panelGroup>
				<h:outputText id="outputLabel2" value="#{msgs.cdfm_fullDescription}" styleClass="sakai-form-label"/>
				<sakai:inputRichText textareaOnly="#{PrivateMessagesTool.mobileSession}" rows="#{ForumTool.editorRows}" cols="132" id="df_compose_description" value="#{ForumTool.selectedForum.forum.extendedDescription}">
				</sakai:inputRichText>
			</h:panelGroup>
		</div>

		<div class="sakai-form-section">
			<h:outputText value="#{msgs.cdfm_att}" styleClass="sakai-form-section__title"/>
			<h:dataTable styleClass="sakai-table sakai-table--stack" id="attmsg" value="#{ForumTool.attachments}" var="eachAttach"
					rendered="#{!empty ForumTool.attachments}">
				<h:column>
					<f:facet name="header"><h:outputText value=" "/></f:facet>
					<sakai:contentTypeMap fileType="#{eachAttach.attachment.attachmentType}" mapType="image" var="imagePath" pathPrefix="/library/image/"/>
					<h:graphicImage id="exampleFileIcon" value="#{imagePath}" alt=""/>
				</h:column>
				<h:column>
					<f:facet name="header"><h:outputText value="#{msgs.cdfm_title}"/></f:facet>
					<h:outputText value="#{eachAttach.attachment.attachmentName}"/>
				</h:column>
				<h:column>
					<f:facet name="header"><h:outputText value=" "/></f:facet>
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
						value="#{msgs.cdfm_button_bar_add_attachment_more_redirect}"
						styleClass="sakai-btn sakai-btn-secondary"
						rendered="#{!empty ForumTool.attachments}"/>
				<h:commandButton action="#{ForumTool.processAddAttachmentRedirect}"
						value="#{msgs.cdfm_button_bar_add_attachment_redirect}"
						styleClass="sakai-btn sakai-btn-secondary"
						rendered="#{empty ForumTool.attachments}"/>
			</div>
		</div>

		<div class="sakai-form-section">
			<h:outputText id="forum_posting_head" value="#{msgs.cdfm_forum_posting}" styleClass="sakai-form-section__title"/>
			<div class="sakai-form-field">
				<div class="sakai-form-choice-group">
					<div class="sakai-form-choice">
						<h:selectBooleanCheckbox title="ForumLocked" value="#{ForumTool.selectedForum.forumLocked}" id="forum_locked"/>
						<h:outputLabel for="forum_locked" value="#{msgs.cdfm_lock_forum}"/>
					</div>
					<div class="sakai-form-choice">
						<h:selectBooleanCheckbox title="Moderated" value="#{ForumTool.selectedForum.forumModerated}" id="moderated"/>
						<h:outputLabel for="moderated" value="#{msgs.cdfm_moderate_forum}"/>
					</div>
					<div class="sakai-form-choice">
						<h:selectBooleanCheckbox title="postFirst" value="#{ForumTool.selectedForum.forumPostFirst}" id="postFirst"/>
						<h:outputLabel for="postFirst" value="#{msgs.cdfm_postFirst}"/>
					</div>
				</div>
			</div>
		</div>

		<div class="sakai-form-section">
			<h:outputText id="forumAvailabilityLabel2" value="#{msgs.cdfm_forum_availability}" styleClass="sakai-form-section__title"/>
			<div class="sakai-form-field">
				<h:selectOneRadio layout="pageDirection" onclick="this.blur()" onchange="setDatesEnabled(this);"
						disabled="#{not ForumTool.editMode}" id="availabilityRestricted"
						value="#{ForumTool.selectedForum.availabilityRestricted}"
						styleClass="sakai-form-choice-group">
					<f:selectItem itemValue="false" itemLabel="#{msgs.cdfm_forum_avail_show}"/>
					<f:selectItem itemValue="true" itemLabel="#{msgs.cdfm_forum_avail_date}"/>
				</h:selectOneRadio>
			</div>
			<h:panelGroup id="openDateSpan" layout="block" styleClass="sakai-form-field openDateSpan calWidget"
					style="display: #{ForumTool.selectedForum.availabilityRestricted ? 'block' : 'none'}">
				<h:outputLabel value="#{msgs.openDate}" for="openDate" styleClass="sakai-form-label"/>
				<h:inputText id="openDate" styleClass="sakai-form-control openDate" value="#{ForumTool.selectedForum.openDate}"/>
			</h:panelGroup>
			<h:panelGroup id="closeDateSpan" layout="block" styleClass="sakai-form-field closeDateSpan calWidget"
					style="display: #{ForumTool.selectedForum.availabilityRestricted ? 'block' : 'none'}">
				<h:outputLabel value="#{msgs.closeDate}" for="closeDate" styleClass="sakai-form-label"/>
				<h:inputText id="closeDate" styleClass="sakai-form-control closeDate" value="#{ForumTool.selectedForum.closeDate}"/>
			</h:panelGroup>
			<h:panelGroup layout="block" styleClass="sakai-form-field" style="display: #{ForumTool.doesSiteHaveCalendar ? '' : 'none'}">
				<h:panelGroup id="sendOpenCloseDateToCalendarSpan" layout="block"
						styleClass="sakai-form-choice lockForumAfterCloseDateSpan calWidget"
						style="display: #{ForumTool.selectedForum.availabilityRestricted ? '' : 'none'}">
					<h:selectBooleanCheckbox id="sendOpenCloseDateToCalendar"
							disabled="#{not ForumTool.doesSiteHaveCalendar}"
							value="#{ForumTool.selectedForum.forum.sendOpenCloseToCalendar}"/>
					<h:outputLabel for="sendOpenCloseDateToCalendar" value="#{msgs.sendOpenCloseToCalendar}"/>
				</h:panelGroup>
			</h:panelGroup>
			<h:panelGroup layout="block" id="lockForumAfterCloseDateSpan" styleClass="sakai-form-field lockForumAfterCloseDateSpan"
					style="display: #{ForumTool.selectedForum.availabilityRestricted ? '' : 'none'}">
				<div class="sakai-form-choice">
					<h:selectBooleanCheckbox id="lockForumAfterCloseDate" value="#{ForumTool.selectedForum.forum.lockedAfterClosed}"/>
					<h:outputLabel for="lockForumAfterCloseDate" value="#{msgs.lockForumAfterCloseDate}"/>
				</div>
			</h:panelGroup>
		</div>

			<script>
				// Initialize datepickers
				localDatePicker({
					input: '.openDate',
					allowEmptyDate: true,
					ashidden: { iso8601: 'openDateISO8601' },
					value: '.openDate',
					useTime: 1
				});

				localDatePicker({
					input: '.closeDate',
					allowEmptyDate: true,
					ashidden: { iso8601: 'closeDateISO8601' },
					value: '.closeDate',
					useTime: 1
				});
			</script>

		<div class="sakai-form-section">
			<h:outputText value="#{msgs.cdfm_forum_mark_read}" styleClass="sakai-form-section__title"/>
			<div class="sakai-form-field">
				<div class="sakai-form-choice">
					<h:selectBooleanCheckbox title="autoMarkThreadsRead"
							value="#{ForumTool.selectedForum.forumAutoMarkThreadsRead}"
							id="autoMarkThreadsRead"/>
					<h:outputLabel for="autoMarkThreadsRead" value="#{msgs.cdfm_auto_mark_threads_read}"/>
				</div>
			</div>
		</div>

		<h:panelGroup layout="block" styleClass="sakai-form-section" rendered="#{ForumTool.gradebookExist}">
			<h:outputText value="#{msgs.perm_choose_assignment_head}" styleClass="sakai-form-section__title"/>
			<h:panelGroup layout="block" rendered="#{ForumTool.discussionGeneric}">
				<h:outputText styleClass="sakai-banner sakai-banner--info" value="#{msgs.group_sitegradebook_simple_forum}"/>
			</h:panelGroup>
			<h:panelGroup layout="block" styleClass="sakai-form-field" id="forum_grading" rendered="#{not ForumTool.discussionGeneric}">
				<h:outputLabel for="forum_assignments" value="#{msgs.perm_choose_assignment}" styleClass="sakai-form-label"/>
				<f:subview id="non_group_view" rendered="#{!ForumTool.gradebookGroupEnabled}">
					<h:panelGroup styleClass="gradeSelector">
						<h:selectOneMenu id="forum_assignments" onchange="updateGradeAssignment()"
								value="#{ForumTool.selectedForum.gradeAssign}"
								disabled="#{not ForumTool.editMode}"
								styleClass="sakai-form-control">
							<f:selectItems value="#{ForumTool.assignments}"/>
						</h:selectOneMenu>
						<p class="sakai-form-help instrWOGrades display-none">
							<h:outputText value="#{msgs.perm_choose_assignment_none_f}"/>
						</p>
						<p class="sakai-form-help instrWithGrades">
							<h:outputText value="#{msgs.perm_choose_instruction_forum}"/>
							<h:outputLink value="#" styleClass="sakai-btn sakai-btn-icon" title="#{msgs.perm_choose_instruction_forum_more}" onclick="return false;">
								<span class="si si-info" aria-hidden="true"></span>
								<span class="visually-hidden"><h:outputText value="#{msgs.perm_choose_instruction_more_link}"/></span>
							</h:outputLink>
						</p>
					</h:panelGroup>
				</f:subview>
				<f:subview id="group_view" rendered="#{ForumTool.gradebookGroupEnabled}">
					<sakai-gradebook-item-selector
							id="gb-selector" input-id="revise:group_view:forum_assignments"
							app-name="sakai.forums"
							site-id='<h:outputText value="#{ForumTool.siteId}" />'
							user-id='<h:outputText value="#{ForumTool.userId}" />'
							group-id='<h:outputText value="#{ForumTool.groupId}" />'
							selected-temp='<h:outputText value="#{ForumTool.selectedForum.gradeAssign}" />'>
					</sakai-gradebook-item-selector>
					<h:inputHidden id="forum_assignments" value="#{ForumTool.selectedForum.gradeAssign}"/>
				</f:subview>
				<h:panelGroup id="createTaskGroup" layout="block"
						styleClass="sakai-form-choice #{((ForumTool.selectedForum.gradeAssign != null && ForumTool.selectedForum.gradeAssign != 'Default_0') ? '' : 'display-none')}">
					<h:selectBooleanCheckbox id="createTask" title="createTask" value="#{ForumTool.selectedForum.createTask}"/>
					<h:outputLabel for="createTask" value="#{msgs.perm_create_task_forum}"/>
				</h:panelGroup>
			</h:panelGroup>
			<sakai-rubric-association class="display-none"
					site-id='<h:outputText value="#{ForumTool.siteId}" />'
					dont-associate-label='<h:outputText value="#{msgs.forum_dont_associate_label}" />'
					associate-label='<h:outputText value="#{msgs.forum_associate_label}" />'
					read-only="true"
					tool-id="sakai.gradebookng"
					fine-tune-points='<h:outputText value="#{msgs.option_pointsoverride}" />'
					hide-student-preview='<h:outputText value="#{msgs.option_studentpreview}" />'>
			</sakai-rubric-association>
		</h:panelGroup>

		<h:panelGroup layout="block" styleClass="sakai-form-section"
				rendered="#{ForumTool.selectedForum.forum.id==null && !empty ForumTool.siteGroups}">
			<h:outputText value="#{msgs.cdfm_autocreate_forums_header}" styleClass="sakai-form-section__title"/>
			<div class="sakai-form-field">
				<h:selectOneRadio layout="pageDirection" onclick="this.blur()" onchange="setAutoCreatePanel();"
						disabled="#{not ForumTool.editMode}" id="createForumsForGroups"
						value="#{ForumTool.selectedForum.restrictPermissionsForGroups}"
						styleClass="sakai-form-choice-group">
					<f:selectItem itemValue="false" itemLabel="#{msgs.cdfm_create_one_forum}"/>
					<f:selectItem itemValue="true" itemLabel="#{msgs.cdfm_autocreate_forums_for_groups}"/>
				</h:selectOneRadio>
			</div>
		</h:panelGroup>

		<div id="createOneForumPanel" class="createOneForumPanel sakai-form-section">
			<%@ include file="/jsp/discussionForum/permissions/permissions_include.jsp"%>
		</div>

		<div id="createForumsForGroupsPanel" class="createForumsForGroupsPanel sakai-form-section display-none">
			<h:panelGroup rendered="#{ForumTool.selectedForum.forum.id==null && !empty ForumTool.siteGroups}">
				<p class="sakai-form-help">
					<h:outputText value="#{msgs.cdfm_autocreate_forums_desc}"/>
					<h:outputText value=" #{ForumTool.autoRolesNoneDesc}"/>
					<h:outputText value="#{ForumTool.autoGroupsDesc}"/>
				</p>
				<div class="sakai-form-choice-group sakai-form-choice-group--scroll">
					<h:dataTable value="#{ForumTool.siteGroups}" var="siteGroup"
							styleClass="sakai-table sakai-table--stack"
							rendered="#{ForumTool.selectedForum.forum.id==null}">
						<h:column>
							<div class="sakai-form-choice">
								<h:selectBooleanCheckbox value="#{siteGroup.createForumForGroup}" id="forum_siteGroupCheck"/>
								<h:outputText value="#{siteGroup.group.title}" id="forum_siteGroupCheck_label"/>
							</div>
						</h:column>
					</h:dataTable>
				</div>
			</h:panelGroup>
		</div>

		<div class="sakai-actions">
			<h:commandButton action="#{ForumTool.processActionSaveForumSettings}" value="#{msgs.cdfm_button_bar_save_setting}"
					rendered="#{!ForumTool.selectedForum.markForDeletion}" accesskey="s"
					styleClass="sakai-btn sakai-btn-primary blockMeOnClick">
				<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
			</h:commandButton>
			<h:commandButton id="saveandadd" action="#{ForumTool.processActionSaveForumAndAddTopic}"
					value="#{msgs.cdfm_button_bar_save_setting_add_topic}" accesskey="t"
					rendered="#{!ForumTool.selectedForum.markForDeletion}"
					styleClass="sakai-btn sakai-btn-secondary blockMeOnClick">
				<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
			</h:commandButton>
			<h:commandButton action="#{ForumTool.processActionSaveForumAsDraft}" value="#{msgs.cdfm_button_bar_save_draft}" accesskey="v"
					rendered="#{!ForumTool.selectedForum.markForDeletion}"
					styleClass="sakai-btn sakai-btn-secondary blockMeOnClick">
				<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
			</h:commandButton>
			<h:commandButton id="delete_confirm" action="#{ForumTool.processActionDeleteForumConfirm}"
					value="#{msgs.cdfm_button_bar_delete_forum}"
					rendered="#{!ForumTool.selectedForum.markForDeletion && ForumTool.displayForumDeleteOption}"
					accesskey="d" styleClass="sakai-btn sakai-btn-ghost blockMeOnClick">
				<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
			</h:commandButton>
			<h:commandButton id="delete" action="#{ForumTool.processActionDeleteForum}"
					value="#{msgs.cdfm_button_bar_delete_forum}" rendered="#{ForumTool.selectedForum.markForDeletion}"
					accesskey="d" styleClass="sakai-btn sakai-btn-primary blockMeOnClick">
				<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
			</h:commandButton>
			<h:commandButton immediate="true" action="#{ForumTool.processActionHome}" value="#{msgs.cdfm_button_bar_cancel}"
					accesskey="x" styleClass="sakai-btn sakai-btn-ghost"/>
			<h:outputText styleClass="sakai-banner sakai-banner--info display-none" value="#{msgs.cdfm_processing_submit_message}"/>
		</div>
	 </h:form>
    </sakai:view>
</f:view>
