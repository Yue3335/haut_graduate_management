<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    request.setAttribute("pageTitle", "查看申请材料 - 毕业管理系统");
%>

<jsp:include page="/WEB-INF/jsp/common/header.jsp"/>
<jsp:include page="/WEB-INF/jsp/common/navbar.jsp"/>

<style>
    /* 申请材料详情页面专属样式 - 科研风格统一 */
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

    /* 审核备注样式 */
    .remark-text {
        color: #4a5568;
        line-height: 1.6;
    }

    .no-remark {
        color: #718096;
        font-style: italic;
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
            <h3 class="page-title">申请材料详情</h3>

            <c:if test="${empty apply}">
                <div class="danger-alert">
                    未找到该申请材料记录。
                </div>
            </c:if>

            <c:if test="${not empty apply}">
                <div class="detail-card">
                    <table class="detail-table">
                        <tr>
                            <th>标题</th>
                            <td>${apply.title}</td>
                        </tr>
                        <tr>
                            <th>类型</th>
                            <td>${apply.type}</td>
                        </tr>
                        <tr>
                            <th>提交时间</th>
                            <td>${apply.createdAt}</td>
                        </tr>
                        <tr>
                            <th>当前状态</th>
                            <td>
                                <span class="
                                    <c:choose>
                                        <c:when test="${apply.status == '已通过'}">status-approved</c:when>
                                        <c:when test="${apply.status == '已驳回'}">status-rejected</c:when>
                                        <c:otherwise>status-pending</c:otherwise>
                                    </c:choose>
                                ">
                                        ${apply.status}
                                </span>
                            </td>
                        </tr>
                        <tr>
                            <th>审核备注</th>
                            <td>
                                <c:choose>
                                    <c:when test="${empty apply.remark}">
                                        <span class="no-remark">无</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="remark-text"><c:out value="${apply.remark}"/></span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                        <tr>
                            <th>材料附件</th>
                            <td>
                                <c:if test="${empty apply.filePath}">
                                    <span class="no-attachment">暂无附件</span>
                                </c:if>
                                <c:if test="${not empty apply.filePath}">
                                    <a href="${pageContext.request.contextPath}/${apply.filePath}"
                                       target="_blank" class="attachment-link">
                                        点击查看附件
                                    </a>
                                </c:if>
                            </td>
                        </tr>
                    </table>
                </div>

                <a class="btn btn-secondary"
                   href="${pageContext.request.contextPath}/student/apply/list">
                    返回列表
                </a>
            </c:if>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>