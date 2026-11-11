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
	<sakai:view title="#{msgs.cdfm_default_template_settings}">
	<h:form id="revise" styleClass="sakai-forums">
        <script>includeLatestJQuery("msgcntr");</script>
		<script src="/messageforums-tool/js/datetimepicker.js"></script>
       		<script src="/messageforums-tool/js/sak-10625.js"></script>
		<script src="/messageforums-tool/js/permissions_header.js"></script>
		<script src="/messageforums-tool/js/forum.js"></script>
		<script src="/messageforums-tool/js/messages.js"></script>
		<link href="/library/webjars/jquery-ui/1.12.1/jquery-ui.min.css" rel="stylesheet" type="text/css" />
		<script src="/library/js/lang-datepicker/lang-datepicker.js"></script>

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

         $(document).ready(function() {
             $('#revise\\:moderated\\:0, #revise\\:moderated\\:1').each(function() {
                     let label = $('#revise\\:forumPostingLabel1').text() + " " + $('#revise\\:outputLabel4').text() + " " + $(this).next().text();
                     $(this).attr('aria-label', label);
              });
              $('#revise\\:postFirst\\:0, #revise\\:postFirst\\:1').each(function() {
                      let label = $('#revise\\:forumPostingLabel1').text() + " " + $('#revise\\:outputLabel15').text() + " " + $(this).next().text();
                      $(this).attr('aria-label', label);
              });
              $('#revise\\:autoMarkThreadsRead\\:0, #revise\\:autoMarkThreadsRead\\:1').each(function() {
                       let label = $('#revise\\:outputLabel5').text() + " " + $(this).next().text();
                       $(this).attr('aria-label', label);
              });
              $('#revise\\:availabilityRestricted\\:0, #revise\\:availabilityRestricted\\:1').each(function() {
                        let label = $('#revise\\:forumAvailabilityLabel').text() + " " + $(this).next().text();
                        $(this).attr('aria-label', label);
              });

         });

	</script> 
<script>
	function setDatesEnabled(radioButton){
		$(".openDateSpan").toggle();
		$(".closeDateSpan").toggle();
		$(".lockForumAfterCloseDateSpan").toggle();
		resize();
	}

	function openDateCal(){
			NewCal('revise:openDate','MMDDYYYY',true,12, '<h:outputText value="#{ForumTool.defaultAvailabilityTime}"/>');
	}

	function closeDateCal(){
			NewCal('revise:closeDate','MMDDYYYY',true,12, '<h:outputText value="#{ForumTool.defaultAvailabilityTime}"/>');
	}
</script>

<!--jsp/discussionForum/area/dfTemplateSettings.jsp-->


				<% request.setAttribute("dfHeaderTitleKey", "cdfm_default_template_settings"); %>
