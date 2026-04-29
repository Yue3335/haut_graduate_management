<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    request.setAttribute("pageTitle", "账号与密码管理 - 管理员后台");
%>

<jsp:include page="/WEB-INF/jsp/common/header.jsp"/>
<jsp:include page="/WEB-INF/jsp/common/navbar.jsp"/>

<style>
    /* 基础样式 - 白色基调+科研风格统一 */
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

    /* 卡片通用样式 - 科研风白色卡片 */
    .data-card {
        border: 1px solid #e8eef4;
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
        overflow: hidden;
        background-color: #ffffff;
        margin-bottom: 24px;
        transition: all 0.3s ease;
    }

    .data-card:hover {
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
        border-color: #d1e0f0;
    }

    /* 卡片头部样式 */
    .card-header {
        background-color: #f8fafc;
        border-bottom: 1px solid #e8eef4;
        color: #2c5282;
        padding: 14px 20px;
        font-weight: 500;
        font-size: 15px;
        display: flex;
        align-items: center;
    }

    .card-header::before {
        content: "";
        display: inline-block;
        width: 4px;
        height: 18px;
        background-color: #3182ce;
        border-radius: 2px;
        margin-right: 10px;
    }

    /* 卡片内容区 */
    .card-body {
        padding: 20px;
    }

    /* 功能说明文本样式 */
    .function-desc {
        color: #4a5568;
        line-height: 1.7;
        font-size: 14px;
    }

    .function-desc ul {
        margin-top: 8px;
        padding-left: 20px;
    }

    .function-desc li {
        margin-bottom: 4px;
    }

    /* 表单控件样式 */
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
        padding: 4px 8px;
        font-size: 12px;
    }

    .btn-outline-primary:hover {
        background-color: #f0f7ff;
        border-color: #2c5282;
        color: #2c5282;
    }

    .btn-outline-danger {
        border-color: #e53e3e;
        color: #e53e3e;
        padding: 4px 8px;
        font-size: 12px;
    }

    .btn-outline-danger:hover {
        background-color: #fef7fb;
        border-color: #c53030;
        color: #c53030;
    }

    .btn-outline-success {
        border-color: #38b2ac;
        color: #38b2ac;
        padding: 4px 8px;
        font-size: 12px;
    }

    .btn-outline-success:hover {
        background-color: #e6fffa;
        border-color: #319795;
        color: #319795;
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

    /* 状态标签样式 */
    .status-normal {
        color: #38b2ac;
        font-weight: 500;
    }

    .status-disabled {
        color: #e53e3e;
        font-weight: 500;
    }

    /* 空数据提示 */
    .empty-tip {
        color: #718096;
        font-size: 14px;
        padding: 40px 20px;
        text-align: center;
        margin: 0;
    }

    /* 响应式适配 */
    @media (max-width: 992px) {
        .card-body {
            padding: 16px;
        }
        .search-form .row {
            gap: 10px;
        }
        .search-form .col-md-4 {
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
            <h3 class="page-title">账号与密码管理</h3>
            <!-- 功能说明卡片 -->
            <div class="data-card">
                <div class="card-header">
                    功能说明
                </div>
                <div class="card-body function-desc">
                    <p class="mb-1">
                        本页面用于管理员维护系统用户的账号与密码，例如：
                    </p>
                    <ul class="mb-0">
                        <li>重置学生、指导老师、辅导员、班主任等用户的登录密码；</li>
                        <li>创建新的用户账号，并分配角色（学生 / 老师 / 管理员等）；</li>
                        <li>禁用或启用某个用户账号。</li>
                    </ul>
                </div>
            </div>

            <!-- 搜索用户卡片 -->
            <div class="data-card">
                <div class="card-header">
                    搜索用户
                </div>
                <div class="card-body">
                    <form class="row g-3 search-form" method="get"
                          action="${pageContext.request.contextPath}/admin/system/account">
                        <div class="col-md-4">
                            <input type="text" name="keyword" class="form-control"
                                   placeholder="按用户名/姓名搜索" value="${param.keyword}">
                        </div>
                        <div class="col-md-4">
                            <select name="role" class="form-select">
                                <option value="">全部角色</option>
                                <option value="STUDENT"
                                        <c:if test="${param.role == 'STUDENT'}">selected</c:if>>
                                    学生
                                </option>
                                <!-- 这里改成 SUPERVISOR -->
                                <option value="SUPERVISOR"
                                        <c:if test="${param.role == 'SUPERVISOR'}">selected</c:if>>
                                    指导老师
                                </option>
                                <option value="COUNSELOR"
                                        <c:if test="${param.role == 'COUNSELOR'}">selected</c:if>>
                                    辅导员
                                </option>
                                <option value="CLASS_TEACHER"
                                        <c:if test="${param.role == 'CLASS_TEACHER'}">selected</c:if>>
                                    班主任
                                </option>
                                <option value="ADMIN"
                                        <c:if test="${param.role == 'ADMIN'}">selected</c:if>>
                                    管理员
                                </option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <button type="submit" class="btn btn-primary w-100">
                                查询
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- 用户列表卡片 -->
            <div class="data-card">
                <div class="card-header">
                    用户列表
                </div>
                <div class="card-body p-0">
                    <c:if test="${empty users}">
                        <p class="empty-tip">暂未查询到符合条件的用户。</p>
                    </c:if>

                    <c:if test="${not empty users}">
                        <table class="data-table mb-0 align-middle">
                            <thead>
                            <tr>
                                <th style="width: 10%;">用户ID</th>
                                <th style="width: 15%;">用户名</th>
                                <th style="width: 15%;">姓名</th>
                                <th style="width: 25%;">角色</th>
                                <th style="width: 10%;">状态</th>
                                <th style="width: 25%;">操作</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="u" items="${users}">
                                <tr>
                                    <td>${u.userId}</td>
                                    <td>${u.username}</td>
                                    <td>${u.realName}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty u.roles}">
                                                ${u.roles}
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: #718096;">无角色</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${u.status == 1}">
                                                <span class="status-normal">正常</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-disabled">禁用</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <!-- 重置密码 -->
                                        <form method="post"
                                              action="${pageContext.request.contextPath}/admin/system/account"
                                              style="display:inline;">
                                            <input type="hidden" name="userId" value="${u.userId}"/>
                                            <input type="hidden" name="action" value="resetPassword"/>
                                            <!-- 保留当前查询条件 -->
                                            <input type="hidden" name="keyword" value="${param.keyword}"/>
                                            <input type="hidden" name="role" value="${param.role}"/>

                                            <button type="submit"
                                                    class="btn btn-sm btn-outline-primary me-1"
                                                    onclick="return confirm('确定要重置该用户的密码吗？');">
                                                重置密码
                                            </button>
                                        </form>

                                        <!-- 启用/禁用 -->
                                        <form method="post"
                                              action="${pageContext.request.contextPath}/admin/system/account"
                                              style="display:inline;">
                                            <input type="hidden" name="userId" value="${u.userId}"/>
                                            <input type="hidden" name="action" value="toggleStatus"/>
                                            <input type="hidden" name="keyword" value="${param.keyword}"/>
                                            <input type="hidden" name="role" value="${param.role}"/>

                                            <button type="submit"
                                                    class="btn btn-sm
                                                    <c:choose>
                                                        <c:when test='${u.status == 1}'> btn-outline-danger</c:when>
                                                        <c:otherwise> btn-outline-success</c:otherwise>
                                                    </c:choose>">
                                                <c:choose>
                                                    <c:when test="${u.status == 1}">禁用</c:when>
                                                    <c:otherwise>启用</c:otherwise>
                                                </c:choose>
                                            </button>
                                        </form>
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