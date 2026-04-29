<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
  /* 管理员侧边栏样式 - 复用教师侧边栏风格 */
  .admin-sidebar-group {
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
    border: 1px solid #e8eef4;
    background-color: #ffffff;
  }

  .admin-sidebar-item {
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

  .admin-sidebar-item.active {
    background-color: #f0f7ff;
    border-left-color: #3182ce;
    font-weight: 500;
    color: #2c5282;
    box-shadow: inset 0 0 0 1000px rgba(49, 130, 206, 0.05);
  }

  .admin-sidebar-item:not(.active):hover {
    background-color: #f8fafc;
    border-left-color: #3182ce;
    color: #3182ce;
    padding-left: 25px;
  }

  .admin-sidebar-item + .admin-sidebar-item {
    border-top: 1px solid #f0f2f5;
  }

  /* 简单 emoji 图标，如果不想要可以删掉 ::before 部分 */
  .admin-sidebar-item::before {
    font-size: 16px;
    opacity: 0.8;
  }

  .admin-sidebar-item:nth-child(1)::before {
    content: "🏠"; /* 管理员首页 */
  }
  .admin-sidebar-item:nth-child(2)::before {
    content: "🎓"; /* 学生管理 */
  }
  .admin-sidebar-item:nth-child(3)::before {
    content: "👨‍🏫"; /* 指导老师管理 */
  }
  .admin-sidebar-item:nth-child(4)::before {
    content: "🔐"; /* 账号与密码管理 */
  }

  @media (max-width: 768px) {
    .admin-sidebar-item {
      padding: 12px 16px;
      font-size: 14px;
    }
    .admin-sidebar-item:not(.active):hover {
      padding-left: 20px;
    }
  }
</style>

<c:if test="${sessionScope.currentUser != null
             && sessionScope.currentUser.roles != null
             && sessionScope.currentUser.roles.contains('ADMIN')}">
  <div class="list-group admin-sidebar-group">
    <!-- 管理员首页 -->
    <a href="${pageContext.request.contextPath}/admin/home"
       class="list-group-item admin-sidebar-item
              <c:if test='${pageContext.request.requestURI.endsWith("/admin/home")}'>active</c:if>">
      管理员首页
    </a>

    <!-- 学生管理 -->
    <a href="${pageContext.request.contextPath}/admin/student/list"
       class="list-group-item admin-sidebar-item
              <c:if test='${pageContext.request.requestURI.contains("/admin/student/")}'>active</c:if>">
      学生管理
    </a>

    <!-- 指导老师管理 -->
    <a href="${pageContext.request.contextPath}/admin/teacher/list"
       class="list-group-item admin-sidebar-item
              <c:if test='${pageContext.request.requestURI.contains("/admin/teacher/")}'>active</c:if>">
      指导老师管理
    </a>

    <!-- 账号与密码管理 -->
    <a href="${pageContext.request.contextPath}/admin/system/account"
       class="list-group-item admin-sidebar-item
              <c:if test='${pageContext.request.requestURI.contains("/admin/system/")}'>active</c:if>">
      账号与密码管理
    </a>
  </div>
</c:if>