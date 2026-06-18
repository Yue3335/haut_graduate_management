<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
  /* ===================== 全局重置 ===================== */
  * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }

  /* ===================== 右侧固定侧边栏容器 ===================== */
  .admin-sidebar-wrapper {
    /* 核心：固定在页面最右侧 */
    position: fixed;
    top: 120px;
    right: 30px;
    z-index: 99;
    width: 240px;
  }

  /* 侧边栏卡片外壳 */
  .admin-sidebar-group {
    border-radius: 16px;
    overflow: hidden;
    box-shadow: 0 4px 16px rgba(49, 130, 206, 0.12);
    border: 1px solid #e2e8f0;
    background: #fff;
    /* 悬浮轻微上浮效果 */
    transition: transform 0.3s ease;
  }
  .admin-sidebar-group:hover {
    transform: translateY(-4px);
  }

  /* ===================== 侧边菜单项 ===================== */
  .admin-sidebar-item {
    display: flex;
    align-items: center;
    gap: 10px;
    border: none;
    padding: 16px 22px;
    font-size: 15px;
    font-weight: 400;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    color: #4a5568;
    border-left: 4px solid transparent;
    background-color: #ffffff;
    text-decoration: none;
  }
  /* 菜单分隔线 */
  .admin-sidebar-item + .admin-sidebar-item {
    border-top: 1px solid #f7fafc;
  }

  /* 当前激活菜单样式（蓝渐变高级感） */
  .admin-sidebar-item.active {
    background: linear-gradient(90deg, #ebf8ff, #f0f7ff);
    border-left-color: #3182ce;
    font-weight: 600;
    color: #2b6cb0;
  }

  /* 悬浮交互：缩进+变色+轻微放大 */
  .admin-sidebar-item:not(.active):hover {
    background-color: #f7fafc;
    border-left-color: #63b3ed;
    color: #3182ce;
    padding-left: 28px;
    font-size: 15.2px;
  }

  /* ===================== Emoji图标美化 ===================== */
  .admin-sidebar-item::before {
    font-size: 18px;
    opacity: 0.85;
    width: 22px;
    text-align: center;
    transition: transform 0.2s ease;
  }
  .admin-sidebar-item:hover::before {
    transform: scale(1.15);
    opacity: 1;
  }
  /* 各个菜单图标 */
  .admin-sidebar-item:nth-child(1)::before { content: "🏠"; }
  .admin-sidebar-item:nth-child(2)::before { content: "🎓"; }
  .admin-sidebar-item:nth-child(3)::before { content: "👨‍🏫"; }
  .admin-sidebar-item:nth-child(4)::before { content: "🔐"; }

  /* ===================== 响应式：手机端适配 ===================== */
  @media (max-width: 768px) {
    .admin-sidebar-wrapper {
      top: auto;
      bottom: 20px;
      right: 16px;
      width: 180px;
    }
    .admin-sidebar-item {
      padding: 13px 16px;
      font-size: 14px;
    }
    .admin-sidebar-item:not(.active):hover {
      padding-left: 20px;
    }
    .admin-sidebar-item::before {
      font-size: 16px;
    }
  }
</style>

<%-- 仅管理员可见：外层新增靠右容器 --%>
<c:if test="${sessionScope.currentUser != null
             && sessionScope.currentUser.roles != null
             && sessionScope.currentUser.roles.contains('ADMIN')}">
  <!-- 右侧固定侧边栏容器 -->
  <div class="admin-sidebar-wrapper">
    <div class="list-group admin-sidebar-group">
      <!-- 管理员首页 -->
      <a href="${pageContext.request.contextPath}/admin/home"
         class="list-group-item admin-sidebar-item
                <c:if test='${pageContext.request.requestURI eq "/admin/home"}'>active</c:if>">
        管理员首页
      </a>

      <!-- 学生管理 -->
      <a href="${pageContext.request.contextPath}/admin/student/list"
         class="list-group-item admin-sidebar-item
                <c:if test='${pageContext.request.requestURI.startsWith("/admin/student/")}'>active</c:if>">
        学生管理
      </a>

      <!-- 指导老师管理 -->
      <a href="${pageContext.request.contextPath}/admin/teacher/list"
         class="list-group-item admin-sidebar-item
                <c:if test='${pageContext.request.requestURI.startsWith("/admin/teacher/")}'>active</c:if>">
        指导老师管理
      </a>

      <!-- 账号与密码管理 -->
      <a href="${pageContext.request.contextPath}/admin/system/account"
         class="list-group-item admin-sidebar-item
                <c:if test='${pageContext.request.requestURI.startsWith("/admin/system/")}'>active</c:if>">
        账号与密码管理
      </a>
    </div>
  </div>
</c:if>