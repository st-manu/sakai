<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>

<f:view>
	<sakai:view title="Forums">
<link rel="stylesheet" href="/library/webjars/jquery-ui/1.12.1/jquery-ui.min.css" type="text/css" />
<!-- messageforums-app/src/webapp/jsp/discussionForum/message-->

<script>includeLatestJQuery("msgcntr");</script>
<script src="/messageforums-tool/js/json2.js"></script>
<script src="/messageforums-tool/js/forum.js"></script>
<script src="/messageforums-tool/js/frameAdjust.js"></script>
<script src="/messageforums-tool/js/forum_movethread.js"></script>

<script src="/messageforums-tool/js/sak-10625.js"></script>
<script type="module" src="/webcomponents/bundles/rubric-association-requirements.js<h:outputText value="#{ForumTool.CDNQuery}" />"></script>

<!--jsp/discussionForum/message/dfAllMessages.jsp-->
		<script src="/messageforums-tool/js/forumTopicThreadsSorter.js"></script>
		<script>
 		jQuery(document).ready(function(){
			var threadsTable = document.getElementById('msgForum:messagesInHierDataTable');
			if (threadsTable) {
				sakaiForumThreadsSorter.init(threadsTable, '<h:outputText value="#{ForumTool.userLocale}" />');
				instrumentThreads('msgForum\\:messagesInHierDataTable');
			}
			document.querySelectorAll("[data-sakai-forum-sort-trigger]").forEach(function (button) {
				button.addEventListener("click", function () {
					var mode = button.getAttribute("data-sakai-forum-sort-trigger");
					var hook = document.querySelector("#msgForum\\:messagesInHierDataTable [data-sakai-forum-sort='" + mode + "']");
					if (hook) {
						(hook.closest("th") || hook).click();
					}
				});
			});
			if (document.getElementById("msgForum:df_move_message_commandLink")) {
				enableDisableMoveThreadLink();
			}
 		});

        function disableMoveLink() {
            var movelink = document.getElementById("msgForum:df_move_message_commandLink");
            if (!movelink) {
                return;
            }
            movelink.disabled = true;
            movelink.setAttribute("aria-disabled", "true");
        }

        function enableMoveLink() {
            var movelink = document.getElementById("msgForum:df_move_message_commandLink");
            if (!movelink) {
                return;
            }
            movelink.disabled = false;
            movelink.setAttribute("aria-disabled", "false");
        }

        function enableDisableMoveThreadLink() {
            var form = document.forms['msgForum'];
            var totalChecked = 0;
            if (!form || typeof form.moveCheckbox === 'undefined') {
                disableMoveLink();
                return;
            }
            if (typeof form.moveCheckbox.length === 'undefined') {
                if (form.moveCheckbox.checked == true ) {
                    totalChecked += 1;
                }
            } else {
                var chkBoxCount = form.moveCheckbox.length;
                for (var i = 0; i < chkBoxCount; i++) {
                    if (eval("document.forms['msgForum'].moveCheckbox[" + i + "].checked") == true)
                    {
                        totalChecked += 1;
                    }
                }
            }
            if (totalChecked >0) {
                enableMoveLink();
            }
            else {
                disableMoveLink();
            }
         }
        var newFlag = "<h:outputText value="#{msgs.cdfm_newflag}"/>";
 		</script>
		<h:outputText styleClass="showMoreText"  style="display:none" value="#{msgs.cdfm_show_more_full_description}"  />

	<%--//
		//plugin required below
		<script src="/messageforums-tool/js/pxToEm.js"></script>
		
		/*
		gsilver: get a value representing max indents
	 	from the server configuraiton service or the language bundle, parse 
		all the indented items, and if the item indent goes over the value, flatten to the value 
		*/
		<script>
		$(document).ready(function() {
			// pick value from element (that gets it from language bundle)
			maxThreadDepth =$('#maxthreaddepth').text()
			// double check that this is a number
			if (isNaN(maxThreadDepth)){
				maxThreadDepth=10
			}
			// for each message, if the message is indented more than the value above
			// void that and set the new indent to the value
			$("td.messageTitle").each(function (i) {
				paddingDepth= $(this).css('padding-left').split('px');
				if ( paddingDepth[0] > parseInt(maxThreadDepth.pxToEm ({scope:'body', reverse:true}))){
					$(this).css ('padding-left', maxThreadDepth + 'em');
				}
			});
		});

		</script>	
		// element into which the value gets insert and retrieved from
		<span class="highlight"  id="maxthreaddepth" class="skip"><h:outputText value="#{msgs.cdfm_maxthreaddepth}" /></span>
