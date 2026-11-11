<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>
<f:view>
<sakai:view>
	<h:form id="msgForum" styleClass="sakai-forums" rendered="#{!ForumTool.selectedForum.forum.draft || ForumTool.selectedForum.forum.createdBy == ForumTool.userId}">
		<script>includeLatestJQuery("msgcntr");</script>
		<script src="/messageforums-tool/js/sak-10625.js"></script>
		<script src="/messageforums-tool/js/forum.js"></script>
		<script type="module" src="/webcomponents/bundles/rubric-association-requirements.js<h:outputText value="#{ForumTool.CDNQuery}" />"></script>
<!--jsp/discussionForum/forum/dfForumDetail.jsp-->

		<% request.setAttribute("dfHeaderView", "forum"); %>
		<% request.setAttribute("dfHeaderBack", "discussions"); %>
		<%@ include file="/jsp/discussionForum/menu/forumsHeader.jsp" %>
		<h:outputText styleClass="showMoreText" style="display:none" value="#{msgs.cdfm_show_more_full_description}"/>

		<div class="sakai-forums__forum-header">
			<div class="sakai-forums__forum-identity">
				<h:outputText id="draft" styleClass="sakai-forums__status sakai-forums__status--draft"
						value="#{msgs.cdfm_draft}" rendered="#{ForumTool.selectedForum.forum.draft == 'true'}"/>
				<h:panelGroup styleClass="sakai-forums__status" rendered="#{ForumTool.selectedForum.forum.availability == 'false'}">
					<span class="si si-calendar-x" aria-hidden="true"></span>
					<span class="visually-hidden"><h:outputText value="#{msgs.forum_restricted_message}" escape="false"/></span>
				</h:panelGroup>
				<h:panelGroup styleClass="sakai-forums__status" rendered="#{ForumTool.selectedForum.locked == 'true'}">
					<span class="si si-locked" aria-hidden="true"></span>
					<span class="visually-hidden"><h:outputText value="#{msgs.cdfm_forum_locked}" escape="false"/></span>
				</h:panelGroup>
				<h:panelGroup rendered="#{ForumTool.selectedForum.hasRubric == 'true'}">
					<sakai-rubric-student-preview-button
						site-id='<h:outputText value="#{ForumTool.siteId}" />'
						display="icon"
						tool-id="sakai.gradebookng"
						entity-id="<h:outputText value="#{ForumTool.selectedForum.gradeAssign}" />">
					</sakai-rubric-student-preview-button>
				</h:panelGroup>
				<h:outputText value="#{msgs.cdfm_forum_moderated_flag}" styleClass="sakai-forums__meta"
						rendered="#{ForumTool.selectedForum.moderated == 'true'}"/>
			</div>
			<h:outputText value="#{ForumTool.selectedForum.forum.shortDescription}" styleClass="sakai-forums__description"
					rendered="#{!empty ForumTool.selectedForum.forum.shortDescription}"/>
			<f:subview id="longDesc" rendered="#{!empty ForumTool.selectedForum.attachList || (ForumTool.selectedForum.forum.extendedDescription != '' && ForumTool.selectedForum.forum.extendedDescription != null && ForumTool.selectedForum.forum.extendedDescription != '<br/>')}">
				<h:panelGroup layout="block" id="openLinkBlock" styleClass="toggleParent openLinkBlock">
					<a href="#" id="showMessage" class="toggle show">
						<span class="si si-chevron-down" aria-hidden="true"></span>
						<h:outputText value=" #{msgs.cdfm_read_full_description}"/>
						<h:outputText value=" #{msgs.cdfm_and}" rendered="#{!empty ForumTool.selectedForum.attachList}"/>
						<h:outputText value=" #{msgs.cdfm_attach}" rendered="#{!empty ForumTool.selectedForum.attachList}"/>
					</a>
				</h:panelGroup>
				<h:panelGroup layout="block" id="hideLinkBlock" styleClass="toggleParent hideLinkBlock display-none">
					<a href="#" id="hideMessage" class="toggle show">
						<span class="si si-chevron-up" aria-hidden="true"></span>
						<h:outputText value=" #{msgs.cdfm_hide_full_description}"/>
						<h:outputText value=" #{msgs.cdfm_and}" rendered="#{!empty ForumTool.selectedForum.attachList}"/>
						<h:outputText value=" #{msgs.cdfm_attach}" rendered="#{!empty ForumTool.selectedForum.attachList}"/>
					</a>
				</h:panelGroup>
				<h:panelGroup layout="block" id="fullTopicDescription" styleClass="textPanel fullTopicDescription display-none">
					<h:outputText escape="false" value="#{ForumTool.selectedForum.forum.extendedDescription}"/>
					<h:dataTable styleClass="sakai-table sakai-table--stack attachListTable" value="#{ForumTool.selectedForum.attachList}"
							var="eachAttach" rendered="#{!empty ForumTool.selectedForum.attachList}">
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
			<f:subview id="dates" rendered="#{ForumTool.showAvailabilityDates == 'true' && ForumTool.selectedForum.availabilityRestricted == 'true'}">
				<details class="sakai-forums__dates">
					<summary>
						<span class="si si-calendar" aria-hidden="true"></span>
						<h:outputText value="#{msgs.cdfm_read_dates}"/>
					</summary>
					<p class="sakai-forums__meta">
						<h:outputText value="#{msgs.openDate}: #{ForumTool.selectedForum.formattedOpenDate}"/>
						<br/>
						<h:outputText value="#{msgs.closeDate}: #{ForumTool.selectedForum.formattedCloseDate}"/>
					</p>
				</details>
			</f:subview>
		</div>

		<h:panelGroup layout="block" styleClass="sakai-forums__empty" rendered="#{empty ForumTool.selectedForum.topics}">
			<p class="sakai-forums__empty-text"><h:outputText value="#{msgs.cdfm_no_topics}"/></p>
			<h:commandLink action="#{ForumTool.processActionNewTopic}" styleClass="sakai-btn sakai-btn-primary"
					rendered="#{ForumTool.selectedForum.newTopic}">
				<h:outputText value="" styleClass="si si-add" escape="false"/>
				<h:outputText value="#{msgs.cdfm_new_topic}"/>
				<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
			</h:commandLink>
		</h:panelGroup>

		<h:panelGroup layout="block" styleClass="sakai-table-wrap" rendered="#{!empty ForumTool.selectedForum.topics}">
			<h:dataTable id="topics" value="#{ForumTool.selectedForum.topics}" var="topic"
					styleClass="sakai-table sakai-table--hover sakai-table--stack sakai-forums__topics"
					columnClasses="sakai-table__primary,sakai-table__nowrap,sakai-table__nowrap,sakai-table__actions"
					rowClasses="sakai-forums__topic-row">
				<h:column>
					<f:facet name="header">
						<h:outputText value="#{msgs.cdfm_topics}"/>
					</f:facet>
					<h:panelGroup layout="block" rendered="#{!topic.nonePermission}">
						<h:panelGroup rendered="#{ForumTool.selectedForum.forum.draft == 'true'}">
							<span class="si si-warning sakai-forums__topic-icon" aria-hidden="true"></span>
							<span class="visually-hidden"><h:outputText value="#{msgs.cdfm_forum_draft_topic_unavailable}" escape="false"/></span>
						</h:panelGroup>
						<h:panelGroup rendered="#{ForumTool.selectedForum.forum.draft != 'true'}">
							<h:outputText styleClass="si si-folder sakai-forums__topic-icon" rendered="#{topic.unreadNoMessages == 0}" escape="false"/>
							<h:outputText styleClass="si si-folder-fill sakai-forums__topic-icon" rendered="#{topic.unreadNoMessages > 0}" escape="false"/>
						</h:panelGroup>
						<h:outputText id="draft" styleClass="sakai-forums__status sakai-forums__status--draft draftTopic"
								value="#{msgs.cdfm_draft}" rendered="#{topic.topic.draft == 'true'}"/>
						<h:panelGroup styleClass="sakai-forums__status" rendered="#{topic.availability == 'false'}">
							<span class="si si-calendar-x" aria-hidden="true"></span>
							<span class="visually-hidden"><h:outputText value="#{msgs.topic_restricted_message}" escape="false"/></span>
						</h:panelGroup>
						<h:panelGroup styleClass="sakai-forums__status" rendered="#{ForumTool.selectedForum.locked == 'true' || topic.locked == 'true'}">
							<span class="si si-locked" aria-hidden="true"></span>
							<span class="visually-hidden"><h:outputText value="#{msgs.cdfm_forum_locked}" escape="false"/></span>
						</h:panelGroup>
						<h:panelGroup rendered="#{topic.hasRubric == 'true'}">
							<sakai-rubric-student-preview-button
								site-id='<h:outputText value="#{ForumTool.siteId}" />'
								display="icon"
								tool-id="sakai.gradebookng"
								entity-id="<h:outputText value="#{topic.gradeAssign}" />">
							</sakai-rubric-student-preview-button>
						</h:panelGroup>
						<h:commandLink action="#{ForumTool.processActionDisplayTopic}" id="topic_title"
								title="#{topic.topic.title}"
								styleClass="#{ForumTool.selectedForum.forum.draft == 'true' ? 'sakai-forums__title draft-forum-topic' : 'sakai-forums__title'}">
							<f:param value="#{topic.topic.id}" name="topicId"/>
							<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
							<h:outputText value="#{topic.topic.title}"/>
						</h:commandLink>
						<h:outputText id="topic_moderated" value="#{msgs.cdfm_topic_moderated_flag}" styleClass="sakai-forums__meta"
								rendered="#{topic.moderated == 'true' && topic.isRead && ForumTool.selectedForum.forum.draft != 'true'}"/>
						<h:outputText id="topic_desc" value="#{topic.topic.shortDescription}" styleClass="sakai-forums__description"
								rendered="#{!empty topic.topic.shortDescription}"/>
						<f:subview id="longDescTopic" rendered="#{!empty topic.attachList || (topic.topic.extendedDescription != '' && topic.topic.extendedDescription != null && topic.topic.extendedDescription != '<br/>')}">
							<h:panelGroup layout="block" id="openLinkBlock" styleClass="toggleParent openLinkBlock">
								<a href="#" id="showMessage" class="toggle show">
									<span class="si si-chevron-down" aria-hidden="true"></span>
									<h:outputText value=" #{msgs.cdfm_read_full_description}"/>
									<h:outputText value=" #{msgs.cdfm_and}" rendered="#{!empty topic.attachList}"/>
									<h:outputText value=" #{msgs.cdfm_attach}" rendered="#{!empty topic.attachList}"/>
								</a>
							</h:panelGroup>
							<h:panelGroup layout="block" id="hideLinkBlock" styleClass="toggleParent hideLinkBlock display-none">
								<a href="#" id="hideMessage" class="toggle show">
									<span class="si si-chevron-up" aria-hidden="true"></span>
									<h:outputText value=" #{msgs.cdfm_hide_full_description}"/>
									<h:outputText value=" #{msgs.cdfm_and}" rendered="#{!empty topic.attachList}"/>
									<h:outputText value=" #{msgs.cdfm_attach}" rendered="#{!empty topic.attachList}"/>
								</a>
							</h:panelGroup>
							<h:panelGroup layout="block" id="fullTopicDescription" styleClass="textPanel fullTopicDescription display-none">
								<h:outputText escape="false" value="#{topic.topic.extendedDescription}"/>
								<h:dataTable styleClass="sakai-table sakai-table--stack attachListTable" value="#{topic.attachList}"
										var="eachAttach" rendered="#{!empty topic.attachList}">
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
					</h:panelGroup>
				</h:column>
				<h:column>
					<f:facet name="header">
						<h:outputText value="#{msgs.cdfm_messages}"/>
					</f:facet>
					<h:outputText id="topic_msg_count" value="#{topic.totalNoMessages}"
							rendered="#{!topic.nonePermission && topic.isRead && ForumTool.selectedForum.forum.draft != 'true' && topic.totalNoMessages == 1}"/>
					<h:outputText id="topic_msgs_count" value="#{topic.totalNoMessages}"
							rendered="#{!topic.nonePermission && topic.isRead && ForumTool.selectedForum.forum.draft != 'true' && topic.totalNoMessages != 1}"/>
				</h:column>
				<h:column>
					<f:facet name="header">
						<h:outputText value="#{msgs.cdfm_unread}"/>
					</f:facet>
					<h:outputText id="topic_msg_count_unread" value="#{topic.unreadNoMessages}"
							styleClass="sakai-forums__unread"
							rendered="#{!topic.nonePermission && topic.isRead && ForumTool.selectedForum.forum.draft != 'true' && topic.unreadNoMessages >= 1}"/>
					<h:outputText id="topic_msgs_count0_unread" value="#{topic.unreadNoMessages}"
							rendered="#{!topic.nonePermission && topic.isRead && ForumTool.selectedForum.forum.draft != 'true' && topic.unreadNoMessages == 0}"/>
				</h:column>
				<h:column>
					<f:facet name="header">
						<h:outputText value="#{msgs.cdfm_other_actions}" styleClass="visually-hidden"/>
					</f:facet>
					<h:panelGroup layout="block" styleClass="sakai-row-actions"
							rendered="#{!topic.nonePermission && (topic.changeSettings || ForumTool.selectedForum.newTopic || ForumTool.instructor)}">
						<details class="sakai-overflow-menu">
							<summary class="sakai-overflow-menu__toggle">
								<span class="si si-three-dots" aria-hidden="true"></span>
								<h:outputText value="#{msgs.pvt_more_actions}" styleClass="visually-hidden"/>
							</summary>
							<div class="sakai-overflow-menu__panel">
								<h:commandLink action="#{ForumTool.processActionTopicSettings}" id="topic_setting"
										rendered="#{topic.changeSettings}">
									<h:outputText value="#{msgs.cdfm_topic_settings}"/>
									<f:param value="#{topic.topic.id}" name="topicId"/>
									<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
								</h:commandLink>
								<h:commandLink action="#{ForumTool.processActionDuplicateTopicMainConfirm}" id="duplicate_confirm"
										rendered="#{ForumTool.selectedForum.newTopic}">
									<h:outputText value="#{msgs.cdfm_duplicate_topic}"/>
									<f:param value="#{topic.topic.id}" name="topicId"/>
									<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
								</h:commandLink>
								<h:commandLink action="#{mfStatisticsBean.processActionStatisticsByTopic}" immediate="true"
										rendered="#{ForumTool.instructor}">
									<h:outputText value="#{msgs.cdfm_button_bar_grade}"/>
									<f:param value="#{topic.topic.id}" name="topicId"/>
									<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
								</h:commandLink>
								<h:commandLink action="#{ForumTool.processActionDeleteTopicMainConfirm}" id="delete_confirm"
										rendered="#{topic.changeSettings}">
									<h:outputText value="#{msgs.cdfm_button_bar_delete_topic}"/>
									<f:param value="#{topic.topic.id}" name="topicId"/>
									<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
								</h:commandLink>
							</div>
						</details>
					</h:panelGroup>
				</h:column>
			</h:dataTable>
		</h:panelGroup>
		<h:inputHidden id="mainOrForumOrTopic" value="dfForumDetail" />
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
	 <h:outputText value="#{msgs.cdfm_insufficient_privileges_view_forum}" rendered="#{ForumTool.selectedForum.forum.draft && ForumTool.selectedForum.forum.createdBy != ForumTool.userId}" />
    </sakai:view>
</f:view>
