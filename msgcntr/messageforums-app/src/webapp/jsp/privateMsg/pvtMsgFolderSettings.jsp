<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>


<f:view>
	<sakai:view title="#{msgs.pvt_msgs_label} #{msgs.pvt_foldersettings}">

<!--jsp/privateMsg/pvtMsgFolderSettings.jsp-->
		<h:form id="pvtMsgFolderSettings">
			<script>includeLatestJQuery("msgcntr");</script>
			<script src="/messageforums-tool/js/sak-10625.js"></script>
			<script src="/messageforums-tool/js/messages.js"></script>

			<% request.setAttribute("pvtHeaderTitleKey", "pvt_foldersettings"); %>
			<% request.setAttribute("pvtHeaderBack", "folderSettings"); %>
			<%@ include file="/jsp/privateMsg/pvtToolHeader.jsp" %>

			<h:messages styleClass="sakai-banner sakai-banner--error" id="errorMessages" rendered="#{! empty facesContext.maximumSeverity}" />

			<dl class="sakai-messages__folder-summary">
				<dt><h:outputText value="#{msgs.pvt_folder_title}"/></dt>
				<dd><h:outputText value="#{PrivateMessagesTool.selectedTopicTitle}" /></dd>
			</dl>

			<div class="sakai-actions">
				<h:commandButton action="#{PrivateMessagesTool.processPvtMsgFolderSettingRevise}" value="#{msgs.pvt_rename_folder_button}" accesskey="r" styleClass="sakai-btn sakai-btn-primary" />
				<h:commandButton action="#{PrivateMessagesTool.processPvtMsgFolderInFolderAdd}" value="#{msgs.pvt_add}" styleClass="sakai-btn sakai-btn-secondary"/>
				<h:commandButton action="#{PrivateMessagesTool.processPvtMsgFolderSettingDelete}" value="#{msgs.pvt_delete}" styleClass="sakai-btn sakai-btn-secondary"/>
				<h:commandButton action="#{PrivateMessagesTool.processPvtMsgReturnToMainOrHp}" value="#{msgs.pvt_cancel}" accesskey="x" styleClass="sakai-btn sakai-btn-ghost" />
			</div>

		 </h:form>

	</sakai:view>
</f:view>