//--%>
	<h:form id="msgForum" styleClass="sakai-forums" rendered="#{!ForumTool.selectedTopic.topic.draft || ForumTool.selectedTopic.topic.createdBy == ForumTool.userId}">
		<% request.setAttribute("dfHeaderView", "topic"); %>
		<% request.setAttribute("dfHeaderBack", "forum"); %>
		<%@ include file="/jsp/discussionForum/menu/forumsHeader.jsp" %>
        <f:subview id="picker2">
            <%@ include file="moveThreadPicker.jsp" %>
        </f:subview>

 		<h:messages styleClass="sakai-banner sakai-banner--error" id="errorMessages" rendered="#{! empty facesContext.maximumSeverity}" />

		<div class="sakai-segmented-control">
			<span class="sakai-segmented-control__btn is-active" aria-current="page"><h:outputText value="#{msgs.msg_view_threaded}"/></span>
			<h:commandLink immediate="true" action="#{ForumTool.processActionDisplayFlatView}" styleClass="sakai-segmented-control__btn">
				<h:outputText value="#{msgs.cdfm_flat_view_label}"/>
			</h:commandLink>
		</div>

		<div class="sakai-forums__forum-header">
			<div class="sakai-forums__forum-identity">
				<h:outputText id="draft" styleClass="sakai-forums__status sakai-forums__status--draft"
						value="#{msgs.cdfm_draft}" rendered="#{ForumTool.selectedTopic.topic.draft == 'true'}"/>
				<h:panelGroup styleClass="sakai-forums__status" rendered="#{ForumTool.selectedTopic.topic.availability == 'false'}">
					<span class="si si-calendar-x" aria-hidden="true"></span>
					<h:outputText value="#{msgs.topic_restricted_message}"/>
				</h:panelGroup>
				<h:panelGroup styleClass="sakai-forums__status" rendered="#{ForumTool.selectedForum.locked == 'true'}">
					<span class="si si-locked" aria-hidden="true"></span>
					<span class="visually-hidden"><h:outputText value="#{msgs.cdfm_forum_locked}"/></span>
				</h:panelGroup>
				<h:panelGroup styleClass="sakai-forums__status" rendered="#{ForumTool.selectedForum.locked != 'true' && ForumTool.selectedTopic.locked == 'true'}">
					<span class="si si-locked" aria-hidden="true"></span>
					<span class="visually-hidden">
						<h:outputFormat value="#{msgs.cdfm_topic_locked}">
							<f:param value="#{ForumTool.selectedTopic.topic.title}"/>
						</h:outputFormat>
					</span>
				</h:panelGroup>
				<h:panelGroup rendered="#{ForumTool.selectedTopic.hasRubric == 'true'}">
					<sakai-rubric-student-preview-button
						site-id='<h:outputText value="#{ForumTool.siteId}" />'
						display="icon"
						tool-id="sakai.gradebookng"
						entity-id="<h:outputText value="#{ForumTool.selectedTopic.gradeAssign}" />">
					</sakai-rubric-student-preview-button>
				</h:panelGroup>
				<h:outputText id="topic_moderated" value="#{msgs.cdfm_forum_moderated_flag}" styleClass="sakai-forums__meta"
						rendered="#{ForumTool.selectedTopic.moderated == 'true'}"/>
			</div>
			<h:outputText value="#{ForumTool.selectedTopic.topic.shortDescription}" styleClass="sakai-forums__description"
					rendered="#{!empty ForumTool.selectedTopic.topic.shortDescription}"/>
			<f:subview id="longDesc" rendered="#{!empty ForumTool.selectedTopic.attachList || (ForumTool.selectedTopic.topic.extendedDescription != '' && ForumTool.selectedTopic.topic.extendedDescription != null && ForumTool.selectedTopic.topic.extendedDescription != '<br/>')}">
				<h:panelGroup layout="block" id="openLinkBlock" styleClass="toggleParent openLinkBlock">
					<a href="#" id="showMessage" class="toggle show">
						<span class="si si-chevron-down" aria-hidden="true"></span>
						<h:outputText value=" #{msgs.cdfm_read_full_description}"/>
						<h:outputText value=" #{msgs.cdfm_and}" rendered="#{!empty ForumTool.selectedTopic.attachList}"/>
						<h:outputText value=" #{msgs.cdfm_attach}" rendered="#{!empty ForumTool.selectedTopic.attachList}"/>
					</a>
				</h:panelGroup>
				<h:panelGroup layout="block" id="hideLinkBlock" styleClass="toggleParent hideLinkBlock display-none">
					<a href="#" id="hideMessage" class="toggle show">
						<span class="si si-chevron-up" aria-hidden="true"></span>
						<h:outputText value=" #{msgs.cdfm_hide_full_description}"/>
						<h:outputText value=" #{msgs.cdfm_and}" rendered="#{!empty ForumTool.selectedTopic.attachList}"/>
						<h:outputText value=" #{msgs.cdfm_attach}" rendered="#{!empty ForumTool.selectedTopic.attachList}"/>
					</a>
				</h:panelGroup>
				<h:panelGroup layout="block" id="fullTopicDescription" styleClass="textPanel fullTopicDescription display-none">
					<h:outputText escape="false" value="#{ForumTool.selectedTopic.topic.extendedDescription}"/>
					<h:dataTable styleClass="sakai-table sakai-table--stack attachListTable" value="#{ForumTool.selectedTopic.attachList}"
							var="eachAttach" rendered="#{!empty ForumTool.selectedTopic.attachList}">
						<h:column>
							<sakai:contentTypeMap fileType="#{eachAttach.attachment.attachmentType}" mapType="image" var="imagePath" pathPrefix="/library/image/"/>
							<h:graphicImage id="exampleFileIcon" value="#{imagePath}" alt=""/>
						</h:column>
						<h:column>
							<h:outputLink value="#{eachAttach.url}" target="_blank">
								<h:outputText value="#{eachAttach.attachment.attachmentName}"/>
							</h:outputLink>
						</h:column>
					</h:dataTable>
				</h:panelGroup>
			</f:subview>
		</div>

		<h:outputText styleClass="messageAlert" value="#{msgs.cdfm_postFirst_warning}" rendered="#{ForumTool.selectedTopic != null && ForumTool.needToPostFirst}"/>
		<h:panelGroup layout="block" styleClass="sakai-forums__empty" rendered="#{ForumTool.selectedTopic == null || (empty ForumTool.selectedTopic.messages && !ForumTool.needToPostFirst)}">
			<p class="sakai-forums__empty-text"><h:outputText value="#{msgs.cdfm_no_messages}"/></p>
			<h:commandLink immediate="true" action="#{ForumTool.processAddMessage}" styleClass="sakai-btn sakai-btn-primary"
					rendered="#{ForumTool.selectedTopic != null && ForumTool.selectedTopic.isNewResponse && !ForumTool.selectedTopic.locked && !ForumTool.selectedForum.locked}">
				<h:outputText value="" styleClass="si si-add" escape="false"/>
				<h:outputText value="#{msgs.cdfm_container_title_thread}"/>
			</h:commandLink>
		</h:panelGroup>
		<h:panelGroup layout="block" rendered="#{!empty ForumTool.messages}">
            <div id="checkbox" class="sakai-table-wrap">
			<div class="sakai-table-toolbar sakai-table-toolbar--compact-only sakai-no-print">
				<div class="sakai-table-toolbar__filters" role="group">
					<button type="button" class="sakai-btn sakai-btn-ghost" data-sakai-forum-sort-trigger="thread" aria-pressed="false">
						<h:outputText value="#{msgs.sort_thread}"/>
					</button>
					<button type="button" class="sakai-btn sakai-btn-ghost" data-sakai-forum-sort-trigger="author" aria-pressed="false">
						<h:outputText value="#{msgs.sort_author}"/>
					</button>
					<button type="button" class="sakai-btn sakai-btn-ghost" data-sakai-forum-sort-trigger="date" aria-pressed="false">
						<h:outputText value="#{msgs.sort_date}"/>
					</button>
				</div>
			</div>
			<mf:hierDataTable styleClass="sakai-table sakai-table--hover sakai-table--stack allMessages" id="messagesInHierDataTable" value="#{ForumTool.messages}" var="message" expanded="#{ForumTool.expanded}"
					columnClasses="sakai-table__select,sakai-forums__thread-toggle,sakai-table__primary messageTitle,sakai-table__nowrap,sakai-table__nowrap,sakai-table__actions">
			<h:column id="_checkbox">
				<f:facet name="header">
					<h:graphicImage value="/images/expand-collapse.gif" alt="#{msgs.expandAll}" title="#{msgs.expandAll}"/>
				</f:facet>
			</h:column>
			<h:column id="_toggle">
				<f:facet name="header">
					<h:outputText value="#{msgs.expandAll}" styleClass="visually-hidden"/>
				</f:facet>
			</h:column>
			<h:column id="_msg_subject">
				<f:facet name="header">
					<h:outputLink value="#" title="#{msgs.sort_thread}" styleClass="sakai-table__sort sakai-table__sort--desktop">
						<f:verbatim><span data-sakai-forum-sort="thread"></span></f:verbatim>
						<h:outputText value="#{msgs.cdfm_thread}"/>
					</h:outputLink>
				</f:facet>

				<%-- moved--%>
				<h:panelGroup rendered="#{message.moved}" styleClass="sakai-forums__moved">
					<h:outputText value="#{message.message.title} " styleClass="sakai-forums__meta"/>
					<h:commandLink action="#{ForumTool.processActionDisplayTopic}" id="topic_title">
						<h:outputText value="#{msgs.moved}"/>
						<f:param value="#{message.message.topic.id}" name="topicId"/>
						<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
					</h:commandLink>
					<h:outputText value=" #{message.message.topic.title}" styleClass="sakai-forums__meta"/>
				</h:panelGroup>
				<%-- moved--%>

				<%-- NOT moved--%>
				<h:panelGroup rendered="#{!message.moved}">
				<h:outputText escape="false" value="<a id=\"#{message.message.id}\" name=\"#{message.message.id}\"></a>" />
					<%-- display deleted message linked if any child messages (not deleted)
						displays the message "this message has been deleted" if the message has been, um deleted, leaves reply children in place --%>
					<h:panelGroup styleClass="inactive firstChild" rendered="#{message.deleted && message.depth == 0 && message.childCount > 0}">
					<h:commandLink action="#{ForumTool.processActionDisplayThread}" immediate="true" title="#{msgs.cdfm_msg_deleted_label}" >
						<h:outputText value="#{msgs.cdfm_msg_deleted_label}" />
       	    			<f:param value="#{message.message.id}" name="messageId"/>
   	    		    	<f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId"/>
    			    	<f:param value="#{ForumTool.selectedTopic.topic.baseForum.id}" name="forumId"/>
					</h:commandLink>
				</h:panelGroup>
				
					<h:panelGroup rendered="#{!message.deleted}" layout="block" styleClass="sakai-forums__thread-title firstChild">
						<h:panelGroup>
							<h:outputText styleClass="messageNew" value="#{msgs.cdfm_newflag}" rendered="#{!message.read}"/>
							<h:outputText value="#{msgs.cdfm_msg_pending_label}" styleClass="messagePending" rendered="#{message.msgPending}" />
							<h:outputText value="#{msgs.cdfm_msg_denied_label}" styleClass="messageDenied" rendered="#{message.msgDenied}" />
							<h:commandLink styleClass="messagetitlelink" action="#{ForumTool.processActionDisplayThread}" immediate="true" title="#{message.message.title}"
									rendered="#{message.depth == 0}">
								<h:outputText value="#{message.message.title}" rendered="#{message.read && message.childUnread == 0 }" />
								<h:outputText styleClass="unreadMsg" value="#{message.message.title}" rendered="#{!message.read || message.childUnread > 0}"/>
								<f:param value="#{message.message.id}" name="messageId"/>
								<f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId"/>
								<f:param value="#{ForumTool.selectedTopic.topic.baseForum.id}" name="forumId"/>
							</h:commandLink>
							<h:commandLink styleClass="messagetitlelink" action="#{ForumTool.processActionDisplayMessage}" immediate="true" title=" #{message.message.title}"
									rendered="#{message.depth != 0}" >
								<h:outputText value="#{message.message.title}" rendered="#{message.read}" />
								<h:outputText styleClass="unreadMsg" value="#{message.message.title}" rendered="#{!message.read}"/>
								<f:param value="#{message.message.id}" name="messageId"/>
								<f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId"/>
								<f:param value="#{ForumTool.selectedTopic.topic.baseForum.id}" name="forumId"/>
							</h:commandLink>
						</h:panelGroup>
						<h:panelGroup layout="block" styleClass="sakai-forums__thread-meta" rendered="#{message.depth == 0}">
							<h:outputText styleClass="childrenNew childrenNewNumber" id="topic_msg_count55" value="#{(message.childUnread) + (message.read ? 0 : 1)}"
									rendered="#{((message.childUnread) + (message.read ? 0 : 1)) >= 1}"/>
							<h:outputText styleClass="childrenNew" id="topic_msg_count56" value=" #{msgs.cdfm_lowercase_unread_msg}"
									rendered="#{((message.childUnread) + (message.read ? 0 : 1)) >= 1}"/>
							<h:outputText styleClass="childrenZero childrenNewZero" id="topic_msg_count57" value="#{(message.childUnread) + (message.read ? 0 : 1)}"
									rendered="#{((message.childUnread) + (message.read ? 0 : 1)) == 0}"/>
							<h:outputText styleClass="childrenZero" id="topic_msg_unread_count57" value=" #{msgs.cdfm_lowercase_unread_msg}"
									rendered="#{((message.childUnread) + (message.read ? 0 : 1)) == 0}"/>
							<h:outputText styleClass="textPanelFooter" id="topic_msg_count58" value=" #{msgs.cdfm_of} #{message.childCount + 1} #{msgs.cdfm_lowercase_msg}"
									rendered="#{message.childCount ==0}"  />
							<h:outputText styleClass="textPanelFooter" id="topic_msg_count59" value=" #{msgs.cdfm_of} #{message.childCount + 1} #{msgs.cdfm_lowercase_msgs}"
									rendered="#{message.childCount >=1}"  />
						</h:panelGroup>
					</h:panelGroup>
					<h:panelGroup styleClass="inactive firstChild" rendered="#{message.deleted && (message.depth != 0 || message.childCount == 0)}" >
						<h:outputText value="#{msgs.cdfm_msg_deleted_label}" />
					</h:panelGroup>
				</h:panelGroup>
			</h:column>
			<h:column>
				<f:facet name="header">
					<h:outputLink value="#" title="#{msgs.sort_author}" styleClass="sakai-table__sort sakai-table__sort--desktop">
						<f:verbatim><span data-sakai-forum-sort="author"></span></f:verbatim>
						<h:outputText value="#{msgs.cdfm_authoredby}"/>
					</h:outputLink>
				</f:facet>
				<h:panelGroup rendered="#{!message.deleted}" >
                    <h:outputText value="#{message.anonAwareAuthor}" rendered="#{!ForumTool.instructor || message.useAnonymousId}" styleClass="#{message.useAnonymousId ? 'anonymousAuthor' : ''}" />
                    <h:outputText value=" #{msgs.cdfm_me}" rendered="#{message.currentUserAndAnonymous}" />
                    <h:commandLink action="#{mfStatisticsBean.processActionStatisticsUser}" immediate="true" title=" #{message.anonAwareAuthor}" rendered="#{ForumTool.instructor && !message.useAnonymousId}" styleClass="#{message.useAnonymousId ? 'anonymousAuthor' : ''}">
                        <f:param value="#{message.authorEid}" name="siteUserId"/>
                        <h:outputText value="#{message.anonAwareAuthor}" />
                    </h:commandLink>
				</h:panelGroup>
			</h:column>
				<%-- date column --%>
			<h:column>
				<f:facet name="header">
					<h:outputLink value="#" title="#{msgs.sort_date}" styleClass="sakai-table__sort sakai-table__sort--desktop">
						<f:verbatim><span data-sakai-forum-sort="date"></span></f:verbatim>
						<h:outputText value="#{msgs.cdfm_date}"/>
					</h:outputLink>
				</f:facet>
				<h:panelGroup rendered="#{!message.deleted}" >
					<h:outputText value="#{message.message.created}" rendered="#{message.read}">
						<f:convertDateTime pattern="#{msgs.date_format}" timeZone="#{ForumTool.userTimeZone}" locale="#{ForumTool.userLocale}"/>
					</h:outputText>
					<h:outputText styleClass="unreadMsg" value="#{message.message.created}" rendered="#{!message.read}">
						<f:convertDateTime pattern="#{msgs.date_format}" timeZone="#{ForumTool.userTimeZone}" locale="#{ForumTool.userLocale}"/>
					</h:outputText>
				</h:panelGroup>
			</h:column>
			<h:column rendered="#{ForumTool.selectedTopic.isMarkAsNotRead and not ForumTool.selectedTopic.topic.autoMarkThreadsRead}">
				<f:facet name="header">
					<h:outputText value="#{msgs.cdfm_other_actions}" styleClass="visually-hidden"/>
				</f:facet>
				<h:panelGroup layout="block" styleClass="sakai-row-actions" rendered="#{message.read and !message.deleted}">
					<details class="sakai-overflow-menu sakai-no-print">
						<summary class="sakai-btn sakai-btn-icon sakai-overflow-menu__toggle">
							<h:outputText value="" styleClass="si si-three-dots" escape="false"/>
							<h:outputText value="#{msgs.pvt_more_actions}" styleClass="visually-hidden"/>
						</summary>
						<div class="sakai-overflow-menu__panel">
							<h:outputLink value="javascript:void(0);" title="#{msgs.cdfm_mark_as_not_read}" styleClass="markAsNotReadIcon"
									onclick="doAjax(#{message.message.id}, #{ForumTool.selectedTopic.topic.id}, this); return false;">
								<h:outputText value="#{msgs.cdfm_mark_as_not_read}"/>
							</h:outputLink>
						</div>
					</details>
				</h:panelGroup>
			</h:column>
		</mf:hierDataTable>
			</div>
			<h:panelGroup layout="block" styleClass="sakai-actions sakai-forums__selection sakai-no-print" rendered="#{ForumTool.selectedTopic.isMovePostings}">
				<h:commandLink value="" action="#{ForumTool.processMoveThread}" id="hidden_move_message_commandLink" styleClass="visually-hidden">
				</h:commandLink>
				<h:commandLink value="" action="$('.topic-picker').dialog('close');" id="hidden_close_move_thread" styleClass="visually-hidden">
				</h:commandLink>
				<button type="button" class="sakai-btn sakai-btn-primary display-topic-picker" id="msgForum:df_move_message_commandLink" onclick="resizeFrameForDialog();" disabled="disabled" aria-disabled="true">
					<h:outputText value="#{msgs.move_thread}"/>
				</button>
			</h:panelGroup>
		</h:panelGroup>

		<h:panelGroup layout="block" styleClass="sakai-actions sakai-forums__pager sakai-no-print">
			<h:panelGroup styleClass="sakai-btn sakai-btn-secondary is-disabled" rendered="#{!ForumTool.selectedTopic.hasPreviousTopic}">
				<h:outputText value="#{msgs.cdfm_previous_topic}"/>
			</h:panelGroup>
			<h:commandLink styleClass="sakai-btn sakai-btn-secondary" action="#{ForumTool.processActionDisplayPreviousTopic}" rendered="#{ForumTool.selectedTopic.hasPreviousTopic}" title="#{msgs.cdfm_previous_topic}">
				<h:outputText value="#{msgs.cdfm_previous_topic}"/>
				<f:param value="#{ForumTool.selectedTopic.previousTopicId}" name="previousTopicId"/>
				<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
			</h:commandLink>
			<h:panelGroup styleClass="sakai-btn sakai-btn-secondary is-disabled" rendered="#{!ForumTool.selectedTopic.hasNextTopic}">
				<h:outputText value="#{msgs.cdfm_next_topic}"/>
			</h:panelGroup>
			<h:commandLink styleClass="sakai-btn sakai-btn-secondary" action="#{ForumTool.processActionDisplayNextTopic}" rendered="#{ForumTool.selectedTopic.hasNextTopic}" title="#{msgs.cdfm_next_topic}">
				<h:outputText value="#{msgs.cdfm_next_topic}"/>
				<f:param value="#{ForumTool.selectedTopic.nextTopicId}" name="nextTopicId"/>
				<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
			</h:commandLink>
		</h:panelGroup>
		
<input type="hidden" id="selectedTopicid" name="selectedTopicid" class="selectedTopicid" value="0" />
<input type="hidden" id="moveReminder" name="moveReminder" class="moveReminder" value="false" />

		<h:inputHidden id="mainOrForumOrTopic" value="dfAllMessages" />
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
