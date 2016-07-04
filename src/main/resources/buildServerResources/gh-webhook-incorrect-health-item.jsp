<%@ page import="jetbrains.buildServer.web.openapi.healthStatus.HealthStatusItemDisplayMode" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="afn" uri="/WEB-INF/functions/authz" %>
<%@ taglib prefix="forms" tagdir="/WEB-INF/tags/forms" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="/include-internal.jsp" %>

<jsp:useBean id="showMode" type="jetbrains.buildServer.web.openapi.healthStatus.HealthStatusItemDisplayMode" scope="request"/>
<jsp:useBean id="healthStatusReportUrl" type="java.lang.String" scope="request"/>
<jsp:useBean id="pageUrl" type="java.lang.String" scope="request"/>

<c:set var="inplaceMode" value="<%=HealthStatusItemDisplayMode.IN_PLACE%>"/>
<c:set var="cameFromUrl" value="${showMode eq inplaceMode ? pageUrl : healthStatusReportUrl}"/>

<%--@elvariable id="healthStatusItem" type="jetbrains.buildServer.serverSide.healthStatus.HealthStatusItem"--%>
<%--@elvariable id="pluginResourcesPath" type="java.lang.String"--%>
<%--@elvariable id="has_connections" type="java.lang.Boolean"--%>
<%--@elvariable id="has_tokens" type="java.lang.Boolean"--%>

<c:set var="GitHubInfo" value="${healthStatusItem.additionalData['GitHubInfo']}"/>
<c:set var="HookInfo" value="${healthStatusItem.additionalData['HookInfo']}"/>
<c:set var="Reason" value="${healthStatusItem.additionalData['Reason']}"/>
<c:set var="Project" value="${healthStatusItem.additionalData['Project']}"/>
<%--@elvariable id="GitHubInfo" type="org.jetbrains.teamcity.github.GitHubRepositoryInfo"--%>
<%--@elvariable id="HookInfo" type="org.jetbrains.teamcity.github.WebHooksStorage.HookInfo"--%>
<%--@elvariable id="Project" type="jetbrains.buildServer.serverSide.SProject"--%>
<%--@elvariable id="Reason" type="java.lang.String"--%>

<c:set var="id" value="hid_i_${util:forJSIdentifier(GitHubInfo.identifier)}"/>

<div id='${id}' class="suggestionItem" data-repository="${GitHubInfo}" data-server="${GitHubInfo.server}">
    <c:if test="${HookInfo != null}"><a href="<c:out value="${GitHubInfo.repositoryUrl}/settings/hooks/${HookInfo.id}"/>">Webhook</a></c:if>
    <c:if test="${HookInfo == null}">Webhook</c:if>
    for GitHub repository <a href="${GitHubInfo.repositoryUrl}"><c:out value="${GitHubInfo}"/></a>
    is outdated or misconfigured: <c:out value="${Reason}"/>
    <div class="suggestionAction">
        <c:set var="projectUrl"><admin:editProjectLink projectId="${Project}" withoutLink="true"/></c:set>
        <forms:addLink
                href="${projectUrl}&tab=installWebHook&repository=${util:urlEscape(GitHubInfo.toString())}&cameFromUrl=${util:urlEscape(cameFromUrl)}">Install webhook</forms:addLink>
    </div>
</div>

<script type="text/javascript">
    (function () {
        if (typeof BS.GitHubWebHooks === 'undefined') {
            $j('#${id}').append("<script type='text/javascript' src='<c:url value="${pluginResourcesPath}gh-webhook.js"/>'/>");
        }
        if (typeof BS.ServerInfo === 'undefined') {
            BS.ServerInfo = {
                url: '${serverSummary.rootURL}'
            };
        }
        if (typeof BS.RequestInfo === 'undefined') {
            BS.RequestInfo = {
                context_path: '${pageContext.request.contextPath}'
            };
        }
        BS.GitHubWebHooks.info['${GitHubInfo.identifier}'] = ${GitHubInfo.toJson()};
        BS.GitHubWebHooks.forcePopup['${GitHubInfo.server}'] = ${not has_connections or not has_tokens};
    })();
</script>