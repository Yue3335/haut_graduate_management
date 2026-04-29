<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    request.setAttribute("pageTitle", "指导老师管理 - 管理员后台");
%>

<jsp:include page="/WEB-INF/jsp/common/header.jsp"/>
<jsp:include page="/WEB-INF/jsp/common/navbar.jsp"/>

<style>
    /* 基础样式 - 白色基调+科研风格 */
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    body {
        font-family: "Microsoft YaHei", "PingFang SC", "Helvetica Neue", Arial, sans-serif;
        background-color: #ffffff;
        color: #333647;
    }

    /* 容器布局 */
    .container {
        padding-top: 30px;
        padding-bottom: 50px;
        max-width: 1200px;
    }

    /* 页面标题 */
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

    /* 搜索表单样式 */
    .search-form {
        background-color: #f8fafc;
        border: 1px solid #e8eef4;
        border-radius: 10px;
        padding: 18px 20px;
        margin-bottom: 24px;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.02);
    }

    .form-control, .form-select {
        border: 1px solid #e2e8f0;
        border-radius: 6px;
        padding: 8px 12px;
        font-size: 14px;
        transition: all 0.2s ease;
    }

    .form-control:focus, .form-select:focus {
        border-color: #3182ce;
        box-shadow: 0 0 0 2px rgba(49, 130, 206, 0.1);
        outline: none;
    }

    /* 按钮通用样式 */
    .btn {
        border-radius: 6px;
        font-size: 14px;
        font-weight: 500;
        transition: all 0.2s ease;
    }

    .btn-primary {
        background-color: #3182ce;
        border-color: #3182ce;
        padding: 8px 20px;
    }

    .btn-primary:hover {
        background-color: #2c5282;
        border-color: #2c5282;
        box-shadow: 0 2px 8px rgba(49, 130, 206, 0.2);
    }

    .btn-outline-primary {
        border-color: #3182ce;
        color: #3182ce;
    }

    .btn-outline-primary:hover {
        background-color: #f0f7ff;
        border-color: #2c5282;
        color: #2c5282;
    }

    .btn-outline-secondary {
        border-color: #718096;
        color: #718096;
    }

    .btn-outline-secondary:hover {
        background-color: #f8fafc;
        border-color: #4a5568;
        color: #4a5568;
    }

    /* 卡片样式 */
    .data-card {
        border: 1px solid #e8eef4;
        border-radius: 10px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
        overflow: hidden;
        background-color: #ffffff;
    }

    .data-card-header {
        background-color: #f8fafc;
        border-bottom: 1px solid #e8eef4;
        color: #2c5282;
        padding: 14px 20px;
        font-weight: 500;
        font-size: 15px;
        display: flex;
        align-items: center;
    }

    .data-card-header::before {
        content: "";
        display: inline-block;
        width: 4px;
        height: 18px;
        background-color: #3182ce;
        border-radius: 2px;
        margin-right: 10px;
    }

    /* 表格样式 - 科研风极简表格 */
    .data-table {
        width: 100%;
        border-collapse: collapse;
    }

    .data-table thead {
        background-color: #f8fafc;
    }

    .data-table th {
        padding: 12px 10px;
        font-size: 13px;
        font-weight: 500;
        color: #2d3748;
        text-align: left;
        border-bottom: 2px solid #e8eef4;
        white-space: nowrap;
    }

    .data-table td {
        padding: 12px 10px;
        font-size: 14px;
        color: #4a5568;
        border-bottom: 1px solid #f0f2f5;
        vertical-align: middle;
    }

    .data-table tbody tr:hover {
        background-color: #f8fafc;
    }

    /* 空数据提示 */
    .empty-tip {
        color: #718096;
        font-size: 14px;
        padding: 40px 20px;
        text-align: center;
        margin: 0;
    }

    /* 操作按钮组 */
    .action-buttons .btn {
        padding: 4px 8px;
        font-size: 12px;
    }

    /* 响应式适配 */
    @media (max-width: 992px) {
        .search-form .row {
            gap: 10px;
        }
        .search-form .col-md-3 {
            flex: 0 0 100%;
            max-width: 100%;
        }
        .data-table {
            display: block;
            overflow-x: auto;
        }
    }
