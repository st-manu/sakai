<%--
  Shared Niobe header for the private messages views.
  Pages set request attributes before including it:
    pvtHeaderView       home | list | search | detail
    pvtHeaderTitleKey   message bundle key for flow views
    pvtHeaderBack       destination handled by PrivateMessagesTool.processPvtMsgHeaderBack()
--%>
<%
  String pvtHeaderView = (String) request.getAttribute("pvtHeaderView");
  String pvtHeaderTitleKey = (String) request.getAttribute("pvtHeaderTitleKey");
  String pvtHeaderBack = (String) request.getAttribute("pvtHeaderBack");
  boolean pvtHeaderIsFolderView = "home".equals(pvtHeaderView) || "list".equals(pvtHeaderView) || "search".equals(pvtHeaderView);
  // Folder views without a dedicated back destination return to the folder list instead.
  boolean pvtHeaderShowsAllFolders = ("list".equals(pvtHeaderView) || "search".equals(pvtHeaderView)) && (pvtHeaderBack == null || pvtHeaderBack.isEmpty());
  // On list/search the utilities only exist in the overflow, so keep it at every width.
  boolean pvtHeaderMorePersistent = "list".equals(pvtHeaderView) || "search".equals(pvtHeaderView);
%>
<header class="sakai-tool-header">
  <% if ((pvtHeaderBack != null && !pvtHeaderBack.isEmpty()) || pvtHeaderShowsAllFolders) { %>
  <h:panelGroup layout="block" styleClass="sakai-back-link-row sakai-no-print">
    <% if (pvtHeaderShowsAllFolders) { %>
    <h:commandLink immediate="true" action="#{PrivateMessagesTool.processActionPrivateMessages}" styleClass="sakai-back-link">
      <h:outputText value="" styleClass="si si-arrow-left" escape="false"/>
      <h:outputText value="#{msgs.pvt_all_folders}"/>
    </h:commandLink>
    <% } else { %>
    <h:commandLink immediate="true" action="#{PrivateMessagesTool.processPvtMsgHeaderBack}" styleClass="sakai-back-link">
      <h:outputText value="" styleClass="si si-arrow-left" escape="false"/>
      <h:outputText value="#{msgs.pvt_bktolist}" rendered="#{requestScope.pvtHeaderBack ne 'detail'}"/>
      <h:outputText value="#{msgs.pvt_back}" rendered="#{requestScope.pvtHeaderBack eq 'detail'}"/>
      <f:param name="pvtHeaderBack" value="#{requestScope.pvtHeaderBack}"/>
    </h:commandLink>
    <% } %>
  </h:panelGroup>
  <% } %>
  <h1 class="sakai-tool-header__title">
    <% if (pvtHeaderTitleKey != null && !pvtHeaderTitleKey.isEmpty()) { %>
      <%= msgs.getString(pvtHeaderTitleKey) %>
    <% } else if ("detail".equals(pvtHeaderView)) { %>
      <h:outputText value="#{msgs.pvt_preview}" rendered="#{PrivateMessagesTool.detailMsg.isPreview or PrivateMessagesTool.detailMsg.isPreviewReply or PrivateMessagesTool.detailMsg.isPreviewReplyAll or PrivateMessagesTool.detailMsg.isPreviewForward}"/>
      <h:outputText value="#{PrivateMessagesTool.detailMsg.msg.title}" rendered="#{!PrivateMessagesTool.detailMsg.isPreview and !PrivateMessagesTool.detailMsg.isPreviewReply and !PrivateMessagesTool.detailMsg.isPreviewReplyAll and !PrivateMessagesTool.detailMsg.isPreviewForward}"/>
    <% } else if ("search".equals(pvtHeaderView)) { %>
      <h:outputText value="#{msgs.pvt_search}"/>
    <% } else if ("list".equals(pvtHeaderView)) { %>
      <h:outputText value="#{msgs[PrivateMessagesTool.selectedTopic.topic.title]}"
        rendered="#{PrivateMessagesTool.selectedTopic.topic.title == 'pvt_received' or PrivateMessagesTool.selectedTopic.topic.title == 'pvt_sent' or PrivateMessagesTool.selectedTopic.topic.title == 'pvt_deleted' or PrivateMessagesTool.selectedTopic.topic.title == 'pvt_drafts' or PrivateMessagesTool.selectedTopic.topic.title == 'pvt_scheduler'}"/>
      <h:outputText value="#{PrivateMessagesTool.selectedTopic.topic.title}"
        rendered="#{not empty PrivateMessagesTool.selectedTopic.topic.title and PrivateMessagesTool.selectedTopic.topic.title != 'pvt_received' and PrivateMessagesTool.selectedTopic.topic.title != 'pvt_sent' and PrivateMessagesTool.selectedTopic.topic.title != 'pvt_deleted' and PrivateMessagesTool.selectedTopic.topic.title != 'pvt_drafts' and PrivateMessagesTool.selectedTopic.topic.title != 'pvt_scheduler'}"/>
      <h:outputText value="#{msgs.cdfm_message_pvtarea}" rendered="#{empty PrivateMessagesTool.selectedTopic.topic.title}"/>
    <% } else { %>
      <h:outputText value="#{msgs.cdfm_message_pvtarea}"/>
    <% } %>
  </h1>

  <% if (pvtHeaderIsFolderView) { %>
  <h:panelGroup layout="block" styleClass="sakai-tool-header__actions sakai-no-print">
    <h:commandLink immediate="true" action="#{PrivateMessagesTool.processPvtMsgCompose}" styleClass="sakai-btn sakai-btn-primary sakai-messages__compose-link" title="#{msgs.pvt_compose}" rendered="#{!PrivateMessagesTool.dispError}">
      <h:outputText value="" styleClass="si si-add" escape="false"/>
      <h:outputText value="#{msgs.pvt_compose}"/>
    </h:commandLink>

    <% if ("home".equals(pvtHeaderView)) { %>
    <h:panelGroup layout="block" styleClass="sakai-tool-header__secondary">
      <h:commandLink immediate="true" action="#{PrivateMessagesTool.processPvtMsgFolderSettingAdd}" styleClass="sakai-btn sakai-btn-secondary"
        id="newFolder" rendered="#{!PrivateMessagesTool.dispError}">
        <h:outputText value="#{msgs.pvt_newfolder}"/>
      </h:commandLink>
      <h:commandLink immediate="true" action="#{PrivateMessagesTool.processPvtMsgSettings}" styleClass="sakai-btn sakai-btn-secondary"
        id="settings" rendered="#{PrivateMessagesTool.showSettingsLink}">
        <h:outputText value="#{msgs.pvt_settings}"/>
      </h:commandLink>
      <h:commandLink immediate="true" action="#{PrivateMessagesTool.processActionPermissions}" styleClass="sakai-btn sakai-btn-ghost"
        id="permissions" rendered="#{PrivateMessagesTool.instructor}">
        <h:outputText value="#{msgs.pvt_permissions}"/>
      </h:commandLink>
    </h:panelGroup>
    <% } %>

    <h:panelGroup layout="block"
      rendered="#{!PrivateMessagesTool.dispError or PrivateMessagesTool.showSettingsLink or PrivateMessagesTool.instructor}">
      <details class="sakai-overflow-menu sakai-tool-header__more <%= pvtHeaderMorePersistent ? "sakai-tool-header__more--persistent" : "" %>">
        <summary class="sakai-btn sakai-btn-ghost sakai-overflow-menu__toggle">
          <h:outputText value="" styleClass="si si-three-dots" escape="false"/>
          <h:outputText value="#{msgs.pvt_more_actions}" styleClass="visually-hidden"/>
        </summary>
        <div class="sakai-overflow-menu__panel">
          <h:commandLink immediate="true" action="#{PrivateMessagesTool.processPvtMsgFolderSettingAdd}" rendered="#{!PrivateMessagesTool.dispError}">
            <h:outputText value="#{msgs.pvt_newfolder}"/>
          </h:commandLink>
          <h:commandLink immediate="true" action="#{PrivateMessagesTool.processPvtMsgSettings}" rendered="#{PrivateMessagesTool.showSettingsLink}">
            <h:outputText value="#{msgs.pvt_settings}"/>
          </h:commandLink>
          <h:commandLink immediate="true" action="#{PrivateMessagesTool.processActionPermissions}" rendered="#{PrivateMessagesTool.instructor}">
            <h:outputText value="#{msgs.pvt_permissions}"/>
          </h:commandLink>
        </div>
      </details>
    </h:panelGroup>
  </h:panelGroup>
  <% } %>
</header>
