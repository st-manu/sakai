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
	<sakai:view title="#{msgs.cdfm_message_pvtarea}">
		<!--jsp/privateMsg/pvtMsgHpView.jsp-->
		<h:form id="msgForum">

<%
  FacesContext context = FacesContext.getCurrentInstance();
  Application app = context.getApplication();
  ValueBinding binding = app.createValueBinding("#{PrivateMessagesTool}");
  PrivateMessagesTool pmt = (PrivateMessagesTool) binding.getValue(context);

  if (pmt.getUserId() != null) {
  pmt.initializePrivateMessageArea();
%>

			<script>includeLatestJQuery("msgcntr");</script>
			<script src="/messageforums-tool/js/sak-10625.js"></script>

			<% request.setAttribute("pvtHeaderView", "home"); %>
			<%@ include file="/jsp/privateMsg/pvtToolHeader.jsp" %>

			<h:panelGroup layout="block" styleClass="sakai-banner sakai-banner--error"
				rendered="#{PrivateMessagesTool.messages and PrivateMessagesTool.dispError}">
				<h:outputText value="#{msgs.pvt_hlprpgerror}"/>
			</h:panelGroup>

			<h:panelGroup layout="block" styleClass="sakai-table-wrap" rendered="#{PrivateMessagesTool.pvtAreaEnabled}">
				<h:dataTable value="#{PrivateMessagesTool.decoratedForum.topics}" var="topic"
					styleClass="sakai-table sakai-table--hover sakai-messages__folders" captionClass="visually-hidden"
					columnClasses="sakai-table__primary,sakai-table__nowrap,sakai-table__nowrap,sakai-table__actions">
					<f:facet name="caption">
						<h:outputText value="#{msgs.pvt_folders}" styleClass="visually-hidden"/>
					</f:facet>

					<h:column>
						<f:facet name="header">
							<h:outputText value="#{msgs.pvt_folder}"/>
						</f:facet>
						<h:outputText value="" styleClass="bi bi-folder sakai-messages__folder-icon" escape="false"/>
						<h:commandLink action="#{PrivateMessagesTool.processPvtMsgTopic}" immediate="true">
							<h:outputText value="#{msgs[topic.topic.title]}"
								rendered="#{topic.topic.title == 'pvt_received' or topic.topic.title == 'pvt_sent' or topic.topic.title == 'pvt_deleted' or topic.topic.title == 'pvt_drafts' or topic.topic.title == 'pvt_scheduler'}"/>
							<h:outputText value="#{topic.topic.title}"
								rendered="#{topic.topic.title != 'pvt_received' and topic.topic.title != 'pvt_sent' and topic.topic.title != 'pvt_deleted' and topic.topic.title != 'pvt_drafts' and topic.topic.title != 'pvt_scheduler'}"/>
							<f:param value="#{topic.topic.uuid}" name="pvtMsgTopicId"/>
						</h:commandLink>
					</h:column>

					<h:column>
						<f:facet name="header">
							<h:outputText value="#{msgs.pvt_messages}"/>
						</f:facet>
						<h:outputText value="#{topic.totalNoMessages}"/>
					</h:column>

					<h:column>
						<f:facet name="header">
							<h:outputText value="#{msgs.pvt_unread}"/>
						</f:facet>
						<h:outputText value="#{topic.unreadNoMessages}"
							styleClass="#{topic.unreadNoMessages > 0 ? 'sakai-messages__unread' : ''}"/>
					</h:column>

					<h:column>
						<f:facet name="header">
							<h:outputText value="#{msgs.cdfm_other_actions}" styleClass="visually-hidden"/>
						</f:facet>
						<h:panelGroup rendered="#{topic.topic.mutable}">
							<details class="sakai-overflow-menu">
								<summary class="sakai-btn sakai-btn-icon sakai-overflow-menu__toggle">
									<h:outputText value="" styleClass="bi bi-three-dots" escape="false"/>
									<h:outputText value="#{msgs.pvt_more_actions}" styleClass="visually-hidden"/>
								</summary>
								<div class="sakai-overflow-menu__panel">
									<h:commandLink action="#{PrivateMessagesTool.processPvtMsgFolderSettings}" title="#{msgs.pvt_foldersettings}">
										<h:outputText value="#{msgs.pvt_foldersettings}"/>
										<f:param value="#{topic.topic.uuid}" name="pvtMsgTopicId"/>
									</h:commandLink>
								</div>
							</details>
						</h:panelGroup>
					</h:column>
				</h:dataTable>
			</h:panelGroup>

			<h:outputText value="#{msgs.pvt_mainpgerror}" styleClass="sakai-banner sakai-banner--warn"
				rendered="#{PrivateMessagesTool.dispError}"/>

			<h:inputHidden id="mainOrHp" value="pvtMsgHpView" />

<%
  } else {
%>

<h:outputText value="#{msgs.pvt_anon_warning}" styleClass="sakai-banner sakai-banner--warn"/>

<%
  }
%>
		</h:form>
	</sakai:view>
</f:view>
