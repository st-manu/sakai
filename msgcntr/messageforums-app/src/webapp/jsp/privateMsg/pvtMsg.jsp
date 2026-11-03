<%@ page import="java.util.*, jakarta.faces.context.*, jakarta.faces.application.*,
                 jakarta.faces.el.*, org.sakaiproject.tool.messageforums.*,
                 org.sakaiproject.tool.messageforums.ui.*"%>
<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf" %>
<%@ taglib uri="http://myfaces.apache.org/tomahawk" prefix="t"%>

<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>

<f:view>
	<sakai:view title="#{msgs.pvtarea_name}">
<!--jsp/privateMsg/pvtMsg.jsp-->
		<h:form id="prefs_pvt_form">
<%
// FOR WHEN COMING FROM SYNOPTIC TOOL
    FacesContext context = FacesContext.getCurrentInstance();
    ExternalContext exContext = context.getExternalContext();
    Map paramMap = exContext.getRequestParameterMap();
    Application app = context.getApplication();
    ValueBinding binding = app.createValueBinding("#{PrivateMessagesTool}");
    PrivateMessagesTool pmt = (PrivateMessagesTool) binding.getValue(context);

     if ( "pvt_received".equals((String) paramMap.get("selectedTopic")) ) {
	  pmt.initializeFromSynoptic();
    }

    if(pmt.getUserId() != null){
  	//show entire page, otherwise, don't allow anon user to use this tool:
%>

    <script src="/library/webjars/jquery/1.12.4/jquery.min.js?version="></script>
    <script src="/messageforums-tool/js/sak-10625.js"></script>
    <script src="/messageforums-tool/js/forum.js"></script>
    <script src="/messageforums-tool/js/messages.js"></script>
    <script>includeWebjarLibrary('datatables');</script>

    <script>
        document.addEventListener('DOMContentLoaded', function() {

            const messagesTable = document.getElementById('prefs_pvt_form:pvtmsgs');
            if (messagesTable?.querySelector('tbody td:not(:empty)')) {
                new DataTable(messagesTable, {
                    "paging": false,
                    // the search box above the table filters it, see setupMessagesSearch
                    "layout": {"topEnd": null},
                    "info": false,
                    "order": [[4, "desc"]],
                    "columns": [
                        {"orderable": false, "searchable": false},
                        {"orderable": true, "searchable": false},
                        {"orderable": false, "searchable": false},
                        {"orderable": true, "searchable": true},
                        {"orderable": true, "searchable": false},
                        <h:outputText value="{\"orderable\": true, \"searchable\": false}," rendered="#{PrivateMessagesTool.selectedTopic.topic.title == 'pvt_scheduler'}" />
                        {"orderable": true, "searchable": true},
                        <h:outputText value="{\"orderable\": true, \"searchable\": false}," rendered="#{PrivateMessagesTool.selectedTopic.topic.title != 'pvt_sent' && PrivateMessagesTool.selectedTopic.topic.title != 'pvt_received' && PrivateMessagesTool.selectedTopic.topic.title != 'pvt_drafts' && PrivateMessagesTool.selectedTopic.topic.title != 'pvt_deleted' && PrivateMessagesTool.selectedTopic.topic.title != 'pvt_scheduler' }"/>
                        {"orderable": true, "searchable": true},
                    ],
                    "language": {
                        "search": <h:outputText value="'#{msgs.datatables_sSearch}'" />,
                        "zeroRecords": <h:outputText value="'#{msgs.datatables_zeroRecords}'" />,
                        "info": <h:outputText value="'#{msgs.datatables_info}'" />,
                        "infoEmpty": <h:outputText value="'#{msgs.datatables_infoEmpty}'" />,
                        "infoFiltered": <h:outputText value="'#{msgs.datatables_infoFiltered}'" />,
                        "emptyTable": <h:outputText value="'#{msgs.datatables_infoEmpty}'" />,
                        "paginate": {
                            "next": <h:outputText value="'#{msgs.datatables_paginate_next}'" />,
                            "previous": <h:outputText value="'#{msgs.datatables_paginate_previous}'" />,
                        },
                        "aria": {
                            "sortAscending": <h:outputText value="'#{msgs.datatables_aria_sortAscending}'" />,
                            "sortDescending": <h:outputText value="'#{msgs.datatables_aria_sortDescending}'" />,
                        }
                    }
                });
            }

            const threadedMessagesTable = document.getElementById('prefs_pvt_form:threaded_pvtmsgs');
            if (threadedMessagesTable?.querySelector('tbody td:not(:empty)')) {
                new DataTable(threadedMessagesTable, {
                    "paging": false,
                    // the search box above the table filters it, see setupMessagesSearch
                    "layout": {"topEnd": null},
                    "order": [[4, "desc"]],
                    "info": false,
                    "columns": [
                        {"orderable": false, "searchable": false},
                        {"orderable": true, "searchable": false},
                        {"orderable": false, "searchable": false},
                        {"orderable": true, "searchable": true},
                        {"orderable": true, "searchable": false},
                        <h:outputText value="{\"orderable\": true, \"searchable\": false}," rendered="#{ PrivateMessagesTool.selectedTopic.topic.title != 'pvt_received' }" />
                        {"orderable": true, "searchable": true},
                        <h:outputText value="{\"orderable\": true, \"searchable\": false}," rendered="#{PrivateMessagesTool.selectedTopic.topic.title != 'pvt_sent' && PrivateMessagesTool.selectedTopic.topic.title != 'pvt_received' && PrivateMessagesTool.selectedTopic.topic.title != 'pvt_drafts' && PrivateMessagesTool.selectedTopic.topic.title != 'pvt_deleted' && PrivateMessagesTool.selectedTopic.topic.title != 'pvt_scheduler' }"/>
                        {"orderable": true, "searchable": true},
                        <h:outputText value="{\"orderable\": false, \"searchable\": true}," rendered="#{PrivateMessagesTool.canUseTags}" />
                    ],
                    "language": {
                        "search": <h:outputText value="'#{msgs.datatables_sSearch}'" />,
                        "zeroRecords": <h:outputText value="'#{msgs.datatables_zeroRecords}'" />,
                        "info": <h:outputText value="'#{msgs.datatables_info}'" />,
                        "infoEmpty": <h:outputText value="'#{msgs.datatables_infoEmpty}'" />,
                        "infoFiltered": <h:outputText value="'#{msgs.datatables_infoFiltered}'" />,
                        "emptyTable": <h:outputText value="'#{msgs.datatables_infoEmpty}'" />,
                        "paginate": {
                            "next": <h:outputText value="'#{msgs.datatables_paginate_next}'" />,
                            "previous": <h:outputText value="'#{msgs.datatables_paginate_previous}'" />,
                        },
                        "aria": {
                            "sortAscending": <h:outputText value="'#{msgs.datatables_aria_sortAscending}'" />,
                            "sortDescending": <h:outputText value="'#{msgs.datatables_aria_sortDescending}'" />,
                        }
                    }
                });
            }

    });
    </script>

    <% request.setAttribute("pvtHeaderView", "list"); %>
    <%@ include file="/jsp/privateMsg/pvtToolHeader.jsp" %>

			<h:messages styleClass="sakai-banner sakai-banner--error" id="errorMessages" rendered="#{! empty facesContext.maximumSeverity}"/>
 			<!-- Display successfully moving checked messsages to Deleted folder -->
			<h:panelGroup layout="block" styleClass="sakai-banner sakai-banner--success" rendered="#{PrivateMessagesTool.multiDeleteSuccess}">
				<h:outputText value="#{PrivateMessagesTool.multiDeleteSuccessMsg}"/>
			</h:panelGroup>

		<%@ include file="msgHeader.jsp"%>
		<%-- gsilver:this table needs a render atrtibute that will make it not display if there are no messages - and a companion text block classed as "instruction" that will render instead--%>
	  <h:panelGroup layout="block" styleClass="sakai-table-wrap">
	  <h:dataTable styleClass="sakai-table sakai-table--hover sakai-messages__list" id="pvtmsgs" captionClass="visually-hidden" width="100%" value="#{PrivateMessagesTool.decoratedPvtMsgs}" var="rcvdItems"
		             rendered="#{PrivateMessagesTool.selectView != 'threaded'}"
		             summary="#{msgs.pvtMsgListSummary}"
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
		  <h:column>
		    <f:facet name="header">
		        <h:outputText value="" styleClass="bi bi-paperclip" escape="false" />
				<h:outputText value="#{msgs.sort_attachment}" styleClass="visually-hidden" />
			</f:facet>
			<h:outputText value="" styleClass="bi bi-paperclip" escape="false" rendered="#{rcvdItems.msg.hasAttachments}" />
		  </h:column>
		  <h:column>
		    <f:facet name="header">
	        	<h:outputText value="" styleClass="bi bi-reply-fill" escape="false" />
				<h:outputText value="#{msgs.pvt_msgs_replied}" styleClass="visually-hidden" />
			</f:facet>
			<h:outputText value="" styleClass="bi bi-reply-fill" escape="false" rendered="#{rcvdItems.replied}" />
		  </h:column>
		  <h:column headerClass="sakai-table__primary">
		    <f:facet name="header">
				<h:outputLink value="#" onclick="return false;"><h:outputText value="#{msgs.pvt_subject}"/></h:outputLink>
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
				<h:outputLink value="#" onclick="return false;"><h:outputText value="#{msgs.pvt_date}"/></h:outputLink>
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
				<h:outputLink value="#" onclick="return false;"><h:outputText value="#{msgs.pvt_date_scheduler}"/></h:outputLink>
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
				<h:outputLink value="#" onclick="return false;"><h:outputText value="#{msgs.pvt_authby}"/></h:outputLink>
		    </f:facet>
		     <h:outputText value="#{rcvdItems.msg.author}" rendered="#{rcvdItems.hasRead}"/>
		     <h:outputText styleClass="unreadMsg" value="#{rcvdItems.msg.author}" rendered="#{!rcvdItems.hasRead}"/>
		  </h:column>
				  <h:column rendered="#{PrivateMessagesTool.selectedTopic.topic.title != 'pvt_received' &&
		  PrivateMessagesTool.selectedTopic.topic.title != 'pvt_drafts' &&
		  PrivateMessagesTool.selectedTopic.topic.title != 'pvt_deleted' &&
		  PrivateMessagesTool.selectedTopic.topic.title != 'pvt_scheduler' }">
		    <f:facet name="header">
				<h:outputLink value="#" onclick="return false;"><h:outputText value="#{msgs.pvt_to}"/></h:outputLink>
		    </f:facet>
		     <h:outputText value="#{rcvdItems.sendToStringDecorated}" rendered="#{rcvdItems.hasRead}" />
		     <h:outputText styleClass="unreadMsg" value="#{rcvdItems.sendToStringDecorated}" rendered="#{!rcvdItems.hasRead}"/>
		  </h:column>
		  <h:column>
		    <f:facet name="header">
			   <h:outputLink value="#" onclick="return false;"><h:outputText value="#{msgs.pvt_label}"/></h:outputLink>
		    </f:facet>
		     <h:outputText value="#{rcvdItems.label}"/>
		  </h:column>
		</h:dataTable>
	  </h:panelGroup>
	  <h:panelGroup layout="block" styleClass="sakai-table-wrap" rendered="#{PrivateMessagesTool.threadedView}">
	  <mf:hierPvtMsgDataTable styleClass="sakai-table sakai-table--hover sakai-messages__list" id="threaded_pvtmsgs" width="100%"
	                          value="#{PrivateMessagesTool.decoratedPvtMsgs}"
		                        var="rcvdItems"
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
		  <h:column>
				<f:facet name="header">
					<h:outputText value="" styleClass="bi bi-paperclip" escape="false" />
					<h:outputText value="#{msgs.msg_has_attach}" styleClass="visually-hidden" />
				</f:facet>
				<h:outputText value="" styleClass="bi bi-paperclip" escape="false" rendered="#{rcvdItems.msg.hasAttachments}" />
			</h:column>
			<h:column>
				<f:facet name="header">
					<h:outputText value="" styleClass="bi bi-reply-fill" escape="false" />
					<h:outputText value="#{msgs.pvt_msgs_replied}" styleClass="visually-hidden" />
				</f:facet>
				<h:outputText value="" styleClass="bi bi-reply-fill" escape="false" rendered="#{rcvdItems.replied}" />
			</h:column>
			<h:column id="_msg_subject" headerClass="sakai-table__primary">
		    <f:facet name="header">
		       <h:outputLink value="#" onclick="return false;"><h:outputText value="#{msgs.pvt_subject}"/></h:outputLink>
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
		       <h:outputLink value="#" onclick="return false;"><h:outputText value="#{msgs.pvt_date}"/></h:outputLink>
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
				<h:outputLink value="#" onclick="return false;"><h:outputText value="#{msgs.pvt_date_scheduler}"/></h:outputLink>
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
		       <h:outputLink value="#" onclick="return false;"><h:outputText value="#{msgs.pvt_authby}"/></h:outputLink>
		    </f:facet>
		     <h:outputText value="#{rcvdItems.msg.author}" rendered="#{rcvdItems.hasRead}"/>
		     <h:outputText styleClass="unreadMsg" value="#{rcvdItems.msg.author}" rendered="#{!rcvdItems.hasRead}"/>
		  </h:column>
		  <h:column rendered="#{PrivateMessagesTool.selectedTopic.topic.title != 'pvt_received' &&
		  PrivateMessagesTool.selectedTopic.topic.title != 'pvt_drafts' &&
		  PrivateMessagesTool.selectedTopic.topic.title != 'pvt_deleted' &&
		  PrivateMessagesTool.selectedTopic.topic.title != 'pvt_scheduler' }">
		    <f:facet name="header">
		       <h:outputLink value="#" onclick="return false;"><h:outputText value="#{msgs.pvt_to}"/></h:outputLink>
		    </f:facet>
		     <h:outputText value="#{rcvdItems.sendToStringDecorated}" rendered="#{rcvdItems.hasRead}"/>
		     <h:outputText styleClass="unreadMsg" value="#{rcvdItems.sendToStringDecorated}" rendered="#{!rcvdItems.hasRead}"/>
		  </h:column>
		  <h:column>
		    <f:facet name="header">
			   <h:outputLink value="#" onclick="return false;"><h:outputText value="#{msgs.pvt_label}"/></h:outputLink>
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

<%
}else{
//user is an anon user, just show a message saying they can't use this tool:
%>

<h:outputText value="#{msgs.pvt_anon_warning}" styleClass="sakai-banner sakai-banner--warn"/>

<%
}
%>

		</h:form>
	</sakai:view>
</f:view>
