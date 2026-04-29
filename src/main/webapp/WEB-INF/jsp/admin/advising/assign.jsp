<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    request.setAttribute("pageTitle", "指导关系分配 - 管理员后台");
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

    /* 操作结果提示 */
    .success-alert {
        background-color: #e6fffa;
        border: 1px solid #38b2ac;
        color: #285e61;
        border-radius: 8px;
        padding: 12px 16px;
        font-size: 14px;
        margin-bottom: 20px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.02);
    }

    /* 选择老师表单样式 */
    .teacher-select-form {
        background-color: #f8fafc;
        border: 1px solid #e8eef4;
        border-radius: 10px;
        padding: 18px 20px;
        margin-bottom: 24px;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.02);
    }

    .form-label {
        font-weight: 500;
        color: #2d3748;
        font-size: 14px;
        margin-bottom: 8px;
    }

    .form-select {
        border: 1px solid #e2e8f0;
        border-radius: 6px;
        padding: 8px 12px;
        font-size: 14px;
        transition: all 0.2s ease;
    }

    .form-select:focus {
        border-color: #3182ce;
        box-shadow: 0 0 0 2px rgba(49, 130, 206, 0.1);
        outline: none;
    }

    /* 当前导师信息提示 */
    .teacher-info {
        color: #4a5568;
        font-size: 14px;
        line-height: 1.6;
        margin-bottom: 24px;
        padding: 12px 16px;
        background-color: #f8fafc;
        border-radius: 8px;
        border-left: 3px solid #3182ce;
    }

    .teacher-info strong {
        color: #2c5282;
    }

    .empty-tip {
        color: #718096;
        font-size: 14px;
        padding: 40px 20px;
        text-align: center;
        margin: 0;
    }

    /* 卡片通用样式 - 科研风白色卡片 */
    .data-card {
        border: 1px solid #e8eef4;
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
        overflow: hidden;
        background-color: #ffffff;
        transition: all 0.3s ease;
        height: 100%;
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
        padding: 0;
        max-height: 400px;
        overflow-y: auto;
    }

    /* 卡片底部操作区 */
    .card-footer {
        background-color: #f8fafc;
        border-top: 1px solid #e8eef4;
        padding: 12px 20px;
        text-align: right;
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

    /* 复选框样式 */
    .form-check-input {
        width: 16px;
        height: 16px;
        border: 1px solid #e2e8f0;
        border-radius: 3px;
        cursor: pointer;
    }

    .form-check-input:checked {
        background-color: #3182ce;
        border-color: #3182ce;
    }

    /* 按钮通用样式 */
    .btn {
        border-radius: 6px;
        font-size: 14px;
        font-weight: 500;
        transition: all 0.2s ease;
        padding: 6px 16px;
    }

    .btn-primary {
        background-color: #3182ce;
        border-color: #3182ce;
    }

    .btn-primary:hover {
        background-color: #2c5282;
        border-color: #2c5282;
        box-shadow: 0 2px 8px rgba(49, 130, 206, 0.2);
    }

    .btn-outline-danger {
        border-color: #e53e3e;
        color: #e53e3e;
    }

    .btn-outline-danger:hover {
        background-color: #fef7fb;
        border-color: #c53030;
        color: #c53030;
    }

    /* 响应式适配 */
    @media (max-width: 992px) {
        .row > .col-md-6 {
            margin-bottom: 24px;
        }
        .data-table {
            display: block;
            overflow-x: auto;
        }
    }

    @media (max-width: 576px) {
        .teacher-select-form {
            padding: 14px 16px;
        }
        .card-header {
            padding: 12px 16px;
            font-size: 14px;
        }
        .card-footer {
            padding: 10px 16px;
        }
        .btn {
            padding: 5px 12px;
            font-size: 13px;
        }
    }
</style>

<div class="container" style="padding-top: 30px; padding-bottom: 50px; max-width: 1200px;">
    <div class="row">
        <!-- 左侧管理员导航 -->
        <div class="col-md-4 col-lg-3 mb-4">
            <jsp:include page="/WEB-INF/jsp/admin/sidebar.jsp"/>
        </div>

        <!-- 右侧内容 -->
        <div class="col-md-8 col-lg-9">
            <h3 class="page-title">指导关系分配</h3>

            <!-- 操作结果提示 -->
            <c:if test="${param.msg == 'ok'}">
                <div class="success-alert">
                    操作已完成。
                </div>
            </c:if>

            <!-- 选择老师 -->
            <form class="teacher-select-form row g-3 mb-4" method="get"
                  action="${pageContext.request.contextPath}/admin/advising/assign">
                <div class="col-md-12">
                    <label class="form-label">选择指导老师</label>
                    <select name="teacherId" class="form-select" onchange="this.form.submit()">
                        <option value="">请选择指导老师</option>
                        <c:forEach var="t" items="${teachers}">
                            <option value="${t.teacherId}"
                                    <c:if test="${t.teacherId == currentTeacherId}">selected</c:if>>
                                    ${t.realName}（${t.deptName}）
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </form>

            <!-- 当前选中导师信息 -->
            <c:if test="${not empty currentTeacherId}">
                <p class="teacher-info">
                    当前指导老师：
                    <strong>
                        <c:out value="${currentTeacher.realName}"/>
                        （<c:out value="${currentTeacher.deptName}"/>）
                    </strong>，
                    已分配学生人数：
                    <strong><c:out value="${fn:length(assignedStudents)}"/></strong>
                </p>
            </c:if>

            <c:if test="${empty currentTeacherId}">
                <p class="empty-tip" style="margin-bottom: 0;">请先在上方选择一位指导老师。</p>
            </c:if>

            <c:if test="${not empty currentTeacherId}">
                <div class="row">
                    <!-- 可分配学生列表 -->
                    <div class="col-md-6 mb-4">
                        <div class="data-card">
                            <div class="card-header">
                                可分配学生
                            </div>
                            <form method="post"
                                  action="${pageContext.request.contextPath}/admin/advising/assign">
                                <input type="hidden" name="teacherId" value="${currentTeacherId}"/>

                                <div class="card-body">
                                    <c:if test="${empty unassignedStudents}">
                                        <p class="empty-tip">当前没有可分配的学生。</p>
                                    </c:if>
                                    <c:if test="${not empty unassignedStudents}">
                                        <table class="data-table mb-0 align-middle">
                                            <thead>
                                            <tr>
                                                <th style="width: 8%;">
                                                    <input type="checkbox" class="form-check-input" onclick="toggleCheckAll(this, 'assignIds')"/>
                                                </th>
                                                <th style="width: 20%;">学号</th>
                                                <th style="width: 20%;">姓名</th>
                                                <th style="width: 25%;">专业</th>
                                                <th style="width: 25%;">班级</th>
                                            </tr>
                                            </thead>
                                            <tbody>
                                            <c:forEach var="s" items="${unassignedStudents}">
                                                <tr>
                                                    <td>
                                                        <input type="checkbox" class="form-check-input" name="assignIds"
                                                               value="${s.studentId}"/>
                                                    </td>
                                                    <td>${s.studentNo}</td>
                                                    <td>${s.realName}</td>
                                                    <td>${s.majorName}</td>
                                                    <td>${s.className}</td>
                                                </tr>
                                            </c:forEach>
                                            </tbody>
                                        </table>
                                    </c:if>
                                </div>
                                <div class="card-footer">
                                    <button type="submit" name="action" value="assign"
                                            class="btn btn-primary">
                                        将选中学生分配给该老师
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <!-- 已分配学生列表 -->
                    <div class="col-md-6 mb-4">
                        <div class="data-card">
                            <div class="card-header">
                                已分配学生
                            </div>
                            <form method="post"
                                  action="${pageContext.request.contextPath}/admin/advising/assign">
                                <input type="hidden" name="teacherId" value="${currentTeacherId}"/>

                                <div class="card-body">
                                    <c:if test="${empty assignedStudents}">
                                        <p class="empty-tip">当前该老师尚未分配学生。</p>
                                    </c:if>
                                    <c:if test="${not empty assignedStudents}">
                                        <table class="data-table mb-0 align-middle">
                                            <thead>
                                            <tr>
                                                <th style="width: 8%;">
                                                    <input type="checkbox" class="form-check-input" onclick="toggleCheckAll(this, 'removeIds')"/>
                                                </th>
                                                <th style="width: 20%;">学号</th>
                                                <th style="width: 20%;">姓名</th>
                                                <th style="width: 25%;">专业</th>
                                                <th style="width: 25%;">班级</th>
                                            </tr>
                                            </thead>
                                            <tbody>
                                            <c:forEach var="s" items="${assignedStudents}">
                                                <tr>
                                                    <td>
                                                        <input type="checkbox" class="form-check-input" name="removeIds"
                                                               value="${s.studentId}"/>
                                                    </td>
                                                    <td>${s.studentNo}</td>
                                                    <td>${s.realName}</td>
                                                    <td>${s.majorName}</td>
                                                    <td>${s.className}</td>
                                                </tr>
                                            </c:forEach>
                                            </tbody>
                                        </table>
                                    </c:if>
                                </div>
                                <div class="card-footer">
                                    <button type="submit" name="action" value="remove"
                                            class="btn btn-outline-danger">
                                        从该老师名下移除选中学生
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
</div>

<script>
    function toggleCheckAll(source, name) {
        var checkboxes = document.getElementsByName(name);
        for (var i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = source.checked;
        }
    }
</script>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>