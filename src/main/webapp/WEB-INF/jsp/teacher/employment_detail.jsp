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

                <!-- 学生基本信息 -->
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
                    </div>
                </div>

                <!-- 最新一次就业去向登记 + 审核 -->
                <div class="detail-card">
                    <div class="detail-card-header">
                        最新一次就业去向登记
                    </div>
                    <div class="detail-card-body">
                        <c:if test="${empty latestEmployment}">
                            <p class="muted-text mb-0">该学生尚未登记就业去向。</p>
                        </c:if>

                        <c:if test="${not empty latestEmployment}">
                            <!-- 基本信息展示 -->
                            <div class="info-row">
                                <span class="info-label">就业状态：</span>
                                <span class="info-value">${latestEmployment.status}</span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">单位：</span>
                                <span class="info-value">${latestEmployment.companyName}</span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">岗位：</span>
                                <span class="info-value">${latestEmployment.position}</span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">城市：</span>
                                <span class="info-value">${latestEmployment.city}</span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">月薪：</span>
                                <span class="info-value">${latestEmployment.salaryMonth}</span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">备注：</span>
                                <span class="info-value">${latestEmployment.remark}</span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">登记时间：</span>
                                <span class="muted-text">${latestEmployment.reportTime}</span>
                            </div>

                            <!-- 当前审核状态，和数据库中的 reviewStatus 一致 -->
                            <c:if test="${not empty latestEmployment.reviewStatus}">
                                <div class="info-row">
                                    <span class="info-label">当前审核状态：</span>
                                    <span class="info-value">
                                        <c:choose>
                                            <c:when test="${latestEmployment.reviewStatus == 'PENDING'}">
                                                待审核（学生最新提交，需重新审核）
                                            </c:when>
                                            <c:when test="${latestEmployment.reviewStatus == 'APPROVED'}">
                                                已通过
                                            </c:when>
                                            <c:when test="${latestEmployment.reviewStatus == 'REJECTED'}">
                                                已退回修改
                                            </c:when>
                                            <c:otherwise>
                                                ${latestEmployment.reviewStatus}
                                            </c:otherwise>
                                        </c:choose>
                                        <c:if test="${not empty latestEmployment.reviewRemark}">
                                            （备注：${latestEmployment.reviewRemark}）
                                        </c:if>
                                    </span>
                                </div>
                            </c:if>

                            <!-- 审核表单 -->
                            <hr/>
                            <h5 style="margin-top: 12px; margin-bottom: 10px;">审核该次就业登记</h5>
                            <form action="${pageContext.request.contextPath}/teacher/employment/review"
                                  method="post" class="mt-2">

                                <!-- 必须带上这条最新记录的 ID 和 studentId -->
                                <input type="hidden" name="employmentId"
                                       value="${latestEmployment.employmentId}"/>
                                <input type="hidden" name="studentId"
                                       value="${student.studentId}"/>

                                <div class="info-row">
                                    <span class="info-label">审核结果：</span>
                                    <select name="reviewStatus" class="form-control"
                                            style="display:inline-block; width:auto;">
                                        <option value="APPROVED"
                                                <c:if test="${latestEmployment.reviewStatus == 'APPROVED'}">selected</c:if>>
                                            通过
                                        </option>
                                        <option value="REJECTED"
                                                <c:if test="${latestEmployment.reviewStatus == 'REJECTED'}">selected</c:if>>
                                            退回修改
                                        </option>
                                    </select>
                                </div>

                                <div class="info-row">
                                    <span class="info-label">审核意见：</span>
                                    <textarea name="reviewRemark" rows="3" cols="40" class="form-control"
                                              style="display:inline-block; width:auto;">${latestEmployment.reviewRemark}</textarea>
                                </div>

                                <button type="submit" class="btn btn-primary btn-sm mt-1">
                                    提交审核
                                </button>
                            </form>
                        </c:if>
                    </div>
                </div>

                <!-- 就业去向相关附件 -->
                <div class="detail-card">
                    <div class="detail-card-header">
                        就业去向相关附件
                    </div>
                    <div class="detail-card-body">
                        <c:if test="${empty latestSubmission || empty latestSubmission.contentPath}">
                            <p class="muted-text mb-0">该学生尚未上传附件。</p>
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
                   href="javascript:history.back();">
                    返回
                </a>
            </c:if>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>