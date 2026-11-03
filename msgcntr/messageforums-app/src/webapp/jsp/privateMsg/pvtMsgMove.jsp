<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>
<f:view>
	<sakai:view title="#{msgs.pvt_move} #{msgs.pvt_rcvd_msgs}">
<!--jsp/privateMsg/pvtMsgMove.jsp-->
		<h:form id="pvtMsgMove">
			<script>includeLatestJQuery("msgcntr");</script>
			<script src="/messageforums-tool/js/sak-10625.js"></script>
			<script src="/messageforums-tool/js/messages.js"></script>

			<% request.setAttribute("pvtHeaderTitleKey", "pvt_move"); %>
			<% request.setAttribute("pvtHeaderBack", "detail"); %>
			<%@ include file="/jsp/privateMsg/pvtToolHeader.jsp" %>

			<h:messages styleClass="sakai-banner sakai-banner--error" id="errorMessages" rendered="#{! empty facesContext.maximumSeverity}"/>

			<h:panelGroup layout="block" styleClass="sakai-form-field">
				<h:outputLabel for="moveTo" styleClass="sakai-form-label">
					<h:outputText value="#{msgs.pvt_move_msg_to}"/>
				</h:outputLabel>
				<h:selectOneMenu id="moveTo" value="#{PrivateMessagesTool.moveToTopic}" styleClass="sakai-form-control"
					onchange="this.form.submit();" valueChangeListener="#{PrivateMessagesTool.processPvtMsgParentFolderMove}">
					<f:selectItems value="#{PrivateMessagesTool.decoratedForum.topics}" var="topic"
						itemValue="#{topic.topic.uuid}"
						itemDisabled="#{PrivateMessagesTool.selectedTopic.topic == topic.topic}"
						itemLabel="#{(topic.topic.title == 'pvt_received' || topic.topic.title == 'pvt_sent' || topic.topic.title == 'pvt_deleted' || topic.topic.title == 'pvt_drafts' || topic.topic.title == 'pvt_scheduler') ? msgs[topic.topic.title] : topic.topic.title}" />
				</h:selectOneMenu>
			</h:panelGroup>

			<div class="sakai-actions">
				<h:commandButton action="#{PrivateMessagesTool.processPvtMsgMoveMessage}" value="#{msgs.pvt_move_msg}" accesskey="s" styleClass="sakai-btn sakai-btn-primary"/>
				<h:commandButton action="#{PrivateMessagesTool.processPvtMsgCancelToDetailView}" value="#{msgs.pvt_cancel}" accesskey="x" styleClass="sakai-btn sakai-btn-ghost" />
			</div>

		</h:form>

	</sakai:view>
</f:view>
