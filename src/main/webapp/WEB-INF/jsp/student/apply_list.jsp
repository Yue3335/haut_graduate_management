<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    request.setAttribute("pageTitle", "我的申请材料 - 毕业管理系统");
%>

<jsp:include page="/WEB-INF/jsp/common/header.jsp"/>
<jsp:include page="/WEB-INF/jsp/common/navbar.jsp"/>

<style>
    /* 申请材料页面专属样式 - 科研风格统一 */
    .page-title {
        color: #2d3748;
        font-weight: 600;
        font-size: 22px;
        margin-bottom: 28px !important;
        position: relative;
        padding-bottom: 12px;
        border-bottom: 1px solid #f0f2f5;
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

    /* 信息提示框 */
    .info-alert {
        background-color: #f0f7ff;
        border: 1px solid #3182ce;
        color: #2c5282;
        border-radius: 8px;
        padding: 12px 16px;
        font-size: 14px;
        margin-bottom: 24px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.02);
        text-align: center;
    }

    /* 表格容器样式 */
    .data-table-container {
        border: 1px solid #e8eef4;
        border-radius: 12px;
        overflow: hidden;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
        margin-bottom: 24px;
    }

    /* 表格样式 - 科研风 */
    .data-table {
        width: 100%;
        margin-bottom: 0;
        background-color: #ffffff;
    }

    .data-table thead {
        background-color: #f8fafc;
    }

    .data-table th {
        padding: 14px 12px;
        font-size: 13px;
        font-weight: 500;
        color: #2d3748;
        border-bottom: 2px solid #e8eef4;
        text-align: left;
        vertical-align: middle;
    }

    .data-table td {
        padding: 12px 12px;
        font-size: 14px;
        color: #4a5568;
        border-bottom: 1px solid #f0f2f5;
        vertical-align: middle;
    }

    .data-table tbody tr:hover {
        background-color: #f8fafc;
    }

    /* 状态样式差异化 */
    .status-approved {
        color: #38b2ac;
        font-weight: 500;
    }

    .status-rejected {
        color: #e53e3e;
        font-weight: 500;
    }

    .status-pending {
        color: #ed8936;
        font-weight: 500;
    }

    /* 操作按钮样式 */
    .btn-outline-primary {
        border-color: #3182ce;
        color: #3182ce;
        border-radius: 6px;
        padding: 6px 12px;
        font-size: 13px;
        transition: all 0.2s ease;
    }

    .btn-outline-primary:hover {
        background-color: #f0f7ff;
        border-color: #2c5282;
        color: #2c5282;
    }

    /* 响应式适配 */
    @media (max-width: 992px) {
        .data-table-container {
            overflow-x: auto;
        }
        .data-table th, .data-table td {
            padding: 12px 10px;
            font-size: 13px;
        }
    }

    @media (max-width: 576px) {
        .page-title {
            font-size: 20px;
        }
        .btn-outline-primary {
            width: 100%;
        }
    }
</style>

<div class="container">
    <div class="row">
        <jsp:include page="/WEB-INF/jsp/student/sidebar.jsp"/>

        <div class="col-md-9">
            <h3 class="page-title">我的申请材料</h3>

            <c:if test="${empty applyList}">
                <div class="info-alert">
                    您暂未提交任何申请材料。
                </div>
            </c:if>

            <c:if test="${not empty applyList}">
                <div class="data-table-container">
                    <table class="table data-table align-middle">
                        <thead>
                        <tr>
                            <th style="width: 5%;">ID</th>
                            <th style="width: 35%;">标题</th>
                            <th style="width: 15%;">类型</th>
                            <th style="width: 15%;">状态</th>
                            <th style="width: 20%;">提交时间</th>
                            <th style="width: 10%;">操作</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="a" items="${applyList}">
                            <tr>
                                <td>${a.applyId}</td>
                                <td>${a.title}</td>
                                <td>${a.type}</td>
                                <td>
                                    <span class="
                                        <c:choose>
                                            <c:when test="${a.status == '已通过'}">status-approved</c:when>
                                            <c:when test="${a.status == '已驳回'}">status-rejected</c:when>
                                            <c:otherwise>status-pending</c:otherwise>
                                        </c:choose>
                                    ">
                                            ${a.status}
                                    </span>
                                </td>
                                <td>${a.createdAt}</td>
                                <td>
                                    <a class="btn btn-outline-primary"
                                       href="${pageContext.request.contextPath}/student/apply/view?applyId=${a.applyId}">
                                        查看材料
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:if>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>