</style>

<div class="container" style="padding-top:30px;padding-bottom:50px;max-width:1200px;">
    <div class="row">
        <!-- 左侧管理员导航 -->
        <div class="col-md-4 col-lg-3 mb-4">
            <jsp:include page="/WEB-INF/jsp/admin/sidebar.jsp"/>
        </div>

        <!-- 右侧内容 -->
        <div class="col-md-8 col-lg-9">
            <h3 class="page-title">指导老师管理</h3>

            <!-- 查询过滤区域 -->
            <form class="search-form row g-3 mb-4" method="get"
                  action="${pageContext.request.contextPath}/admin/teacher/list">
                <div class="col-md-3">
                    <input type="text" name="keyword" class="form-control"
                           placeholder="按姓名/工号搜索" value="${param.keyword}">
                </div>
                <div class="col-md-3">
                    <input type="text" name="dept" class="form-control"
                           placeholder="按学院搜索" value="${param.dept}">
                </div>
                <div class="col-md-3">
                    <select name="identity" class="form-select">
                        <option value="">全部身份</option>
                        <!-- 这里用 SUPERVISOR 对应真正的指导老师角色 -->
                        <option value="SUPERVISOR"
                                <c:if test="${param.identity == 'SUPERVISOR'}">selected</c:if>>
                            指导老师
                        </option>
                        <option value="COUNSELOR"
                                <c:if test="${param.identity == 'COUNSELOR'}">selected</c:if>>
                            辅导员
                        </option>
                        <option value="CLASS_TEACHER"
                                <c:if test="${param.identity == 'CLASS_TEACHER'}">selected</c:if>>
                            班主任
                        </option>
                    </select>
                </div>
                <div class="col-md-3">
                    <button type="submit" class="btn btn-primary w-100">
                        查询
                    </button>
                </div>
            </form>

            <!-- 列表 -->
            <div class="data-card">
                <div class="data-card-header">
                    老师列表
                </div>
                <div class="card-body p-0">
                    <c:if test="${empty teachers}">
                        <p class="empty-tip">暂未查询到符合条件的老师数据。</p>
                    </c:if>

                    <c:if test="${not empty teachers}">
                        <table class="data-table mb-0 align-middle">
                            <thead>
                            <tr>
                                <th style="width: 10%;">工号</th>
                                <th style="width: 12%;">姓名</th>
                                <th style="width: 20%;">学院</th>
                                <th style="width: 12%;">职称</th>
                                <th style="width: 10%;">是否辅导员</th>
                                <th style="width: 10%;">当前带生数</th>
                                <th style="width: 10%;">最大带生数(可选)</th>
                                <th style="width: 16%;">操作</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="t" items="${teachers}">
                                <tr>
                                    <td>${t.teacherNo}</td>
                                    <td>${t.realName}</td>
                                    <td>${t.deptName}</td>
                                    <td>${t.title}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${t.isCounselor == 1}">
                                                <span style="color: #38b2ac; font-weight: 500;">是</span>
                                            </c:when>
                                            <c:otherwise>否</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${t.currentStudentCount}</td>
                                    <td>
                                        <c:if test="${t.maxStudentCount != null}">
                                            ${t.maxStudentCount}
                                        </c:if>
                                        <c:if test="${t.maxStudentCount == null}">
                                            <span style="color: #718096;">-</span>
                                        </c:if>
                                    </td>
                                    <td class="action-buttons">
                                        <!-- 跳转到：指导关系分配页面，并选中该老师 -->
                                        <a href="${pageContext.request.contextPath}/admin/advising/assign?teacherId=${t.teacherId}"
                                           class="btn btn-sm btn-outline-primary me-1"
                                           title="查看并分配该老师的指导关系">
                                            指导关系
                                        </a>

                                        <!-- 跳转到：账号与密码管理页面，按用户名定位该指导老师账号 -->
                                        <a href="${pageContext.request.contextPath}/admin/system/account?keyword=${t.username}&role=SUPERVISOR"
                                           class="btn btn-sm btn-outline-secondary"
                                           title="管理该老师账号（重置密码 / 启用禁用等）">
                                            账号管理
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </c:if>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>