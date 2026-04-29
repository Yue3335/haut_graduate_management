<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    request.setAttribute("pageTitle", "学生管理 - 管理员后台");
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

    /* 搜索表单样式 */
    .search-form {
        background-color: #f8fafc;
        border: 1px solid #e8eef4;
        border-radius: 10px;
        padding: 18px 20px;
        margin-bottom: 24px;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.02);
    }

    /* 表单控件样式 */
    .form-control {
        border: 1px solid #e2e8f0;
        border-radius: 6px;
        padding: 8px 12px;
        font-size: 14px;
        transition: all 0.2s ease;
    }

    .form-control:focus {
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

    .btn-outline-secondary {
        border-color: #718096;
        color: #718096;
        padding: 4px 8px;
        font-size: 12px;
    }

    .btn-outline-secondary:hover {
        background-color: #f8fafc;
        border-color: #4a5568;
        color: #4a5568;
    }

    /* 卡片通用样式 - 科研风白色卡片 */
    .data-card {
        border: 1px solid #e8eef4;
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
        overflow: hidden;
        background-color: #ffffff;
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
    .status-enroll {
        color: #38b2ac;
        font-weight: 500;
    }

    .status-graduate {
        color: #4299e1;
        font-weight: 500;
    }

    .status-other {
        color: #718096;
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
            <h3 class="page-title">学生管理</h3>

            <!-- 查询过滤 -->
            <form class="search-form row g-3 mb-4" method="get"
                  action="${pageContext.request.contextPath}/admin/student/list">
                <div class="col-md-3">
                    <input type="text" name="keyword" class="form-control"
                           placeholder="按姓名/学号搜索" value="${param.keyword}">
                </div>
                <div class="col-md-3">
                    <input type="text" name="major" class="form-control"
                           placeholder="按专业搜索" value="${param.major}">
                </div>
                <div class="col-md-3">
                    <input type="text" name="className" class="form-control"
                           placeholder="按班级搜索" value="${param.className}">
                </div>
                <div class="col-md-3">
                    <button type="submit" class="btn btn-primary w-100">查询</button>
                </div>
            </form>

            <div class="data-card">
                <div class="card-header">
                    学生列表
                </div>
                <div class="card-body p-0">
                    <c:if test="${empty students}">
                        <p class="empty-tip">暂未查询到学生数据。</p>
                    </c:if>

                    <c:if test="${not empty students}">
                        <table class="data-table mb-0 align-middle">
                            <thead>
                            <tr>
                                <th style="width: 8%;">学号</th>
                                <th style="width: 10%;">姓名</th>
                                <th style="width: 20%;">专业</th>
                                <th style="width: 20%;">班级</th>
                                <th style="width: 10%;">入学年份</th>
                                <th style="width: 10%;">状态</th>
                                <th style="width: 12%;">操作</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="s" items="${students}">
                                <tr>
                                    <td>${s.studentNo}</td>
                                    <td>${s.realName}</td>
                                    <td>${s.majorName}</td>
                                    <td>${s.className}</td>
                                    <td>${s.enrollYear}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${s.status == 1}">
                                                <span class="status-enroll">在读</span>
                                            </c:when>
                                            <c:when test="${s.status == 2}">
                                                <span class="status-graduate">毕业</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-other">其他</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/admin/advising/assign?studentId=${s.studentId}"
                                           class="btn btn-sm btn-outline-secondary"
                                           title="为该学生分配指导老师">
                                            分配导师
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