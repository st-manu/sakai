<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf" %>

<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>

<f:view>
  <sakai:view title="#{msgs.pvt_detmsgreply}">
    <h:form id="pvtMsgDetail">
      <script>
        var msgs_js = {
          "loading_wait":<h:outputText value="\"#{msgs.loading_wait}\"" />,
          "cdfm_profile_information":<h:outputText value="\"#{msgs.cdfm_profile_information}\"" />
        };
      </script>
      <script>includeLatestJQuery("msgcntr");</script>
      <script src="/messageforums-tool/js/sak-10625.js"></script>
      <script src="/messageforums-tool/js/messages.js"></script>

      <% request.setAttribute("pvtHeaderView", "detail"); %>
      <% request.setAttribute("pvtHeaderBack", "list"); %>
      <%@ include file="/jsp/privateMsg/pvtToolHeader.jsp" %>

      <h:messages styleClass="sakai-banner sakai-banner--error" id="errorMessages" rendered="#{! empty facesContext.maximumSeverity}"/>
      <h:panelGroup layout="block" styleClass="sakai-banner sakai-banner--success" rendered="#{PrivateMessagesTool.multiDeleteSuccess}">
        <h:outputText value="#{PrivateMessagesTool.multiDeleteSuccessMsg}"/>
      </h:panelGroup>

      <div class="sakai-messages__detail-summary">
        <f:subview id="authorImage" rendered="#{PrivateMessagesTool.showProfileInfoMsg}">
          <h:panelGroup>
            <sakai-user-photo profile-popup="on" user-id="<h:outputText value="#{PrivateMessagesTool.detailMsg.msg.authorId}"/>" />
          </h:panelGroup>
        </f:subview>

        <dl class="sakai-messages__meta">
          <div class="sakai-messages__meta-row">
            <dt><h:outputText value="#{msgs.pvt_authby}"/></dt>
            <dd>
              <h:outputText value="#{PrivateMessagesTool.detailMsg.msg.author}" />
              <h:outputText value=" #{msgs.pvt_openb}" />
              <h:outputText value="#{((PrivateMessagesTool.userId ne PrivateMessagesTool.detailMsg.msg.createdBy) and (! empty PrivateMessagesTool.detailMsg.msg.scheduledDate)) ? PrivateMessagesTool.detailMsg.msg.scheduledDate: PrivateMessagesTool.detailMsg.msg.created}" >
                <f:convertDateTime pattern="#{msgs.date_format}" timeZone="#{PrivateMessagesTool.userTimeZone}" locale="#{PrivateMessagesTool.userLocale}"/>
              </h:outputText>
              <h:outputText value="#{msgs.pvt_closeb}" />
            </dd>
          </div>
          <div class="sakai-messages__meta-row">
            <dt><h:outputText value="#{msgs.pvt_group}"/></dt>
            <dd><h:outputText value="#{PrivateMessagesTool.senderRoleAndGroups} "/></dd>
          </div>
          <div class="sakai-messages__meta-row">
            <dt><h:outputText value="#{msgs.pvt_to}" /></dt>
            <dd>
              <h:outputText value="#{PrivateMessagesTool.detailMsg.recipientsAsText}" />
              <h:outputText value=", (#{msgs.pvt_sent_as_email})" rendered="#{PrivateMessagesTool.detailMsg.msg.externalEmail}"/>
            </dd>
          </div>
          <f:subview id="bccRecipients" rendered="#{ForumTool.userId == PrivateMessagesTool.detailMsg.msg.createdBy && PrivateMessagesTool.detailMsg.recipientsAsTextBcc != null && PrivateMessagesTool.detailMsg.recipientsAsTextBcc != ''}">
            <div class="sakai-messages__meta-row">
              <dt><h:outputText value="#{msgs.pvt_bcc}" /></dt>
              <dd><h:outputText value="#{PrivateMessagesTool.detailMsg.recipientsAsTextBcc}" /></dd>
            </div>
          </f:subview>
          <div class="sakai-messages__meta-row">
            <dt><h:outputText value="#{msgs.pvt_subject}"/></dt>
            <dd><h:outputText value="#{PrivateMessagesTool.detailMsg.msg.title}" /></dd>
          </div>
          <div class="sakai-messages__meta-row">
            <dt><h:outputText value="#{msgs.pvt_label}"/></dt>
            <dd><h:outputText value="#{PrivateMessagesTool.detailMsg.label}" /></dd>
          </div>
          <h:panelGroup layout="block" styleClass="sakai-messages__meta-row" rendered="#{!empty PrivateMessagesTool.detailMsg.attachList}">
            <dt><h:outputText value="#{msgs.pvt_att}" /></dt>
            <dd>
              <h:dataTable value="#{PrivateMessagesTool.detailMsg.attachList}" var="eachAttach"
                styleClass="sakai-table sakai-table--sm sakai-messages__attachments"
                rendered="#{!empty PrivateMessagesTool.detailMsg.attachList}">
                <h:column rendered="#{!empty PrivateMessagesTool.detailMsg.attachList}">
                  <sakai:contentTypeMap fileType="#{eachAttach.attachment.attachmentType}" mapType="image" var="imagePath" pathPrefix="/library/image/"/>
                  <h:graphicImage id="exampleFileIcon" value="#{imagePath}" />
                  <h:outputLink value="#{eachAttach.url}" target="_blank">
                    <h:outputText value="#{eachAttach.attachment.attachmentName}"/>
                  </h:outputLink>
                  <h:outputText value=" (#{PrivateMessagesTool.getAttachmentReadableSize(eachAttach.attachment.attachmentSize)})" styleClass="sakai-messages__attachment-size"/>
                </h:column>
              </h:dataTable>
            </dd>
          </h:panelGroup>
        </dl>
      </div>

      <div class="sakai-messages__body">
        <mf:htmlShowArea value="#{PrivateMessagesTool.detailMsg.msg.body}" id="htmlMsgText" hideBorder="true" />
      </div>

      <h:panelGroup layout="block" styleClass="sakai-form-section" rendered="#{PrivateMessagesTool.canUseTags}">
        <h:outputText value="#{msgs.pvt_tags_header}" styleClass="sakai-form-section__title" />
        <h:inputHidden value="#{PrivateMessagesTool.selectedTags}" id="tag_selector"></h:inputHidden>
        <h:panelGroup styleClass="#{PrivateMessagesTool.detailMsg.isPreview || PrivateMessagesTool.detailMsg.isPreviewReply || PrivateMessagesTool.detailMsg.isPreviewReplyAll || PrivateMessagesTool.detailMsg.isPreviewForward ? 'DisableTags' : ''}">
          <sakai-tag-selector
            id="tag-selector"
            input-id="pvtMsgDetail:tag_selector"
            <h:panelGroup rendered="#{PrivateMessagesTool.detailMsg.isPreview || PrivateMessagesTool.detailMsg.isPreviewReply || PrivateMessagesTool.detailMsg.isPreviewReplyAll || PrivateMessagesTool.detailMsg.isPreviewForward}">
              tabindex="-1"
            </h:panelGroup>
            selected-ids='<h:outputText value="#{PrivateMessagesTool.selectedTags}"/>'
            collection-id='<h:outputText value="#{PrivateMessagesTool.getSiteId()}"/>'
            site-id='<h:outputText value="#{PrivateMessagesTool.getSiteId()}"/>'
            tool='<h:outputText value="#{PrivateMessagesTool.getTagTool()}"/>'
            add-new="true"
          ></sakai-tag-selector>
        </h:panelGroup>
        <h:panelGroup layout="block" styleClass="sakai-actions" rendered="#{!PrivateMessagesTool.detailMsg.isPreview && !PrivateMessagesTool.detailMsg.isPreviewReply && !PrivateMessagesTool.detailMsg.isPreviewReplyAll && !PrivateMessagesTool.detailMsg.isPreviewForward}">
          <h:commandButton action="#{PrivateMessagesTool.processPvtMsgSaveTags}" value="#{msgs.pvt_tags_save}" styleClass="sakai-btn sakai-btn-secondary" />
        </h:panelGroup>
      </h:panelGroup>

      <h:panelGroup layout="block" styleClass="sakai-actions" rendered="#{!PrivateMessagesTool.deleteConfirm && !PrivateMessagesTool.detailMsg.isPreview && !PrivateMessagesTool.detailMsg.isPreviewReply && !PrivateMessagesTool.detailMsg.isPreviewReplyAll && !PrivateMessagesTool.detailMsg.isPreviewForward}">
        <h:commandButton action="#{PrivateMessagesTool.processPvtMsgReply}" value="#{msgs.pvt_repmsg}" accesskey="r" styleClass="sakai-btn sakai-btn-primary" />
        <h:commandButton action="#{PrivateMessagesTool.processPvtMsgReplyAll}" value="#{msgs.pvt_repmsg_ALL}" accesskey="r" styleClass="sakai-btn sakai-btn-secondary" />
        <h:commandButton action="#{PrivateMessagesTool.processPvtMsgForward}" value="#{msgs.pvt_forwardmsg}" accesskey="r" styleClass="sakai-btn sakai-btn-secondary" />
        <h:commandButton action="#{PrivateMessagesTool.processPvtMsgMove}" value="#{msgs.pvt_move}" accesskey="m" styleClass="sakai-btn sakai-btn-secondary" />
        <h:commandButton action="#{PrivateMessagesTool.processPvtMsgPublishToFaqEdit}" value="#{msgs.pvt_publish_to_faq}"
          rendered="#{PrivateMessagesTool.detailMessagePublishableToFaq && mfPublishToFaqBean.canPost}" accesskey="m" styleClass="sakai-btn sakai-btn-secondary" />
        <h:commandButton action="#{PrivateMessagesTool.processPvtMsgDeleteConfirm}" value="#{msgs.pvt_delete}" styleClass="sakai-btn sakai-btn-secondary" />
      </h:panelGroup>

      <h:panelGroup layout="block" styleClass="sakai-actions" rendered="#{PrivateMessagesTool.deleteConfirm}">
        <h:commandButton action="#{PrivateMessagesTool.processPvtMsgDeleteConfirmYes}" value="#{msgs.pvt_delete}" accesskey="s" styleClass="sakai-btn sakai-btn-primary"/>
        <h:commandButton action="#{PrivateMessagesTool.processPvtMsgCancelToDetailView}" value="#{msgs.pvt_cancel}" accesskey="x" styleClass="sakai-btn sakai-btn-ghost" />
      </h:panelGroup>

      <h:panelGroup layout="block" styleClass="sakai-actions" rendered="#{PrivateMessagesTool.detailMsg.isPreview}">
        <h:commandButton action="#{PrivateMessagesTool.processPvtMsgPreviewSend}" value="#{msgs.pvt_send}" accesskey="s" styleClass="sakai-btn sakai-btn-primary"/>
        <h:commandButton action="#{PrivateMessagesTool.processPvtMsgPreviewBack}" value="#{msgs.pvt_back}" accesskey="b" styleClass="sakai-btn sakai-btn-ghost" />
      </h:panelGroup>
      <h:panelGroup layout="block" styleClass="sakai-actions" rendered="#{PrivateMessagesTool.detailMsg.isPreviewReply}">
        <h:commandButton action="#{PrivateMessagesTool.processPvtMsgPreviewReplySend}" value="#{msgs.pvt_send}" accesskey="s" styleClass="sakai-btn sakai-btn-primary"/>
        <h:commandButton action="#{PrivateMessagesTool.processPvtMsgPreviewReplyBack}" value="#{msgs.pvt_back}" accesskey="b" styleClass="sakai-btn sakai-btn-ghost" />
      </h:panelGroup>
      <h:panelGroup layout="block" styleClass="sakai-actions" rendered="#{PrivateMessagesTool.detailMsg.isPreviewReplyAll}">
        <h:commandButton action="#{PrivateMessagesTool.processPvtMsgPreviewReplyAllSend}" value="#{msgs.pvt_send}" accesskey="s" styleClass="sakai-btn sakai-btn-primary"/>
        <h:commandButton action="#{PrivateMessagesTool.processPvtMsgPreviewReplyAllBack}" value="#{msgs.pvt_back}" accesskey="b" styleClass="sakai-btn sakai-btn-ghost" />
      </h:panelGroup>
      <h:panelGroup layout="block" styleClass="sakai-actions" rendered="#{PrivateMessagesTool.detailMsg.isPreviewForward}">
        <h:commandButton action="#{PrivateMessagesTool.processPvtMsgPreviewForwardSend}" value="#{msgs.pvt_send}" accesskey="s" styleClass="sakai-btn sakai-btn-primary"/>
        <h:commandButton action="#{PrivateMessagesTool.processPvtMsgPreviewForwardBack}" value="#{msgs.pvt_back}" accesskey="b" styleClass="sakai-btn sakai-btn-ghost" />
      </h:panelGroup>
    </h:form>
  </sakai:view>
</f:view>
