<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
	<jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>
<f:view>
  <sakai:view >
  	<h:form id="dfStatisticsForm" rendered="#{ForumTool.instructor}">
<!-- discussionForum/statistics/dfStatisticsListByAllTopics.jsp-->
       		<script>includeLatestJQuery("msgcntr");</script>
       		<script src="/messageforums-tool/js/sak-10625.js"></script>

			<% request.setAttribute("dfHeaderView", "statisticsByTopic"); %>
			<% request.setAttribute("dfHeaderBack", "discussions"); %>
<%@ include file="/jsp/discussionForum/menu/forumsHeader.jsp" %>

      <div class="sakai-table-toolbar sakai-no-print">
        <div class="sakai-table-toolbar__actions">
          <h:commandLink action="#{mfStatisticsBean.processExportDataTableByTopic}" styleClass="sakai-btn sakai-btn-ghost" title="#{msgs.stat_explort_table}">
            <h:outputText value="" styleClass="si si-download" escape="false"/>
            <h:outputText value="#{msgs.stat_explort_table}"/>
          </h:commandLink>
        </div>
      </div>

      <div class="sakai-table-wrap">
  		<h:dataTable styleClass="sakai-table sakai-table--hover sakai-table--stack" id="members" value="#{mfStatisticsBean.allTopicStatistics}" var="stat" rendered="true"
   	 		columnClasses="sakai-table__primary,bogus,bogus,bogus" cellpadding="0" cellspacing="0">
  			<h:column>
  				<f:facet name="header">
  					<h:commandLink action="#{mfStatisticsBean.toggleAllTopicsForumTitleSort}" title="#{msgs.stat_forum_title}">
					   	<h:outputText value="#{msgs.stat_forum_title}" />
						<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.allTopicsForumTitleSort && mfStatisticsBean.ascendingForAllTopics}"/>
						<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.allTopicsForumTitleSort && !mfStatisticsBean.ascendingForAllTopics}"/>
					</h:commandLink>
  				</f:facet>
				<h:commandLink action="#{mfStatisticsBean.processActionStatisticsByTopic}" immediate="true">
  				    <f:param value="" name="topicId"/>
  				    <f:param value="#{stat.forumId}" name="forumId"/>
  				    <h:outputText value="#{stat.forumTitle}" />
	          	</h:commandLink>
			</h:column>
  			<h:column>
  				<f:facet name="header">
  					<h:commandLink action="#{mfStatisticsBean.toggleAllTopicsTopicTitleSort}" title="#{msgs.stat_topic_title}">
					   	<h:outputText value="#{msgs.stat_topic_title}" />
						<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.allTopicsTopicTitleSort && mfStatisticsBean.ascendingForAllTopics}"/>
						<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.allTopicsTopicTitleSort && !mfStatisticsBean.ascendingForAllTopics}"/>
					</h:commandLink>
  				</f:facet>
  				<h:commandLink action="#{mfStatisticsBean.processActionStatisticsByTopic}" immediate="true">
  				    <f:param value="#{stat.topicId}" name="topicId"/>
  				    <f:param value="#{stat.forumId}" name="forumId"/>
  				    <h:outputText value="#{stat.topicTitle}" />
	          	</h:commandLink>
  			</h:column>
  			<h:column>
  				<f:facet name="header">
  					<h:commandLink action="#{mfStatisticsBean.toggleAllTopicsForumDateSort}" title="#{msgs.stat_forum_date}">
					   	<h:outputText value="#{msgs.stat_forum_date}" />
						<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.allTopicsTopicDateSort && mfStatisticsBean.ascendingForAllTopics}"/>
						<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.allTopicsTopicDateSort && !mfStatisticsBean.ascendingForAllTopics}"/>
					</h:commandLink>
  				</f:facet>
  				<h:outputText value="#{stat.topicDate}">
  					<f:convertDateTime pattern="#{msgs.date_format}" timeZone="#{ForumTool.userTimeZone}" locale="#{ForumTool.userLocale}"/>
  				</h:outputText>
  			</h:column>
  			<h:column>
  				<f:facet name="header">
  					<h:commandLink action="#{mfStatisticsBean.toggleAllTopicsTopicTotalMessagesSort}" title="#{msgs.stat_totalMessages}">
					   	<h:outputText value="#{msgs.stat_totalMessages}" />
						<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.allTopicsTopicTotalMessagesSort && mfStatisticsBean.ascendingForAllTopics}"/>
						<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.allTopicsTopicTotalMessagesSort && !mfStatisticsBean.ascendingForAllTopics}"/>
					</h:commandLink>
  				</f:facet>
  				<h:outputText value="#{stat.totalTopicMessages}" />
  			</h:column>
  		</h:dataTable>
      </div>

  	</h:form>
  </sakai:view>
</f:view>
