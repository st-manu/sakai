<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
    <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>
<f:view><sakai:view title="#{msgs.pvt_publish_to_faq} #{msgs.pvt_rcvd_msgs}">
    <!--jsp/privateMsg/pvtMsgPublishToFaqEdit.jsp-->
    <h:form id="pvtPublishToFaqEdit">
        <script>includeLatestJQuery("msgcntr");</script>
        <script src="/messageforums-tool/js/sak-10625.js"></script>
        <script src="/messageforums-tool/js/messages.js"></script>

        <% request.setAttribute("pvtHeaderTitleKey", "pvt_publish_to_faq"); %>
        <% request.setAttribute("pvtHeaderBack", "detail"); %>
        <%@ include file="/jsp/privateMsg/pvtToolHeader.jsp" %>

        <h:messages styleClass="sakai-banner sakai-banner--error" rendered="#{! empty facesContext.maximumSeverity}"/>

        <h:panelGroup layout="block" styleClass="sakai-form-field">
            <h:outputLabel for="title" styleClass="sakai-form-label required">
                <h:outputText value="#{msgs.pvt_title}" />
            </h:outputLabel>
            <h:inputText id="title" value="#{mfPublishToFaqBean.title}" styleClass="sakai-form-control" >
                <f:validateLength maximum="255" />
            </h:inputText>
        </h:panelGroup>

        <h:panelGroup layout="block" styleClass="sakai-form-field">
            <h:outputLabel for="question" styleClass="sakai-form-label required">
                <h:outputText value="#{msgs.pvt_question}" />
            </h:outputLabel>
            <sakai:inputRichText id="question" value="#{mfPublishToFaqBean.question}" textareaOnly="#{PrivateMessagesTool.mobileSession}"
                    rows="#{ForumTool.editorRows}" />
        </h:panelGroup>

        <h:panelGroup layout="block" styleClass="sakai-form-field" rendered="#{mfPublishToFaqBean.canReply}">
            <h:outputLabel for="answer" value="#{msgs.pvt_answer}" styleClass="sakai-form-label" />
            <sakai:inputRichText id="answer" value="#{mfPublishToFaqBean.answer}" textareaOnly="#{PrivateMessagesTool.mobileSession}"
                    rows="#{ForumTool.editorRows}" />
            <h:outputText value="#{msgs.pvt_answer_info}" styleClass="sakai-form-help"/>
        </h:panelGroup>

        <div class="sakai-actions">
            <h:commandButton action="#{PrivateMessagesTool.processPvtMsgPublishToFaq}" value="#{msgs.pvt_publish_to_faq}" accesskey="s" styleClass="sakai-btn sakai-btn-primary"/>
            <h:commandButton action="#{PrivateMessagesTool.processPvtMsgCancelToDetailView}" value="#{msgs.pvt_cancel}" accesskey="x" styleClass="sakai-btn sakai-btn-ghost" />
        </div>

    </h:form>
</sakai:view></f:view>
