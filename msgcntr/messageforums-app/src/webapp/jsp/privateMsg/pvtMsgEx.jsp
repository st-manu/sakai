<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf" %>
<%@ taglib uri="http://myfaces.apache.org/tomahawk" prefix="t"%>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>


<f:view>
	<sakai:view title="#{msgs.pvt_rcvd_msgs}">
<!--jsp/privateMsg/pvtMsgEx.jsp-->

		<script>includeLatestJQuery("msgcntr");</script>
		<script src="/messageforums-tool/js/sak-10625.js"></script>
		<script src="/messageforums-tool/js/forum.js"></script>
		<script src="/messageforums-tool/js/messages.js"></script>
		<script>includeWebjarLibrary('datatables');</script>
		<script>
				document.addEventListener('DOMContentLoaded', function() {

						// Initialize DataTables for search results
						const messagesTable = document.getElementById('prefs_pvt_form:pvtmsgs');
						if (messagesTable) {
							new DataTable(messagesTable, {
								"paging": false,
								// the search box above the table filters it, see setupMessagesSearch
								"layout": {"topEnd": null},
								"info": false,
								"order": [[4, "desc"]] // Sort by date column (index 4) in descending order
							});
						}

						// Initialize DataTables for threaded view if it exists
						const threadedMessagesTable = document.getElementById("prefs_pvt_form:threaded_pvtmsgs");
						if (threadedMessagesTable) {
							new DataTable(threadedMessagesTable, {
								"paging": false,
								// the search box above the table filters it, see setupMessagesSearch
								"layout": {"topEnd": null},
								"info": false,
								"order": [[4, "desc"]] // Sort by date column (index 4) in descending order
							});
						}
					});
		</script>

		<h:form id="prefs_pvt_form">
			<% request.setAttribute("pvtHeaderView", "search"); %>
			<%@ include file="/jsp/privateMsg/pvtToolHeader.jsp" %>

			<h:messages styleClass="sakai-banner sakai-banner--error" id="errorMessages" rendered="#{! empty facesContext.maximumSeverity}"/>
			<%@ include file="msgHeader.jsp"%>

	  <h:panelGroup layout="block" styleClass="sakai-table-wrap">
	  <h:dataTable styleClass="sakai-table sakai-table--hover sakai-table--stack sakai-messages__list" cellpadding="0" captionClass="visually-hidden" cellspacing="0"  id="pvtmsgs" width="100%" value="#{PrivateMessagesTool.searchPvtMsgs}" var="rcvdItems"
		rendered="#{PrivateMessagesTool.selectView != 'threaded'}" columnClasses="#{PrivateMessagesTool.calculateColumnClass()}">
		  <f:facet name="caption">
		    <h:outputText value="#{msgs.pvtMsgListSummary}" styleClass="visually-hidden"/>
		  </f:facet>
		  <h:column headerClass="sakai-table__select sakai-no-print">
		    <f:facet name="header">
				<h:panelGroup>
					<h:selectBooleanCheckbox id="checkAll" title="#{msgs.cdfm_checkall}"/>
					<h:outputLabel for="checkAll" styleClass="visually-hidden"><h:outputText value="#{msgs.cdfm_checkall}"/></h:outputLabel>
				</h:panelGroup>
		    </f:facet>
				<h:selectBooleanCheckbox value="#{rcvdItems.isSelected}" onclick="updateCount(this.checked); toggleBulkOperations(anyChecked(), 'prefs_pvt_form');" />
		  </h:column>
		  <h:column headerClass="no-sort">
		    <f:facet name="header">
		        <h:outputText value="" styleClass="bi bi-paperclip" escape="false" />
				<h:outputText value="#{msgs.sort_attachment}" styleClass="visually-hidden" />
			</f:facet>
			<h:outputText value="" styleClass="bi bi-paperclip" escape="false" rendered="#{rcvdItems.msg.hasAttachments}" />
		  </h:column>
		  <h:column headerClass="no-sort">
		    <f:facet name="header">
		        <h:outputText value="" styleClass="bi bi-reply-fill" escape="false" />
				<h:outputText value="#{msgs.pvt_msgs_replied}" styleClass="visually-hidden" />
			</f:facet>
			<h:outputText value="" styleClass="bi bi-reply-fill" escape="false" rendered="#{rcvdItems.replied}" />
		  </h:column>
		  <h:column headerClass="sakai-table__primary">
		    <f:facet name="header">
				<h:outputText value="#{msgs.pvt_subject}"/>
		    </f:facet>
			<h:commandLink action="#{PrivateMessagesTool.processPvtMsgDetail}" title="#{rcvdItems.msg.title}" immediate="true">

            <h:outputText value=" #{rcvdItems.msg.title}" rendered="#{rcvdItems.hasRead}"/>
            <h:outputText styleClass="unreadMsg" value=" #{rcvdItems.msg.title}" rendered="#{!rcvdItems.hasRead}"/>
			<h:outputText styleClass="skip" value="#{msgs.pvt_openb}#{msgs.pvt_unread}#{msgs.pvt_closeb}" rendered="#{!rcvdItems.hasRead}"/>
            <f:param value="#{rcvdItems.msg.id}" name="current_msg_detail"/>
          </h:commandLink>
			<h:panelGroup layout="block" styleClass="sakai-messages__subject-tags" rendered="#{PrivateMessagesTool.canUseTags and !empty rcvdItems.tagList}">
				<t:dataList value="#{rcvdItems.tagList}" var="eachTag">
					<span class="sakai-badge sakai-badge--subtle"><h:outputText value="#{eachTag}"/></span>
				</t:dataList>
			</h:panelGroup>
		  </h:column>
		  <h:column headerClass="sakai-table__nowrap">
		    <f:facet name="header">
				<h:outputText value="#{msgs.pvt_date}"/>
		    </f:facet>
			 <%-- This hidden date is for sorting purposes using datetables --%>
		     <h:outputText value="#{((PrivateMessagesTool.userId ne rcvdItems.msg.createdBy) and (! empty rcvdItems.msg.scheduledDate)) ? rcvdItems.msg.scheduledDate : rcvdItems.msg.created}" rendered="#{rcvdItems.hasRead}" styleClass="d-none">
			     <f:convertDateTime pattern="yyyy-MM-dd HH:mm:ss" timeZone="#{PrivateMessagesTool.userTimeZone}" locale="#{PrivateMessagesTool.userLocale}"/>
			 </h:outputText>
		     <h:outputText value="#{((PrivateMessagesTool.userId ne rcvdItems.msg.createdBy) and (! empty rcvdItems.msg.scheduledDate)) ? rcvdItems.msg.scheduledDate : rcvdItems.msg.created}" rendered="#{rcvdItems.hasRead}">
			     <f:convertDateTime pattern="#{msgs.date_format}" timeZone="#{PrivateMessagesTool.userTimeZone}" locale="#{PrivateMessagesTool.userLocale}"/>
			 </h:outputText>
			 <%-- This hidden date is for sorting purposes using datetables --%>
			 <h:outputText value="#{((PrivateMessagesTool.userId ne rcvdItems.msg.createdBy) and (! empty rcvdItems.msg.scheduledDate)) ? rcvdItems.msg.scheduledDate : rcvdItems.msg.created}" rendered="#{!rcvdItems.hasRead}" styleClass="d-none">
			     <f:convertDateTime pattern="yyyy-MM-dd HH:mm:ss" timeZone="#{PrivateMessagesTool.userTimeZone}" locale="#{PrivateMessagesTool.userLocale}"/>
			 </h:outputText>
		   <h:outputText styleClass="unreadMsg" value="#{((PrivateMessagesTool.userId ne rcvdItems.msg.createdBy) and (! empty rcvdItems.msg.scheduledDate)) ? rcvdItems.msg.scheduledDate : rcvdItems.msg.created}" rendered="#{!rcvdItems.hasRead}">
			   <f:convertDateTime pattern="#{msgs.date_format}" timeZone="#{PrivateMessagesTool.userTimeZone}" locale="#{PrivateMessagesTool.userLocale}"/>
			 </h:outputText>
		  </h:column>
		  <h:column rendered="#{PrivateMessagesTool.selectedTopic.topic.title == 'pvt_scheduler'}">
		    <f:facet name="header">
				<h:outputText value="#{msgs.pvt_date_scheduler}"/>
		    </f:facet>
			 <%-- This hidden date is for sorting purposes using datetables --%>
		     <h:outputText value="#{rcvdItems.msg.scheduledDate}" rendered="#{rcvdItems.hasRead}" styleClass="d-none">
			     <f:convertDateTime pattern="yyyy-MM-dd HH:mm:ss" timeZone="#{PrivateMessagesTool.userTimeZone}" locale="#{PrivateMessagesTool.userLocale}"/>
			 </h:outputText>
		     <h:outputText value="#{rcvdItems.msg.scheduledDate}" rendered="#{rcvdItems.hasRead}">
			     <f:convertDateTime pattern="#{msgs.date_format}" timeZone="#{PrivateMessagesTool.userTimeZone}" locale="#{PrivateMessagesTool.userLocale}"/>
			 </h:outputText>
			 <%-- This hidden date is for sorting purposes using datetables --%>
			 <h:outputText value="#{rcvdItems.msg.scheduledDate}" rendered="#{!rcvdItems.hasRead}" styleClass="d-none">
			     <f:convertDateTime pattern="yyyy-MM-dd HH:mm:ss" timeZone="#{PrivateMessagesTool.userTimeZone}" locale="#{PrivateMessagesTool.userLocale}"/>
			 </h:outputText>
		   <h:outputText styleClass="unreadMsg" value="#{rcvdItems.msg.scheduledDate}" rendered="#{!rcvdItems.hasRead}">
			   <f:convertDateTime pattern="#{msgs.date_format}" timeZone="#{PrivateMessagesTool.userTimeZone}" locale="#{PrivateMessagesTool.userLocale}"/>
			 </h:outputText>
		  </h:column>
		  <h:column rendered="#{PrivateMessagesTool.selectedTopic.topic.title != 'pvt_sent'}">
		    <f:facet name="header">
				<h:outputText value="#{msgs.pvt_authby}"/>
		    </f:facet>
		     <h:outputText value="#{rcvdItems.msg.author}" rendered="#{rcvdItems.hasRead}"/>
		     <h:outputText styleClass="unreadMsg" value="#{rcvdItems.msg.author}" rendered="#{!rcvdItems.hasRead}"/>
		  </h:column>
		  <h:column rendered="#{PrivateMessagesTool.selectedTopic.topic.title != 'pvt_received' &&
		  PrivateMessagesTool.selectedTopic.topic.title != 'pvt_drafts' &&
		  PrivateMessagesTool.selectedTopic.topic.title != 'pvt_deleted' &&
		  PrivateMessagesTool.selectedTopic.topic.title != 'pvt_scheduler' }">
		    <f:facet name="header">
				<h:outputText value="#{msgs.pvt_to}"/>
		    </f:facet>
		     <h:outputText value="#{rcvdItems.sendToStringDecorated}" rendered="#{rcvdItems.hasRead}" />
		     <h:outputText styleClass="unreadMsg" value="#{rcvdItems.sendToStringDecorated}" rendered="#{!rcvdItems.hasRead}"/>
		  </h:column>
		  <h:column>
		    <f:facet name="header">
			   <h:outputText value="#{msgs.pvt_label}"/>
		    </f:facet>
		     <h:outputText value="#{rcvdItems.label}"/>
		  </h:column>
		</h:dataTable>
	  </h:panelGroup>

	  <h:panelGroup layout="block" styleClass="sakai-table-wrap" rendered="#{PrivateMessagesTool.threadedView}">
	  <mf:hierPvtMsgDataTable  styleClass="sakai-table sakai-table--hover sakai-table--stack sakai-messages__list" cellpadding="0" cellspacing="0"  id="threaded_pvtmsgs" width="100%"
		value="#{PrivateMessagesTool.searchPvtMsgs}"
		var="rcvdItems"
		rendered="#{PrivateMessagesTool.threadedView}"
		expanded="true"
		columnClasses="#{PrivateMessagesTool.calculateColumnClass()}">
		  <f:facet name="caption">
		    <h:outputText value="#{msgs.pvtMsgListSummary}" styleClass="visually-hidden"/>
		  </f:facet>
		  <h:column headerClass="sakai-table__select sakai-no-print">
		    <f:facet name="header">
				<h:panelGroup>
					<h:selectBooleanCheckbox id="checkAll" title="#{msgs.cdfm_checkall}"/>
					<h:outputLabel for="checkAll" styleClass="visually-hidden"><h:outputText value="#{msgs.cdfm_checkall}"/></h:outputLabel>
				</h:panelGroup>
		    </f:facet>
				<h:selectBooleanCheckbox value="#{rcvdItems.isSelected}" onclick="updateCount(this.checked); toggleBulkOperations(anyChecked(), 'prefs_pvt_form');" />
		  </h:column>
		  <h:column headerClass="no-sort">
				<f:facet name="header">
					<h:outputText value="" styleClass="bi bi-paperclip" escape="false" />
					<h:outputText value="#{msgs.msg_has_attach}" styleClass="visually-hidden" />
				</f:facet>
				<h:outputText value="" styleClass="bi bi-paperclip" escape="false" rendered="#{rcvdItems.msg.hasAttachments}" />
			</h:column>
			<h:column headerClass="no-sort">
				<f:facet name="header">
					<h:outputText value="" styleClass="bi bi-reply-fill" escape="false" />
					<h:outputText value="#{msgs.pvt_msgs_replied}" styleClass="visually-hidden" />
				</f:facet>
				<h:outputText value="" styleClass="bi bi-reply-fill" escape="false" rendered="#{rcvdItems.replied}" />
			</h:column>
			<h:column id="_msg_subject" headerClass="sakai-table__primary">
		    <f:facet name="header">
		       <h:outputText value="#{msgs.pvt_subject}"/>
		    </f:facet>
		      <h:commandLink action="#{PrivateMessagesTool.processPvtMsgDetail}" immediate="true" title=" #{rcvdItems.msg.title}">
            <h:outputText value=" #{rcvdItems.msg.title}" rendered="#{rcvdItems.hasRead}"/>
            <h:outputText styleClass="unreadMsg" value=" #{rcvdItems.msg.title}" rendered="#{!rcvdItems.hasRead}"/>
            <f:param value="#{rcvdItems.msg.id}" name="current_msg_detail"/>
          </h:commandLink>
			<h:panelGroup layout="block" styleClass="sakai-messages__subject-tags" rendered="#{PrivateMessagesTool.canUseTags and !empty rcvdItems.tagList}">
				<t:dataList value="#{rcvdItems.tagList}" var="eachTag">
					<span class="sakai-badge sakai-badge--subtle"><h:outputText value="#{eachTag}"/></span>
				</t:dataList>
			</h:panelGroup>
		  </h:column>
		  <h:column headerClass="sakai-table__nowrap">
		    <f:facet name="header">
		       <h:outputText value="#{msgs.pvt_date}"/>
		    </f:facet>
		     <h:outputText value="#{((PrivateMessagesTool.userId ne rcvdItems.msg.createdBy) and (! empty rcvdItems.msg.scheduledDate)) ? rcvdItems.msg.scheduledDate : rcvdItems.msg.created}" rendered="#{rcvdItems.hasRead}">
			     <f:convertDateTime pattern="#{msgs.date_format}" timeZone="#{PrivateMessagesTool.userTimeZone}" locale="#{PrivateMessagesTool.userLocale}"/>
			 </h:outputText>
		     <h:outputText styleClass="unreadMsg" value="#{((PrivateMessagesTool.userId ne rcvdItems.msg.createdBy) and (! empty rcvdItems.msg.scheduledDate)) ? rcvdItems.msg.scheduledDate : rcvdItems.msg.created}" rendered="#{!rcvdItems.hasRead}">
			     <f:convertDateTime pattern="#{msgs.date_format}" timeZone="#{PrivateMessagesTool.userTimeZone}" locale="#{PrivateMessagesTool.userLocale}"/>
			 </h:outputText>
		  </h:column>
		  <h:column rendered="#{PrivateMessagesTool.selectedTopic.topic.title == 'pvt_scheduler'}">
		    <f:facet name="header">
				<h:outputText value="#{msgs.pvt_date_scheduler}"/>
		    </f:facet>
			 <%-- This hidden date is for sorting purposes using datetables --%>
		     <h:outputText value="#{rcvdItems.msg.scheduledDate}" rendered="#{rcvdItems.hasRead}" styleClass="d-none">
			     <f:convertDateTime pattern="yyyy-MM-dd HH:mm:ss" timeZone="#{PrivateMessagesTool.userTimeZone}" locale="#{PrivateMessagesTool.userLocale}"/>
			 </h:outputText>
		     <h:outputText value="#{rcvdItems.msg.scheduledDate}" rendered="#{rcvdItems.hasRead}">
			     <f:convertDateTime pattern="#{msgs.date_format}" timeZone="#{PrivateMessagesTool.userTimeZone}" locale="#{PrivateMessagesTool.userLocale}"/>
			 </h:outputText>
			 <%-- This hidden date is for sorting purposes using datetables --%>
			 <h:outputText value="#{rcvdItems.msg.scheduledDate}" rendered="#{!rcvdItems.hasRead}" styleClass="d-none">
			     <f:convertDateTime pattern="yyyy-MM-dd HH:mm:ss" timeZone="#{PrivateMessagesTool.userTimeZone}" locale="#{PrivateMessagesTool.userLocale}"/>
			 </h:outputText>
		   <h:outputText styleClass="unreadMsg" value="#{rcvdItems.msg.scheduledDate}" rendered="#{!rcvdItems.hasRead}">
			   <f:convertDateTime pattern="#{msgs.date_format}" timeZone="#{PrivateMessagesTool.userTimeZone}" locale="#{PrivateMessagesTool.userLocale}"/>
			 </h:outputText>
		  </h:column>
		  <h:column rendered="#{PrivateMessagesTool.selectedTopic.topic.title != 'pvt_sent'}">
		    <f:facet name="header">
		       <h:outputText value="#{msgs.pvt_authby}"/>
		    </f:facet>
		     <h:outputText value="#{rcvdItems.msg.author}" rendered="#{rcvdItems.hasRead}"/>
		     <h:outputText styleClass="unreadMsg" value="#{rcvdItems.msg.author}" rendered="#{!rcvdItems.hasRead}"/>
		  </h:column>
		  <h:column rendered="#{PrivateMessagesTool.selectedTopic.topic.title != 'pvt_received' &&
		  PrivateMessagesTool.selectedTopic.topic.title != 'pvt_drafts' &&
		  PrivateMessagesTool.selectedTopic.topic.title != 'pvt_deleted' &&
		  PrivateMessagesTool.selectedTopic.topic.title != 'pvt_scheduler' }">
		    <f:facet name="header">
		       <h:outputText value="#{msgs.pvt_to}"/>
		    </f:facet>
		     <h:outputText value="#{rcvdItems.sendToStringDecorated}" rendered="#{rcvdItems.hasRead}"/>
		     <h:outputText styleClass="unreadMsg" value="#{rcvdItems.sendToStringDecorated}" rendered="#{!rcvdItems.hasRead}"/>
		  </h:column>
		  <h:column>
		    <f:facet name="header">
			   <h:outputText value="#{msgs.pvt_label}"/>
		    </f:facet>
		     <h:outputText value="#{rcvdItems.label}"/>
		  </h:column>
		</mf:hierPvtMsgDataTable>
		</h:panelGroup>

		<h:panelGroup layout="block" styleClass="sakai-actions sakai-no-print">
			<h:commandButton action="#{PrivateMessagesTool.processActionMarkCheckedAsRead}" id="markAsread"
				value="#{msgs.cdfm_mark_check_as_read}" styleClass="ToggleBulk sakai-btn sakai-btn-secondary"/>
			<h:commandButton action="#{PrivateMessagesTool.processActionMarkCheckedAsUnread}" id="markAsUnread"
				value="#{msgs.cdfm_mark_check_as_unread}" styleClass="ToggleBulk sakai-btn sakai-btn-secondary"/>
			<h:commandButton action="#{PrivateMessagesTool.processActionDeleteChecked}" id="deleteMarked"
				value="#{msgs.cdfm_mark_check_as_delete}" styleClass="ToggleBulk sakai-btn sakai-btn-secondary"
				rendered="#{PrivateMessagesTool.msgNavMode != 'pvt_deleted'}"/>
			<h:commandButton id="deleteChecked" action="#{PrivateMessagesTool.processPvtMsgEmptyDelete}"
				value="#{msgs.cdfm_mark_check_as_delete}" styleClass="ToggleBulk sakai-btn sakai-btn-secondary"
				rendered="#{PrivateMessagesTool.msgNavMode == 'pvt_deleted'}"/>
			<h:commandButton action="#{PrivateMessagesTool.processActionMoveCheckedToFolder}" id="moveCheckedToFolder"
				value="#{msgs.cdfm_mark_check_move_to_folder}" styleClass="ToggleBulk sakai-btn sakai-btn-secondary"/>
		</h:panelGroup>

<%-- Added if user clicks Check All --%>
    <script>
     // setting number checked just in case Check All being processed
     // needed to 'enable' bulk operations
     numberChecked = <h:outputText value="#{PrivateMessagesTool.numberChecked}" />;

     toggleBulkOperations(numberChecked > 0, 'prefs_pvt_form');
     </script>

   	</h:form>

	</sakai:view>
</f:view>
