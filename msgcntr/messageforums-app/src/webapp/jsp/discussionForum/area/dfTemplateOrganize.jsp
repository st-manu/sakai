<%@ page import="java.util.*, jakarta.faces.context.*, jakarta.faces.application.*,
                 jakarta.faces.el.*, org.sakaiproject.tool.messageforums.*,
                 org.sakaiproject.tool.messageforums.ui.*,
                 org.sakaiproject.api.app.messageforums.*"%>
<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>

<f:view>
	<sakai:view title="#{msgs.cdfm_default_template_organize}">
		<script>includeLatestJQuery("msgcntr");</script>
		<script src="/messageforums-tool/js/sak-10625.js"></script>
		<script src="/messageforums-tool/js/messages.js"></script>
		<script type="module" src="/webcomponents/bundles/sakai-reorderer.js<h:outputText value="#{ForumTool.CDNQuery}" />"></script>
		<script type="module" src="/messageforums-tool/js/forums-organize.js<h:outputText value="#{ForumTool.CDNQuery}" />"></script>

		<h:form id="revise" styleClass="sakai-forums">
			<% request.setAttribute("dfHeaderTitleKey", "cdfm_default_template_organize"); %>
			<% request.setAttribute("dfHeaderBack", "discussions"); %>
			<%@ include file="/jsp/discussionForum/menu/forumsHeader.jsp" %>

<%
FacesContext organizeContext = FacesContext.getCurrentInstance();
Application organizeApp = organizeContext.getApplication();
ValueBinding organizeBinding = organizeApp.createValueBinding("#{ForumTool}");
DiscussionForumTool organizeTool = (DiscussionForumTool) organizeBinding.getValue(organizeContext);
List organizeForums = organizeTool.getForums();
if (organizeForums == null) {
	organizeForums = Collections.emptyList();
}
List visibleForums = new ArrayList();
for (Iterator forumIt = organizeForums.iterator(); forumIt.hasNext(); ) {
	DiscussionForumBean forumBean = (DiscussionForumBean) forumIt.next();
	if (!Boolean.TRUE.equals(forumBean.getNonePermission())) {
		visibleForums.add(forumBean);
	}
}
int forumCount = visibleForums.size();
String dragHandleLabel = msgs.getString("cdfm_organize_drag_handle");
String moveUpLabel = msgs.getString("cdfm_organize_move_up");
String moveDownLabel = msgs.getString("cdfm_organize_move_down");
String movedMessage = msgs.getString("cdfm_organize_moved");
String topicsLabel = msgs.getString("cdfm_topics");
String forumLabel = msgs.getString("cdfm_forums");
%>

			<p class="sakai-form-section__intro">
				<h:outputText value="#{msgs.cdfm_default_template_organize_instruction}"/>
				<span id="inputKbdMessage" class="visually-hidden"><h:outputText value="#{msgs.cdfm_organize_instruction_hidden}"/></span>
			</p>

