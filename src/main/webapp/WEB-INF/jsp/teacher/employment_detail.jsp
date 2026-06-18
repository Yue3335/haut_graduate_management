<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    request.setAttribute("pageTitle", "学生就业去向详情 - 教师端");
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
    .detail-card {
        border-radius: 12px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 2px 8px rgba(15, 23, 42, 0.03);
        overflow: hidden;
        margin-bottom: 18px;
        background-color: #ffffff;
    }
    .detail-card-header {
        padding: 10px 16px;
        background-color: #f8fafc;
        border-bottom: 1px solid #e2e8f0;
        font-weight: 600;
        font-size: 14px;
        color: #1e293b;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .detail-card-body {
        padding: 16px 18px;
        font-size: 14px;
        color: #374151;
    }
    .info-row {
        margin-bottom: 8px;
    }
    .info-label {
        display: inline-block;
        min-width: 90px;
        color: #6b7280;
    }
    .info-value {
        color: #111827;
    }
    .muted-text {
        color: #9ca3af;
        font-size: 13px;
    }
    .status-pill {
        display: inline-block;
        padding: 2px 8px;
        border-radius: 999px;
        font-size: 12px;
        font-weight: 500;
        white-space: nowrap;
    }
    .status-waiting {
        background: #e5e7eb;
        color: #374151;
    }
    .status-pending {
        background: #fef3c7;
        color: #92400e;
    }
    .status-approved {
        background: #dcfce7;
        color: #15803d;
    }
    .status-rejected {
        background: #fee2e2;
        color: #b91c1c;
    }
    .status-current {
        background: #dbeafe;
        color: #1d4ed8;
    }
    .process-grid {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 12px;
        margin-top: 10px;
    }
    .process-step {
        border: 1px solid #e2e8f0;
        border-radius: 10px;
        padding: 12px;
        background: #f8fafc;
    }
    .process-step-title {
        font-weight: 600;
        color: #1f2937;
        margin-bottom: 8px;
    }
    .remark-text {
        color: #64748b;
        font-size: 12px;
        margin-top: 6px;
    }

    @media (max-width: 768px) {
        .process-grid {
            grid-template-columns: 1fr;
        }
    }
         /* ===== 流程增强版（在你原CSS后追加）===== */
     .process-grid {
         display: flex;
         gap: 12px;
         margin-top: 10px;
     }

    .process-step {
        flex: 1;
        border: 1px solid #e5e7eb;
        border-radius: 10px;
        padding: 12px;
        background: #f9fafb;
        transition: all 0.2s ease;
    }

    .process-step:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.06);
    }

    .process-step-title {
        font-weight: 600;
        margin-bottom: 6px;
    }

    .step-active {
        border: 2px solid #2563eb;
        background: #eff6ff;
    }

    .step-done {
        border: 2px solid #16a34a;
        background: #ecfdf5;
    }
</style>

</style>

