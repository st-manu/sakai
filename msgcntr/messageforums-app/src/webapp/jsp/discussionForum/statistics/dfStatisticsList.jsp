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
<!-- discussionForum/statistics/dfStatisticsList.jsp-->
       		<script>includeLatestJQuery("msgcntr");</script>
       		<script src="/messageforums-tool/js/sak-10625.js"></script>
        <% request.setAttribute("dfHeaderView", "statistics"); %>
        <% request.setAttribute("dfHeaderBack", "discussions"); %>
<%@ include file="/jsp/discussionForum/menu/forumsHeader.jsp" %>

      <div class="sakai-table-toolbar sakai-no-print">
        <div class="sakai-table-toolbar__actions">
          <h:commandLink action="#{mfStatisticsBean.processExportDataTableByUser}" styleClass="sakai-btn sakai-btn-ghost" title="#{msgs.stat_explort_table}">
            <h:outputText value="" styleClass="si si-download" escape="false"/>
            <h:outputText value="#{msgs.stat_explort_table}"/>
          </h:commandLink>
        </div>
      </div>

      <div class="sakai-table-wrap">
  		<h:dataTable styleClass="sakai-table sakai-table--hover sakai-table--stack" id="members" value="#{mfStatisticsBean.allUserStatistics}" var="stat" rendered="true"
   	 		columnClasses="sakai-table__primary,bogus,bogus,bogus,bogus,bogus,bogus,bogus" cellpadding="0" cellspacing="0">
  			<h:column>
  				<f:facet name="header">
					<h:commandLink action="#{mfStatisticsBean.toggleNameSort}" title="#{mfStatisticsBean.pureAnon ? msgs.stat_anon_user : msgs.stat_name}">
					   	<h:outputText value="#{mfStatisticsBean.pureAnon ? msgs.stat_anon_user : msgs.stat_name}" />
						<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.nameSort && mfStatisticsBean.ascending}"/>
						<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.nameSort && !mfStatisticsBean.ascending}"/>
					</h:commandLink>
  				</f:facet>
  				<h:commandLink action="#{mfStatisticsBean.processActionStatisticsUser}" immediate="true">
  				    <f:param value="#{stat.siteUserId}" name="siteUserId"/>
  				    <h:outputText rendered="#{!stat.useAnonId}" value="#{stat.siteUser}" />
  				    <h:outputText rendered="#{stat.useAnonId}" value="#{stat.siteAnonId}" styleClass="anonymousAuthor"/>
	          	</h:commandLink>
			</h:column>

			<h:column rendered="#{!mfStatisticsBean.pureAnon}">
				<f:facet name="header">
					<h:commandLink action="#{mfStatisticsBean.toggleIdSort}" title="#{msgs.stat_eid}">
						<h:outputText value="#{msgs.stat_eid}" />
						<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.idSort && mfStatisticsBean.ascending}"/>
						<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.idSort && !mfStatisticsBean.ascending}"/>
					</h:commandLink>
				</f:facet>
				<h:commandLink action="#{mfStatisticsBean.processActionStatisticsUser}" immediate="true">
					<f:param value="#{stat.siteUserId}" name="siteUserId"/>
					<h:outputText value="#{stat.siteUserDisplayId}" />
				</h:commandLink>
			</h:column>

			<h:column>
                            <f:facet name="header">
                                <h:commandLink action="#{mfStatisticsBean.toggleAuthoredNewSort}" title="#{msgs.stat_authored_new}">
                                    <h:outputText value="#{msgs.stat_authored_new}" />
                                    <h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.authoredNewSort && mfStatisticsBean.ascending}"/>
                                    <h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.authoredNewSort && !mfStatisticsBean.ascending}"/>
                                </h:commandLink>
                            </f:facet>
                            <h:outputText value="#{stat.authoredForumsNewAmt}" />
                        </h:column>
                        <h:column>
                            <f:facet name="header">
                                <h:commandLink action="#{mfStatisticsBean.toggleAuthoredRepliesSort}" title="#{msgs.stat_authored_replies}">
                                    <h:outputText value="#{msgs.stat_authored_replies}" />
                                    <h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.authoredRepliesSort && mfStatisticsBean.ascending}"/>
                                    <h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.authoredRepliesSort && !mfStatisticsBean.ascending}"/>
                                </h:commandLink>
                            </f:facet>
                            <h:outputText value="#{stat.authoredForumsRepliesAmt}" />
                        </h:column>

  			<h:column>
  				<f:facet name="header">
  					<h:commandLink action="#{mfStatisticsBean.toggleAuthoredSort}" title="#{msgs.stat_authored_total}">
                        <h:outputText value="#{msgs.stat_authored_total}" />
                        <h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.authoredSort && mfStatisticsBean.ascending}"/>
                        <h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.authoredSort && !mfStatisticsBean.ascending}"/>
					</h:commandLink>
  				</f:facet>
  				<h:outputText value="#{stat.authoredForumsAmt}" />
  			</h:column>
  			<h:column>
  				<f:facet name="header">
  					<h:commandLink action="#{mfStatisticsBean.toggleReadSort}" title="#{msgs.stat_read}">
					   	<h:outputText value="#{msgs.stat_read}" />
						<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.readSort && mfStatisticsBean.ascending}"/>
						<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.readSort && !mfStatisticsBean.ascending}"/>
					</h:commandLink>
  				</f:facet>
  				<h:outputText value="#{stat.readForumsAmt}" />
  			</h:column>
  			<h:column>
  				<f:facet name="header">
  					<h:commandLink action="#{mfStatisticsBean.toggleUnreadSort}" title="#{msgs.stat_unread}">
					   	<h:outputText value="#{msgs.stat_unread}" />
						<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.unreadSort && mfStatisticsBean.ascending}"/>
						<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.unreadSort && !mfStatisticsBean.ascending}"/>
					</h:commandLink>
  				</f:facet>
  				<h:outputText value="#{stat.unreadForumsAmt}" />
  			</h:column>
  			<h:column>
  				<f:facet name="header">
  					<h:commandLink action="#{mfStatisticsBean.togglePercentReadSort}" title="#{msgs.stat_percent_read}">
					   	<h:outputText value="#{msgs.stat_percent_read}" />
						<h:outputText value="" styleClass="si si-sort-up" escape="false" rendered="#{mfStatisticsBean.percentReadSort && mfStatisticsBean.ascending}"/>
						<h:outputText value="" styleClass="si si-sort-down" escape="false" rendered="#{mfStatisticsBean.percentReadSort && !mfStatisticsBean.ascending}"/>
					</h:commandLink>
  				</f:facet>
  				<h:outputText value="#{stat.percentReadForumsAmt}">
  					<f:convertNumber type="percent" />
  				</h:outputText>
  			</h:column>
  		</h:dataTable>
      </div>
  	</h:form>
  </sakai:view>
</f:view>
