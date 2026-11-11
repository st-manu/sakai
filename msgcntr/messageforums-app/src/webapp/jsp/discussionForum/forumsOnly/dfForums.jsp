<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf" %>
<%@ taglib uri="http://myfaces.apache.org/tomahawk" prefix="t" %>

<%
// hack in attempt to fix navigation quirk
org.sakaiproject.tool.cover.SessionManager.getCurrentToolSession().
	removeAttribute(org.sakaiproject.jsf2.util.JsfTool.LAST_VIEW_VISITED);
%>

<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>



<f:view>
  <sakai:view title="#{msgs.cdfm_discussions}">
  		<script>includeLatestJQuery("msgcntr");</script>
		<script src="/messageforums-tool/js/sak-10625.js"></script>
		<script src="/messageforums-tool/js/forum.js"></script>
	<h:form id="msgForum" styleClass="sakai-forums">
	<% request.setAttribute("dfHeaderView", "home"); %>
	<%@ include file="/jsp/discussionForum/menu/forumsHeader.jsp" %>
	<h:messages styleClass="sakai-banner sakai-banner--error" id="errorMessages" rendered="#{! empty facesContext.maximumSeverity}" />
	<%@ include file="/jsp/discussionForum/includes/dfAreaInclude.jsp"%>
	
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
 	</sakai:view>
 </f:view>
