<%
  String dfHeaderView = (String) request.getAttribute("dfHeaderView");
  String dfHeaderTitleKey = (String) request.getAttribute("dfHeaderTitleKey");
  String dfHeaderBack = (String) request.getAttribute("dfHeaderBack");
  boolean dfHeaderIsHome = "home".equals(dfHeaderView);
  boolean dfHeaderIsPending = "pending".equals(dfHeaderView);
  boolean dfHeaderIsStatistics = "statistics".equals(dfHeaderView);
  boolean dfHeaderIsStatisticsByTopic = "statisticsByTopic".equals(dfHeaderView);
  boolean dfHeaderHasSections = dfHeaderIsHome || dfHeaderIsPending;
  boolean dfHeaderHasStatisticsSections = dfHeaderIsStatistics || dfHeaderIsStatisticsByTopic;
%>
<header class="sakai-tool-header">
  <% if (dfHeaderBack != null && !dfHeaderBack.isEmpty()) { %>
  <h:panelGroup layout="block" styleClass="sakai-back-link-row sakai-no-print">
    <% if ("discussions".equals(dfHeaderBack)) { %>
    <h:commandLink immediate="true" action="forumsMain" styleClass="sakai-back-link">
      <h:outputText value="" styleClass="si si-arrow-left" escape="false"/>
      <h:outputText value="#{msgs.cdfm_back_to} "/>
      <h:outputText value="#{msgs.cdfm_discussions}"/>
    </h:commandLink>
    <% } else if ("forum".equals(dfHeaderBack)) { %>
    <h:commandLink immediate="true" action="#{ForumTool.processActionDisplayForum}" styleClass="sakai-back-link">
      <h:outputText value="" styleClass="si si-arrow-left" escape="false"/>
      <h:outputText value="#{msgs.cdfm_back_to} "/>
      <h:outputText value="#{ForumTool.selectedForum.forum.title}"/>
      <f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
    </h:commandLink>
    <% } else if ("topic".equals(dfHeaderBack)) { %>
    <h:commandLink immediate="true" action="#{ForumTool.processActionDisplayTopic}" styleClass="sakai-back-link">
      <h:outputText value="" styleClass="si si-arrow-left" escape="false"/>
      <h:outputText value="#{msgs.cdfm_back_to} "/>
      <h:outputText value="#{ForumTool.selectedTopic.topic.title}"/>
      <f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
      <f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId"/>
    </h:commandLink>
    <% } else if ("thread".equals(dfHeaderBack)) { %>
    <h:commandLink immediate="true" action="#{ForumTool.processActionDisplayThread}" styleClass="sakai-back-link">
      <h:outputText value="" styleClass="si si-arrow-left" escape="false"/>
      <h:outputText value="#{msgs.cdfm_back_to} "/>
      <h:outputText value="#{ForumTool.selectedThreadHead.message.title}"/>
      <f:param value="#{ForumTool.selectedThreadHead.message.id}" name="messageId"/>
      <f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId"/>
      <f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
    </h:commandLink>
    <% } else if ("message".equals(dfHeaderBack)) { %>
    <h:commandLink immediate="true" action="#{ForumTool.processActionDisplayMessage}" styleClass="sakai-back-link">
      <h:outputText value="" styleClass="si si-arrow-left" escape="false"/>
      <h:outputText value="#{msgs.cdfm_back_to} "/>
      <h:outputText value="#{ForumTool.selectedMessage.message.title}"/>
      <f:param value="#{ForumTool.selectedMessage.message.id}" name="messageId"/>
      <f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId"/>
      <f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
    </h:commandLink>
    <% } else if ("statistics".equals(dfHeaderBack)) { %>
    <h:commandLink immediate="true" action="#{ForumTool.processActionStatistics}" styleClass="sakai-back-link">
      <h:outputText value="" styleClass="si si-arrow-left" escape="false"/>
      <h:outputText value="#{msgs.cdfm_back_to} "/>
      <h:outputText value="#{msgs.cdfm_statistics}"/>
    </h:commandLink>
    <% } else if ("statisticsByTopic".equals(dfHeaderBack)) { %>
    <h:commandLink immediate="true" action="#{mfStatisticsBean.processActionStatisticsByAllTopics}" styleClass="sakai-back-link">
      <h:outputText value="" styleClass="si si-arrow-left" escape="false"/>
      <h:outputText value="#{msgs.cdfm_back_to} "/>
      <h:outputText value="#{msgs.cdfm_statistics}"/>
    </h:commandLink>
    <% } else if ("statisticsUser".equals(dfHeaderBack)) { %>
    <h:commandLink immediate="true" action="#{mfStatisticsBean.processActionBackToUser}" styleClass="sakai-back-link">
      <h:outputText value="" styleClass="si si-arrow-left" escape="false"/>
      <h:outputText value="#{msgs.cdfm_back_to} "/>
      <h:outputText value="#{mfStatisticsBean.selectedSiteUser}"/>
    </h:commandLink>
    <% } else if ("ranks".equals(dfHeaderBack)) { %>
    <h:commandLink immediate="true" action="#{ForumTool.processActionViewRanks}" styleClass="sakai-back-link">
      <h:outputText value="" styleClass="si si-arrow-left" escape="false"/>
      <h:outputText value="#{msgs.cdfm_back_to} "/>
      <h:outputText value="#{msgs.ranks}"/>
    </h:commandLink>
    <% } %>
  </h:panelGroup>
  <% } %>

  <h1 class="sakai-tool-header__title">
    <% if ("home".equals(dfHeaderView)) { %>
      <h:outputText value="#{msgs.cdfm_discussions}"/>
    <% } else if ("pending".equals(dfHeaderView)) { %>
      <h:outputText value="#{msgs.cdfm_msg_pending_queue_title}"/>
    <% } else if ("forum".equals(dfHeaderView)) { %>
      <h:outputText value="#{ForumTool.selectedForum.forum.title}"/>
    <% } else if ("topic".equals(dfHeaderView) || "flat".equals(dfHeaderView)) { %>
      <h:outputText value="#{ForumTool.selectedTopic.topic.title}"/>
    <% } else if ("thread".equals(dfHeaderView)) { %>
      <h:outputText value="#{ForumTool.selectedThreadHead.message.title}"/>
    <% } else if ("message".equals(dfHeaderView)) { %>
      <h:outputText value="#{ForumTool.selectedMessage.message.title}"/>
    <% } else if ("forumSettings".equals(dfHeaderView)) { %>
      <h:outputText value="#{msgs.cdfm_button_bar_delete_forum}" rendered="#{ForumTool.selectedForum.markForDeletion}"/>
      <h:outputText value="#{msgs.cdfm_duplicate_forum}" rendered="#{ForumTool.selectedForum.markForDuplication}"/>
      <h:outputText value="#{msgs.cdfm_new_forum}" rendered="#{!ForumTool.selectedForum.markForDeletion and !ForumTool.selectedForum.markForDuplication and empty ForumTool.selectedForum.forum.id}"/>
      <h:outputText value="#{msgs.cdfm_forum_settings}" rendered="#{!ForumTool.selectedForum.markForDeletion and !ForumTool.selectedForum.markForDuplication and !empty ForumTool.selectedForum.forum.id}"/>
    <% } else if ("topicSettings".equals(dfHeaderView)) { %>
      <h:outputText value="#{msgs.cdfm_button_bar_delete_topic}" rendered="#{ForumTool.selectedTopic.markForDeletion}"/>
      <h:outputText value="#{msgs.cdfm_duplicate_topic}" rendered="#{ForumTool.selectedTopic.markForDuplication}"/>
      <h:outputText value="#{msgs.cdfm_new_topic}" rendered="#{!ForumTool.selectedTopic.markForDeletion and !ForumTool.selectedTopic.markForDuplication and empty ForumTool.selectedTopic.topic.id}"/>
      <h:outputText value="#{msgs.cdfm_topic_settings}" rendered="#{!ForumTool.selectedTopic.markForDeletion and !ForumTool.selectedTopic.markForDuplication and !empty ForumTool.selectedTopic.topic.id}"/>
    <% } else if (dfHeaderIsStatistics || dfHeaderIsStatisticsByTopic) { %>
      <h:outputText value="#{msgs.stat_list}"/>
    <% } else if ("statisticsUser".equals(dfHeaderView)) { %>
      <h:outputText value="#{mfStatisticsBean.selectedSiteUser}"/>
    <% } else if ("statisticsForumTopic".equals(dfHeaderView)) { %>
      <h:outputText value="#{mfStatisticsBean.selectedAllTopicsTopicTitle}" rendered="#{!empty mfStatisticsBean.selectedAllTopicsTopicId}"/>
      <h:outputText value="#{mfStatisticsBean.selectedAllTopicsForumTitle}" rendered="#{empty mfStatisticsBean.selectedAllTopicsTopicId}"/>
    <% } else if ("statisticsAuthored".equals(dfHeaderView)) { %>
      <h:outputText value="#{msgs.stat_authored}"/>
    <% } else if ("statisticsMessage".equals(dfHeaderView)) { %>
      <h:outputText value="#{mfStatisticsBean.selectedMsgSubject}"/>
    <% } else if ("statisticsThread".equals(dfHeaderView)) { %>
      <h:outputText value="#{ForumTool.selectedTopic.topic.title}"/>
    <% } else if (dfHeaderTitleKey != null && !dfHeaderTitleKey.isEmpty()) { %>
      <%= msgs.getString(dfHeaderTitleKey) %>
    <% } %>
  </h1>

  <% if (dfHeaderIsHome) { %>
  <h:panelGroup layout="block" styleClass="sakai-tool-header__actions sakai-no-print">
    <h:commandLink immediate="true" action="#{ForumTool.processActionNewForum}" styleClass="sakai-btn sakai-btn-primary" rendered="#{ForumTool.newForum}">
      <h:outputText value="" styleClass="si si-add" escape="false"/>
      <h:outputText value="#{msgs.cdfm_new_forum}"/>
    </h:commandLink>
    <h:panelGroup layout="block" styleClass="sakai-tool-header__secondary">
      <h:commandLink immediate="true" action="#{ForumTool.processActionTemplateOrganize}" styleClass="sakai-btn sakai-btn-secondary" rendered="#{ForumTool.instructor}">
        <h:outputText value="#{msgs.cdfm_organize}"/>
      </h:commandLink>
    </h:panelGroup>
    <details class="sakai-overflow-menu sakai-tool-header__more sakai-tool-header__more--persistent">
      <summary class="sakai-btn sakai-btn-ghost sakai-overflow-menu__toggle">
        <h:outputText value="" styleClass="si si-three-dots" escape="false"/>
        <h:outputText value="#{msgs.pvt_more_actions}" styleClass="visually-hidden"/>
      </summary>
      <div class="sakai-overflow-menu__panel">
        <h:commandLink immediate="true" action="#{ForumTool.processActionTemplateOrganize}"
            styleClass="sakai-tool-header__priority-2" rendered="#{ForumTool.instructor}">
          <h:outputText value="#{msgs.cdfm_organize}"/>
        </h:commandLink>
        <h:commandLink immediate="true" action="#{ForumTool.processActionTemplateSettings}" rendered="#{ForumTool.instructor}">
          <h:outputText value="#{msgs.cdfm_template_setting}"/>
        </h:commandLink>
        <h:commandLink immediate="true" action="#{ForumTool.processActionStatistics}" rendered="#{ForumTool.instructor}">
          <h:outputText value="#{msgs.cdfm_statistics}"/>
        </h:commandLink>
        <h:commandLink immediate="true" action="#{mfStatisticsBean.processActionStatisticsUser}" rendered="#{!ForumTool.instructor}">
          <h:outputText value="#{msgs.stat_list_student}"/>
          <f:param value="#{ForumTool.userId}" name="siteUserId"/>
        </h:commandLink>
        <h:commandLink immediate="true" action="#{ForumTool.processActionViewRanks}" rendered="#{ForumTool.instructor && ForumTool.ranksEnabled}">
          <h:outputText value="#{msgs.ranks}"/>
        </h:commandLink>
        <h:commandLink immediate="true" action="#{ForumTool.processActionWatch}">
          <h:outputText value="#{msgs.watch}"/>
        </h:commandLink>
      </div>
    </details>
  </h:panelGroup>
  <% } else if ("forum".equals(dfHeaderView)) { %>
  <h:panelGroup layout="block" styleClass="sakai-tool-header__actions sakai-no-print">
    <h:commandLink immediate="true" action="#{ForumTool.processActionNewTopic}" styleClass="sakai-btn sakai-btn-primary" rendered="#{ForumTool.selectedForum.newTopic}">
      <h:outputText value="" styleClass="si si-add" escape="false"/>
      <h:outputText value="#{msgs.cdfm_new_topic}"/>
      <f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
    </h:commandLink>
    <h:panelGroup layout="block" styleClass="sakai-tool-header__secondary">
      <h:commandLink immediate="true" action="#{ForumTool.processActionForumSettings}" styleClass="sakai-btn sakai-btn-secondary" rendered="#{ForumTool.selectedForum.changeSettings}">
        <h:outputText value="#{msgs.cdfm_forum_settings}"/>
        <f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
      </h:commandLink>
    </h:panelGroup>
    <details class="sakai-overflow-menu sakai-tool-header__more sakai-tool-header__more--persistent">
      <summary class="sakai-btn sakai-btn-ghost sakai-overflow-menu__toggle">
        <h:outputText value="" styleClass="si si-three-dots" escape="false"/>
        <h:outputText value="#{msgs.pvt_more_actions}" styleClass="visually-hidden"/>
      </summary>
      <div class="sakai-overflow-menu__panel">
        <h:commandLink immediate="true" action="#{ForumTool.processActionForumSettings}"
            styleClass="sakai-tool-header__priority-2" rendered="#{ForumTool.selectedForum.changeSettings}">
          <h:outputText value="#{msgs.cdfm_forum_settings}"/>
          <f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
        </h:commandLink>
        <h:commandLink immediate="true" action="#{mfStatisticsBean.processActionStatisticsByTopic}" rendered="#{ForumTool.instructor}">
          <h:outputText value="#{msgs.cdfm_button_bar_grade}"/>
          <f:param value="" name="topicId"/>
          <f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
        </h:commandLink>
        <h:commandLink immediate="true" action="#{ForumTool.processActionDuplicateForumMainConfirm}" rendered="#{ForumTool.selectedForum.newTopic}">
          <h:outputText value="#{msgs.cdfm_duplicate_forum}"/>
          <f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
        </h:commandLink>
        <h:commandLink immediate="true" action="#{ForumTool.processActionDeleteForumMainConfirm}" rendered="#{ForumTool.displayForumDeleteOption}">
          <h:outputText value="#{msgs.cdfm_button_bar_delete_forum}"/>
          <f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
        </h:commandLink>
      </div>
    </details>
  </h:panelGroup>
  <% } else if ("topic".equals(dfHeaderView) || "flat".equals(dfHeaderView)) { %>
  <h:panelGroup layout="block" styleClass="sakai-tool-header__actions sakai-no-print">
    <h:commandLink immediate="true" action="#{ForumTool.processAddMessage}" styleClass="sakai-btn sakai-btn-primary"
      rendered="#{ForumTool.selectedTopic.isNewResponse && !ForumTool.selectedTopic.locked && !ForumTool.selectedForum.locked}">
      <h:outputText value="" styleClass="si si-add" escape="false"/>
      <h:outputText value="#{msgs.cdfm_container_title_thread}"/>
    </h:commandLink>
    <h:panelGroup layout="block" styleClass="sakai-tool-header__secondary">
      <h:commandLink immediate="true" action="#{ForumTool.processActionTopicSettings}" styleClass="sakai-btn sakai-btn-secondary" rendered="#{ForumTool.selectedTopic.changeSettings}">
        <h:outputText value="#{msgs.cdfm_topic_settings}"/>
        <f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId"/>
        <f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
      </h:commandLink>
    </h:panelGroup>
    <details class="sakai-overflow-menu sakai-tool-header__more sakai-tool-header__more--persistent">
      <summary class="sakai-btn sakai-btn-ghost sakai-overflow-menu__toggle">
        <h:outputText value="" styleClass="si si-three-dots" escape="false"/>
        <h:outputText value="#{msgs.pvt_more_actions}" styleClass="visually-hidden"/>
      </summary>
      <div class="sakai-overflow-menu__panel">
        <h:commandLink immediate="true" action="#{ForumTool.processActionTopicSettings}"
            styleClass="sakai-tool-header__priority-2" rendered="#{ForumTool.selectedTopic.changeSettings}">
          <h:outputText value="#{msgs.cdfm_topic_settings}"/>
          <f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId"/>
          <f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
        </h:commandLink>
        <h:outputLink value="javascript:printFriendly('#{ForumTool.printFriendlyUrl}');">
          <h:outputText value="" styleClass="si si-print" escape="false"/>
          <h:outputText value="#{msgs.print_friendly}"/>
        </h:outputLink>
        <h:commandLink immediate="true" action="#{ForumTool.processActionDeleteTopicConfirm}"
          rendered="#{!ForumTool.selectedTopic.markForDeletion && ForumTool.displayTopicDeleteOption}">
          <h:outputText value="#{msgs.cdfm_button_bar_delete_topic}"/>
          <f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId"/>
        </h:commandLink>
      </div>
    </details>
  </h:panelGroup>
  <% } else if ("thread".equals(dfHeaderView)) { %>
  <h:panelGroup layout="block" styleClass="sakai-tool-header__actions sakai-no-print">
    <h:commandLink immediate="true" action="#{ForumTool.processDfMsgReplyThread}" styleClass="sakai-btn sakai-btn-primary"
      rendered="#{!ForumTool.threadMoved && ForumTool.selectedTopic.isNewResponseToResponse && ForumTool.selectedThreadHead.msgApproved && !ForumTool.selectedTopic.locked && !ForumTool.selectedForum.locked}">
      <h:outputText value="" styleClass="si si-reply-fill" escape="false"/>
      <h:outputText value="#{msgs.cdfm_reply_thread}"/>
    </h:commandLink>
    <h:panelGroup layout="block" styleClass="sakai-tool-header__secondary">
      <h:commandLink immediate="true" action="#{ForumTool.processActionMarkAllThreadAsNotRead}" styleClass="sakai-btn sakai-btn-secondary"
        rendered="#{ForumTool.selectedTopic.isMarkAsNotRead and not ForumTool.selectedTopic.topic.autoMarkThreadsRead}">
        <h:outputText value="#{msgs.cdfm_mark_all_as_not_read}"/>
      </h:commandLink>
    </h:panelGroup>
    <details class="sakai-overflow-menu sakai-tool-header__more">
      <summary class="sakai-btn sakai-btn-ghost sakai-overflow-menu__toggle">
        <h:outputText value="" styleClass="si si-three-dots" escape="false"/>
        <h:outputText value="#{msgs.pvt_more_actions}" styleClass="visually-hidden"/>
      </summary>
      <div class="sakai-overflow-menu__panel">
        <h:outputLink value="javascript:printFriendly('#{ForumTool.printFriendlyUrlThread}');">
          <h:outputText value="" styleClass="si si-print" escape="false"/>
          <h:outputText value="#{msgs.print_friendly}"/>
        </h:outputLink>
      </div>
    </details>
  </h:panelGroup>
  <% } else if ("message".equals(dfHeaderView)) { %>
  <h:panelGroup layout="block" styleClass="sakai-tool-header__actions sakai-no-print">
    <h:commandLink immediate="true" action="#{ForumTool.processDfMsgReplyMsg}" styleClass="sakai-btn sakai-btn-primary"
      rendered="#{!ForumTool.deleteMsg && !ForumTool.selectedMessage.message.deleted && ForumTool.selectedTopic.isNewResponseToResponse && ForumTool.selectedMessage.msgApproved && !ForumTool.selectedTopic.locked && !ForumTool.selectedForum.locked}">
      <h:outputText value="" styleClass="si si-reply-fill" escape="false"/>
      <h:outputText value="#{msgs.cdfm_button_bar_reply_to_msg}"/>
    </h:commandLink>
    <h:panelGroup layout="block" styleClass="sakai-tool-header__secondary">
      <h:commandLink immediate="true" action="#{ForumTool.processDfMsgReplyThread}" styleClass="sakai-btn sakai-btn-secondary"
        rendered="#{!ForumTool.deleteMsg && !ForumTool.selectedMessage.message.deleted && ForumTool.selectedTopic.isNewResponseToResponse && ForumTool.selectedThreadHead.msgApproved && !ForumTool.selectedTopic.locked && !ForumTool.selectedForum.locked}">
        <h:outputText value="#{msgs.cdfm_reply_thread}"/>
      </h:commandLink>
    </h:panelGroup>
  </h:panelGroup>
  <% } else if ("ranks".equals(dfHeaderView)) { %>
  <h:panelGroup layout="block" styleClass="sakai-tool-header__actions sakai-no-print">
    <h:commandLink immediate="true" action="#{ForumTool.processActionAddRank}" styleClass="sakai-btn sakai-btn-primary" rendered="#{ForumTool.instructor}">
      <h:outputText value="" styleClass="si si-add" escape="false"/>
      <h:outputText value="#{msgs.add_rank}"/>
    </h:commandLink>
  </h:panelGroup>
  <% } %>
