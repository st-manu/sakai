<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>

<f:view>
  <sakai:view title="#{msgs.pvt_msgs_label} #{msgs.pvt_create_folder}">
<!--jsp/privateMsg/pvtMsgFolderAdd.jsp-->
		<h:form id="pvtMsgFolderAdd">
			<script>includeLatestJQuery("msgcntr");</script>
			<script src="/messageforums-tool/js/sak-10625.js"></script>
			<script src="/messageforums-tool/js/messages.js"></script>

			<% request.setAttribute("pvtHeaderTitleKey", "pvt_create_folder"); %>
			<% request.setAttribute("pvtHeaderBack", "folderSettings"); %>
			<%@ include file="/jsp/privateMsg/pvtToolHeader.jsp" %>

			<h:messages styleClass="sakai-banner sakai-banner--error" id="errorMessages" rendered="#{! empty facesContext.maximumSeverity}" />

			<h:panelGroup layout="block" styleClass="sakai-form-field">
				<h:outputLabel for="title" styleClass="sakai-form-label required">
					<h:outputText value="#{msgs.pvt_folder_title}"/>
				</h:outputLabel>
				<h:inputText id="title" value="#{PrivateMessagesTool.addFolder}" styleClass="sakai-form-control" />
			</h:panelGroup>

			<div class="sakai-actions">
				<h:commandButton action="#{PrivateMessagesTool.processPvtMsgFldCreate}" value="#{msgs.pvt_add}" accesskey="s" styleClass="sakai-btn sakai-btn-primary"/>
				<h:commandButton action="#{PrivateMessagesTool.processPvtMsgReturnToMainOrHp}" value="#{msgs.pvt_cancel}" accesskey="x" styleClass="sakai-btn sakai-btn-ghost" />
			</div>

		</h:form>

	</sakai:view>
</f:view>
