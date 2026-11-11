 <%@ page import="java.util.*, jakarta.faces.context.*, jakarta.faces.application.*,
                 jakarta.faces.el.*, org.sakaiproject.tool.messageforums.*,
                 org.sakaiproject.api.app.messageforums.*,
                 org.sakaiproject.site.cover.SiteService,
                 org.sakaiproject.tool.messageforums.ui.MessageForumStatisticsBean,
                 org.sakaiproject.tool.cover.ToolManager" %>
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
 	
	FacesContext context = FacesContext.getCurrentInstance();
	Application app = context.getApplication();
	ValueBinding binding = app.createValueBinding("#{mfStatisticsBean}");
	MessageForumStatisticsBean statsBean = (MessageForumStatisticsBean) binding.getValue(context);
	statsBean.setDefaultSelectedAssign();
 	
%>
<f:view>
  <sakai:view >
    <script>includeWebjarLibrary('awesomplete')</script>
    <script src="/library/js/sakai-reminder.js"></script>
  	<h:form id="dfStatisticsForm" rendered="#{ForumTool.instructor}">
<!-- discussionForum/statistics/dfStatisticsList.jsp-->
	<script>

	
			var iframeId = '<%= org.sakaiproject.util.Web.escapeJavascript(thisId)%>';
			
			function resize(){
				mySetMainFrameHeight('<%= org.sakaiproject.util.Web.escapeJavascript(thisId)%>');
			}
		
		
			function mySetMainFrameHeight(id)
			{
				// run the script only if this window's name matches the id parameter
				// this tells us that the iframe in parent by the name of 'id' is the one who spawned us
				if (typeof window.name != "undefined" && id != window.name) return;
			
				var frame = parent.document.getElementById(id);
				if (frame)
				{
			
					var objToResize = (frame.style) ? frame.style : frame;
			  
			    // SAK-11014 revert           if ( false ) {
			
					var height; 		
					var offsetH = document.body.offsetHeight;
					var innerDocScrollH = null;
			
					if (typeof(frame.contentDocument) != 'undefined' || typeof(frame.contentWindow) != 'undefined')
					{
						// very special way to get the height from IE on Windows!
						// note that the above special way of testing for undefined variables is necessary for older browsers
						// (IE 5.5 Mac) to not choke on the undefined variables.
			 			var innerDoc = (frame.contentDocument) ? frame.contentDocument : frame.contentWindow.document;
						innerDocScrollH = (innerDoc != null) ? innerDoc.body.scrollHeight : null;
					}
				
					if (document.all && innerDocScrollH != null)
					{
						// IE on Windows only
						height = innerDocScrollH;
					}
					else
					{
						// every other browser!
						height = offsetH;
					}
			   // SAK-11014 revert		} 
			
			   // SAK-11014 revert             var height = getFrameHeight(frame);
			
					// here we fudge to get a little bigger
					var newHeight = height + 40;
			
					// but not too big!
					if (newHeight > 32760) newHeight = 32760;
			
					// capture my current scroll position
					var scroll = findScroll();
			
					// resize parent frame (this resets the scroll as well)
					objToResize.height=newHeight + "px";
			
					// reset the scroll, unless it was y=0)
					if (scroll[1] > 0)
					{
						var position = findPosition(frame);
						parent.window.scrollTo(position[0]+scroll[0], position[1]+scroll[1]);
					}
				}
			}			
			
			function dialogLinkClick(link){
				dialogutil.openDialog('dialogDiv', 'dialogFrame');
			}
			var warn = false;
			window.onbeforeunload = function (evt) {
				if(warn && '<h:outputText value="#{mfStatisticsBean.selectedAssign}"/>' != 'Default_0'){
					var message = "<h:outputText value="#{msgs.confirm_navigation}" escape="false"/>";
					if (typeof evt == "undefined") {
					evt = window.event;
					}
					if (evt) {
					evt.returnValue = message;
					}
					return message;
				}
			}
		</script>
			<script>includeLatestJQuery("msgcntr");</script>
			<script src="/messageforums-tool/js/dialog.js"></script>
			<script src="/library/js/spinner.js"></script>
		<script>
			function initGbSelector(gbSelectorId, inputId) {
				const input = document.getElementById(inputId);
				const gbSelector = document.getElementById(gbSelectorId);
				if (input && gbSelector) {
					gbSelector.addEventListener("change", (event) => {
						const gbs = event.detail?.[0];
						if (gbs) {
							// Ids of the gbs separated by comma
							const gbIds = gbs.map(gb => gb.id);
							input.value = gbIds.join(",");
							// Call callback function if present
							callbackFn?.(gbIds);
						}
					});
				} else {
					if (!gbSelector) {
						console.error(`GB selector with id ${gbSelectorId} not found`);
					}

					if (!input) {
						console.error(`Input with id ${inputId} not found`);
					}
				}

				// Return the gbIds of the inputs initial value
				return input?.value?.split(",").filter(gbId => gbId != "") ?? null;
			}
			function toggleComments(link){
				if(link.innerHTML == "<h:outputText value="#{msgs.stat_forum_comments_show}" escape="false"/>"){
					$('.awesomplete').fadeIn();
					$('.commentsHidden').fadeOut();
					link.innerHTML = '<h:outputText value="#{msgs.stat_forum_comments_hide}"/>';
				}else{
					$('.awesomplete').fadeOut();
					$('.commentsHidden').fadeIn();
					link.innerHTML = '<h:outputText value="#{msgs.stat_forum_comments_show}"/>';
				}
				
				resize();
			}

			function applyDefaultToUngraded(value){
				$('.gradeInput').each(function(){
					if($(this).val() == null || $(this).val() == ''){
						$(this).val($('.defaultValue').val());
					}
				});

				dialogutil.showDiv('gradesNeedSaved');
			}

			$(document).ready(function() {
				$('.selAssignVal').val('<h:outputText value="#{mfStatisticsBean.selectedAssign}"/>');
				const sakaiReminder = new SakaiReminder();
                                $('textarea.awesomplete').each(function () {
                                    new Awesomplete(this, {
                                         list: sakaiReminder.getAll()
                                    });
                                });
                                $('#dfStatisticsForm').submit(function (e) {
                                  $('textarea.awesomplete').each(function () {
                                    sakaiReminder.new($(this).val());
                                  });
                                });
			});
		</script>
        <% request.setAttribute("dfHeaderView", "statisticsForumTopic"); %>
