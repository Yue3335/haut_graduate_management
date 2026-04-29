<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    request.setAttribute("pageTitle", "联系老师 - 毕业管理系统");
%>

<jsp:include page="/WEB-INF/jsp/common/header.jsp"/>
<jsp:include page="/WEB-INF/jsp/common/navbar.jsp"/>

<style>
    /* 页面标题样式 - 统一科研风格 */
    .page-title {
        color: #2d3748;
        font-weight: 600;
        font-size: 22px;
        margin-bottom: 16px !important;
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

    /* 提示文本样式 */
    .page-desc {
        font-size: 14px;
        color: #718096;
        line-height: 1.6;
        margin-bottom: 24px !important;
        padding: 10px 16px;
        background-color: #f8fafc;
        border-radius: 8px;
        border-left: 3px solid #3182ce;
    }

    /* 警告提示框优化 */
    .warning-alert {
        background-color: #fef7fb;
        border: 1px solid #ed8936;
        color: #744210;
        border-radius: 8px;
        padding: 12px 16px;
        font-size: 14px;
        margin-bottom: 24px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.02);
    }

    /* 老师卡片核心样式 - 科研风升级 */
    .teacher-card {
        border-radius: 12px;
        border: 1px solid #e8eef4;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
        transition: all 0.3s ease;
        margin-bottom: 20px;
        overflow: hidden;
        background-color: #ffffff;
    }

    .teacher-card:hover {
        box-shadow: 0 6px 16px rgba(0, 0, 0, 0.06);
        transform: translateY(-2px);
        border-color: #d1e0f0;
    }

    /* 卡片头部样式 */
    .teacher-card-header {
        padding: 14px 20px;
        border-bottom: 1px solid #f0f2f5;
        display: flex;
        align-items: center;
        justify-content: space-between;
        background-color: #f8fafc;
    }

    .teacher-card-header strong {
        color: #2d3748;
        font-size: 15px;
        font-weight: 500;
    }

    /* 角色徽章样式优化 */
    .teacher-role-badge {
        font-size: 12px;
        padding: 4px 10px;
        border-radius: 999px;
        color: #ffffff;
        font-weight: 500;
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
    }

    .teacher-role-badge.class {
        background: linear-gradient(135deg, #2c5282, #3182ce);
    }

    .teacher-role-badge.supervisor {
        background: linear-gradient(135deg, #2f855a, #38b2ac);
    }

    .teacher-role-badge.counselor {
        background: linear-gradient(135deg, #c05621, #ed8936);
    }

    /* 卡片主体样式 */
    .teacher-card-body {
        padding: 20px;
        display: flex;
        align-items: center;
    }

    /* 空数据提示 */
    .empty-teacher-tip {
        color: #94a3b8;
        font-size: 14px;
        padding: 10px 0;
        font-style: italic;
    }

    /* 头像样式升级 */
    .teacher-avatar {
        width: 56px;
        height: 56px;
        border-radius: 50%;
        background: linear-gradient(135deg, #2c5282, #3182ce);
        color: #ffffff;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 600;
        font-size: 20px;
        margin-right: 20px;
        flex-shrink: 0;
        box-shadow: 0 2px 8px rgba(49, 130, 206, 0.2);
        transition: all 0.3s ease;
    }

    .teacher-avatar.supervisor {
        background: linear-gradient(135deg, #2f855a, #38b2ac);
        box-shadow: 0 2px 8px rgba(56, 178, 172, 0.2);
    }

    .teacher-avatar.counselor {
        background: linear-gradient(135deg, #c05621, #ed8936);
        box-shadow: 0 2px 8px rgba(237, 137, 54, 0.2);
    }

    .teacher-avatar:hover {
        transform: scale(1.05);
    }

    /* 老师信息区域 */
    .teacher-info-main {
        flex: 1;
    }

    .teacher-name {
        font-size: 17px;
        font-weight: 600;
        color: #2d3748;
        margin-bottom: 4px;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    .teacher-name::after {
        content: "👨‍🏫";
        font-size: 16px;
    }

    .teacher-sub {
        font-size: 13px;
        color: #718096;
        margin-bottom: 8px;
        padding-bottom: 8px;
        border-bottom: 1px solid #f0f2f5;
    }

    /* 联系方式样式 */
    .teacher-contact {
        font-size: 14px;
        color: #4a5568;
        line-height: 1.8;
        margin-bottom: 12px;
    }

    .teacher-contact span {
        display: flex;
        align-items: center;
        gap: 6px;
        margin-bottom: 4px;
    }

    .teacher-contact span::before {
        font-size: 14px;
    }

    .teacher-contact span:first-child::before {
        content: "📞";
    }

    .teacher-contact span:last-child::before {
        content: "📧";
    }

    /* 操作按钮样式 */
    .teacher-actions .btn {
        border-radius: 6px;
        padding: 8px 20px;
        font-size: 14px;
        font-weight: 500;
        transition: all 0.2s ease;
    }

    .btn-outline-primary {
        border-color: #3182ce;
        color: #3182ce;
    }

    .btn-outline-primary:hover {
        background-color: #f0f7ff;
        border-color: #2c5282;
        color: #2c5282;
        box-shadow: 0 2px 8px rgba(49, 130, 206, 0.2);
    }

    .btn-outline-success {
        border-color: #38b2ac;
        color: #38b2ac;
    }

    .btn-outline-success:hover {
        background-color: #e6fffa;
        border-color: #2f855a;
        color: #2f855a;
        box-shadow: 0 2px 8px rgba(56, 178, 172, 0.2);
    }

    .btn-outline-warning {
        border-color: #ed8936;
        color: #ed8936;
    }

    .btn-outline-warning:hover {
        background-color: #fffaf0;
        border-color: #c05621;
        color: #c05621;
        box-shadow: 0 2px 8px rgba(237, 137, 54, 0.2);
    }

    /* 响应式适配 */
    @media (max-width: 768px) {
        .teacher-card-body {
            padding: 16px;
            flex-direction: column;
            align-items: flex-start;
        }
        .teacher-avatar {
            margin-right: 0;
            margin-bottom: 16px;
        }
        .teacher-contact span {
            display: block;
        }
    }

    @media (max-width: 576px) {
        .page-title {
            font-size: 20px;
        }
        .teacher-card-header {
            padding: 12px 16px;
        }
        .teacher-actions .btn {
            width: 100%;
            text-align: center;
        }
    }
</style>

<div class="container">
    <div class="row">
        <!-- 左侧学生导航 -->
        <jsp:include page="/WEB-INF/jsp/student/sidebar.jsp"/>

        <!-- 右侧主体 -->
        <div class="col-md-9">
            <h3 class="page-title">联系老师</h3>

            <c:if test="${empty student}">
                <div class="warning-alert">
                    未找到学生档案信息，请联系管理员。
                </div>
            </c:if>

            <c:if test="${not empty student}">
                <p class="page-desc">
                    您可以通过下方的“发起聊天”与班主任、指导老师、辅导员进行在线沟通，咨询毕业相关问题。
                </p>

                <!-- 班主任 -->
                <div class="teacher-card">
                    <div class="teacher-card-header">
                        <div><strong>班主任</strong></div>
                        <span class="teacher-role-badge class">班主任</span>
                    </div>
                    <div class="teacher-card-body">
                        <c:if test="${empty classTeacher}">
                            <div class="empty-teacher-tip">暂未为您设置班主任。</div>
                        </c:if>
                        <c:if test="${not empty classTeacher}">
                            <div class="teacher-avatar">
                                <c:out value="${fn:substring(classTeacher.realName, 0, 1)}"/>
                            </div>
                            <div class="teacher-info-main">
                                <div class="teacher-name">${classTeacher.realName}</div>
                                <div class="teacher-sub">
                                    工号：${classTeacher.username}
                                </div>
                                <div class="teacher-contact">
                                    <span>${classTeacher.phone}</span>
                                    <span>${classTeacher.email}</span>
                                </div>
                                <div class="teacher-actions">
                                    <a class="btn btn-outline-primary"
                                       href="${pageContext.request.contextPath}/student/chat?toUserId=${classTeacher.userId}">
                                        发起聊天
                                    </a>
                                </div>
                            </div>
                        </c:if>
                    </div>
                </div>

                <!-- 指导老师 -->
                <div class="teacher-card">
                    <div class="teacher-card-header">
                        <div><strong>指导老师</strong></div>
                        <span class="teacher-role-badge supervisor">指导老师</span>
                    </div>
                    <div class="teacher-card-body">
                        <c:if test="${empty supervisor}">
                            <div class="empty-teacher-tip">暂未为您指定指导老师。</div>
                        </c:if>
                        <c:if test="${not empty supervisor}">
                            <div class="teacher-avatar supervisor">
                                <c:out value="${fn:substring(supervisor.realName, 0, 1)}"/>
                            </div>
                            <div class="teacher-info-main">
                                <div class="teacher-name">${supervisor.realName}</div>
                                <div class="teacher-sub">
                                    工号：${supervisor.username}
                                </div>
                                <div class="teacher-contact">
                                    <span>${supervisor.phone}</span>
                                    <span>${supervisor.email}</span>
                                </div>
                                <div class="teacher-actions">
                                    <a class="btn btn-outline-success"
                                       href="${pageContext.request.contextPath}/student/chat?toUserId=${supervisor.userId}">
                                        发起聊天
                                    </a>
                                </div>
                            </div>
                        </c:if>
                    </div>
                </div>

                <!-- 辅导员 -->
                <div class="teacher-card">
                    <div class="teacher-card-header">
                        <div><strong>辅导员</strong></div>
                        <span class="teacher-role-badge counselor">辅导员</span>
                    </div>
                    <div class="teacher-card-body">
                        <c:if test="${empty counselor}">
                            <div class="empty-teacher-tip">暂未为您指定辅导员。</div>
                        </c:if>
                        <c:if test="${not empty counselor}">
                            <div class="teacher-avatar counselor">
                                <c:out value="${fn:substring(counselor.realName, 0, 1)}"/>
                            </div>
                            <div class="teacher-info-main">
                                <div class="teacher-name">${counselor.realName}</div>
                                <div class="teacher-sub">
                                    工号：${counselor.username}
                                </div>
                                <div class="teacher-contact">
                                    <span>${counselor.phone}</span>
                                    <span>${counselor.email}</span>
                                </div>
                                <div class="teacher-actions">
                                    <a class="btn btn-outline-warning"
                                       href="${pageContext.request.contextPath}/student/chat?toUserId=${counselor.userId}">
                                        发起聊天
                                    </a>
                                </div>
                            </div>
                        </c:if>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>