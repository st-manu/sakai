<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf" %>

<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>

<%
	String thisId = request.getParameter("panel");
	if (thisId == null) {
		thisId = "Main"	+ org.sakaiproject.tool.cover.ToolManager.getCurrentPlacement().getId();
	}
%>

<f:view>
	<sakai:view title="#{msgs.pvt_repmsg_ALL}">
		<link rel="stylesheet" href="/messageforums-tool/css/messages.css" type="text/css" />
		<link rel="stylesheet" href="/library/webjars/jquery-ui/1.12.1/jquery-ui.min.css" type="text/css" />
		<script>includeLatestJQuery("msgcntr");</script>
		<script src="/messageforums-tool/js/datetimepicker.js"></script>
		<script src="/library/js/lang-datepicker/lang-datepicker.js"></script>
		<script src="/messageforums-tool/js/sak-10625.js"></script>
		<script src="/messageforums-tool/js/messages.js"></script>
		<script type="module" src="/webcomponents/bundles/user-picker.js"></script>
	<h:form id="pvtMsgForward">
	<script>
		function clearSelection(selectObject)
		{
			for (var i=0; i<selectObject.options.length; i++)
			{
				selectObject.options[i].selected=false;
			}
			selectObject.dispatchEvent(new Event('change', { bubbles: true }));
		}

		function setBccVisible(visible, clearSelected) {
			document.getElementById('pvtMsgForward:bcc_field').hidden = !visible;
			if (clearSelected) {
				clearSelection(document.getElementById('pvtMsgForward:list2'));
			}
			resize();
		}

		function fadeInBcc(clearSelected) {
			setBccVisible(true, clearSelected);
		}

		function fadeOutBcc(clearSelected) {
			setBccVisible(false, clearSelected);
		}

		function resize(){
			mySetMainFrameHeight('<%=org.sakaiproject.util.Web.escapeJavascript(thisId)%>');
		}

		$(document).ready(function() {
			if(document.getElementById('pvtMsgForward:list2').selectedIndex != -1){
				setBccVisible(true, false);
				document.getElementById('pvtMsgForward:bcc_checkbox').checked = true;
			}
			bindRecipientPicker(document.getElementById('pvtMsgForward:list2'));
			resize();
			document.getElementById('pvtMsgForward:openDateSpan').hidden = !document.getElementById('pvtMsgForward:scheduler_send_email').checked;
		});
	</script>

	<% request.setAttribute("pvtHeaderTitleKey", "pvt_repmsg_ALL"); %>
	<% request.setAttribute("pvtHeaderBack", "detail"); %>
	<%@ include file="/jsp/privateMsg/pvtToolHeader.jsp" %>

		<f:verbatim><input type="hidden" id="ckeditor-autosave-context" name="ckeditor-autosave-context" value="messages_pvtMsgReply" /></f:verbatim>
		<h:panelGroup rendered="#{PrivateMessagesTool.detailMsg.msg.id!=null}"><f:verbatim><input type="hidden" id="ckeditor-autosave-entity-id" name="ckeditor-autosave-entity-id" value="</f:verbatim><h:outputText value="#{PrivateMessagesTool.detailMsg.msg.id}"/><f:verbatim>"/></f:verbatim></h:panelGroup>

		<h:outputLink rendered="#{PrivateMessagesTool.renderPrivacyAlert}" value="#{PrivateMessagesTool.privacyAlertUrl}" target="_blank" >
			<sakai:instruction_message value="#{PrivateMessagesTool.privacyAlert}"/>
		</h:outputLink>

		<h:messages styleClass="sakai-banner sakai-banner--error" id="errorMessages" rendered="#{! empty facesContext.maximumSeverity}" />

		<h:panelGroup layout="block" styleClass="sakai-banner sakai-banner--warn" rendered="#{PrivateMessagesTool.displayHiddenGroupsMsg}">
			<h:outputText value="#{msgs.pvt_hiddenGroupsBccMsg}" />
		</h:panelGroup>

		<div class="sakai-form-section">
			<h:outputText value="#{msgs.pvt_recipients}" styleClass="sakai-form-section__title" />

			<h:panelGroup layout="block" styleClass="sakai-form-field">
				<h:outputText value="#{msgs.pvt_to}" styleClass="sakai-form-label" />
				<h:outputText id="send_to" value="#{PrivateMessagesTool.detailMsg.msg.author}" />
			</h:panelGroup>
			<h:panelGroup layout="block" styleClass="sakai-form-field">
				<h:outputText value="#{msgs.pvt_to_cc}" styleClass="sakai-form-label" />
				<h:outputText id="send_to2" value="#{PrivateMessagesTool.detailMsg.recipientsAsText}" />
			</h:panelGroup>

			<h:panelGroup styleClass="sakai-form-choice">
				<h:selectBooleanCheckbox id="bcc_checkbox" onclick="if(this.checked){fadeInBcc(true);}else{fadeOutBcc(true);}"/>
				<h:outputLabel for="bcc_checkbox">
					<h:outputText value="#{msgs.pvt_addBcc}"/>
				</h:outputLabel>
			</h:panelGroup>

			<f:verbatim><div id="pvtMsgForward:bcc_field" class="sakai-form-field" hidden></f:verbatim>
				<h:outputLabel for="list2" styleClass="sakai-form-label"><h:outputText value="#{msgs.pvt_bcc}"/></h:outputLabel>
				<h:selectManyListbox id="list2" value="#{PrivateMessagesTool.selectedComposeBccList}" size="5"
					styleClass="sakai-form-control" title="#{msgs.pvt_bcc}">
					<f:selectItems value="#{PrivateMessagesTool.totalComposeToBccList}"/>
				</h:selectManyListbox>
			<f:verbatim></div></f:verbatim>

			<h:panelGroup styleClass="sakai-form-choice">
				<h:selectBooleanCheckbox value="#{PrivateMessagesTool.booleanEmailOut}" id="send_email_out" disabled="#{!PrivateMessagesTool.emailCopyOptional}"></h:selectBooleanCheckbox>
				<h:outputLabel for="send_email_out">
					<h:outputText value="#{msgs.pvt_send_as_email}"/>
				</h:outputLabel>
			</h:panelGroup>

			<h:panelGroup styleClass="sakai-form-choice">
				<h:selectBooleanCheckbox value="#{PrivateMessagesTool.booleanReadReceipt}" id="read_receipt" ></h:selectBooleanCheckbox>
				<h:outputLabel for="read_receipt">
					<h:outputText value="#{msgs.pvt_read_receipt_text}"/>
				</h:outputLabel>
			</h:panelGroup>

			<h:panelGroup layout="block" styleClass="sakai-form-field">
				<h:outputLabel for="viewlist" styleClass="sakai-form-label">
					<h:outputText value="#{msgs.pvt_label}"/>
				</h:outputLabel>
				<h:selectOneListbox size="1" id="viewlist" styleClass="sakai-form-control" value="#{PrivateMessagesTool.selectedLabel}">
					<f:selectItem itemValue="pvt_priority_normal" itemLabel="#{msgs.pvt_priority_normal}"/>
					<f:selectItem itemValue="pvt_priority_low" itemLabel="#{msgs.pvt_priority_low}"/>
					<f:selectItem itemValue="pvt_priority_high" itemLabel="#{msgs.pvt_priority_high}"/>
				</h:selectOneListbox>
			</h:panelGroup>

			<h:panelGroup layout="block" styleClass="sakai-form-field">
				<h:panelGroup styleClass="sakai-form-choice">
					<h:selectBooleanCheckbox value="#{PrivateMessagesTool.booleanSchedulerSend}" id="scheduler_send_email"
						onclick="document.getElementById('pvtMsgForward:openDateSpan').hidden = !this.checked"></h:selectBooleanCheckbox>
					<h:outputLabel for="scheduler_send_email">
						<h:outputText value="#{msgs.pvt_scheduler_send_as_email}"/>
					</h:outputLabel>
				</h:panelGroup>

				<f:verbatim><div id="pvtMsgForward:openDateSpan" class="sakai-form-subfield" hidden></f:verbatim>
					<h:outputLabel value="#{msgs.pvt_scheduler_send_date} " for="openDate" styleClass="sakai-form-label" />
					<h:inputText id="openDate" styleClass="sakai-form-control openDate" value="#{PrivateMessagesTool.schedulerSendDateString}" />
				<f:verbatim></div></f:verbatim>
			</h:panelGroup>

			<script>
				localDatePicker({
					input:'.openDate',
					allowEmptyDate:true,
					ashidden: { iso8601: 'openDateISO8601' },
					val: document.querySelector('.openDate').value,
					useTime:1
				});
			</script>

			<h:panelGroup layout="block" styleClass="sakai-form-field">
				<h:outputLabel for="subject" styleClass="sakai-form-label required">
					<h:outputText value="#{msgs.pvt_subject}"  />
				</h:outputLabel>
				<h:inputText value="#{PrivateMessagesTool.replyToAllSubject}" id="subject" size="45" styleClass="sakai-form-control">
					<f:validateLength maximum="255"/>
				</h:inputText>
			</h:panelGroup>
		</div>

		<div class="sakai-form-section">
			<h:outputText value="#{msgs.pvt_message}" styleClass="sakai-form-section__title" />
			<sakai:inputRichText textareaOnly="#{PrivateMessagesTool.mobileSession}" rows="#{ForumTool.editorRows}" cols="132" id="pvt_forward_body" value="#{PrivateMessagesTool.replyToAllBody}">
			</sakai:inputRichText>
		</div>

		<div class="sakai-form-section">
			<h:outputText value="#{msgs.pvt_att}" styleClass="sakai-form-section__title" />
			<h:outputText value="#{msgs.pvt_noatt}" rendered="#{empty PrivateMessagesTool.allAttachments}" styleClass="sakai-form-help"/>
			<div class="sakai-actions">
				<h:commandButton action="#{PrivateMessagesTool.processAddAttachmentRedirect}" value="#{msgs.cdfm_button_bar_add_attachment_redirect}" accesskey="a" styleClass="sakai-btn sakai-btn-secondary" />
			</div>
			<h:dataTable styleClass="sakai-table sakai-table--sm" id="attmsgrep" width="100%"
				rendered="#{!empty PrivateMessagesTool.allAttachments}" value="#{PrivateMessagesTool.allAttachments}" var="eachAttach" >
				<h:column >
					<f:facet name="header">
						<h:outputText value="#{msgs.pvt_title}"/>
					</f:facet>
					<sakai:contentTypeMap fileType="#{eachAttach.attachment.attachmentType}" mapType="image" var="imagePath" pathPrefix="/library/image/"/>
					<h:graphicImage id="exampleFileIcon" value="#{imagePath}" />
					<h:outputLink value="#{eachAttach.url}" target="_blank">
						<h:outputText value="#{eachAttach.attachment.attachmentName}"/>
					</h:outputLink>
				</h:column>
				<h:column >
					<h:commandLink action="#{PrivateMessagesTool.processDeleteReplyAttach}" immediate="true" onfocus="document.forms[0].onsubmit();">
						<h:outputText value="#{msgs.pvt_attrem}"/>
						<f:param value="#{eachAttach.attachment.attachmentId}" name="remsg_current_attach"/>
					</h:commandLink>
				</h:column>
				<h:column>
					<f:facet name="header">
						<h:outputText value="#{msgs.pvt_attsize}" />
					</f:facet>
					<h:outputText value="#{PrivateMessagesTool.getAttachmentReadableSize(eachAttach.attachment.attachmentSize)}"/>
				</h:column>
				<h:column >
					<f:facet name="header">
						<h:outputText value="#{msgs.pvt_atttype}" />
					</f:facet>
					<h:outputText value="#{eachAttach.attachment.attachmentType}"/>
				</h:column>
			</h:dataTable>
		</div>

		<h:panelGroup layout="block" styleClass="sakai-form-section" rendered="#{PrivateMessagesTool.canUseTags}">
			<h:outputText value="#{msgs.pvt_tags_header}" styleClass="sakai-form-section__title" />
			<h:inputHidden value="#{PrivateMessagesTool.selectedTags}" id="tag_selector"></h:inputHidden>
			<sakai-tag-selector
				id="tag-selector"
				input-id="pvtMsgForward:tag_selector"
				selected-ids='<h:outputText value="#{PrivateMessagesTool.selectedTags}"/>'
				collection-id='<h:outputText value="#{PrivateMessagesTool.getSiteId()}"/>'
				site-id='<h:outputText value="#{PrivateMessagesTool.getSiteId()}"/>'
				tool='<h:outputText value="#{PrivateMessagesTool.getTagTool()}"/>'
				add-new="true"
			></sakai-tag-selector>
		</h:panelGroup>

		<div class="sakai-actions">
			<h:commandButton action="#{PrivateMessagesTool.processPvtMsgReplyAllSend}" value="#{msgs.pvt_send}" accesskey="s" styleClass="sakai-btn sakai-btn-primary" />
			<h:commandButton action="#{PrivateMessagesTool.processPvtMsgPreviewReplyAll}" value="#{msgs.pvt_preview}" accesskey="p" styleClass="sakai-btn sakai-btn-secondary" />
			<h:commandButton action="#{PrivateMessagesTool.processPvtMsgReplyAllSaveDraft}" value="#{msgs.pvt_savedraft }" styleClass="sakai-btn sakai-btn-secondary" />
			<h:commandButton action="#{PrivateMessagesTool.processPvtMsgCancelToDetailView}" value="#{msgs.pvt_cancel}" accesskey="x" styleClass="sakai-btn sakai-btn-ghost" />
		</div>
	</h:form>

	</sakai:view>
</f:view>