<% if (forumCount == 0) { %>
			<div class="sakai-forums__empty">
				<p class="sakai-forums__empty-text"><h:outputText value="#{msgs.cdfm_forum_noforums}"/></p>
			</div>
<% } else { %>
			<div class="sakai-reorder-undo sakai-no-print">
				<button type="button" class="sakai-btn sakai-btn-secondary" id="undo-last" disabled>
					<span class="si si-arrow-counterclockwise" aria-hidden="true"></span>
					<span><h:outputText value="#{msgs.cdfm_organize_undo_last}"/></span>
				</button>
				<button type="button" class="sakai-btn sakai-btn-secondary" id="undo-all" disabled>
					<span class="si si-arrow-repeat" aria-hidden="true"></span>
					<span><h:outputText value="#{msgs.cdfm_organize_undo_all}"/></span>
				</button>
			</div>
			<span id="lastMoveArray" hidden></span>
			<span id="lastMoveArrayInit" hidden></span>
			<span id="lastItemMoved" class="visually-hidden" aria-live="polite" aria-atomic="true" data-moved-message="<%= org.sakaiproject.util.Web.escapeHtml(movedMessage) %>"></span>

			<div class="sakai-reorder">
				<sakai-reorderer id="forums-reorderer" style="display:block" apply-dom>
					<ul id="forums-reorder-list" class="sakai-reorder-list" role="list">
<%
	for (int forumIndex = 0; forumIndex < forumCount; forumIndex++) {
		DiscussionForumBean forumBean = (DiscussionForumBean) visibleForums.get(forumIndex);
		DiscussionForum forum = forumBean.getForum();
		Long forumId = forum.getId();
		List topics = forum.getTopics();
		if (topics == null) {
			topics = Collections.emptyList();
		}
		int topicCount = topics.size();
%>
						<li class="reorder-element sakai-reorder-row sakai-reorder-group"
							id="forum.orderable<%= forumId %>"
							data-reorderable-id="forum.<%= forumId %>"
							aria-label="<%= org.sakaiproject.util.Web.escapeHtml(forumLabel + ": " + forum.getTitle()) %>">
							<div class="sakai-reorder-row-main sakai-reorder-group__bar">
								<div class="sakai-reorder-move-controls">
									<span class="sakai-btn-icon sakai-reorder-drag-handle drag-handle"
											tabindex="0"
											role="button"
											title="<%= org.sakaiproject.util.Web.escapeHtml(dragHandleLabel) %>"
											aria-label="<%= org.sakaiproject.util.Web.escapeHtml(dragHandleLabel) %>">
										<span class="si si-drag-handle" aria-hidden="true"></span>
									</span>
									<button type="button"
											class="sakai-btn-icon"
											data-action="move-up"
											<% if (forumIndex == 0) { %>disabled="disabled"<% } %>
											title="<%= org.sakaiproject.util.Web.escapeHtml(moveUpLabel) %>"
											aria-label="<%= org.sakaiproject.util.Web.escapeHtml(moveUpLabel) %>">
										<span class="si si-chevron-up" aria-hidden="true"></span>
									</button>
									<button type="button"
											class="sakai-btn-icon"
											data-action="move-down"
											<% if (forumIndex == forumCount - 1) { %>disabled="disabled"<% } %>
											title="<%= org.sakaiproject.util.Web.escapeHtml(moveDownLabel) %>"
											aria-label="<%= org.sakaiproject.util.Web.escapeHtml(moveDownLabel) %>">
										<span class="si si-chevron-down" aria-hidden="true"></span>
									</button>
								</div>
								<div class="sakai-reorder-row-content">
									<div class="sakai-reorder-title-block">
										<div class="sakai-reorder-display">
											<span class="sakai-reorder-kind"><%= org.sakaiproject.util.Web.escapeHtml(forumLabel) %></span>
											<span class="sakai-reorder-title"><%= org.sakaiproject.util.Web.escapeHtml(forum.getTitle()) %></span>
										</div>
									</div>
									<input type="hidden" name="forumOrder" value="<%= forumId %>"/>
								</div>
							</div>
<% if (topicCount > 0) { %>
							<div class="sakai-reorder-nested">
								<p class="sakai-reorder-nested__label" id="topics-label-<%= forumId %>">
									<%= org.sakaiproject.util.Web.escapeHtml(topicsLabel) %>
								</p>
								<sakai-reorderer style="display:block" apply-dom data-forum-id="<%= forumId %>">
									<ul class="sakai-reorder-list"
											id="topics-reorder-list-<%= forumId %>"
											role="list"
											aria-labelledby="topics-label-<%= forumId %>">
<%
			for (int topicIndex = 0; topicIndex < topicCount; topicIndex++) {
				Topic topic = (Topic) topics.get(topicIndex);
				Long topicId = topic.getId();
%>
										<li class="reorder-element sakai-reorder-row"
											id="topic.orderable<%= topicId %>"
											data-reorderable-id="topic.<%= topicId %>"
											aria-label="<%= org.sakaiproject.util.Web.escapeHtml(topicsLabel + ": " + topic.getTitle()) %>">
											<div class="sakai-reorder-row-main">
												<div class="sakai-reorder-move-controls">
													<span class="sakai-btn-icon sakai-reorder-drag-handle drag-handle"
															tabindex="0"
															role="button"
															title="<%= org.sakaiproject.util.Web.escapeHtml(dragHandleLabel) %>"
															aria-label="<%= org.sakaiproject.util.Web.escapeHtml(dragHandleLabel) %>">
														<span class="si si-drag-handle" aria-hidden="true"></span>
													</span>
													<button type="button"
															class="sakai-btn-icon"
															data-action="move-up"
															<% if (topicIndex == 0) { %>disabled="disabled"<% } %>
															title="<%= org.sakaiproject.util.Web.escapeHtml(moveUpLabel) %>"
															aria-label="<%= org.sakaiproject.util.Web.escapeHtml(moveUpLabel) %>">
														<span class="si si-chevron-up" aria-hidden="true"></span>
													</button>
													<button type="button"
															class="sakai-btn-icon"
															data-action="move-down"
															<% if (topicIndex == topicCount - 1) { %>disabled="disabled"<% } %>
															title="<%= org.sakaiproject.util.Web.escapeHtml(moveDownLabel) %>"
															aria-label="<%= org.sakaiproject.util.Web.escapeHtml(moveDownLabel) %>">
														<span class="si si-chevron-down" aria-hidden="true"></span>
													</button>
												</div>
												<div class="sakai-reorder-row-content">
													<div class="sakai-reorder-title-block">
														<div class="sakai-reorder-display">
															<span class="sakai-reorder-title"><%= org.sakaiproject.util.Web.escapeHtml(topic.getTitle()) %></span>
														</div>
													</div>
													<input type="hidden" name="topicOrder_<%= forumId %>" value="<%= topicId %>"/>
												</div>
											</div>
										</li>
<%
			}
%>
									</ul>
								</sakai-reorderer>
							</div>
<% } else { %>
							<p class="sakai-reorder-nested__empty"><h:outputText value="#{msgs.cdfm_no_topics}"/></p>
<% } %>
						</li>
<%
	}
%>
					</ul>
				</sakai-reorderer>
			</div>
<% } %>

			<div class="sakai-actions">
				<h:commandButton action="#{ForumTool.processActionSaveTemplateOrganization}"
						value="#{msgs.cdfm_button_bar_save_setting}"
						accesskey="s"
						styleClass="sakai-btn sakai-btn-primary"/>
				<h:commandButton action="#{ForumTool.processActionHome}"
						value="#{msgs.cdfm_button_bar_cancel}"
						accesskey="x"
						styleClass="sakai-btn sakai-btn-ghost"/>
			</div>
		</h:form>
	</sakai:view>
</f:view>