</header>

<% if (dfHeaderHasSections) { %>
<h:panelGroup layout="block" rendered="#{ForumTool.displayPendingMsgQueue}">
  <nav class="sakai-tool-nav" aria-label="<%= msgs.getString("cdfm_tool_sections") %>">
    <% if (dfHeaderIsHome) { %>
    <span class="sakai-tool-nav__btn is-active" aria-current="page"><h:outputText value="#{msgs.cdfm_discussions}"/></span>
    <% } else { %>
    <h:commandLink immediate="true" action="forumsMain" styleClass="sakai-tool-nav__btn">
      <h:outputText value="#{msgs.cdfm_discussions}"/>
    </h:commandLink>
    <% } %>
    <% if (dfHeaderIsPending) { %>
    <span class="sakai-tool-nav__btn is-active" aria-current="page">
      <h:outputText value="#{msgs.cdfm_msg_pending_queue}"/>
      <h:outputText value=" ("/><h:outputText value="#{ForumTool.numPendingMessages}"/><h:outputText value=")"/>
    </span>
    <% } else { %>
    <h:commandLink immediate="true" action="#{ForumTool.processPendingMsgQueue}" styleClass="sakai-tool-nav__btn">
      <h:outputText value="#{msgs.cdfm_msg_pending_queue}"/>
      <h:outputText value=" ("/><h:outputText value="#{ForumTool.numPendingMessages}"/><h:outputText value=")"/>
    </h:commandLink>
    <% } %>
  </nav>
</h:panelGroup>
<% } %>

<% if (dfHeaderHasStatisticsSections) { %>
<nav class="sakai-tool-nav sakai-no-print" aria-label="<%= msgs.getString("cdfm_tool_sections") %>">
  <% if (dfHeaderIsStatistics) { %>
  <span class="sakai-tool-nav__btn is-active" aria-current="page"><h:outputText value="#{msgs.stat_byUser}"/></span>
  <% } else { %>
  <h:commandLink immediate="true" action="#{ForumTool.processActionStatistics}" styleClass="sakai-tool-nav__btn">
    <h:outputText value="#{msgs.stat_byUser}"/>
  </h:commandLink>
  <% } %>
  <% if (dfHeaderIsStatisticsByTopic) { %>
  <span class="sakai-tool-nav__btn is-active" aria-current="page"><h:outputText value="#{msgs.stat_byTopic}"/></span>
  <% } else { %>
  <h:commandLink immediate="true" action="#{mfStatisticsBean.processActionStatisticsByAllTopics}" styleClass="sakai-tool-nav__btn">
    <h:outputText value="#{msgs.stat_byTopic}"/>
  </h:commandLink>
  <% } %>
</nav>
<% } %>