<div class="container">
    <div class="row">
        <jsp:include page="/WEB-INF/jsp/teacher/sidebar.jsp"/>

        <div class="col-md-9">
            <h3 class="page-title">学生就业去向详情</h3>

            <c:if test="${empty student}">
                <div class="alert alert-danger mt-2">
                    未找到该学生信息。
                </div>
            </c:if>

            <c:if test="${not empty student}">
                <div class="detail-card">
                    <div class="detail-card-header">
                        学生基本信息
                    </div>

                    <div class="detail-card-body">
                        <div class="info-row">
                            <span class="info-label">学号：</span>
                            <span class="info-value">${student.studentNo}</span>
                        </div>

                        <div class="info-row">
                            <span class="info-label">姓名：</span>
                            <span class="info-value">
                                <c:choose>
                                    <c:when test="${not empty studentUser}">
                                        ${studentUser.realName}
                                    </c:when>
                                    <c:otherwise>
                                        未提供
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>

                        <div class="info-row">
                            <span class="info-label">当前身份：</span>
                            <span class="status-pill status-current">${reviewerRoleLabel}</span>
                        </div>
                    </div>
                </div>

                <div class="detail-card">
                    <div class="detail-card-header">
                        <span>最新一次就业去向登记</span>
                        <span class="muted-text">只显示已经流转到你的待审核记录</span>
                    </div>

                    <div class="detail-card-body">
                        <c:if test="${empty latestEmployment}">
                            <p class="muted-text mb-0">
                                该学生尚未登记就业去向，或者该就业登记尚未流转到你当前身份。
                            </p>
                        </c:if>

                        <c:if test="${not empty latestEmployment}">
                            <div class="info-row">
                                <span class="info-label">就业状态：</span>
                                <span class="info-value">${latestEmployment.status}</span>
                            </div>

                            <div class="info-row">
                                <span class="info-label">单位：</span>
                                <span class="info-value">
                                    <c:out value="${latestEmployment.companyName}" default="-"/>
                                </span>
                            </div>

                            <div class="info-row">
                                <span class="info-label">岗位：</span>
                                <span class="info-value">
                                    <c:out value="${latestEmployment.position}" default="-"/>
                                </span>
                            </div>

                            <div class="info-row">
                                <span class="info-label">城市：</span>
                                <span class="info-value">
                                    <c:out value="${latestEmployment.city}" default="-"/>
                                </span>
                            </div>

                            <div class="info-row">
                                <span class="info-label">月薪：</span>
                                <span class="info-value">
                                    <c:out value="${latestEmployment.salaryMonth}" default="-"/>
                                </span>
                            </div>

                            <div class="info-row">
                                <span class="info-label">备注：</span>
                                <span class="info-value">
                                    <c:out value="${latestEmployment.remark}" default="-"/>
                                </span>
                            </div>

                            <div class="info-row">
                                <span class="info-label">登记时间：</span>
                                <span class="muted-text">${latestEmployment.reportTime}</span>
                            </div>

                            <hr/>

                            <h5 style="font-size: 15px; margin: 8px 0 10px;">
                                审核流程进度
                            </h5>

                            <div class="process-grid">

                                <!-- 指导老师 -->
                                <div class="process-step ${latestEmployment.reviewStage == 'SUPERVISOR' ? 'step-active' : (latestEmployment.reviewStage != 'SUPERVISOR' ? 'step-done' : '')}">
                                    <div class="process-step-title">1. 指导老师</div>

                                    <span class="status-pill
            ${latestEmployment.supervisorStatus == 'APPROVED' ? 'status-approved' :
              latestEmployment.supervisorStatus == 'REJECTED' ? 'status-rejected' :
              latestEmployment.reviewStage == 'SUPERVISOR' ? 'status-pending' : 'status-waiting'}">

                                            ${latestEmployment.supervisorStatus}
                                    </span>
                                </div>

                                <!-- 班主任 -->
                                <div class="process-step ${latestEmployment.reviewStage == 'CLASS_TEACHER' ? 'step-active' :
                               (latestEmployment.reviewStage == 'COUNSELOR' || latestEmployment.reviewStage == 'DONE' ? 'step-done' : '')}">
                                    <div class="process-step-title">2. 班主任</div>

                                    <span class="status-pill
            ${latestEmployment.classTeacherStatus == 'APPROVED' ? 'status-approved' :
              latestEmployment.classTeacherStatus == 'REJECTED' ? 'status-rejected' :
              latestEmployment.reviewStage == 'CLASS_TEACHER' ? 'status-pending' :
              (latestEmployment.reviewStage == 'COUNSELOR' || latestEmployment.reviewStage == 'DONE' ? 'status-approved' : 'status-waiting')}">

                                            ${latestEmployment.classTeacherStatus}
                                    </span>
                                </div>

                                <!-- 辅导员 -->
                                <div class="process-step ${latestEmployment.reviewStage == 'COUNSELOR' ? 'step-active' :
                               (latestEmployment.reviewStage == 'DONE' ? 'step-done' : '')}">
                                    <div class="process-step-title">3. 辅导员</div>

                                    <span class="status-pill
            ${latestEmployment.counselorStatus == 'APPROVED' ? 'status-approved' :
              latestEmployment.counselorStatus == 'REJECTED' ? 'status-rejected' :
              latestEmployment.reviewStage == 'COUNSELOR' ? 'status-pending' :
              latestEmployment.reviewStage == 'DONE' ? 'status-approved' : 'status-waiting'}">

                                            ${latestEmployment.counselorStatus}
                                    </span>
                                </div>

                            </div>

                            <hr/>

                            <h5 style="font-size: 15px; margin-top: 12px; margin-bottom: 10px;">
                                    ${reviewerRoleLabel}审核该次就业登记
                            </h5>

                            <form action="${pageContext.request.contextPath}/teacher/employment/review"
                                  method="post"
                                  class="mt-2">
                                <input type="hidden"
                                       name="employmentId"
                                       value="${latestEmployment.employmentId}"/>

                                <input type="hidden"
                                       name="studentId"
                                       value="${student.studentId}"/>

                                <div class="info-row">
                                    <span class="info-label">审核结果：</span>
                                    <select name="reviewStatus"
                                            class="form-control"
                                            style="display:inline-block; width:auto;">
                                        <option value="APPROVED">通过并流转到下一级</option>
                                        <option value="REJECTED">驳回给学生修改</option>
                                    </select>
                                </div>

                                <div class="info-row">
                                    <span class="info-label">审核意见：</span>
                                    <textarea name="reviewRemark"
                                              rows="3"
                                              cols="45"
                                              class="form-control"
                                              style="display:inline-block; width:auto;"
                                              placeholder="可填写通过意见或驳回原因"></textarea>
                                </div>

                                <button type="submit" class="btn btn-primary btn-sm mt-1">
                                    提交审核
                                </button>
                            </form>
                        </c:if>
                    </div>
                </div>

                <div class="detail-card">
                    <div class="detail-card-header">
                        就业去向相关附件
                    </div>

                    <div class="detail-card-body">
                        <c:if test="${empty latestSubmission || empty latestSubmission.contentPath}">
                            <p class="muted-text mb-0">
                                该学生尚未上传附件。
                            </p>
                        </c:if>

                        <c:if test="${not empty latestSubmission && not empty latestSubmission.contentPath}">
                            <div class="info-row">
                                <span class="info-label">提交标题：</span>
                                <span class="info-value">${latestSubmission.title}</span>
                            </div>

                            <div class="info-row">
                                <span class="info-label">提交时间：</span>
                                <span class="muted-text">${latestSubmission.createdAt}</span>
                            </div>

                            <div class="info-row">
                                <span class="info-label">附件：</span>
                                <span class="info-value">
                                    <a href="${pageContext.request.contextPath}/download?path=${latestSubmission.contentPath}"
                                       target="_blank">
                                        点击查看 / 下载附件
                                    </a>
                                </span>
                            </div>
                        </c:if>
                    </div>
                </div>

                <a class="btn btn-secondary btn-sm mt-2"
                   href="${pageContext.request.contextPath}/teacher/students/employment">
                    返回待审核列表
                </a>
            </c:if>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>