<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    request.setAttribute("pageTitle", "就业去向审核进度 - 学生端");
%>

<jsp:include page="/WEB-INF/jsp/common/header.jsp"/>
<jsp:include page="/WEB-INF/jsp/common/navbar.jsp"/>

<style>
    body {
        background: #f5f7fb;
    }

    .page-title {
        color: #1f2937;
        font-weight: 700;
        font-size: 24px;
        margin-bottom: 10px !important;
    }

    .page-subtitle {
        color: #64748b;
        font-size: 14px;
        margin-bottom: 22px;
        line-height: 1.7;
    }

    .main-card {
        background: #ffffff;
        border: 1px solid #e5e7eb;
        border-radius: 16px;
        box-shadow: 0 8px 24px rgba(15, 23, 42, 0.06);
        margin-bottom: 24px;
        overflow: hidden;
    }

    .main-card-header {
        padding: 18px 22px;
        border-bottom: 1px solid #edf2f7;
        background: linear-gradient(135deg, #f8fafc, #ffffff);
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 12px;
    }

    .main-card-title {
        font-size: 17px;
        font-weight: 700;
        color: #111827;
        margin: 0;
    }

    .main-card-desc {
        font-size: 13px;
        color: #64748b;
        margin-top: 4px;
    }

    .record-count {
        font-size: 12px;
        color: #475569;
        background: #f1f5f9;
        border-radius: 999px;
        padding: 5px 12px;
        white-space: nowrap;
    }

    .empty-box {
        margin: 20px;
        border: 1px dashed #cbd5e1;
        border-radius: 14px;
        padding: 28px 20px;
        text-align: center;
        color: #64748b;
        background: #f8fafc;
    }

    .empty-box-title {
        font-size: 16px;
        font-weight: 700;
        color: #334155;
        margin-bottom: 6px;
    }

    .employment-card {
        margin: 18px 20px;
        border: 1px solid #e5e7eb;
        border-radius: 16px;
        background: #ffffff;
        box-shadow: 0 4px 16px rgba(15, 23, 42, 0.04);
        overflow: hidden;
    }

    .employment-card-top {
        padding: 16px 18px;
        background: #fbfdff;
        border-bottom: 1px solid #edf2f7;
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        gap: 16px;
    }

    .employment-main-info {
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        gap: 10px;
    }

    .employment-id {
        color: #64748b;
        font-size: 13px;
    }

    .employment-status-name {
        font-size: 18px;
        font-weight: 700;
        color: #111827;
    }

    .employment-meta {
        margin-top: 8px;
        color: #64748b;
        font-size: 13px;
        line-height: 1.6;
    }

    .total-status {
        font-size: 13px;
        border-radius: 999px;
        padding: 6px 12px;
        font-weight: 600;
        white-space: nowrap;
    }

    .total-pending {
        background: #eff6ff;
        color: #2563eb;
    }

    .total-approved {
        background: #dcfce7;
        color: #16a34a;
    }

    .total-rejected {
        background: #fee2e2;
        color: #dc2626;
    }

    .workflow-area {
        padding: 26px 24px 24px;
    }

    .workflow-line {
        display: grid;
        grid-template-columns: 1fr 54px 1fr 54px 1fr;
        align-items: stretch;
        gap: 0;
    }

    .step-card {
        border-radius: 16px;
        min-height: 150px;
        padding: 18px 14px;
        text-align: center;
        border: 2px solid #e5e7eb;
        background: #f8fafc;
        position: relative;
        transition: all 0.2s ease;
    }

    .step-card.done {
        border-color: #22c55e;
        background: linear-gradient(180deg, #ecfdf5, #ffffff);
        box-shadow: 0 8px 20px rgba(34, 197, 94, 0.12);
    }

    .step-card.current {
        border-color: #3b82f6;
        background: linear-gradient(180deg, #eff6ff, #ffffff);
        box-shadow: 0 8px 20px rgba(59, 130, 246, 0.12);
    }

    .step-card.waiting {
        border-color: #e5e7eb;
        background: #f8fafc;
    }

    .step-card.rejected {
        border-color: #ef4444;
        background: linear-gradient(180deg, #fef2f2, #ffffff);
        box-shadow: 0 8px 20px rgba(239, 68, 68, 0.12);
    }

    .step-icon {
        width: 46px;
        height: 46px;
        border-radius: 50%;
        margin: 0 auto 12px;
        display: flex;
        justify-content: center;
        align-items: center;
        font-size: 20px;
        font-weight: 800;
    }

    .done .step-icon {
        background: #22c55e;
        color: #ffffff;
    }

    .current .step-icon {
        background: #3b82f6;
        color: #ffffff;
    }

    .waiting .step-icon {
        background: #e5e7eb;
        color: #94a3b8;
    }

    .rejected .step-icon {
        background: #ef4444;
        color: #ffffff;
    }

    .step-name {
        font-size: 16px;
        font-weight: 700;
        color: #111827;
        margin-bottom: 6px;
    }

    .step-desc {
        font-size: 12px;
        color: #64748b;
        margin-bottom: 10px;
    }

    .step-badge {
        display: inline-block;
        border-radius: 999px;
        padding: 4px 10px;
        font-size: 12px;
        font-weight: 600;
    }

    .badge-done {
        background: #dcfce7;
        color: #16a34a;
    }

    .badge-current {
        background: #dbeafe;
        color: #2563eb;
    }

    .badge-waiting {
        background: #e5e7eb;
        color: #64748b;
    }

    .badge-rejected {
        background: #fee2e2;
        color: #dc2626;
    }

    .flow-arrow {
        display: flex;
        justify-content: center;
        align-items: center;
        color: #cbd5e1;
        font-size: 30px;
        font-weight: 800;
    }

    .flow-arrow.done {
        color: #22c55e;
    }

    .remark-box {
        margin-top: 12px;
        padding: 8px 10px;
        border-radius: 10px;
        background: #f8fafc;
        border: 1px solid #e5e7eb;
        color: #475569;
        font-size: 12px;
        text-align: left;
        line-height: 1.6;
    }

    .workflow-summary {
        margin-top: 18px;
        border-radius: 12px;
        padding: 12px 14px;
        font-size: 14px;
        line-height: 1.7;
    }

    .summary-pending {
        background: #eff6ff;
        color: #1d4ed8;
        border: 1px solid #bfdbfe;
    }

    .summary-approved {
        background: #ecfdf5;
        color: #15803d;
        border: 1px solid #bbf7d0;
    }

    .summary-rejected {
        background: #fef2f2;
        color: #b91c1c;
        border: 1px solid #fecaca;
    }

    .attachment-table {
        width: 100%;
        margin-bottom: 0;
    }

    .attachment-table th {
        background: #f8fafc;
        color: #475569;
        font-size: 13px;
        padding: 12px;
        border-bottom: 1px solid #e5e7eb;
        white-space: nowrap;
    }

    .attachment-table td {
        color: #334155;
        font-size: 13px;
        padding: 12px;
        border-bottom: 1px solid #f1f5f9;
        vertical-align: middle;
    }

    .attachment-table tr:hover td {
        background: #f8fafc;
    }

    .small-pill {
        display: inline-block;
        border-radius: 999px;
        padding: 3px 9px;
        font-size: 12px;
        font-weight: 600;
    }

    .btn-soft {
        border-radius: 8px;
        padding: 6px 12px;
        font-size: 13px;
        border: 1px solid #bfdbfe;
        color: #2563eb;
        background: #eff6ff;
        text-decoration: none;
    }

    .btn-soft:hover {
        background: #dbeafe;
        color: #1d4ed8;
        text-decoration: none;
    }

    .bottom-actions {
        margin-top: 18px;
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
    }

    @media (max-width: 992px) {
        .workflow-line {
            display: block;
        }

        .step-card {
            margin-bottom: 12px;
        }

        .flow-arrow {
            height: 30px;
            transform: rotate(90deg);
            margin-bottom: 12px;
        }

        .employment-card-top {
            flex-direction: column;
        }
    }
</style>

<div class="container">
    <div class="row">
        <jsp:include page="/WEB-INF/jsp/student/sidebar.jsp"/>

        <div class="col-md-9">
            <h3 class="page-title">就业去向审核进度</h3>

            <div class="page-subtitle">
                这里展示你的就业登记审核流转情况。审核顺序为：
                <strong>指导老师 → 班主任 → 导员</strong>。
                已完成的节点会显示为绿色，未到达的节点为灰色，当前审核节点会高亮显示。
            </div>

            <div class="main-card">
                <div class="main-card-header">
                    <div>
                        <h4 class="main-card-title">就业登记审核流程</h4>
                        <div class="main-card-desc">
                            每条就业登记都会按照固定顺序逐级审核，后一级只有在前一级通过后才能看到。
                        </div>
                    </div>

                    <div class="record-count">
                        <c:choose>
                            <c:when test="${not empty employmentList}">
                                共 ${fn:length(employmentList)} 条记录
                            </c:when>
                            <c:otherwise>
                                暂无记录
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <c:if test="${empty employmentList}">
                    <div class="empty-box">
                        <div class="empty-box-title">你还没有提交就业去向登记</div>
                        <div>提交后，系统会自动生成指导老师、班主任、导员三步审核流程。</div>
                    </div>
                </c:if>

                <c:if test="${not empty employmentList}">
                    <c:forEach var="e" items="${employmentList}">
                        <div class="employment-card">
                            <div class="employment-card-top">
                                <div>
                                    <div class="employment-main-info">
                                        <span class="employment-status-name">
                                            <c:out value="${e.status}" default="就业登记"/>
                                        </span>
                                        <span class="employment-id">登记编号：${e.employmentId}</span>
                                    </div>

                                    <div class="employment-meta">
                                        <c:if test="${not empty e.companyName}">
                                            单位：<c:out value="${e.companyName}"/>
                                            &nbsp;&nbsp;
                                        </c:if>

                                        <c:if test="${not empty e.position}">
                                            岗位：<c:out value="${e.position}"/>
                                            &nbsp;&nbsp;
                                        </c:if>

                                        <c:if test="${not empty e.city}">
                                            城市：<c:out value="${e.city}"/>
                                            &nbsp;&nbsp;
                                        </c:if>

                                        登记时间：${e.reportTime}
                                    </div>
                                </div>

                                <div>
                                    <c:choose>
                                        <c:when test="${e.reviewStatus == 'APPROVED'}">
                                            <span class="total-status total-approved">全部审核通过</span>
                                        </c:when>
                                        <c:when test="${e.reviewStatus == 'REJECTED'}">
                                            <span class="total-status total-rejected">审核被驳回</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="total-status total-pending">正在审核中</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="workflow-area">
                                <div class="workflow-line">

                                    <!-- 指导老师 -->
                                    <c:choose>
                                        <c:when test="${e.reviewStage == 'SUPERVISOR' || e.reviewStage == 'CLASS_TEACHER' || e.reviewStage == 'COUNSELOR' || e.reviewStatus == 'APPROVED'}">
                                            <div class="step-card done">
                                                <div class="step-icon">✓</div>
                                                <div class="step-name">指导老师</div>
                                                <div class="step-desc">第一步审核</div>
                                                <span class="step-badge badge-done">已完成</span>
                                            </div>
                                        </c:when>

                                        <c:when test="${e.reviewStatus == 'REJECTED'}">
                                            <div class="step-card rejected">
                                                <div class="step-icon">×</div>
                                                <div class="step-name">指导老师</div>
                                                <div class="step-desc">第一步审核</div>
                                                <span class="step-badge badge-rejected">已驳回</span>
                                            </div>
                                        </c:when>

                                        <c:otherwise>
                                            <div class="step-card current">
                                                <div class="step-icon">1</div>
                                                <div class="step-name">指导老师</div>
                                                <div class="step-desc">第一步审核</div>
                                                <span class="step-badge badge-current">当前审核中</span>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>

                                    <div class="flow-arrow">➜</div>

                                    <!-- 班主任 -->
                                    <c:choose>
                                        <c:when test="${e.reviewStage == 'COUNSELOR' || e.reviewStatus == 'APPROVED'}">
                                            <div class="step-card done">
                                                <div class="step-icon">✓</div>
                                                <div class="step-name">班主任</div>
                                                <div class="step-desc">第二步审核</div>
                                                <span class="step-badge badge-done">已完成</span>
                                            </div>
                                        </c:when>

                                        <c:when test="${e.reviewStage == 'CLASS_TEACHER'}">
                                            <div class="step-card current">
                                                <div class="step-icon">2</div>
                                                <div class="step-name">班主任</div>
                                                <div class="step-desc">第二步审核</div>
                                                <span class="step-badge badge-current">当前审核中</span>
                                            </div>
                                        </c:when>

                                        <c:when test="${e.reviewStatus == 'REJECTED'}">
                                            <div class="step-card rejected">
                                                <div class="step-icon">×</div>
                                                <div class="step-name">班主任</div>
                                                <div class="step-desc">第二步审核</div>
                                                <span class="step-badge badge-rejected">已驳回</span>
                                            </div>
                                        </c:when>

                                        <c:otherwise>
                                            <div class="step-card waiting">
                                                <div class="step-icon">2</div>
                                                <div class="step-name">班主任</div>
                                                <div class="step-desc">第二步未到达</div>
                                                <span class="step-badge badge-waiting">未到达</span>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>

                                    <div class="flow-arrow">➜</div>

                                    <!-- 导员 -->
                                    <c:choose>
                                        <c:when test="${e.reviewStatus == 'APPROVED'}">
                                            <div class="step-card done">
                                                <div class="step-icon">✓</div>
                                                <div class="step-name">导员</div>
                                                <div class="step-desc">第三步审核</div>
                                                <span class="step-badge badge-done">已完成</span>
                                            </div>
                                        </c:when>

                                        <c:when test="${e.reviewStage == 'COUNSELOR'}">
                                            <div class="step-card current">
                                                <div class="step-icon">3</div>
                                                <div class="step-name">导员</div>
                                                <div class="step-desc">第三步审核</div>
                                                <span class="step-badge badge-current">当前审核中</span>
                                            </div>
                                        </c:when>

                                        <c:when test="${e.reviewStatus == 'REJECTED'}">
                                            <div class="step-card rejected">
                                                <div class="step-icon">×</div>
                                                <div class="step-name">导员</div>
                                                <div class="step-desc">第三步审核</div>
                                                <span class="step-badge badge-rejected">已驳回</span>
                                            </div>
                                        </c:when>

                                        <c:otherwise>
                                            <div class="step-card waiting">
                                                <div class="step-icon">3</div>
                                                <div class="step-name">导员</div>
                                                <div class="step-desc">未到达</div>
                                                <span class="step-badge badge-waiting">未到达</span>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                        </div>
                    </c:forEach>
                </c:if>
            </div>

            <div class="main-card">
                <div class="main-card-header">
                    <div>
                        <h4 class="main-card-title">附件提交记录</h4>
                        <div class="main-card-desc">
                            这里展示你上传的就业相关材料，例如协议、证明、截图等。
                        </div>
                    </div>

                    <div class="record-count">
                        <c:choose>
                            <c:when test="${not empty submissionList}">
                                共 ${fn:length(submissionList)} 条记录
                            </c:when>
                            <c:otherwise>
                                暂无附件
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <c:if test="${empty submissionList}">
                    <div class="empty-box">
                        <div class="empty-box-title">你还没有上传附件材料</div>
                        <div>如果学校要求上传就业证明、录用通知或考研证明，可以在就业登记页面补充上传。</div>
                    </div>
                </c:if>

                <c:if test="${not empty submissionList}">
                    <div class="table-responsive">
                        <table class="attachment-table">
                            <thead>
                            <tr>
                                <th style="width: 8%;">ID</th>
                                <th style="width: 28%;">标题</th>
                                <th style="width: 16%;">类型</th>
                                <th style="width: 16%;">附件状态</th>
                                <th style="width: 20%;">提交时间</th>
                                <th style="width: 12%;">操作</th>
                            </tr>
                            </thead>

                            <tbody>
                            <c:forEach var="item" items="${submissionList}">
                                <tr>
                                    <td>${item.submissionId}</td>

                                    <td>
                                        <c:out value="${item.title}" default="-"/>
                                    </td>

                                    <td>
                                        <c:out value="${item.type}" default="-"/>
                                    </td>

                                    <td>
                                        <c:choose>
                                            <c:when test="${e.reviewStatus == 'APPROVED'}">
                                                <div class="workflow-summary summary-approved">
                                                    当前状态：全部审核通过
                                                </div>
                                            </c:when>

                                            <c:when test="${e.reviewStatus == 'REJECTED'}">
                                                <div class="workflow-summary summary-rejected">
                                                    当前状态：已被驳回，请修改后重新提交
                                                </div>
                                            </c:when>

                                            <c:when test="${e.reviewStage == 'SUPERVISOR'}">
                                                <div class="workflow-summary summary-pending">
                                                    当前状态：等待指导老师审核
                                                </div>
                                            </c:when>

                                            <c:when test="${e.reviewStage == 'CLASS_TEACHER'}">
                                                <div class="workflow-summary summary-pending">
                                                    当前状态：指导老师已通过，等待班主任审核
                                                </div>
                                            </c:when>

                                            <c:when test="${e.reviewStage == 'COUNSELOR'}">
                                                <div class="workflow-summary summary-pending">
                                                    当前状态：等待导员最终审核
                                                </div>
                                            </c:when>

                                            <c:otherwise>
                                                <div class="workflow-summary summary-pending">
                                                    当前状态：处理中
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <td>
                                        <c:out value="${item.createdAt}" default="-"/>
                                    </td>

                                    <td>
                                        <a class="btn-soft"
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
            </div>

            <div class="bottom-actions">
                <a class="btn btn-primary"
                   href="${pageContext.request.contextPath}/student/submission">
                    返回就业登记
                </a>

                <a class="btn btn-outline-secondary"
                   href="${pageContext.request.contextPath}/student/dashboard">
                    返回学生首页
                </a>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>