<% request.setAttribute("dfHeaderBack", "statisticsByTopic"); %>
<%@ include file="/jsp/discussionForum/menu/forumsHeader.jsp" %>
		
		<div class="modal fade sakai-forums__grade-modal" id="dialogDiv" data-dialog-frame="dialogFrame" tabindex="-1" role="dialog" aria-modal="true" aria-hidden="true" aria-labelledby="dialogDivLabel">
			<div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
				<div class="modal-content">
					<div class="modal-header">
						<h2 class="modal-title" id="dialogDivLabel">
							<h:outputText value="#{msgs.cdfm_grade_msg}" />
						</h2>
						<button type="button" class="btn-close" data-bs-dismiss="modal">
							<span class="visually-hidden"><h:outputText value="#{msgs.close_window}" /></span>
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
		<div class="sakai-banner sakai-banner--success" id="gradesSavedDiv" style="display:none">
	  		<h:outputText value="#{msgs.cdfm_grade_successful}"/>
	  	</div>
		<div class="sakai-banner sakai-banner--info" id="gradesNeedSaved" style="display:none">
	  		<h:outputText value="#{msgs.stat_forum_default_grade_info}"/>
	  	</div>
		
		<h:panelGroup rendered="#{mfStatisticsBean.gradingService.isGradebookGroupEnabled(ForumTool.siteId)}">
			<h:panelGroup styleClass="sakai-banner sakai-banner--error" rendered="#{mfStatisticsBean.selectMoreThanOneItem}">
				<h:outputText value="#{msgs.cdfm_gradebook_group_selector_error}" />
			</h:panelGroup>
			<h:panelGroup styleClass="sakai-banner sakai-banner--warn">
				<h:outputText value="#{msgs.cdfm_gradebook_group_selector_instructions}" />
			</h:panelGroup>
		</h:panelGroup>
	  	<h:messages globalOnly="true" infoClass="sakai-banner sakai-banner--success" errorClass="sakai-banner sakai-banner--error" rendered="#{! empty facesContext.maximumSeverity}"/>

      <div class="sakai-table-toolbar sakai-no-print">
        <div class="sakai-table-toolbar__filters">
			<h:panelGroup rendered="#{!mfStatisticsBean.gradingService.isGradebookGroupEnabled(ForumTool.siteId)}">
				<label class="sakai-form-label" for="dfStatisticsForm:assignment"><h:outputText value="#{msgs.cdfm_select_assign}"/></label>
				<h:selectOneMenu id="assignment" value="#{mfStatisticsBean.selectedAssign}" valueChangeListener="#{mfStatisticsBean.processGradeAssignChange}" styleClass="selAssignVal sakai-form-control sakai-form-control--sm"
				onchange="document.forms[0].submit();">
				<f:selectItems value="#{mfStatisticsBean.assignments}" />
				</h:selectOneMenu>
			</h:panelGroup>
          <h:panelGroup rendered="#{!empty mfStatisticsBean.cachedGroupsForStatisticsByTopic}">
	      	<label class="sakai-form-label" for="dfStatisticsForm:grade"><h:outputText value="#{msgs.filter_by_group}"/></label>
			<h:selectOneMenu id="grade" value="#{mfStatisticsBean.selectedGroup}" valueChangeListener="#{mfStatisticsBean.processGroupChange}" styleClass="sakai-form-control sakai-form-control--sm" onchange="document.forms[0].submit();">
	           <f:selectItems value="#{mfStatisticsBean.cachedGroupsForStatisticsByTopic}" />
	        </h:selectOneMenu>
          </h:panelGroup>
        </div>
      </div>
        
	  	
	  	<f:subview id="defaultValueView" rendered="#{mfStatisticsBean.selectedAssign != 'Default_0'}">
	  		<div class="sakai-table-toolbar sakai-no-print">
	  			<h:inputText styleClass="defaultValue sakai-form-control sakai-form-control--sm" size="5" value="0" onkeyup="warn = true;"/>
          		<f:verbatim>
          			<input type="button" class="sakai-btn sakai-btn-secondary" onclick="applyDefaultToUngraded();" value="</f:verbatim><h:outputText value="#{msgs.stat_forum_default_grade}"/><f:verbatim>"/>
          		</f:verbatim>
          	</div>
	  	</f:subview>
	  	
		<h:panelGroup layout="block" rendered="#{mfStatisticsBean.gradingService.isGradebookGroupEnabled(ForumTool.siteId) && !mfStatisticsBean.discussionGeneric}" id="multigradebook-group-container" styleClass="sakai-table-toolbar sakai-no-print">
			<div class="sakai-table-toolbar__filters">
				<sakai-gradebook-item-selector
					id="gb-selector" input-id="dfStatisticsForm:gb_selector"
					site-id='<h:outputText value="#{ForumTool.siteId}" />'
					user-id='<h:outputText value="#{ForumTool.userId}" />'
					group-id='<h:outputText value="#{mfStatisticsBean.groupId}" />'
					selected-temp='<h:outputText value="Hey" />'>
				</sakai-gradebook-item-selector>
				<h:inputHidden 
					id="gb_selector" 
					value="#{mfStatisticsBean.selectedAssign}" 
				/>
				<h:commandButton action="#{mfStatisticsBean.proccessActionGradeAssignsChangeSubmit}" value="#{msgs.cdfm_gradebook_group_selector_send_button}" accesskey="s" styleClass="sakai-btn sakai-btn-secondary"
				onclick="warn = false;SPNR.disableControlsAndSpin( this, null );"/>
			</div>
		</h:panelGroup>
	  	
		<%--
			Use cahcedTopicStatistics - value is cached from #{!empty mfStatisticsBean.groupForStatisticsByTopic} above.
			Retrieve the topic statistics, then clear the cache since dfStatisticsBean is scoped to the session, and we don't want this data to persist for future requests
		--%>
		<div class="sakai-table-wrap">
  		<h:dataTable styleClass="sakai-table sakai-table--hover sakai-table--stack" id="members" value="#{mfStatisticsBean.gradeStatisticsForStatsListByTopic}" var="stat" rendered="true"
   	 		columnClasses="sakai-table__primary,bogus,sakai-table__actions" cellpadding="0" cellspacing="0">
  			<h:column>
  				<f:facet name="header">
  					<h:commandLink action="#{mfStatisticsBean.toggleTopicNameSort}" title="#{mfStatisticsBean.pureAnon ? msgs.stat_anon_user : msgs.stat_name}">
					   	<h:outputText value="#{mfStatisticsBean.pureAnon ? msgs.stat_anon_user : msgs.stat_name}" />
						<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.nameSort && mfStatisticsBean.ascending}"/>
						<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.nameSort && !mfStatisticsBean.ascending}"/>
					</h:commandLink>
  				</f:facet>
  				<h:outputLink value="/tool/#{ForumTool.currentToolId}/discussionForum/statistics/dfStatisticsAllAuthoredMsgForOneUser" target="dialogFrame"
					onclick="dialogLinkClick(this);">
					<f:param value="#{stat.siteUserId}" name="siteUserId"/>
  				    <f:param value="dialogDiv" name="dialogDivId"/>
					<f:param value="dialogFrame" name="frameId"/>
					<h:outputText rendered="#{!stat.useAnonId}" value="#{stat.siteUser}" />
					<h:outputText rendered="#{stat.useAnonId}" value="#{stat.siteAnonId}" styleClass="anonymousAuthor"/>
				</h:outputLink>
			</h:column>
			<h:column rendered="#{!mfStatisticsBean.pureAnon}">
				<f:facet name="header">
					<h:commandLink action="#{mfStatisticsBean.toggleTopicIdSort}" title="#{msgs.stat_eid}">
						<h:outputText value="#{msgs.stat_eid}" />
						<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.idSort && mfStatisticsBean.ascending}"/>
						<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.idSort && !mfStatisticsBean.ascending}"/>
					</h:commandLink>
				</f:facet>
				<h:outputLink value="/tool/#{ForumTool.currentToolId}/discussionForum/statistics/dfStatisticsAllAuthoredMsgForOneUser" target="dialogFrame" onclick="dialogLinkClick(this);">
					<f:param value="#{stat.siteUserId}" name="siteUserId"/>
					<f:param value="dialogDiv" name="dialogDivId"/>
					<f:param value="dialogFrame" name="frameId"/>
					<h:outputText value="#{stat.siteUserDisplayId}" />
				</h:outputLink>
			</h:column>
			<h:column>
  				<f:facet name="header">
					<h:outputText value="#{msgs.pvt_more_actions}" styleClass="visually-hidden"/>
  				</f:facet>
				<h:panelGroup layout="block" styleClass="sakai-row-actions">
					<details class="sakai-overflow-menu">
						<summary class="sakai-overflow-menu__toggle">
							<span class="si si-three-dots" aria-hidden="true"></span>
							<span class="visually-hidden"><h:outputText value="#{msgs.pvt_more_actions}"/></span>
						</summary>
						<div class="sakai-overflow-menu__panel">
							<h:commandLink action="#{mfStatisticsBean.processActionStatisticsUser}" immediate="true">
								<f:param value="#{stat.siteUserId}" name="siteUserId"/>
								<h:outputText value="#{msgs.stat_forum_details}" />
							</h:commandLink>
							<h:outputLink value="/tool/#{ForumTool.currentToolId}/discussionForum/message/dfMsgGrade" target="dialogFrame"
									onclick="dialogLinkClick(this);"
									rendered="#{mfStatisticsBean.selectedAssign == 'Default_0' && mfStatisticsBean.discussionGeneric}">
								<f:param value="#{mfStatisticsBean.selectedAllTopicsForumId}" name="forumId"/>
								<f:param value="#{mfStatisticsBean.selectedAllTopicsTopicId}" name="topicId"/>
								<f:param value="#{stat.siteUserId}" name="userId"/>
								<f:param value="" name="messageId"/>
								<f:param value="dialogDiv" name="dialogDivId"/>
								<f:param value="dialogFrame" name="frameId"/>
								<f:param value="gradesSavedDiv" name="gradesSavedDiv"/>
								<h:outputText value="#{msgs.cdfm_button_bar_grade}" />
							</h:outputLink>
						</div>
					</details>
				</h:panelGroup>
  			</h:column>
  			<h:column>
                            <f:facet name="header">
                                <h:commandLink action="#{mfStatisticsBean.toggleTopicAuthoredNewSort}" title="#{msgs.stat_authored_new}">
                                    <h:outputText value="#{msgs.stat_authored_new}" />
                                    <h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.authoredNewSort && mfStatisticsBean.ascending}"/>
                                    <h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.authoredNewSort && !mfStatisticsBean.ascending}"/>
                                </h:commandLink>
                            </f:facet>
                            <h:outputText value="#{stat.authoredForumsNewAmt}" />
                        </h:column>
                        <h:column>
                            <f:facet name="header">
                                <h:commandLink action="#{mfStatisticsBean.toggleTopicAuthoredRepliesSort}" title="#{msgs.stat_authored_replies}">
                                    <h:outputText value="#{msgs.stat_authored_replies}" />
                                    <h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.authoredRepliesSort && mfStatisticsBean.ascending}"/>
                                    <h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.authoredRepliesSort && !mfStatisticsBean.ascending}"/>
                                </h:commandLink>
                            </f:facet>
                            <h:outputText value="#{stat.authoredForumsRepliesAmt}" />
                        </h:column>
  			<h:column>
  				<f:facet name="header">
  					<h:commandLink action="#{mfStatisticsBean.toggleTopicAuthoredSort}" title="#{msgs.stat_authored_total}">
					   	<h:outputText value="#{msgs.stat_authored_total}" />
						<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.authoredSort && mfStatisticsBean.ascending}"/>
						<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.authoredSort && !mfStatisticsBean.ascending}"/>
					</h:commandLink>
  				</f:facet>
  				<h:outputText value="#{stat.authoredForumsAmt}" />
  			</h:column>
  			<h:column>
  				<f:facet name="header">
  					<h:commandLink action="#{mfStatisticsBean.toggleTopicReadSort}" title="#{msgs.stat_read}">
					   	<h:outputText value="#{msgs.stat_read}" />
						<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.readSort && mfStatisticsBean.ascending}"/>
						<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.readSort && !mfStatisticsBean.ascending}"/>
					</h:commandLink>
  				</f:facet>
  				<h:outputText value="#{stat.readForumsAmt}" />
  			</h:column>
  			<h:column>
  				<f:facet name="header">
  					<h:commandLink action="#{mfStatisticsBean.toggleTopicUnreadSort}" title="#{msgs.stat_unread}">
					   	<h:outputText value="#{msgs.stat_unread}" />
						<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.unreadSort && mfStatisticsBean.ascending}"/>
						<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.unreadSort && !mfStatisticsBean.ascending}"/>
					</h:commandLink>
  				</f:facet>
  				<h:outputText value="#{stat.unreadForumsAmt}" />
  			</h:column>
  			<h:column>
  				<f:facet name="header">
  					<h:commandLink action="#{mfStatisticsBean.toggleTopicPercentReadSort}" title="#{msgs.stat_percent_read}">
					   	<h:outputText value="#{msgs.stat_percent_read}" />
						<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.percentReadSort && mfStatisticsBean.ascending}"/>
						<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.percentReadSort && !mfStatisticsBean.ascending}"/>
					</h:commandLink>
  				</f:facet>
  				<h:outputText value="#{stat.percentReadForumsAmt}">
  					<f:convertNumber type="percent" />
  				</h:outputText>
  			</h:column>
  			<h:column rendered="#{mfStatisticsBean.selectedAssign != 'Default_0'}">
  				<f:facet name="header">
  					<h:commandLink action="#{mfStatisticsBean.toggleTopicGradeSort}" title="#{mfStatisticsBean.selAssignName}">
					   	<h:outputText value="#{mfStatisticsBean.selAssignName}" />
						<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.gradeSort && mfStatisticsBean.ascending}"/>
						<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.gradeSort && !mfStatisticsBean.ascending}"/>
						<f:verbatim><br/></f:verbatim>
						<h:outputFormat value=" #{msgs.cdfm_points_possible}" rendered="#{mfStatisticsBean.gradeByPoints}">
							<f:param value="#{mfStatisticsBean.gbItemPointsPossible.split(',')[0]}"/>
						</h:outputFormat>
					</h:commandLink>
  				</f:facet>
  				<h:inputText size="5" value="#{stat.gradebookAssignment.score}" rendered="#{stat.gradebookAssignment.allowedToGrade}" styleClass="gradeInput" onkeyup="warn = true;"/>
  				<h:outputText value="#{msgs.stat_forum_na}" rendered="#{!stat.gradebookAssignment.allowedToGrade}"/>
  				<h:outputText value=" %" rendered="#{mfStatisticsBean.gradeByPercent && stat.gradebookAssignment.allowedToGrade}" />
  			</h:column>
  			<h:column rendered="#{mfStatisticsBean.selectedAssign != 'Default_0'}"	>
  				<f:facet name="header">  		
			  		<h:outputLink id="toggleComments" onclick="toggleComments(this); return null;" value="#">
			  			<h:outputText value="#{msgs.stat_forum_comments_show}"/>
			  		</h:outputLink>
			  			
			  				  		  				
  				</f:facet>
  				<h:inputTextarea rows="4" cols="35" value="#{stat.gradebookAssignment.comment}" style="display:none" styleClass="comments awesomplete" rendered="#{stat.gradebookAssignment.allowedToGrade}" onkeyup="warn = true"/>
  				<h:outputText value="#{msgs.stat_forum_comments_hidden}" styleClass="commentsHidden" rendered="#{stat.gradebookAssignment.allowedToGrade}"/>
  				<h:outputText value="#{msgs.stat_forum_na}" rendered="#{!stat.gradebookAssignment.allowedToGrade}"/>
  			</h:column>
  		</h:dataTable>
  		</div>
		<h:panelGroup layout="block" styleClass="sakai-actions" rendered="#{mfStatisticsBean.selectedAssign != 'Default_0'}">
		  	<h:commandButton action="#{mfStatisticsBean.proccessActionSubmitGrades}" value="#{msgs.stat_forum_submit_grades}" accesskey="s" styleClass="sakai-btn sakai-btn-primary"
		  		onclick="warn = false;SPNR.disableControlsAndSpin( this, null );" />
		  	<h:commandButton value="#{msgs.stat_forum_submit_grades_cancel}" accesskey="x" styleClass="sakai-btn sakai-btn-ghost"
		  		onclick="warn = false;SPNR.disableControlsAndSpin( this, null );" />
		</h:panelGroup>
  	</h:form>
  </sakai:view>
</f:view>
