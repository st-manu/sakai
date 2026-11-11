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
   <sakai:view title="#{msgs.watch_forums_options}">
      <h:form id="revise" styleClass="sakai-forums">
        		<script>includeLatestJQuery("msgcntr");</script>
       		<script src="/messageforums-tool/js/sak-10625.js"></script>
       		<script src="/messageforums-tool/js/messages.js"></script>
          <script>
              $(document).ready(function() {
                  $('#revise\\:emailNotificationOption1, #revise\\:emailNotificationOption2, #revise\\:emailNotificationOption3').each(function() {
                       let label = $('#revise\\:notify_for_all_postings_head').text() + " " + $(this).next().text();
                       $(this).attr('aria-label', label);
                  });
              });
          </script>
				<% request.setAttribute("dfHeaderTitleKey", "watch_forums_options"); %>
<% request.setAttribute("dfHeaderBack", "discussions"); %>
<%@ include file="/jsp/discussionForum/menu/forumsHeader.jsp" %>
<!--jsp/discussionForum/area/dfWatchSettings.jsp-->

		<p class="sakai-form-section__intro">
			<h:outputText escape="false" value="#{msgs.watch_forums_options_instruction}" />
		</p>
		<p class="sakai-banner sakai-banner--info">
			<h:outputText escape="false" value="#{msgs.watch_forums_options_instruction_note}" />
		</p>

		<div class="sakai-form-section">
			<h:outputText id="notify_for_all_postings_head" styleClass="sakai-form-section__title" escape="false" value="#{msgs.notify_for_all_postings_head}" />
			<div class="sakai-form-field">
				<div class="sakai-form-choice-group" role="radiogroup" aria-labelledby="revise:notify_for_all_postings_head">
					<div class="sakai-form-choice">
						<h:selectOneRadio id="emailNotificationOption1" group="emailNotificationOption" value="#{ForumTool.watchSettingsBean.emailNotification.notificationLevel}">
							<f:selectItem itemValue="2" itemLabel="#{msgs.notify_for_all_postings}"/>
						</h:selectOneRadio>
					</div>
					<div class="sakai-form-choice">
						<h:selectOneRadio id="emailNotificationOption2" group="emailNotificationOption" value="#{ForumTool.watchSettingsBean.emailNotification.notificationLevel}">
							<f:selectItem itemValue="1" itemLabel="#{msgs.notify_for_postings_to_my_thread}"/>
						</h:selectOneRadio>
					</div>
					<div class="sakai-form-choice">
						<h:selectOneRadio id="emailNotificationOption3" group="emailNotificationOption" value="#{ForumTool.watchSettingsBean.emailNotification.notificationLevel}">
							<f:selectItem itemValue="0" itemLabel="#{msgs.notify_none}"/>
						</h:selectOneRadio>
					</div>
				</div>
			</div>
		</div>

        <div class="sakai-actions">
          <h:commandButton action="#{ForumTool.processActionSaveEmailNotificationOption}"
                           value="#{msgs.cdfm_button_bar_save_setting}"
                           accesskey="r"
						   styleClass="sakai-btn sakai-btn-primary"/>
          <h:commandButton action="#{ForumTool.processActionHome}"
                           value="#{msgs.cdfm_button_bar_cancel}"
                           accesskey="x"
                           styleClass="sakai-btn sakai-btn-ghost"/>
       </div>
	  </h:form>
    </sakai:view>
</f:view>
