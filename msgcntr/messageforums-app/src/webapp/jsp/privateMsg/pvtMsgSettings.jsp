<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h"%>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f"%>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai"%>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf"%>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>
<f:view>
	<sakai:view title="#{msgs.pvt_msgs_label} #{msgs.pvt_settings}">
<!--jsp/privateMsg/pvtMsgSettings.jsp-->
	<script>
		function displayEmail() {
			document.forms[0].email.disabled = false
		}
	</script>
<h:form id="pvtMsgSettings">
			<script>includeLatestJQuery("msgcntr");</script>
			<script src="/messageforums-tool/js/sak-10625.js"></script>
			<script src="/messageforums-tool/js/messages.js"></script>

			<% request.setAttribute("pvtHeaderTitleKey", "pvt_settings"); %>
			<% request.setAttribute("pvtHeaderBack", "settings"); %>
			<%@ include file="/jsp/privateMsg/pvtToolHeader.jsp" %>

			<h:messages styleClass="sakai-banner sakai-banner--error" id="errorMessages" rendered="#{! empty facesContext.maximumSeverity}"/>

			<h:panelGroup layout="block" styleClass="sakai-form-section" rendered="#{PrivateMessagesTool.instructor && PrivateMessagesTool.messagesandForums}">
				<h:outputText value="#{msgs.pvt_actpvtmsg1}" styleClass="sakai-form-section__title"/>
				<h:panelGroup layout="block" styleClass="sakai-form-field">
					<h:selectOneRadio id="activate" value="#{PrivateMessagesTool.activatePvtMsg}" layout="pageDirection" styleClass="sakai-form-choice-group sakai-messages__choice-group">
						<f:selectItem itemValue="yes" itemLabel="#{msgs.pvt_yes}" />
						<f:selectItem itemValue="no" itemLabel="#{msgs.pvt_no}" />
					</h:selectOneRadio>
				</h:panelGroup>
			</h:panelGroup>

			<h:panelGroup layout="block" styleClass="sakai-form-section" rendered="#{!PrivateMessagesTool.emailForwardDisabled}">
				<h:outputText value="#{msgs.pvt_personal_settings}" styleClass="sakai-form-section__title"/>
				<h:panelGroup layout="block" styleClass="sakai-form-field">
					<h:outputLabel for="fwd_msg" styleClass="sakai-form-label"><h:outputText value="#{msgs.pvt_autofor1}" /></h:outputLabel>
					<h:selectOneRadio immediate="true" id="fwd_msg" value="#{PrivateMessagesTool.forwardPvtMsg}"
						onchange="this.form.submit();" valueChangeListener="#{PrivateMessagesTool.processPvtMsgSettingsRevise}"
						layout="pageDirection" styleClass="sakai-form-choice-group sakai-messages__choice-group">
						<f:selectItem itemValue="yes" itemLabel="#{msgs.pvt_yes}" />
						<f:selectItem itemValue="no" itemLabel="#{msgs.pvt_no}" />
						<f:selectItem itemValue="default" itemLabel="#{msgs.pvt_default}" />
					</h:selectOneRadio>
				</h:panelGroup>
				<h:panelGroup layout="block" styleClass="sakai-form-field">
					<h:outputLabel for="fwd_email" styleClass="sakai-form-label"><h:outputText value="#{msgs.pvt_emailfor}" /></h:outputLabel>
					<h:inputText value="#{PrivateMessagesTool.forwardPvtMsgEmail}" id="fwd_email" styleClass="sakai-form-control"
						disabled="#{!('yes'.equals(PrivateMessagesTool.forwardPvtMsg))}" />
				</h:panelGroup>
			</h:panelGroup>

			<h:panelGroup layout="block" styleClass="sakai-form-section" rendered="#{PrivateMessagesTool.instructor}">
				<h:outputText value="#{msgs.pvt_site_settings}" styleClass="sakai-form-section__title"/>
				<h:panelGroup layout="block" styleClass="sakai-form-field" rendered="#{!PrivateMessagesTool.emailCopyDisabled}">
					<h:outputLabel styleClass="sakai-form-label"><h:outputText value="#{msgs.pvt_sendemailout}"/></h:outputLabel>
					<h:selectOneRadio id="email_sendout" value="#{PrivateMessagesTool.sendToEmail}" layout="pageDirection" styleClass="sakai-form-choice-group sakai-messages__choice-group">
						<f:selectItem itemValue="0" itemLabel="#{msgs.pvt_sendemail_0}" />
						<f:selectItem itemValue="1" itemLabel="#{msgs.pvt_sendemail_1}" />
						<f:selectItem itemValue="2" itemLabel="#{msgs.pvt_sendemail_2}" />
					</h:selectOneRadio>
				</h:panelGroup>

				<h:panelGroup layout="block" styleClass="sakai-form-field" rendered="#{PrivateMessagesTool.currentSiteHasGroups}">
					<h:outputText value="#{msgs.hiddenGroups_hiddenGroups}" styleClass="sakai-form-label"/>
					<h:dataTable styleClass="sakai-table sakai-table--sm" id="hiddenGroups" value="#{PrivateMessagesTool.hiddenGroups}" var="hiddenGroup"
						rendered="#{!empty PrivateMessagesTool.hiddenGroups}">
						<h:column>
							<h:outputText value="#{hiddenGroup.groupId}"/>
							<h:commandLink action="#{PrivateMessagesTool.processActionRemoveHiddenGroup}">
								<f:param value="#{hiddenGroup.groupId}" name="groupId"/>
								<span class="bi bi-x-circle" aria-hidden="true"></span>
								<h:outputText value="#{msgs.hiddenGroups_remove}" styleClass="visually-hidden"/>
							</h:commandLink>
						</h:column>
					</h:dataTable>
				</h:panelGroup>
				<h:panelGroup layout="block" styleClass="sakai-form-field" rendered="#{PrivateMessagesTool.currentSiteHasGroups}">
					<h:outputLabel for="nonHiddenGroup" styleClass="sakai-form-label"><h:outputText value="#{msgs.hiddenGroups_addGroup}"/></h:outputLabel>
					<h:selectOneListbox size="1" id="nonHiddenGroup" styleClass="sakai-form-control" value="#{PrivateMessagesTool.selectedNonHiddenGroup}"
						onchange="this.form.submit();" valueChangeListener="#{PrivateMessagesTool.processActionAddHiddenGroup}">
						<f:selectItems value="#{PrivateMessagesTool.nonHiddenGroups}"/>
					</h:selectOneListbox>
				</h:panelGroup>
			</h:panelGroup>

			<div class="sakai-actions">
				<h:commandButton action="#{PrivateMessagesTool.processPvtMsgSettingsSave}" value="#{msgs.pvt_saveset}" accesskey="s" styleClass="sakai-btn sakai-btn-primary" />
				<h:commandButton action="#{PrivateMessagesTool.processPvtMsgCancel}" value="#{msgs.pvt_cancel}" accesskey="x" styleClass="sakai-btn sakai-btn-ghost" />
			</div>

		</h:form>

	</sakai:view>
</f:view>
