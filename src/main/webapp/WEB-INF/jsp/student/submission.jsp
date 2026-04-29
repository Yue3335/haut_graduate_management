<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    request.setAttribute("pageTitle", "就业去向登记 - 学生端");
%>

<jsp:include page="/WEB-INF/jsp/common/header.jsp"/>
<jsp:include page="/WEB-INF/jsp/common/navbar.jsp"/>

<style>
    /* 就业登记页面专属样式 - 科研风格统一 */
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

    /* 提示框样式 */
    .success-alert {
        background-color: #e6fffa;
        border: 1px solid #38b2ac;
        color: #285e61;
        border-radius: 8px;
        padding: 12px 16px;
        font-size: 14px;
        margin-bottom: 24px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.02);
    }

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

    /* 最近登记信息卡片 */
    .record-card {
        border: 1px solid #e8eef4;
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
        overflow: hidden;
        transition: all 0.3s ease;
        margin-bottom: 24px;
    }

    .record-card:hover {
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
        border-color: #d1e0f0;
    }

    .record-card-header {
        background-color: #f8fafc;
        border-bottom: 1px solid #e8eef4;
        color: #2c5282;
        padding: 14px 20px;
        font-weight: 500;
        font-size: 15px;
        display: flex;
        align-items: center;
    }

    .record-card-header::before {
        content: "";
        display: inline-block;
        width: 4px;
        height: 18px;
        background-color: #3182ce;
        border-radius: 2px;
        margin-right: 10px;
    }

    .record-card-body {
        padding: 20px;
        color: #4a5568;
        font-size: 14px;
    }

    .record-card-body p {
        margin-bottom: 12px;
        line-height: 1.6;
    }

    .record-card-body strong {
        color: #2d3748;
        min-width: 80px;
        display: inline-block;
    }

    .text-muted-custom {
        color: #718096;
        font-size: 13px;
        margin-top: 16px;
        padding-top: 12px;
        border-top: 1px solid #f0f2f5;
    }

    /* 表单样式 */
    .form-container {
        background-color: #ffffff;
        border: 1px solid #e8eef4;
        border-radius: 12px;
        padding: 24px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
        margin-bottom: 24px;
    }

    .form-label {
        font-weight: 500;
        color: #2d3748;
        font-size: 14px;
        margin-bottom: 8px;
    }

    .form-control, .form-select {
        border: 1px solid #e2e8f0;
        border-radius: 6px;
        padding: 10px 12px;
        font-size: 14px;
        transition: all 0.2s ease;
    }

    .form-control:focus, .form-select:focus {
        border-color: #3182ce;
        box-shadow: 0 0 0 2px rgba(49, 130, 206, 0.1);
        outline: none;
    }

    .form-text {
        color: #718096;
        font-size: 13px;
        margin-top: 4px;
    }

    /* 按钮样式 */
    .btn-primary {
        background-color: #3182ce;
        border-color: #3182ce;
        border-radius: 6px;
        padding: 10px 20px;
        font-size: 14px;
        font-weight: 500;
        transition: all 0.2s ease;
    }

    .btn-primary:hover {
        background-color: #2c5282;
        border-color: #2c5282;
        box-shadow: 0 2px 8px rgba(49, 130, 206, 0.2);
    }

    .btn-outline-secondary {
        border-color: #718096;
        color: #718096;
        border-radius: 6px;
        padding: 8px 16px;
        font-size: 14px;
        transition: all 0.2s ease;
    }

    .btn-outline-secondary:hover {
        background-color: #f8fafc;
        border-color: #4a5568;
        color: #4a5568;
    }

    /* 审核状态样式 */
    .status-approved {
        color: #38b2ac;
        font-weight: 500;
    }

    .status-rejected {
        color: #e53e3e;
        font-weight: 500;
    }

    .status-reviewing {
        color: #ed8936;
        font-weight: 500;
    }

    /* 响应式适配 */
    @media (max-width: 768px) {
        .record-card-body, .form-container {
            padding: 16px;
        }
        .btn-primary {
            width: 100%;
        }
    }

    @media (max-width: 576px) {
        .page-title {
            font-size: 20px;
        }
        .record-card-header {
            padding: 12px 16px;
            font-size: 14px;
        }
        .form-container {
            padding: 14px;
        }
    }
</style>

