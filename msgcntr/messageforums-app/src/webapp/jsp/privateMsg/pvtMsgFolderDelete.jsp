<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>

<f:view>

    <sakai:view title="#{msgs.pvt_delcon}">
    <!--jsp/privateMsg/pvtMsgFolderDelete.jsp-->
    <h:form id="pvtMsgFolderDelete">
        <script>includeLatestJQuery("msgcntr");</script>
        <script src="/messageforums-tool/js/sak-10625.js"></script>
        <script src="/messageforums-tool/js/messages.js"></script>

        <% request.setAttribute("pvtHeaderTitleKey", "pvt_delcon"); %>
        <% request.setAttribute("pvtHeaderBack", "folderView"); %>
        <%@ include file="/jsp/privateMsg/pvtToolHeader.jsp" %>

        <h:panelGroup layout="block" styleClass="sakai-banner sakai-banner--warn">
            <h:outputText value="#{msgs.pvt_delete_folder_confirm}" />
        </h:panelGroup>

        <div class="sakai-table-wrap">
            <table class="sakai-table sakai-table--stack">
                <thead>
                    <tr>
                        <th scope="col"><h:outputText value="#{msgs.pvt_folder_title}"/></th>
                        <th scope="col"><h:outputText value="#{msgs.pvt_messages}"/></th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><h:outputText value="#{PrivateMessagesTool.selectedTopicTitle}" /></td>
                        <td><h:outputText value="#{PrivateMessagesTool.totalMsgInFolder}" /></td>
                    </tr>
                </tbody>
            </table>
        </div>

        <div class="sakai-actions">
            <h:commandButton action="#{PrivateMessagesTool.processPvtMsgFldDelete}" value="#{msgs.pvt_delete}" accesskey="s" styleClass="sakai-btn sakai-btn-primary"/>
            <h:commandButton action="#{PrivateMessagesTool.processPvtMsgReturnToFolderView}" value="#{msgs.pvt_cancel}" accesskey="x" styleClass="sakai-btn sakai-btn-ghost" />
        </div>

    </h:form>

    </sakai:view>
</f:view>
