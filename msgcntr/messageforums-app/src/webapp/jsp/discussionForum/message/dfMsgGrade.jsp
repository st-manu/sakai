<%@ page import="java.util.*, jakarta.faces.context.*, jakarta.faces.application.*,
                 jakarta.faces.el.*, org.sakaiproject.tool.messageforums.*,
                 org.sakaiproject.api.app.messageforums.*,
                 org.sakaiproject.site.cover.SiteService,
                 org.sakaiproject.tool.cover.ToolManager" %>
<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>

<f:view>
    <sakai:view>
        <script>includeLatestJQuery("msgcntr");</script>
        <script src="/messageforums-tool/js/sak-10625.js"></script>
        <script src="/messageforums-tool/js/messages.js"></script>
        <script src="/messageforums-tool/js/forum.js"></script>
        <script>includeWebjarLibrary('awesomplete')</script>
        <script src="/library/js/sakai-reminder.js"></script>
        <script type="module" src="/webcomponents/bundles/rubric-association-requirements.js<h:outputText value="#{ForumTool.CDNQuery}" />"></script>
        <script type="module" src="/webcomponents/bundles/gradebook-item-selector.js<h:outputText value="#{ForumTool.CDNQuery}" />"></script>
        <h:form id="msgForum" styleClass="sakai-forums">
            <%
            FacesContext context = FacesContext.getCurrentInstance();
            Application app = context.getApplication();
            ValueBinding binding = app.createValueBinding("#{ForumTool}");
            DiscussionForumTool forumTool = (DiscussionForumTool) binding.getValue(context);

            String messageId = request.getParameter("messageId");
            String topicId = request.getParameter("topicId");
            String forumId = request.getParameter("forumId");
            String userId = request.getParameter("userId");
            String frameId = request.getParameter("frameId");
            String dialogDivId = request.getParameter("dialogDivId");
            String gradesSavedDiv = request.getParameter("gradesSavedDiv");

            boolean isDialogBox = false;
            if (userId != null && !"".equals(userId) && forumId != null && !"".equals(forumId)) {
                isDialogBox = true;

                String noProcessing = request.getParameter("noProccessing");
                if(noProcessing == null || "". equals(noProcessing)){
                    forumTool.processDfMsgGrdFromThread(messageId, topicId, forumId, userId);
                }
            %>
            <script>
                parent.dialogutil.replaceBodyOnLoad("myLoaded();", this);
                function myLoaded() {}
            </script>
            <%
            }
            request.setAttribute("dfGradeDialog", Boolean.valueOf(isDialogBox));

            String entityId = forumTool.getRubricAssociationId();

            if (userId == null) userId = forumTool.getUserId();

            String rbcsEvaluationId = entityId + "." + userId;
            String rbcsEvaluationOwnerId = userId;
            %>

            <script>
                function closeDialogBoxIfExists() {
                    <% if (isDialogBox) { %>
                        parent.dialogutil.closeDialog('<%=dialogDivId%>','<%=frameId%>');
                    <% }%>
                }
                <%
                if (forumTool.isDialogGradeSavedSuccessfully()) {
                    forumTool.setDialogGradeSavedSuccessfully(false);
                %>
                    parent.dialogutil.showDiv('<%=gradesSavedDiv%>');
                    closeDialogBoxIfExists();
                <%
                }
                %>
            </script>
            <script src="/library/js/spinner.js"></script>
            <script>
                $(document).ready(function() {
                    try {
                        var sakaiReminder = new SakaiReminder();
                        new Awesomplete($('.awesomplete')[0], {
                            list: sakaiReminder.getAll()
                        });
                        $('#msgForum').submit(function () {
                            $('textarea.awesomplete').each(function () {
                                sakaiReminder.new($(this).val());
                            });
                        });
                    } catch (err) {}
                });
            </script>

            <h:panelGroup layout="block" styleClass="sakai-form-section" rendered="#{empty requestScope.dfGradeDialog or not requestScope.dfGradeDialog}">
                <h:outputText value="#{msgs.cdfm_grade_msg}" styleClass="sakai-form-section__title"/>
                <p class="sakai-form-section__intro">
                    <h:outputText value="#{ForumTool.selectedForum.forum.title}" />
                    <h:outputText value=" #{msgs.cdfm_dash} " rendered="#{!empty ForumTool.selectedTopic}"/>
                    <h:outputText value="#{ForumTool.selectedTopic.topic.title}" />
                </p>
            </h:panelGroup>

            <h:messages globalOnly="true" infoClass="sakai-banner sakai-banner--success" errorClass="sakai-banner sakai-banner--error" rendered="#{! empty facesContext.maximumSeverity}"/>

            <h:panelGroup layout="block" styleClass="sakai-forums__message" rendered="#{ForumTool.selectedMessage != null}">
                <div class="sakai-forums__message-header">
                    <div class="sakai-forums__message-identity">
                        <h:outputText value="#{ForumTool.selectedMessage.message.title}" styleClass="sakai-forums__title"/>
                    </div>
                    <div class="sakai-forums__message-meta">
                        <h:outputText value="#{ForumTool.selectedMessage.anonAwareAuthor}" styleClass="#{ForumTool.selectedMessage.useAnonymousId ? 'anonymousAuthor' : ''}" />
                        <h:outputText value=" #{msgs.cdfm_me}" rendered="#{ForumTool.selectedMessage.currentUserAndAnonymous}" />
                        <h:outputText value="#{ForumTool.selectedMessage.message.created}">
                            <f:convertDateTime pattern="#{msgs.date_format}" timeZone="#{ForumTool.userTimeZone}" locale="#{ForumTool.userLocale}"/>
                        </h:outputText>
                    </div>
                </div>
                <h:dataTable value="#{ForumTool.selectedMessage.attachList}" var="eachAttach" styleClass="sakai-table sakai-table--stack"
                        rendered="#{!empty ForumTool.selectedMessage.attachList}">
                    <h:column rendered="#{!empty ForumTool.selectedMessage.message.attachments}">
                        <sakai:contentTypeMap fileType="#{eachAttach.attachment.attachmentType}" mapType="image" var="imagePath" pathPrefix="/library/image/"/>
                        <h:graphicImage id="exampleFileIcon" value="#{imagePath}" alt=""/>
                        <h:outputLink value="#{eachAttach.url}" target="_blank">
                            <h:outputText value="#{eachAttach.attachment.attachmentName}" />
                        </h:outputLink>
                    </h:column>
                </h:dataTable>
                <div class="sakai-forums__message-body textPanel">
                    <h:outputText escape="false" value="#{ForumTool.selectedMessage.message.body}"/>
                </div>
            </h:panelGroup>

            <h:panelGroup layout="block" styleClass="sakai-form-section__intro" rendered="#{ForumTool.allowedToGradeItem}">
                <h:outputText value="#{msgs.cdfm_required}" />
                <h:outputText value="#{msgs.pvt_star}" styleClass="reqStarInline"/>
            </h:panelGroup>

            <h:panelGroup layout="block" styleClass="sakai-form-section" rendered="#{ForumTool.gradebookGroupEnabled}">
                <sakai-gradebook-item-selector
                        id="gb-selector" input-id="msgForum:gb_selector"
                        app-name="sakai.forums"
                        site-id='<h:outputText value="#{ForumTool.siteId}" />'
                        user-id='<h:outputText value="#{ForumTool.selectedGradedUserId}" />'
                        group-id='<h:outputText value="#{ForumTool.groupId}" />'
                        selected-temp='<h:outputText value="#{ForumTool.selectedAssign}" />'>
                </sakai-gradebook-item-selector>
                <h:inputHidden id="gb_selector" value="#{ForumTool.currentChange}" />
            </h:panelGroup>

            <div class="sakai-form-section">
                <h:panelGroup layout="block" styleClass="sakai-form-field" rendered="#{!ForumTool.hasAssociatedRubric() && !ForumTool.gradebookGroupEnabled}">
                    <h:outputLabel for="assignment" styleClass="sakai-form-label required" rendered="#{ForumTool.allowedToGradeItem}">
                        <h:outputText value="#{msgs.cdfm_assignments}"/>
                    </h:outputLabel>
                    <h:selectOneMenu id="assignment" value="#{ForumTool.selectedAssign}" valueChangeListener="#{ForumTool.processGradeAssignChange}"
                        onchange="SPNR.insertSpinnerAfter( this, null, null );document.forms[0].submit();"
                        styleClass="sakai-form-control">
                        <f:selectItems value="#{ForumTool.assignments}" />
                    </h:selectOneMenu>
                    <p class="sakai-form-section__intro">
                        <h:outputFormat value="#{msgs.cdfm_points_possible}" rendered="#{!ForumTool.selGBItemRestricted && ForumTool.gbItemPointsPossible != null && ForumTool.gradeByPoints}">
                            <f:param value="#{ForumTool.gbItemPointsPossible}"/>
                        </h:outputFormat>
                    </p>
                </h:panelGroup>

                <h:outputText value="#{msgs.cdfm_no_gb_perm}" rendered="#{ForumTool.selGBItemRestricted && !ForumTool.noItemSelected}" styleClass="sakai-banner sakai-banner--error"/>

                <h:panelGroup layout="block" styleClass="sakai-form-field" rendered="#{!ForumTool.selGBItemRestricted}">
                    <h:outputLabel for="dfMsgGradeGradePoint" styleClass="sakai-form-label required" rendered="#{ForumTool.allowedToGradeItem}">
                        <h:outputText value="#{msgs.cdfm_grade_points}" rendered="#{ForumTool.gradeByPoints}"/>
                        <h:outputText value="#{msgs.cdfm_grade_percent}" rendered="#{ForumTool.gradeByPercent}"/>
                        <h:outputText value="#{msgs.cdfm_grade_letter}" rendered="#{ForumTool.gradeByLetter}"/>
                    </h:outputLabel>
                    <h:panelGroup rendered="#{ForumTool.allowedToGradeItem}">
                        <h:inputText value="#{ForumTool.gradePoint}" id="dfMsgGradeGradePoint" size="5" styleClass="sakai-form-control" />
                        <h:outputText value="%" rendered="#{ForumTool.gradeByPercent}" />
                        <h:message for="dfMsgGradeGradePoint" styleClass="sakai-form-error" />
                    </h:panelGroup>
                    <h:panelGroup rendered="#{!ForumTool.allowedToGradeItem}">
                        <h:outputText value="#{ForumTool.gradePoint}" rendered="#{ForumTool.gradePoint != null}" />
                        <h:outputText value="#{msgs.cdfm_null_points}" rendered="#{ForumTool.gradePoint == null}" />
                    </h:panelGroup>
                </h:panelGroup>

                <h:panelGroup layout="block" styleClass="sakai-form-field" rendered="#{!ForumTool.selGBItemRestricted}">
                    <h:outputLabel for="comments" value="#{msgs.cdfm_comments}" styleClass="sakai-form-label"/>
                    <h:inputTextarea id="comments" value="#{ForumTool.gradeComment}" rows="5" cols="50"
                        styleClass="sakai-form-control awesomplete"
                        readonly="#{!ForumTool.allowedToGradeItem}"/>
                </h:panelGroup>
            </div>

            <h:panelGroup layout="block" styleClass="sakai-form-section" rendered="#{ForumTool.hasAssociatedRubric()}">
                <sakai-rubric-grading
                    tool-id="sakai.gradebookng"
                    site-id='<h:outputText value="#{ForumTool.siteId}" />'
                    entity-id='<%= entityId %>'
                    evaluated-item-id='<%= rbcsEvaluationId %>'
                    evaluated-item-owner-id='<%= rbcsEvaluationOwnerId %>'>
                </sakai-rubric-grading>
            </h:panelGroup>

            <div class="sakai-actions">
                <% if(isDialogBox){ %>
                    <h:commandButton id="save" action="#{ForumTool.processDfGradeSubmitFromDialog}" value="#{msgs.cdfm_submit_grade}"
                        accesskey="s" styleClass="sakai-btn sakai-btn-primary" disabled="#{!ForumTool.allowedToGradeItem}" onclick="SPNR.disableControlsAndSpin( this, null );MFR.saveRubric();" />
                    <h:commandButton id="cancel" action="#{ForumTool.processDfGradeCancelFromDialog}" value="#{msgs.cdfm_cancel}" accesskey="x"
                        styleClass="sakai-btn sakai-btn-ghost" onclick="MFR.cancelGrading();" />
                <% }else {%>
                    <h:commandButton action="#{ForumTool.processDfGradeSubmit}" value="#{msgs.cdfm_submit_grade}"
                        accesskey="s" styleClass="sakai-btn sakai-btn-primary" disabled="#{!ForumTool.allowedToGradeItem}"
                        onclick="SPNR.disableControlsAndSpin( this, null ); MFR.saveRubric();" />
                    <h:commandButton action="#{ForumTool.processDfGradeCancel}" value="#{msgs.cdfm_cancel}" accesskey="x"
                        styleClass="sakai-btn sakai-btn-ghost" onclick="MFR.cancelGrading();" />
                <%}%>
                <h:commandButton value="#{msgs.cdfm_send_info}" onclick="document.forms[0].submit();" accesskey="i"
                    action="#{ForumTool.processGradeAssignSend}" styleClass="sakai-btn sakai-btn-secondary" />
            </div>

            <% if(isDialogBox){ %>
            <input type="hidden" id="userId" name="userId" value="<%=userId%>"/>
            <input type="hidden" id="messageId" name="messageId" value="<%=messageId%>"/>
            <input type="hidden" id="topicId" name="topicId" value="<%=topicId%>"/>
            <input type="hidden" id="forumId" name="forumId" value="<%=forumId%>"/>
            <input type="hidden" id="frameId" name="frameId" value="<%=frameId%>"/>
            <input type="hidden" id="dialogDivId" name="dialogDivId" value="<%=dialogDivId%>"/>
            <input type="hidden" id="gradesSavedDiv" name="gradesSavedDiv" value="<%=gradesSavedDiv%>"/>
            <input type="hidden" id="noProccessing" name="noProccessing" value="true"/>
            <%}%>
        </h:form>
    </sakai:view>
</f:view>
