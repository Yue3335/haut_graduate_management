<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    request.setAttribute("pageTitle", "查看提交材料 - 学生端");
%>

<jsp:include page="/WEB-INF/jsp/common/header.jsp"/>
<jsp:include page="/WEB-INF/jsp/common/navbar.jsp"/>

<style>
    /* 查看材料页面专属样式 - 科研风格统一 */
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

    /* 错误提示框 */
    .danger-alert {
        background-color: #fff5f5;
        border: 1px solid #e53e3e;
        color: #742a2a;
        border-radius: 8px;
        padding: 12px 16px;
        font-size: 14px;
        margin-bottom: 24px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.02);
    }

    /* 详情卡片样式 */
    .detail-card {
        border: 1px solid #e8eef4;
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
        overflow: hidden;
        background-color: #ffffff;
        margin-bottom: 24px;
    }

    .detail-table {
        width: 100%;
        margin-bottom: 0;
        border-collapse: collapse;
    }

    .detail-table th {
        width: 120px;
        padding: 14px 20px;
        background-color: #f8fafc;
        color: #2c5282;
        font-weight: 500;
        font-size: 14px;
        text-align: left;
        border-bottom: 1px solid #e8eef4;
        vertical-align: top;
    }

    .detail-table td {
        padding: 14px 20px;
        color: #4a5568;
        font-size: 14px;
        border-bottom: 1px solid #f0f2f5;
        vertical-align: top;
    }

    /* 最后一行移除边框 */
    .detail-table tr:last-child th,
    .detail-table tr:last-child td {
        border-bottom: none;
    }

    /* 状态样式 */
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

    /* 附件链接样式 */
    .attachment-link {
        color: #3182ce;
        text-decoration: none;
        font-weight: 500;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        transition: all 0.2s ease;
    }

    .attachment-link:hover {
        color: #2c5282;
        text-decoration: underline;
    }

    .attachment-link::before {
        content: "📎";
        font-size: 16px;
    }

    .no-attachment {
        color: #718096;
        font-style: italic;
        font-size: 14px;
    }

    /* 按钮样式 */
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
    @media (max-width: 768px) {
        .detail-table th {
            width: 100px;
            padding: 12px 16px;
            font-size: 13px;
        }
        .detail-table td {
            padding: 12px 16px;
            font-size: 13px;
        }
    }

    @media (max-width: 576px) {
        .page-title {
            font-size: 20px;
        }
        .detail-table th {
            width: 80px;
            padding: 10px 14px;
        }
        .detail-table td {
            padding: 10px 14px;
        }
        .btn-secondary {
            width: 100%;
        }
    }
</style>

<div class="container">
    <div class="row">
        <jsp:include page="/WEB-INF/jsp/student/sidebar.jsp"/>

        <div class="col-md-9">
            <h3 class="page-title">提交材料详情</h3>

            <c:if test="${empty submission}">
                <div class="danger-alert">
                    未找到该提交记录。
                </div>
            </c:if>

            <c:if test="${not empty submission}">
                <div class="detail-card">
                    <table class="detail-table">
                        <tr>
                            <th>标题</th>
                            <td>${submission.title}</td>
                        </tr>
                        <tr>
                            <th>类型</th>
                            <td>${submission.type}</td>
                        </tr>
                        <tr>
                            <th>提交时间</th>
                            <td>${submission.createdAt}</td>
                        </tr>
                        <tr>
                            <th>当前状态</th>
                            <td>
                                <span class="
                                    <c:choose>
                                        <c:when test="${submission.overallStatus == '已通过'}">status-approved</c:when>
                                        <c:when test="${submission.overallStatus == '已驳回'}">status-rejected</c:when>
                                        <c:otherwise>status-pending</c:otherwise>
                                    </c:choose>
                                ">
                                        ${submission.overallStatus}
                                </span>
                            </td>
                        </tr>
                        <tr>
                            <th>附件</th>
                            <td>
                                <c:if test="${empty submission.contentPath}">
                                    <span class="no-attachment">暂无附件</span>
                                </c:if>
                                <c:if test="${not empty submission.contentPath}">
                                    <!-- 假设 contentPath 是类似 upload/submission/20220001/xxx.pdf 的相对路径 -->
                                    <a href="${pageContext.request.contextPath}/${submission.contentPath}"
                                       target="_blank" class="attachment-link">
                                        查看 / 下载附件
                                    </a>
                                </c:if>
                            </td>
                        </tr>
                    </table>
                </div>

                <a class="btn btn-secondary"
                   href="${pageContext.request.contextPath}/student/submission/status">
                    返回历次记录
                </a>
            </c:if>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>