<% request.setAttribute("dfHeaderBack", "discussions"); %>
<%@ include file="/jsp/discussionForum/menu/forumsHeader.jsp" %>

		 		<p class="sakai-form-section__intro">
		  		  <h:outputText id="instruction" value="#{msgs.cdfm_default_template_settings_instruction}"/>
				</p>
				<h:messages styleClass="sakai-banner sakai-banner--error" id="errorMessages" rendered="#{! empty facesContext.maximumSeverity}" />

				<div class="sakai-form-section">
					<h:outputText id="forumPostingLabel1" value="#{msgs.cdfm_forum_posting}" styleClass="sakai-form-section__title"/>
					<div class="sakai-form-field">
						<h:outputText id="outputLabel4" value="#{msgs.cdfm_moderate_forums}" styleClass="sakai-form-label"/>
						<h:selectOneRadio layout="pageDirection" disabled="#{not ForumTool.editMode}" id="moderated" value="#{ForumTool.template.moderated}"
							styleClass="sakai-form-choice-group" onclick="javascript:disableOrEnableModeratePerm();">
							<f:selectItem itemValue="true" itemLabel="#{msgs.cdfm_yes}"/>
							<f:selectItem itemValue="false" itemLabel="#{msgs.cdfm_no}"/>
						</h:selectOneRadio>
					</div>
					<div class="sakai-form-field">
						<h:outputText id="outputLabel15" value="#{msgs.cdfm_postFirst}" styleClass="sakai-form-label"/>
						<h:selectOneRadio layout="pageDirection" disabled="#{not ForumTool.editMode}" id="postFirst" value="#{ForumTool.template.postFirst}"
							styleClass="sakai-form-choice-group">
							<f:selectItem itemValue="true" itemLabel="#{msgs.cdfm_yes}"/>
							<f:selectItem itemValue="false" itemLabel="#{msgs.cdfm_no}"/>
						</h:selectOneRadio>
					</div>
				</div>

				<div class="sakai-form-section">
					<h:outputText id="forumAvailabilityLabel" value="#{msgs.cdfm_forum_availability}" styleClass="sakai-form-section__title"/>
					<div class="sakai-form-field">
						<h:selectOneRadio layout="pageDirection" onclick="this.blur()" onchange="setDatesEnabled(this);" disabled="#{not ForumTool.editMode}" id="availabilityRestricted" value="#{ForumTool.template.availabilityRestricted}"
							styleClass="sakai-form-choice-group">
							<f:selectItem itemValue="false" itemLabel="#{msgs.cdfm_forum_avail_show}"/>
							<f:selectItem itemValue="true" itemLabel="#{msgs.cdfm_forum_avail_date}" />
						</h:selectOneRadio>
					</div>
					<h:panelGroup id="openDateSpan" layout="block" styleClass="sakai-form-field openDateSpan calWidget" style="display: #{ForumTool.template.availabilityRestricted ? 'block' : 'none'}">
						<h:outputLabel value="#{msgs.openDate}" for="openDate" styleClass="sakai-form-label"/>
						<h:inputText id="openDate" styleClass="openDate sakai-form-control" value="#{ForumTool.template.openDate}" />
					</h:panelGroup>
					<h:panelGroup id="closeDateSpan" layout="block" styleClass="sakai-form-field closeDateSpan calWidget" style="display: #{ForumTool.template.availabilityRestricted ? 'block' : 'none'}">
						<h:outputLabel value="#{msgs.closeDate}" for="closeDate" styleClass="sakai-form-label"/>
						<h:inputText id="closeDate" styleClass="closeDate sakai-form-control" value="#{ForumTool.template.closeDate}" />
					</h:panelGroup>
				</div>

				<script>
					localDatePicker({
						input:'.openDate',
						allowEmptyDate:true,
						ashidden: { iso8601: 'openDateISO8601' },
						val: document.querySelector('.openDate').value,
						useTime:1
					});
					localDatePicker({
						input:'.closeDate',
						allowEmptyDate:true,
						ashidden: { iso8601: 'closeDateISO8601' },
						val: document.querySelector('.closeDate').value,
						useTime:1
					});
				</script>

				<div class="sakai-form-section">
					<h:outputText id="forumMarkReadLabel" value="#{msgs.cdfm_forum_mark_read}" styleClass="sakai-form-section__title"/>
					<div class="sakai-form-field">
						<h:outputLabel id="outputLabel5" for="autoMarkThreadsRead" value="#{msgs.cdfm_auto_mark_threads_read}" styleClass="sakai-form-label"/>
						<h:selectOneRadio layout="pageDirection" disabled="#{not ForumTool.editMode}" id="autoMarkThreadsRead"
								value="#{ForumTool.template.autoMarkThreadsRead}" styleClass="sakai-form-choice-group"
								onclick="javascript:disableOrEnableModeratePerm();">
							<f:selectItem itemValue="true" itemLabel="#{msgs.cdfm_yes}"/>
							<f:selectItem itemValue="false" itemLabel="#{msgs.cdfm_no}"/>
						</h:selectOneRadio>
					</div>
				</div>

		 		<%@ include file="/jsp/discussionForum/permissions/permissions_include.jsp"%>

        <div class="sakai-actions">
          <h:commandButton action="#{ForumTool.processActionReviseTemplateSettings}"
                           value="#{msgs.cdfm_button_bar_revise}"
                           rendered="#{not ForumTool.editMode}"
                           accesskey="r"
						   styleClass="sakai-btn sakai-btn-primary"/>
          <h:commandButton action="#{ForumTool.processActionSaveTemplateSettings}"
                           onclick="form.submit;" value="#{msgs.cdfm_button_bar_save_setting}"
                           rendered="#{ForumTool.editMode}"
                           accesskey="s"
						   styleClass="sakai-btn sakai-btn-primary"/>
          <h:commandButton immediate="true"
                           action="#{ForumTool.processActionCancelTemplateSettings}"
                           value="#{msgs.cdfm_button_bar_cancel}"
                           accesskey="x"
                           styleClass="sakai-btn sakai-btn-ghost"/>
       </div>
	  </h:form>
    </sakai:view>
</f:view>
