<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    request.setAttribute("pageTitle", "就业去向历次登记记录 - 学生端");
%>

<jsp:include page="/WEB-INF/jsp/common/header.jsp"/>
<jsp:include page="/WEB-INF/jsp/common/navbar.jsp"/>

<style>
    /* 登记记录页面专属样式 - 科研风格统一 */
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

    /* 表格样式 - 科研风 */
    .data-table-container {
        border: 1px solid #e8eef4;
        border-radius: 12px;
        overflow: hidden;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
        margin-bottom: 24px;
    }

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

    /* 状态样式 */
    .status-pending {
        color: #ed8936;
        font-weight: 500;
    }

    .status-approved {
        color: #38b2ac;
        font-weight: 500;
    }

    .status-rejected {
        color: #e53e3e;
        font-weight: 500;
    }

    /* 按钮样式 */
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

    .btn-secondary {
        background-color: #718096;
        border-color: #718096;
        border-radius: 6px;
        padding: 8px 16px;
        font-size: 14px;
        transition: all 0.2s ease;
    }

    .btn-secondary:hover {
        background-color: #4a5568;
        border-color: #4a5568;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
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
        .btn-secondary {
            width: 100%;
        }
    }
</style>

<div class="container">
    <div class="row">
        <!-- 左侧学生导航 -->
        <jsp:include page="/WEB-INF/jsp/student/sidebar.jsp"/>

        <!-- 右侧内容 -->
        <div class="col-md-9">
            <h3 class="page-title">就业去向历次登记记录 / 审核状态</h3>

            <c:if test="${empty submissionList}">
                <div class="info-alert">
                    您暂未有任何提交记录。
                </div>
            </c:if>

            <c:if test="${not empty submissionList}">
                <div class="data-table-container">
                    <table class="table data-table align-middle">
                        <thead>
                        <tr>
                            <th style="width: 8%;">ID</th>
                            <th style="width: 30%;">标题</th>
                            <th style="width: 15%;">类型</th>
                            <th style="width: 15%;">状态</th>
                            <th style="width: 20%;">提交时间</th>
                            <th style="width: 12%;">操作</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="item" items="${submissionList}">
                            <tr>
                                <td>${item.submissionId}</td>
                                <td>${item.title}</td>
                                <td>${item.type}</td>
                                <td>
                                    <span class="
                                        <c:choose>
                                            <c:when test="${item.overallStatus == '已通过'}">status-approved</c:when>
                                            <c:when test="${item.overallStatus == '已驳回'}">status-rejected</c:when>
                                            <c:otherwise>status-pending</c:otherwise>
                                        </c:choose>
                                    ">
                                            ${item.overallStatus}
                                    </span>
                                </td>
                                <td>${item.createdAt}</td>
                                <td>
                                    <!-- 查看材料链接 -->
                                    <a class="btn btn-outline-primary"
                                       href="${pageContext.request.contextPath}/student/submission/view?submissionId=${item.submissionId}">
                                        查看材料
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:if>

            <a class="btn btn-secondary"
               href="${pageContext.request.contextPath}/student/employment/register">
                返回就业去向登记
            </a>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>