<div class="container">
    <div class="row">
        <!-- 左侧学生导航 -->
        <jsp:include page="/WEB-INF/jsp/student/sidebar.jsp"/>

        <!-- 右侧内容 -->
        <div class="col-md-9">
            <h3 class="page-title">就业去向登记</h3>

            <c:if test="${param.msg == 'ok'}">
                <div class="success-alert">
                    您的就业去向及附件已提交。
                </div>
            </c:if>

            <c:if test="${not empty error}">
                <div class="danger-alert">
                        ${error}
                </div>
            </c:if>

            <!-- 最近一次登记信息 -->
            <c:if test="${not empty latestEmployment}">
                <div class="record-card">
                    <div class="record-card-header">
                        最近一次登记
                    </div>
                    <div class="record-card-body">
                        <p><strong>状态：</strong> ${latestEmployment.status}</p>
                        <c:if test="${not empty latestEmployment.companyName}">
                            <p><strong>单位：</strong> ${latestEmployment.companyName}</p>
                        </c:if>
                        <c:if test="${not empty latestEmployment.position}">
                            <p><strong>岗位：</strong> ${latestEmployment.position}</p>
                        </c:if>
                        <c:if test="${not empty latestEmployment.city}">
                            <p><strong>城市：</strong> ${latestEmployment.city}</p>
                        </c:if>
                        <c:if test="${not empty latestEmployment.salaryMonth}">
                            <p><strong>月薪：</strong> ${latestEmployment.salaryMonth}</p>
                        </c:if>
                        <c:if test="${not empty latestEmployment.remark}">
                            <p><strong>备注：</strong> ${latestEmployment.remark}</p>
                        </c:if>

                        <!-- 审核状态展示 -->
                        <c:if test="${not empty latestEmployment.reviewStatus}">
                            <p>
                                <strong>审核状态：</strong>
                                <span class="
                                    <c:choose>
                                        <c:when test="${latestEmployment.reviewStatus == 'APPROVED'}">status-approved</c:when>
                                        <c:when test="${latestEmployment.reviewStatus == 'REJECTED'}">status-rejected</c:when>
                                        <c:otherwise>status-reviewing</c:otherwise>
                                    </c:choose>
                                ">
                                    <c:choose>
                                        <c:when test="${latestEmployment.reviewStatus == 'APPROVED'}">已通过</c:when>
                                        <c:when test="${latestEmployment.reviewStatus == 'REJECTED'}">已驳回</c:when>
                                        <c:otherwise>审核中</c:otherwise>
                                    </c:choose>
                                </span>
                                <c:if test="${not empty latestEmployment.reviewRemark}">
                                    ，审核备注：${latestEmployment.reviewRemark}
                                </c:if>
                            </p>
                        </c:if>

                        <p class="text-muted-custom">登记时间：${latestEmployment.reportTime}</p>
                    </div>
                </div>
            </c:if>

            <!-- 新登记表单（就业去向 + 可选附件上传） -->
            <div class="form-container">
                <form method="post"
                      action="${pageContext.request.contextPath}/student/submission"
                      enctype="multipart/form-data">

                    <!-- 就业基本信息 -->
                    <div class="mb-3">
                        <label class="form-label">就业状态（必选）</label>
                        <select name="status" class="form-select" required>
                            <option value="">请选择</option>
                            <option value="未就业">未就业</option>
                            <option value="已就业">已就业</option>
                            <option value="考研">考研</option>
                            <option value="出国">出国</option>
                            <option value="其他">其他</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">单位名称</label>
                        <input type="text" name="companyName" class="form-control"
                               placeholder="如：XX科技有限公司">
                    </div>

                    <div class="mb-3">
                        <label class="form-label">岗位/职位</label>
                        <input type="text" name="position" class="form-control"
                               placeholder="如：Java开发工程师">
                    </div>

                    <div class="mb-3">
                        <label class="form-label">工作城市</label>
                        <input type="text" name="city" class="form-control"
                               placeholder="如：河南省郑州市">
                    </div>

                    <div class="mb-3">
                        <label class="form-label">月薪（元）</label>
                        <input type="number" step="0.01" min="0" name="salaryMonth" class="form-control"
                               placeholder="如：8000">
                    </div>

                    <div class="mb-3">
                        <label class="form-label">备注</label>
                        <textarea name="remark" class="form-control" rows="3"
                                  placeholder="其他说明，如考研院校、出国国家等"></textarea>
                    </div>

                    <!-- 附件上传（可选） -->
                    <div class="mb-3">
                        <label class="form-label">上传附件（可选）</label>
                        <input type="file" name="file" class="form-control">
                        <div class="form-text">
                            可上传与就业相关的证明材料，如就业协议、录用通知书等。
                        </div>
                    </div>

                    <!-- 给 submission 用的标题和类型，可隐藏 -->
                    <input type="hidden" name="fileTitle" value="就业去向相关材料">
                    <input type="hidden" name="fileType" value="就业去向">

                    <button type="submit" class="btn btn-primary">提交就业去向及附件</button>
                </form>
            </div>

            <hr style="border: none; border-top: 1px solid #f0f2f5; margin: 20px 0;"/>

            <a class="btn btn-outline-secondary"
               href="${pageContext.request.contextPath}/student/submission/status">
                查看历次登记记录 / 审核状态
            </a>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>