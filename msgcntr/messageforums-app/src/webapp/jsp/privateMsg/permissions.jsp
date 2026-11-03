<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>

<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>
<f:view>
    <sakai:view>
        <% request.setAttribute("pvtHeaderTitleKey", "pvt_permissions"); %>
        <%@ include file="/jsp/privateMsg/pvtToolHeader.jsp" %>
        <sakai-permissions tool="msg.permissions" bundle-key="org.sakaiproject.api.app.messagecenter.bundle.Messages" />
    </sakai:view>
</f:view>
