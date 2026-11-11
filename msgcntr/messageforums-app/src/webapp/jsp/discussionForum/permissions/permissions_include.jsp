<!--jsp/discussionForum/permissions/permissions_include.jsp-->
<script>
  window.ownerLevelArray = <h:outputText value="#{ForumTool.ownerLevelArray}" escape="false"/>;
  window.authorLevelArray = <h:outputText value="#{ForumTool.authorLevelArray}" escape="false"/>;
  window.noneditingAuthorLevelArray = <h:outputText value="#{ForumTool.noneditingAuthorLevelArray}" escape="false"/>;
  window.reviewerLevelArray = <h:outputText value="#{ForumTool.reviewerLevelArray}" escape="false"/>;
  window.noneLevelArray = <h:outputText value="#{ForumTool.noneLevelArray}" escape="false"/>;
  window.contributorLevelArray = <h:outputText value="#{ForumTool.contributorLevelArray}" escape="false"/>;

  setPanelId('<%= org.sakaiproject.util.Web.escapeJavascript(thisId)%>');
  var isGradebookGroupEnabled = <h:outputText value="#{ForumTool.gradebookGroupEnabled}"/>;

  $(document).ready(function() {
          $('input[id*="\\:revisePostings\\:"], input[id*="\\:deletePostings\\:"]').each(function() {
                  let elementId = $(this).attr("id");
                  let rowIndex = elementId.split(":")[2];
                  let groupLabel = elementId.split(":")[3];
                  let permRole = "";
                  if ($("#revise\\:perm\\:"+ rowIndex +"\\:perm_role_label1").length) {
                       permRole = $("#revise\\:perm\\:"+ rowIndex +"\\:perm_role_label1").text();
                  }
                  else if ($("#revise\\:perm\\:"+ rowIndex +"\\:perm_role_label2").length) {
                      permRole = $("#revise\\:perm\\:"+ rowIndex +"\\:perm_role_label2").text();
                  }
                  let label = permRole  + " " + $('#revise\\:perm\\:'+rowIndex+'\\:'+ groupLabel +"_label").text() + " " + $(this).next().text();
                  $(this).attr('aria-label', label);
          });
          $('input:checkbox[id^="revise\\:perm"]').each(function() {
            let elementId = $(this).attr("id");
            let rowIndex = elementId.split(":")[2];
            let permRoleLabel = "";

            if ($("#revise\\:perm\\:"+ rowIndex +"\\:perm_role_label1").length) {
                permRoleLabel = "revise:perm:"+ rowIndex +":perm_role_label1";
            } else if ($("#revise\\:perm\\:"+ rowIndex +"\\:perm_role_label2").length) {
                permRoleLabel = "revise:perm:"+ rowIndex +":perm_role_label2";
            }

            $(this).attr('aria-labelledby', permRoleLabel + " " + $(this).attr('id') + '_label');
          });

          if (isGradebookGroupEnabled) {
            $('select[id^="revise\\:perm"]').each(function() {
              let elementId = $(this).attr("id");
              let rowIndex = elementId.split(":")[2];
              const elementSelect = $("#revise\\:perm\\:" + rowIndex + "\\:level");
              const permissionTrigger = document.getElementById("revise:perm:" + rowIndex + ":customize");

              if (elementSelect) {
                elementSelect.prop("disabled", true);
              }

              if (permissionTrigger) {
                permissionTrigger.style.display = "none";
              }
            });
          }
    });
</script>

