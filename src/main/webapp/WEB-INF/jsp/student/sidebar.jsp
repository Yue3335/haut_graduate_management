<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
  /* 学生侧边栏样式 - 科研风格+白色基调统一 */
  .student-sidebar-group {
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
    border: 1px solid #e8eef4;
    background-color: #ffffff;
  }

  .student-sidebar-item {
    border: none;
    padding: 14px 20px;
    font-size: 15px;
    transition: all 0.3s ease;
    color: #2d3748;
    border-left: 3px solid transparent;
    background-color: #ffffff;
  }

  /* 激活状态样式 - 科研风蓝色 */
  .student-sidebar-item.active {
    background-color: #f0f7ff;
    border-left-color: #3182ce;
    font-weight: 500;
    color: #2c5282;
    box-shadow: inset 0 0 0 1000px rgba(49, 130, 206, 0.05);
  }

  /* 悬停状态 */
  .student-sidebar-item:not(.active):hover {
    background-color: #f8fafc;
    border-left-color: #3182ce;
    color: #3182ce;
    padding-left: 25px;
  }

  /* 移除默认边框，改用科研风浅分隔线 */
  .student-sidebar-item + .student-sidebar-item {
    border-top: 1px solid #f0f2f5;
  }

  /* 响应式适配 */
  @media (max-width: 768px) {
    .student-sidebar-item {
      padding: 12px 16px;
      font-size: 14px;
    }
    .student-sidebar-item:not(.active):hover {
      padding-left: 20px;
    }
  }
</style>

<!-- 学生左侧导航，只负责左栏，不要再 include 头部或导航栏 -->
<div class="col-md-3 mb-4">
  <div class="list-group student-sidebar-group">

    <!-- 学生首页 -->
    <a href="${pageContext.request.contextPath}/student/home"
       class="list-group-item student-sidebar-item
                  <c:if test='${pageContext.request.requestURI.endsWith("/student/home")}'>active</c:if>">
      学生首页
    </a>

    <!-- 联系导师 -->
    <a href="${pageContext.request.contextPath}/student/contact-teacher"
       class="list-group-item student-sidebar-item
                  <c:if test='${pageContext.request.requestURI.contains("/student/contact")}'>active</c:if>">
      联系导师
    </a>

    <!-- 就业去向登记（原“资料上传”） -->
    <a href="${pageContext.request.contextPath}/student/submission"
       class="list-group-item student-sidebar-item
                  <c:if test='${pageContext.request.requestURI.endsWith("/student/submission")}'>active</c:if>">
      就业去向登记
    </a>

    <!-- 就业登记记录 / 审核状态（原“查看审核进度”） -->
    <a href="${pageContext.request.contextPath}/student/submission/status"
       class="list-group-item student-sidebar-item
                  <c:if test='${pageContext.request.requestURI.endsWith("/student/submission/status")}'>active</c:if>">
      审核状态
    </a>

    <a href="${pageContext.request.contextPath}/student/recommendation"
       class="list-group-item student-sidebar-item
                  <c:if test='${pageContext.request.requestURI.contains("/student/recommendation")}'>active</c:if>">
      成绩及发展建议
    </a>

  </div>
</div>