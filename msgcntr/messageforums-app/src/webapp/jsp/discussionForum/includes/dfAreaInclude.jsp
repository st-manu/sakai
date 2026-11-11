<!--jsp/discussionForum/area/dfAreaInclude.jsp-->
<%@ taglib uri="http://myfaces.apache.org/tomahawk" prefix="t"%>
<script type="module" src="/webcomponents/bundles/rubric-association-requirements.js<h:outputText value="#{ForumTool.CDNQuery}" />"></script>

<h:panelGroup layout="block" styleClass="sakai-forums__empty" rendered="#{empty ForumTool.forums}">
	<p class="sakai-forums__empty-text"><h:outputText value="#{msgs.cdfm_forum_noforums}"/></p>
	<h:commandLink id="create_forum" action="#{ForumTool.processActionNewForum}"
			styleClass="sakai-btn sakai-btn-primary" rendered="#{ForumTool.newForum}">
		<h:outputText value="" styleClass="si si-add" escape="false"/>
		<h:outputText value="#{msgs.cdfm_new_forum}"/>
	</h:commandLink>
</h:panelGroup>

<h:outputText styleClass="accessUserCheck" style="display:none" rendered="#{ForumTool.newForum}" value="x"/>

<script>
document.addEventListener("DOMContentLoaded", function() {
	var topicLen = document.querySelectorAll(".sakai-forums__topic-row").length;
	var forumLen = document.querySelectorAll(".sakai-forums__forum").length;
	var draftForumLen = document.querySelectorAll(".draftForum").length;
	var draftTopicLen = document.querySelectorAll(".draftTopic").length;
	var accessCheck = document.querySelectorAll(".accessUserCheck").length;
	var noForums = document.querySelectorAll(".sakai-forums__empty").length;

	if (forumLen === 1 && draftForumLen === 0 && topicLen === 1 && draftTopicLen === 0) {
		document.querySelectorAll(".defForums").forEach(function(el) { el.hidden = false; });
	}
	if ((topicLen === 0 || draftTopicLen === topicLen) && forumLen !== 0) {
		if (topicLen === draftTopicLen && topicLen !== 0) {
			document.querySelectorAll(".noTopicsDraft").forEach(function(el) { el.hidden = false; });
		}
		document.querySelectorAll(".noTopics").forEach(function(el) { el.hidden = false; });
		if (topicLen === 0) {
			document.querySelectorAll(".noTopicsatAll").forEach(function(el) { el.hidden = false; });
		}
	}
	if (forumLen === draftForumLen && forumLen !== 0) {
		document.querySelectorAll(".noForumsDraft").forEach(function(el) { el.hidden = false; });
		document.querySelectorAll(".noTopics").forEach(function(el) { el.hidden = true; });
	}
	if (forumLen === 0 && accessCheck === 0 && noForums === 0) {
		document.querySelectorAll(".noForumsAccess").forEach(function(el) { el.hidden = false; });
	}
});
</script>

<h:outputText styleClass="showMoreText" style="display:none" value="#{msgs.cdfm_show_more_full_description}"/>

<p class="sakai-banner sakai-banner--info noForumsAccess" hidden>
	<h:outputText value="#{msgs.cdfm_forum_inf_no_forum_access}"/>
</p>

<f:subview id="maintainMessages" rendered="#{ForumTool.newForum}">
	<p class="sakai-banner sakai-banner--info defForums" hidden>
		<h:outputText value="#{msgs.cdfm_forum_inf_init_guide}" escape="false"/>
	</p>
	<p class="sakai-banner sakai-banner--warn noTopics" hidden>
		<h:outputText styleClass="sakai-forums__status--draft" value="#{msgs.cdfm_forum_inf_note} "/>
		<span class="noTopicsatAll" hidden><h:outputText value="#{msgs.cdfm_forum_inf_no_topics}" escape="false"/></span>
		<span class="noTopicsDraft" hidden><h:outputText value="#{msgs.cdfm_forum_inf_all_topics_draft}"/></span>
	</p>
	<p class="sakai-banner sakai-banner--warn noForumsDraft" hidden>
		<h:outputText styleClass="sakai-forums__status--draft" value="#{msgs.cdfm_forum_inf_note} "/>
		<span class="noForumsDraft" hidden><h:outputText value="#{msgs.cdfm_forum_inf_all_forums_draft}"/></span>
	</p>
</f:subview>

