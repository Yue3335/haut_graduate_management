<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    /* 教师侧边栏样式 - 科研风格统一 */
    .teacher-sidebar-group {
        border-radius: 12px;
        overflow: hidden;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
        border: 1px solid #e8eef4;
        background-color: #ffffff;
    }

    .teacher-sidebar-item {
        border: none;
        padding: 14px 20px;
        font-size: 15px;
        transition: all 0.3s ease;
        color: #2d3748;
        border-left: 3px solid transparent;
        background-color: #ffffff;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    /* 激活状态样式 - 科研风蓝色 */
    .teacher-sidebar-item.active {
        background-color: #f0f7ff;
        border-left-color: #3182ce;
        font-weight: 500;
        color: #2c5282;
        box-shadow: inset 0 0 0 1000px rgba(49, 130, 206, 0.05);
    }

    /* 悬停状态 */
    .teacher-sidebar-item:not(.active):hover {
        background-color: #f8fafc;
        border-left-color: #3182ce;
        color: #3182ce;
        padding-left: 25px;
    }

    /* 移除默认边框，改用科研风浅分隔线 */
    .teacher-sidebar-item + .teacher-sidebar-item {
        border-top: 1px solid #f0f2f5;
    }

    /* 导航项图标 */
    .teacher-sidebar-item::before {
        font-size: 16px;
        opacity: 0.8;
    }

    .teacher-sidebar-item:nth-child(1)::before {
        content: "🏠";
    }

    .teacher-sidebar-item:nth-child(2)::before {
        content: "📊";
    }

    .teacher-sidebar-item:nth-child(3)::before {
        content: "✅";
    }

    .teacher-sidebar-item:nth-child(4)::before {
        content: "💬";
    }

    /* 响应式适配 */
    @media (max-width: 768px) {
        .teacher-sidebar-item {
            padding: 12px 16px;
            font-size: 14px;
        }
        .teacher-sidebar-item:not(.active):hover {
            padding-left: 20px;
        }
    }
</style>

<div class="col-md-3 mb-4">
    <div class="list-group teacher-sidebar-group">
        <a href="${pageContext.request.contextPath}/teacher/home"
           class="list-group-item teacher-sidebar-item
                  <c:if test='${pageContext.request.requestURI.endsWith("/teacher/home")}'>active</c:if>">
            教师首页
        </a>

        <a href="${pageContext.request.contextPath}/teacher/students/employment"
           class="list-group-item teacher-sidebar-item
                  <c:if test='${pageContext.request.requestURI.contains("/teacher/students/employment")}'>active</c:if>">
            学生就业情况
        </a>

        <a href="${pageContext.request.contextPath}/teacher/review/submissions"
           class="list-group-item teacher-sidebar-item
                  <c:if test='${pageContext.request.requestURI.contains("/teacher/review/submissions")}'>active</c:if>">
            学生材料审批
        </a>

        <a href="${pageContext.request.contextPath}/teacher/chat"
           class="list-group-item teacher-sidebar-item
                  <c:if test='${pageContext.request.requestURI.contains("/teacher/chat")}'>active</c:if>">
            和学生沟通
        </a>
    </div>
</div>