<details class="sakai-forums__permissions-section sakai-form-section" id="cntrl_perm"
		<h:outputText value="open" rendered="#{!ForumTool.collapsePermissionPanel}" escape="false"/>>
	<summary class="sakai-form-section__title sakai-forums__permissions-summary">
		<h:outputText value="#{msgs.cdfm_permissions}"/>
	</summary>

	<h:panelGroup layout="block" styleClass="sakai-form-section__intro" rendered="#{ForumTool.selectedForum.restrictPermissionsForGroups == 'true' && ForumTool.permissionMode == 'forum'}">
		<h:outputText value="#{msgs.cdfm_autocreate_forums_edit}"/>
	</h:panelGroup>
	<h:panelGroup layout="block" styleClass="sakai-form-section__intro" rendered="#{ForumTool.selectedTopic.restrictPermissionsForGroups == 'true' && ForumTool.permissionMode == 'topic'}">
		<h:outputText value="#{msgs.cdfm_autocreate_topics_edit}"/>
	</h:panelGroup>

	<div class="sakai-table-wrap">
		<h:dataTable id="perm" value="#{ForumTool.permissions}" var="permission"
				styleClass="sakai-table sakai-table--stack sakai-forums__permissions"
				columnClasses="sakai-table__primary,sakai-table__nowrap,sakai-table__actions">
			<h:column>
				<f:facet name="header">
					<h:outputText value="#{msgs.perm_role}"/>
				</f:facet>
				<h:panelGroup rendered="#{permission.item.type == 3 && (ForumTool.selectedForum.restrictPermissionsForGroups || ForumTool.selectedTopic.restrictPermissionsForGroups)}">
					<h:outputLabel for="level" styleClass="sakai-form-label"><h:outputText value="#{permission.name}" id="perm_role_label1" /></h:outputLabel>
				</h:panelGroup>
				<h:panelGroup rendered="#{!(ForumTool.selectedForum.restrictPermissionsForGroups || ForumTool.selectedTopic.restrictPermissionsForGroups) || permission.item.type != 3}">
					<h:outputLabel for="level" styleClass="sakai-form-label"><h:outputText value="#{permission.name}" id="perm_role_label2" /></h:outputLabel>
				</h:panelGroup>
			</h:column>
			<h:column>
				<f:facet name="header">
					<h:outputText value="#{msgs.perm_level}"/>
				</f:facet>
				<h:panelGroup rendered="#{permission.item.type == 3 && (ForumTool.selectedForum.restrictPermissionsForGroups || ForumTool.selectedTopic.restrictPermissionsForGroups)}">
					<h:outputText value="#{permission.selectedLevel}" />
				</h:panelGroup>
				<h:panelGroup rendered="#{!(ForumTool.selectedForum.restrictPermissionsForGroups || ForumTool.selectedTopic.restrictPermissionsForGroups) || permission.item.type != 3}">
					<h:selectOneMenu id="level" value="#{permission.selectedLevel}" onchange="javascript:setCorrespondingCheckboxes(this.id);" disabled="#{not ForumTool.editMode}" styleClass="sakai-form-control">
						<f:selectItems value="#{ForumTool.levels}"/>
					</h:selectOneMenu>
				</h:panelGroup>
			</h:column>
			<h:column>
				<f:facet name="header">
					<h:outputText value="#{msgs.perm_customize}" styleClass="visually-hidden"/>
				</f:facet>
				<h:panelGroup rendered="#{!(ForumTool.selectedForum.restrictPermissionsForGroups || ForumTool.selectedTopic.restrictPermissionsForGroups) || permission.item.type != 3}" layout="block" styleClass="sakai-forums__permission-customize-wrap">
					<h:panelGroup id="customize" styleClass="permissionCustomize sakai-forums__permission-customize">
						<h:outputText value="#{msgs.perm_customize}" />
					</h:panelGroup>
					<div class="permissionPanel sakai-forums__permission-panel">
						<div class="sakai-form-choice-group">
							<div class="sakai-form-choice">
								<h:selectBooleanCheckbox id="newForum" onclick="javascript:setCorrespondingLevel(this.id);" value="#{permission.newForum}" disabled="#{not ForumTool.editMode || ForumTool.permissionMode != 'template'}"/>
								<h:outputLabel for="newForum"><h:outputText id="newForum_label" value="#{msgs.perm_new_forum}" /></h:outputLabel>
							</div>
							<div class="sakai-form-choice">
								<h:selectBooleanCheckbox id="newTopic" onclick="javascript:setCorrespondingLevel(this.id);" value="#{permission.newTopic}" disabled="#{not ForumTool.editMode || ForumTool.permissionMode == 'topic'}"/>
								<h:outputLabel for="newTopic"><h:outputText id="newTopic_label" value="#{msgs.perm_new_topic}" /></h:outputLabel>
							</div>
							<div class="sakai-form-choice">
								<h:selectBooleanCheckbox id="newR" value="#{permission.newResponse}" onclick="javascript:setCorrespondingLevel(this.id);" disabled="#{not ForumTool.editMode}"/>
								<h:outputLabel for="newR"><h:outputText id="newR_label" value="#{msgs.perm_new_response}" /></h:outputLabel>
							</div>
							<div class="sakai-form-choice">
								<h:selectBooleanCheckbox id="newRtoR" value="#{permission.responseToResponse}" onclick="javascript:setCorrespondingLevel(this.id);" disabled="#{not ForumTool.editMode}"/>
								<h:outputLabel for="newRtoR"><h:outputText id="newRtoR_label" value="#{msgs.perm_response_to_response}" /></h:outputLabel>
							</div>
							<h:panelGroup layout="block" styleClass="sakai-form-choice" rendered="#{ForumTool.gradebookExist}">
								<h:selectBooleanCheckbox id="postGrades" onclick="javascript:setCorrespondingLevel(this.id);" value="#{permission.postToGradebook}" disabled="#{not ForumTool.editMode}"/>
								<h:outputLabel for="postGrades"><h:outputText id="postGrades_label" value="#{msgs.perm_post_to_gradebook}" /></h:outputLabel>
							</h:panelGroup>
						</div>
						<div class="sakai-form-choice-group">
							<div class="sakai-form-choice">
								<h:selectBooleanCheckbox id="changeSetting" value="#{permission.changeSettings}" onclick="javascript:setCorrespondingLevel(this.id);" disabled="#{not ForumTool.editMode}"/>
								<h:outputLabel for="changeSetting"><h:outputText id="changeSetting_label" value="#{msgs.perm_change_settings}" /></h:outputLabel>
							</div>
							<div class="sakai-form-choice">
								<h:selectBooleanCheckbox id="read" onclick="javascript:setCorrespondingLevel(this.id);" value="#{permission.read}" disabled="#{not ForumTool.editMode}"/>
								<h:outputLabel for="read"><h:outputText id="read_label" value="#{msgs.perm_read}" /></h:outputLabel>
							</div>
							<div class="sakai-form-choice">
								<h:selectBooleanCheckbox id="markAsNotRead" value="#{permission.markAsNotRead}" onclick="javascript:setCorrespondingLevel(this.id);" disabled="#{not ForumTool.editMode}"/>
								<h:outputLabel for="markAsNotRead"><h:outputText id="markAsNotRead_label" value="#{msgs.perm_mark_as_not_read}" /></h:outputLabel>
							</div>
							<div class="sakai-form-choice">
								<h:selectBooleanCheckbox id="moderatePostings" value="#{permission.moderatePostings}" onclick="javascript:setCorrespondingLevel(this.id);" disabled="#{(not ForumTool.editMode) || ForumTool.disableModeratePerm}"/>
								<h:outputLabel for="moderatePostings"><h:outputText id="moderatePostings_label" value="#{msgs.perm_moderate_postings}" /></h:outputLabel>
							</div>
							<h:panelGroup layout="block" styleClass="#{ForumTool.anonymousEnabled ? 'sakai-form-choice' : 'sakai-form-choice display-none'}">
								<h:selectBooleanCheckbox id="identifyAnonAuthors" value="#{permission.identifyAnonAuthors}" onclick="setCorrespondingLevel(this.id);" disabled="#{not ForumTool.editMode}"/>
								<h:outputLabel for="identifyAnonAuthors"><h:outputText id="identifyAnonAuthors_label" value="#{msgs.perm_identify_anon_authors}" /></h:outputLabel>
							</h:panelGroup>
						</div>
						<div class="sakai-form-field">
							<span class="sakai-form-label"><h:outputText value="#{msgs.perm_revise_postings}" id="revisePostings_label"/></span>
							<h:selectOneRadio id="revisePostings" value="#{permission.revisePostings}" layout="pageDirection" onclick="setCorrespondingLevel(this.name);" disabled="#{not ForumTool.editMode}" styleClass="sakai-form-choice-group selectOneRadio">
								<f:selectItems value="#{ForumTool.postingOptions}" />
							</h:selectOneRadio>
						</div>
						<div class="sakai-form-field">
							<span class="sakai-form-label"><h:outputText value="#{msgs.perm_delete_postings}" id="deletePostings_label"/></span>
							<h:selectOneRadio id="deletePostings" value="#{permission.deletePostings}" layout="pageDirection" onclick="setCorrespondingLevel(this.name);" disabled="#{not ForumTool.editMode}" styleClass="sakai-form-choice-group selectOneRadio">
								<f:selectItems value="#{ForumTool.postingOptions}" />
							</h:selectOneRadio>
						</div>
					</div>
				</h:panelGroup>
			</h:column>
		</h:dataTable>
	</div>
</details>