<h:panelGroup layout="block" styleClass="sakai-forums__list" rendered="#{!empty ForumTool.forums}">
	<t:dataList id="forums" value="#{ForumTool.forums}" var="forum" layout="simple" rowIndexVar="forumRow">
			<h:panelGroup layout="block" styleClass="sakai-forums__forum" rendered="#{!forum.nonePermission}">
				<div class="sakai-forums__forum-header">
					<div class="sakai-forums__forum-title-row">
						<div class="sakai-forums__forum-identity">
							<h:outputText styleClass="sakai-forums__status sakai-forums__status--draft draftForum"
									value="#{msgs.cdfm_draft}" rendered="#{forum.forum.draft == 'true'}"/>
							<h:panelGroup styleClass="sakai-forums__status" rendered="#{forum.availability == 'false'}">
								<span class="si si-calendar-x" aria-hidden="true"></span>
								<span class="visually-hidden"><h:outputText value="#{msgs.forum_restricted_message}" escape="false"/></span>
							</h:panelGroup>
							<h:panelGroup styleClass="sakai-forums__status" rendered="#{forum.locked == 'true'}">
								<span class="si si-locked" aria-hidden="true"></span>
								<span class="visually-hidden"><h:outputText value="#{msgs.cdfm_forum_locked}" escape="false"/></span>
							</h:panelGroup>
							<h:panelGroup rendered="#{forum.hasRubric == 'true'}">
								<sakai-rubric-student-preview-button
									site-id='<h:outputText value="#{ForumTool.siteId}" />'
									display="icon"
									tool-id="sakai.gradebookng"
									entity-id="<h:outputText value="#{forum.gradeAssign}" />">
								</sakai-rubric-student-preview-button>
							</h:panelGroup>
							<h:commandLink action="#{ForumTool.processActionDisplayForum}" title="#{forum.forum.title}"
									rendered="#{ForumTool.showForumLinksInNav}" styleClass="sakai-forums__title">
								<f:param value="#{forum.forum.id}" name="forumId"/>
								<h:outputText value="#{forum.forum.title}"/>
							</h:commandLink>
							<h:outputText value="#{forum.forum.title}" rendered="#{!ForumTool.showForumLinksInNav}"
									styleClass="sakai-forums__title"/>
							<h:outputText value="#{msgs.cdfm_forum_moderated_flag}" styleClass="sakai-forums__meta"
									rendered="#{forum.moderated == 'true'}"/>
						</div>
						<h:panelGroup rendered="#{forum.newTopic || ForumTool.newForum || ForumTool.instructor || forum.changeSettings}">
							<details class="sakai-overflow-menu">
								<summary class="sakai-btn sakai-btn-ghost sakai-overflow-menu__toggle">
									<h:outputText value="" styleClass="si si-three-dots" escape="false"/>
									<h:outputText value="#{msgs.pvt_more_actions}" styleClass="visually-hidden"/>
								</summary>
								<div class="sakai-overflow-menu__panel">
									<h:commandLink action="#{ForumTool.processActionNewTopic}" rendered="#{forum.newTopic}">
										<h:outputText value="#{msgs.cdfm_new_topic}"/>
										<f:param value="#{forum.forum.id}" name="forumId"/>
									</h:commandLink>
									<h:commandLink action="#{ForumTool.processActionForumSettings}" rendered="#{forum.changeSettings}">
										<h:outputText value="#{msgs.cdfm_forum_settings}"/>
										<f:param value="#{forum.forum.id}" name="forumId"/>
									</h:commandLink>
									<h:commandLink id="duplicate" action="#{ForumTool.processActionDuplicateForumMainConfirm}"
											rendered="#{ForumTool.newForum}">
										<h:outputText value="#{msgs.cdfm_duplicate_forum}"/>
										<f:param value="#{forum.forum.id}" name="forumId"/>
									</h:commandLink>
									<h:commandLink action="#{mfStatisticsBean.processActionStatisticsByTopic}" immediate="true"
											rendered="#{ForumTool.instructor}">
										<h:outputText value="#{msgs.cdfm_button_bar_grade}"/>
										<f:param value="" name="topicId"/>
										<f:param value="#{forum.forum.id}" name="forumId"/>
									</h:commandLink>
									<h:commandLink id="delete" action="#{ForumTool.processActionDeleteForumMainConfirm}"
											rendered="#{forum.changeSettings}">
										<h:outputText value="#{msgs.cdfm_button_bar_delete_forum}"/>
										<f:param value="#{forum.forum.id}" name="forumId"/>
									</h:commandLink>
								</div>
							</details>
						</h:panelGroup>
					</div>
					<h:outputText value="#{forum.forum.shortDescription}" styleClass="sakai-forums__description"
							rendered="#{!empty forum.forum.shortDescription}"/>
					<f:subview id="longDesc" rendered="#{!empty forum.attachList || (forum.forum.extendedDescription != '' && forum.forum.extendedDescription != null && forum.forum.extendedDescription != '<br/>')}">
						<h:panelGroup layout="block" id="openLinkBlock" styleClass="toggleParent openLinkBlock">
							<a href="#" id="showMessage" class="toggle show">
								<span class="si si-chevron-down" aria-hidden="true"></span>
								<h:outputText value=" #{msgs.cdfm_read_full_description}"/>
								<h:outputText value=" #{msgs.cdfm_and}" rendered="#{!empty forum.attachList}"/>
								<h:outputText value=" #{msgs.cdfm_attach}" rendered="#{!empty forum.attachList}"/>
							</a>
						</h:panelGroup>
						<h:panelGroup layout="block" id="hideLinkBlock" styleClass="toggleParent hideLinkBlock display-none">
							<a href="#" id="hideMessage" class="toggle show">
								<span class="si si-chevron-up" aria-hidden="true"></span>
								<h:outputText value=" #{msgs.cdfm_hide_full_description}"/>
								<h:outputText value=" #{msgs.cdfm_and}" rendered="#{!empty forum.attachList}"/>
								<h:outputText value=" #{msgs.cdfm_attach}" rendered="#{!empty forum.attachList}"/>
							</a>
						</h:panelGroup>
						<h:panelGroup layout="block" id="fullTopicDescription" styleClass="textPanel fullTopicDescription display-none">
							<h:outputText escape="false" value="#{forum.forum.extendedDescription}"/>
							<h:dataTable styleClass="sakai-table sakai-table--stack attachListTable" value="#{forum.attachList}"
									var="eachAttach" rendered="#{!empty forum.attachList}">
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
					<f:subview id="dates" rendered="#{ForumTool.showAvailabilityDates == 'true' && forum.availabilityRestricted == 'true'}">
						<details class="sakai-forums__dates">
							<summary>
								<span class="si si-calendar" aria-hidden="true"></span>
								<h:outputText value="#{msgs.cdfm_read_dates}"/>
							</summary>
							<p class="sakai-forums__meta">
								<h:outputText value="#{msgs.openDate}: #{forum.formattedOpenDate}"/>
								<br/>
								<h:outputText value="#{msgs.closeDate}: #{forum.formattedCloseDate}"/>
							</p>
						</details>
					</f:subview>
				</div>

				<h:panelGroup layout="block" styleClass="sakai-forums__empty sakai-forums__empty--topics" rendered="#{empty forum.topics}">
					<p class="sakai-forums__empty-text"><h:outputText value="#{msgs.cdfm_forum_inf_no_topic_here}"/></p>
					<h:commandLink action="#{ForumTool.processActionNewTopic}" styleClass="sakai-btn sakai-btn-primary"
							rendered="#{forum.newTopic}">
						<h:outputText value="" styleClass="si si-add" escape="false"/>
						<h:outputText value="#{msgs.cdfm_new_topic}"/>
						<f:param value="#{forum.forum.id}" name="forumId"/>
					</h:commandLink>
				</h:panelGroup>

				<div class="sakai-table-wrap">
					<h:dataTable id="topics" rendered="#{!empty forum.topics}" value="#{forum.topics}" var="topic"
							styleClass="sakai-table sakai-table--hover sakai-table--stack sakai-forums__topics"
							columnClasses="sakai-table__primary,sakai-table__nowrap,sakai-table__nowrap,sakai-table__actions"
							rowClasses="sakai-forums__topic-row">
						<h:column>
							<f:facet name="header">
								<h:outputText value="#{msgs.cdfm_topics}"/>
							</f:facet>
							<h:panelGroup rendered="#{!topic.nonePermission}">
								<h:panelGroup rendered="#{forum.forum.draft == 'true'}">
									<span class="si si-warning sakai-forums__topic-icon" aria-hidden="true"></span>
									<span class="visually-hidden"><h:outputText value="#{msgs.cdfm_forum_draft_topic_unavailable}" escape="false"/></span>
								</h:panelGroup>
								<h:panelGroup rendered="#{forum.forum.draft != 'true'}">
									<h:outputText styleClass="si si-folder sakai-forums__topic-icon" rendered="#{topic.unreadNoMessages == 0}" escape="false"/>
									<h:outputText styleClass="si si-folder-fill sakai-forums__topic-icon" rendered="#{topic.unreadNoMessages > 0}" escape="false"/>
								</h:panelGroup>
								<h:outputText styleClass="sakai-forums__status sakai-forums__status--draft draftTopic"
										value="#{msgs.cdfm_draft}" rendered="#{topic.topic.draft == 'true'}"/>
								<h:panelGroup styleClass="sakai-forums__status" rendered="#{topic.availability == 'false'}">
									<span class="si si-calendar-x" aria-hidden="true"></span>
									<span class="visually-hidden"><h:outputText value="#{msgs.topic_restricted_message}" escape="false"/></span>
								</h:panelGroup>
								<h:panelGroup styleClass="sakai-forums__status" rendered="#{forum.locked == 'true' || topic.locked == 'true'}">
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
										styleClass="#{forum.forum.draft == 'true' ? 'sakai-forums__title draft-forum-topic' : 'sakai-forums__title'}">
									<f:param value="#{topic.topic.id}" name="topicId"/>
									<f:param value="#{forum.forum.id}" name="forumId"/>
									<h:outputText value="#{topic.topic.title}"/>
								</h:commandLink>
								<h:outputText value="#{msgs.cdfm_topic_moderated_flag}" styleClass="sakai-forums__meta"
										rendered="#{topic.moderated == 'true' && topic.isRead && forum.forum.draft != 'true'}"/>
								<h:outputText value="#{topic.topic.shortDescription}" styleClass="sakai-forums__description"
										rendered="#{!empty topic.topic.shortDescription}"/>
							</h:panelGroup>
						</h:column>
						<h:column>
							<f:facet name="header">
								<h:outputText value="#{msgs.cdfm_messages}"/>
							</f:facet>
							<h:outputText value="#{topic.totalNoMessages}"
									rendered="#{!topic.nonePermission && topic.isRead && forum.forum.draft != 'true'}"/>
						</h:column>
						<h:column>
							<f:facet name="header">
								<h:outputText value="#{msgs.cdfm_unread}"/>
							</f:facet>
							<h:outputText value="#{topic.unreadNoMessages}"
									styleClass="#{topic.unreadNoMessages > 0 ? 'sakai-forums__unread' : ''}"
									rendered="#{!topic.nonePermission && topic.isRead && forum.forum.draft != 'true'}"/>
						</h:column>
						<h:column>
							<f:facet name="header">
								<h:outputText value="#{msgs.cdfm_other_actions}" styleClass="visually-hidden"/>
							</f:facet>
							<h:panelGroup layout="block" styleClass="sakai-row-actions"
									rendered="#{!topic.nonePermission && (forum.newTopic || ForumTool.instructor || topic.changeSettings)}">
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
											<f:param value="#{forum.forum.id}" name="forumId"/>
										</h:commandLink>
										<h:commandLink action="#{ForumTool.processActionDuplicateTopicMainConfirm}" id="duplicate_confirm"
												rendered="#{forum.newTopic}">
											<h:outputText value="#{msgs.cdfm_duplicate_topic}"/>
											<f:param value="#{topic.topic.id}" name="topicId"/>
											<f:param value="#{forum.forum.id}" name="forumId"/>
										</h:commandLink>
										<h:commandLink action="#{mfStatisticsBean.processActionStatisticsByTopic}" immediate="true"
												rendered="#{ForumTool.instructor}">
											<h:outputText value="#{msgs.cdfm_button_bar_grade}"/>
											<f:param value="#{topic.topic.id}" name="topicId"/>
											<f:param value="#{forum.forum.id}" name="forumId"/>
										</h:commandLink>
										<h:commandLink action="#{ForumTool.processActionDeleteTopicMainConfirm}" id="delete_confirm"
												rendered="#{topic.changeSettings}">
											<h:outputText value="#{msgs.cdfm_button_bar_delete_topic}"/>
											<f:param value="#{topic.topic.id}" name="topicId"/>
											<f:param value="#{forum.forum.id}" name="forumId"/>
										</h:commandLink>
									</div>
								</details>
							</h:panelGroup>
						</h:column>
					</h:dataTable>
				</div>
			</h:panelGroup>
	</t:dataList>
</h:panelGroup>
