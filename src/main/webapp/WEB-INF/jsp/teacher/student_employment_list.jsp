<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    request.setAttribute("pageTitle", "学生就业情况列表 - 毕业管理系统");
%>

<jsp:include page="/WEB-INF/jsp/common/header.jsp"/>
<jsp:include page="/WEB-INF/jsp/common/navbar.jsp"/>

<style>
    .page-title {
        color: #2d3748;
        font-weight: 600;
        font-size: 22px;
        margin: 20px 0 20px !important;
        position: relative;
        padding-bottom: 10px;
        border-bottom: 1px solid #edf2f7;
    }
    .page-title::after {
        content: "";
        position: absolute;
        left: 0;
        bottom: -1px;
        width: 80px;
        height: 2px;
        background: #2c5282;
        border-radius: 1px;
    }

    .list-card {
        border-radius: 12px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 2px 8px rgba(15, 23, 42, 0.03);
        overflow: hidden;
        background-color: #ffffff;
    }
    .list-card-header {
        padding: 10px 16px;
        background-color: #f8fafc;
        border-bottom: 1px solid #e2e8f0;
        font-weight: 500;
        font-size: 14px;
        color: #1e293b;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .list-card-header-left {
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .list-card-header-left::before {
        content: "";
        display: inline-block;
        width: 4px;
        height: 18px;
        border-radius: 4px;
        background: #3b82f6;
    }
    .list-card-body {
        padding: 12px 16px 16px;
    }

    .stats-hint {
        font-size: 13px;
        color: #6b7280;
        margin-bottom: 10px;
    }

    .table-employment {
        margin-bottom: 0;
        font-size: 13px;
    }
    .table-employment thead th {
        background-color: #f8fafc;
        border-bottom: 1px solid #e2e8f0;
        color: #4b5563;
        font-weight: 500;
        white-space: nowrap;
    }
    .table-employment tbody tr:hover {
        background-color: #f1f5f9;
    }

    .status-pill {
        display: inline-block;
        padding: 2px 8px;
        border-radius: 999px;
        font-size: 12px;
        font-weight: 500;
        white-space: nowrap;
    }
    .status-employment {
        background-color: #dbeafe;
        color: #1d4ed8;
    }
    .status-waiting {
        background-color: #fef3c7;
        color: #92400e;
    }
    .status-other {
        background-color: #e5e7eb;
        color: #374151;
    }

    .empty-alert {
        margin-top: 12px;
    }

    @media (max-width: 768px) {
        .page-title {
            font-size: 20px;
            margin-top: 16px !important;
        }
        .list-card-body {
            padding: 10px 12px 14px;
        }
        .table-employment {
            font-size: 12px;
        }
    }
</style>

<div class="container">
    <div class="row">
        <jsp:include page="/WEB-INF/jsp/teacher/sidebar.jsp"/>

        <div class="col-md-9">
            <h3 class="page-title">学生就业待审核列表（${scopeLabel}）</h3>

            <c:if test="${empty latestEmploymentList}">
                <div class="alert alert-info empty-alert">
                    暂无流转到你这里的待审核就业登记。
                </div>
            </c:if>

            <c:if test="${not empty latestEmploymentList}">
                <div class="list-card">
                    <div class="list-card-header">
                        <div class="list-card-header-left">
                            学生就业情况列表
                        </div>
                        <div class="text-muted" style="font-size: 12px;">
                            共 ${fn:length(latestEmploymentList)} 条记录
                        </div>
                    </div>

                    <div class="list-card-body">
                        <p class="stats-hint">
                            这里只显示已经流转到当前登录角色的待审核就业登记。前一级未通过时，后一级不会在此处看到该记录。
                        </p>

                        <div class="table-responsive">
                            <table class="table table-sm table-striped align-middle table-employment">
                                <thead>
                                <tr>
                                    <th style="width: 8%;">学生ID</th>
                                    <th style="width: 14%;">学号</th>
                                    <th style="width: 14%;">就业状态</th>
                                    <th style="width: 22%;">单位</th>
                                    <th style="width: 14%;">岗位</th>
                                    <th style="width: 12%;">城市</th>
                                    <th style="width: 12%;">当前节点</th>
                                    <th style="width: 16%;">登记时间</th>
                                    <th style="width: 10%;">操作</th>
                                </tr>
                                </thead>

                                <tbody>
                                <c:forEach var="e" items="${latestEmploymentList}">
                                    <tr>
                                        <td>${e.studentId}</td>

                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty e.studentNo}">
                                                    ${e.studentNo}
                                                </c:when>
                                                <c:otherwise>
                                                    -
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td>
                                            <c:choose>
                                                <c:when test="${e.status != null && (fn:contains(e.status, '就业') || fn:contains(e.status, '签约') || fn:contains(e.status, '录用'))}">
                                                    <span class="status-pill status-employment">${e.status}</span>
                                                </c:when>
                                                <c:when test="${e.status != null && (fn:contains(e.status, '未') || fn:contains(e.status, '待'))}">
                                                    <span class="status-pill status-waiting">${e.status}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-pill status-other">
                                                        <c:out value="${e.status}" default="-"/>
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td>
                                            <c:out value="${e.companyName}" default="-"/>
                                        </td>

                                        <td>
                                            <c:out value="${e.position}" default="-"/>
                                        </td>

                                        <td>
                                            <c:out value="${e.city}" default="-"/>
                                        </td>

                                        <td>
                                            <c:choose>
                                                <c:when test="${e.reviewStage == 'SUPERVISOR'}">
                                                    <span class="status-pill status-waiting">指导老师审核</span>
                                                </c:when>
                                                <c:when test="${e.reviewStage == 'CLASS_TEACHER'}">
                                                    <span class="status-pill status-waiting">班主任审核</span>
                                                </c:when>
                                                <c:when test="${e.reviewStage == 'COUNSELOR'}">
                                                    <span class="status-pill status-waiting">导员审核</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-pill status-other">${e.reviewStage}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td>
                                            <c:out value="${e.reportTime}" default="-"/>
                                        </td>

                                        <td>
                                            <a href="${pageContext.request.contextPath}/teacher/employment/detail?studentId=${e.studentId}"
                                               class="btn btn-sm btn-outline-secondary">
                                                去审核
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>