<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>

<f:view>
<sakai:view>
	<span class="skip" id="firstPendingItemTitleHolder"><h:outputText value="#{msgs.cdfm_gotofirstpendingtitle}" /></span>
	<span class="skip" id="nextPendingItemTitleHolder"><h:outputText value="#{msgs.cdfm_gotopendtitle}" /></span>
	<span class="skip" id="lastPendingItemTitleHolder"><h:outputText value="#{msgs.cdfm_lastpendtitle}" /></span>
	<span class="skip" id="firstNewItemTitleHolder"><h:outputText value="#{msgs.cdfm_gotofirstnewtitle}" /></span>
	<span class="skip" id="nextNewItemTitleHolder"><h:outputText value="#{msgs.cdfm_gotonewtitle}" /></span>
	<span class="skip" id="lastNewItemTitleHolder"><h:outputText value="#{msgs.cdfm_lastnewtitle}" /></span>
	<h:form id="msgForum" styleClass="sakai-forums" rendered="#{!ForumTool.selectedTopic.topic.draft || ForumTool.selectedTopic.topic.createdBy == ForumTool.userId}">

		<!--jsp/discussionForum/message/dfViewThread.jsp-->
		<script>includeLatestJQuery("msgcntr");</script>
		<script src="/messageforums-tool/js/dialog.js"></script>
		<script src="/messageforums-tool/js/sak-10625.js"></script>
		<script src="/messageforums-tool/js/forum.js"></script>
		<script src="/messageforums-tool/js/threadScrollEvent.js"></script>
		<script>
			$(document).ready(function () {
				setupMessageNav('messagePending');
				setupMessageNav('messageNew');
			});
			var markAsNotReadText = "<h:outputText value="#{msgs.cdfm_mark_as_not_read}"/>";
			var showThreadChanges = "<h:outputText value="#{ForumTool.showThreadChanges}"/>";
			var statRead = "<h:outputText value="#{msgs.stat_forum_read}"/>";
			var newFlag = "<h:outputText value="#{msgs.cdfm_newflag}"/>";
			var isMarkAsNotReadValue = "<h:outputText value="#{ForumTool.selectedTopic.isMarkAsNotRead}"/>";
		</script>
		<% request.setAttribute("dfHeaderView", "thread"); %>
		<% request.setAttribute("dfHeaderBack", "topic"); %>
		<%@ include file="/jsp/discussionForum/menu/forumsHeader.jsp" %>

		<div class="modal fade sakai-forums__grade-modal" id="dialogDiv" data-dialog-frame="dialogFrame" tabindex="-1" role="dialog" aria-modal="true" aria-hidden="true" aria-labelledby="dialogDivLabel">
			<div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
				<div class="modal-content">
					<div class="modal-header">
						<h2 class="modal-title" id="dialogDivLabel">
							<h:outputText value="#{msgs.cdfm_grade_msg}" />
						</h2>
						<button type="button" class="btn-close" data-bs-dismiss="modal">
							<span class="visually-hidden"><h:outputText value="#{msgs.close_window}" /></span>
						</button>
					</div>
					<div class="modal-body">
						<f:verbatim>
							<iframe id="dialogFrame" name="dialogFrame" class="grade-modal-frame" title="</f:verbatim><h:outputText value="#{msgs.cdfm_grade_msg}" /><f:verbatim>"></iframe>
						</f:verbatim>
					</div>
				</div>
			</div>
		</div>

		<%@ include file="dfViewSearchBarThread.jsp"%>

		<h:outputText value="#{msgs.cdfm_postFirst_warning}" rendered="#{ForumTool.needToPostFirst}" styleClass="messageAlert"/>
        <h:panelGroup rendered="#{ForumTool.threadMoved}" >
          <span>
            <h:outputText styleClass="threadMovedMsg" value="<b>#{ForumTool.selectedThreadHead.message.title}</b> " escape="false"/>
            <h:outputText styleClass="threadMovedMsg" value="#{msgs.hasBeen} " />
            <h:commandLink action="#{ForumTool.processActionDisplayTopic}" id="topic_title" styleClass="threadMovedMsg">
              <h:outputText value="#{msgs.moved}" />
                                                    <f:param value="#{ForumTool.selectedThreadHead.message.topic.id}" name="topicId"/>
                                                    <f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
                                            </h:commandLink>
            <h:outputText styleClass="threadMovedMsg"  value=" #{msgs.anotherTopic}" />
          </span>
        </h:panelGroup>
		<div id="messNavHolder" class="sakai-actions sakai-no-print"></div>

		<h:dataTable id="expandedMessages" value="#{ForumTool.selectedThread}" var="message" rendered="#{!ForumTool.threaded}"
   	 		styleClass="sakai-table sakai-table--hover sakai-table--stack messagesFlat specialLink" columnClasses="bogus">
			<h:column>
				<%@ include file="dfViewThreadBodyInclude.jsp" %>
			</h:column>
		</h:dataTable>

		<mf:hierDataTable id="expandedThreadedMessages" value="#{ForumTool.selectedThread}" var="message" rendered="#{ForumTool.threaded}"
   	 		noarrows="true" styleClass="sakai-table sakai-table--hover sakai-table--stack messagesThreaded specialLink" columnClasses="bogus">
			<h:column id="_msg_subject">
				<%@ include file="dfViewThreadBodyInclude.jsp" %>
			</h:column>
		</mf:hierDataTable>

		<h:panelGroup layout="block" styleClass="sakai-actions sakai-forums__pager sakai-no-print">
			<h:commandLink styleClass="sakai-btn sakai-btn-secondary" action="#{ForumTool.processActionDisplayThread}" rendered="#{ForumTool.selectedThreadHead.hasPreThread}">
				<h:outputText value="" styleClass="si si-arrow-left" escape="false"/>
				<h:outputText value="#{msgs.cdfm_previous_thread}"/>
				<f:param value="#{ForumTool.selectedThreadHead.preThreadId}" name="messageId"/>
				<f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId"/>
				<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
			</h:commandLink>
			<h:commandLink styleClass="sakai-btn sakai-btn-secondary" action="#{ForumTool.processActionDisplayThread}" rendered="#{ForumTool.selectedThreadHead.hasNextThread}">
				<h:outputText value="#{msgs.cdfm_next_thread}"/>
				<h:outputText value="" styleClass="si si-arrow-right" escape="false"/>
				<f:param value="#{ForumTool.selectedThreadHead.nextThreadId}" name="messageId"/>
				<f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId"/>
				<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
			</h:commandLink>
		</h:panelGroup>

		<h:inputHidden id="mainOrForumOrTopic" value="dfViewThread" />

	<%
	  	String thisId = request.getParameter("panel");
  		if (thisId == null)
  		{
    		thisId = "Main" + org.sakaiproject.tool.cover.ToolManager.getCurrentPlacement().getId();
  		}
	%>
	<script>
		function resize(){
  			mySetMainFrameHeight('<%= org.sakaiproject.util.Web.escapeJavascript(thisId)%>');
  		}
	</script>

	</h:form>
	<h:outputText value="#{msgs.cdfm_insufficient_privileges_view_topic}" rendered="#{ForumTool.selectedTopic.topic.draft && ForumTool.selectedTopic.topic.createdBy != ForumTool.userId}" />

</sakai:view>
</f:view>
