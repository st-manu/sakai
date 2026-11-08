<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>

<f:view>
	<sakai:view title="#{msgs.pvt_delcon}">
<!--Y:\msgcntr\messageforums-app\src\webapp\jsp\privateMsg\pvtMsgDelete.jsp-->
    <h:form id="pvtMsgDelete">
        <script>includeLatestJQuery("msgcntr");</script>
        <script src="/messageforums-tool/js/sak-10625.js"></script>
        <script src="/messageforums-tool/js/messages.js"></script>

        <% request.setAttribute("pvtHeaderTitleKey", "pvt_delcon"); %>
        <% request.setAttribute("pvtHeaderBack", "deleteList"); %>
        <%@ include file="/jsp/privateMsg/pvtToolHeader.jsp" %>

        <h:messages styleClass="sakai-banner sakai-banner--error" id="errorMessages" rendered="#{! empty facesContext.maximumSeverity}"/>

        <div class="sakai-table-wrap">
            <h:dataTable styleClass="sakai-table sakai-table--hover sakai-table--stack" id="pvtmsgdel" width="100%" value="#{PrivateMessagesTool.selectedDeleteItems}" var="delItems">
                <h:column>
                    <f:facet name="header">
                        <h:outputText value="#{msgs.pvt_subject}"/>
                    </f:facet>
                    <h:outputText value="#{delItems.msg.title}"/>
                </h:column>
                <h:column>
                    <f:facet name="header">
                        <h:outputText value="" styleClass="si si-attachment" escape="false" />
                        <h:outputText value="#{msgs.msg_has_attach}" styleClass="visually-hidden" />
                    </f:facet>
                    <h:outputText value="" styleClass="si si-attachment" escape="false" rendered="#{delItems.msg.hasAttachments}" />
                </h:column>
                <h:column>
                    <f:facet name="header">
                        <h:outputText value="#{msgs.pvt_authby}"/>
                    </f:facet>
                    <h:outputText value="#{delItems.msg.author}"/>
                </h:column>
                <h:column headerClass="sakai-table__nowrap">
                    <f:facet name="header">
                        <h:outputText value="#{msgs.pvt_date}"/>
                    </f:facet>
                    <h:outputText value="#{delItems.msg.created}">
                        <f:convertDateTime pattern="#{msgs.date_format}" timeZone="#{PrivateMessagesTool.userTimeZone}" locale="#{PrivateMessagesTool.userLocale}"/>
                    </h:outputText>
                </h:column>
            </h:dataTable>
        </div>

        <div class="sakai-actions">
            <h:commandButton action="#{PrivateMessagesTool.processPvtMsgMultiDelete}" value="#{msgs.pvt_delmsgs}" accesskey="s" styleClass="sakai-btn sakai-btn-primary"/>
            <h:commandButton action="#{PrivateMessagesTool.processPvtMsgCancelToListView}" value="#{msgs.pvt_cancel}" accesskey="x" styleClass="sakai-btn sakai-btn-ghost" />
        </div>

    </h:form>

	</sakai:view>
</f:view>
