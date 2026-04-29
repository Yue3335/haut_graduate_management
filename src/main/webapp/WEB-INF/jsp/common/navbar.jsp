<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    /* 导航栏核心样式 - 科研风格+白色基调 */
    .navbar {
        background: linear-gradient(135deg, rgb(7, 112, 255), #4690ff) !important;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        padding: 8px 0;
    }

    .navbar-brand {
        font-weight: 600;
        font-size: 18px;
        color: #ffffff !important;
        letter-spacing: 0.5px;
        padding: 8px 0;
    }

    .navbar-brand:hover {
        color: #f0f7ff !important;
    }

    /* 导航项样式 */
    .nav-link {
        color: rgba(255, 255, 255, 0.9) !important;
        font-size: 14px;
        padding: 8px 16px !important;
        border-radius: 6px;
        margin: 0 2px;
        transition: all 0.3s ease;
    }

    .nav-link:hover {
        color: #ffffff !important;
        background-color: rgba(255, 255, 255, 0.1);
    }

    .nav-link.active {
        color: #ffffff !important;
        background-color: rgba(255, 255, 255, 0.2);
        font-weight: 500;
    }

    /* 下拉菜单样式 - 科研风格 */
    .dropdown-menu {
        background-color: #ffffff;
        border: 1px solid #e8eef4;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
        padding: 8px 0;
        margin-top: 4px !important;
    }

    .dropdown-item {
        color: #2d3748;
        font-size: 14px;
        padding: 10px 20px;
        transition: all 0.2s ease;
        border-left: 3px solid transparent;
    }

    .dropdown-item:hover {
        background-color: #f8fafc;
        color: rgb(7, 112, 255);
        border-left-color: rgb(78, 145, 250);
        padding-left: 25px;
    }

    /* 用户信息文本 */
    .navbar-text {
        color: rgba(255, 255, 255, 0.9) !important;
        font-size: 14px;
    }

    /* 折叠按钮样式 */
    .navbar-toggler {
        border-color: rgba(255, 255, 255, 0.2) !important;
    }

    .navbar-toggler-icon {
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 30 30'%3e%3cpath stroke='rgba%28255, 255, 255, 0.8%29' stroke-linecap='round' stroke-miterlimit='10' stroke-width='2' d='M4 7h22M4 15h22M4 23h22'/%3e%3c/svg%3e") !important;
    }

    /* 响应式适配 */
    @media (max-width: 992px) {
        .navbar-collapse {
            background-color: rgba(17, 83, 168, 0.98);
            border-radius: 8px;
            margin-top: 8px;
            padding: 10px;
        }

        .dropdown-menu {
            background-color: rgba(255, 255, 255, 0.95);
        }

        .nav-link {
            padding: 10px 16px !important;
        }
    }

    @media (max-width: 576px) {
        .navbar-brand {
            font-size: 16px;
        }

        .dropdown-item {
            padding: 8px 16px;
            font-size: 13px;
        }
    }
</style>

<nav class="navbar navbar-expand-lg navbar-dark">
    <div class="container-fluid">
        <!-- 左上角系统名 -->
        <a class="navbar-brand" href="${pageContext.request.contextPath}/">
            毕业管理系统
        </a>

        <!-- 折叠按钮（移动端） -->
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                data-bs-target="#mainNavbar" aria-controls="mainNavbar"
                aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <!-- 导航主体 -->
        <div class="collapse navbar-collapse" id="mainNavbar">
            <!-- 左侧导航区域 -->
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <!-- 公共首页入口 -->
                <li class="nav-item">
                    <a class="nav-link" aria-current="page"
                       href="${pageContext.request.contextPath}/">
                        首页
                    </a>
                </li>

                <!-- 学生导航 -->
                <c:if test="${sessionScope.isStudent}">
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="studentDropdown"
                           role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            学生功能
                        </a>
                        <ul class="dropdown-menu" aria-labelledby="studentDropdown">
                            <li>
                                <a class="dropdown-item"
                                   href="${pageContext.request.contextPath}/student/profile">
                                    个人信息维护
                                </a>
                            </li>
                            <li>
                                <a class="dropdown-item"
                                   href="${pageContext.request.contextPath}/student/submission">
                                    资料上传
                                </a>
                            </li>
                            <li>
                                <a class="dropdown-item"
                                   href="${pageContext.request.contextPath}/student/submission/status">
                                    查看审核进度
                                </a>
                            </li>
                            <li>
                                <a class="dropdown-item"
                                   href="${pageContext.request.contextPath}/student/contact-teacher">
                                    联系老师
                                </a>
                            </li>
                            <li>
                                <a class="dropdown-item"
                                   href="${pageContext.request.contextPath}/student/recommendation">
                                    个人发展推荐
                                </a>
                            </li>
                        </ul>
                    </li>
                </c:if>

                <!-- 指导老师导航 -->
                <c:if test="${sessionScope.isTeacher}">
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="teacherDropdown"
                           role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            指导老师
                        </a>
                        <ul class="dropdown-menu" aria-labelledby="teacherDropdown">
                            <li>
                                <a class="dropdown-item"
                                   href="${pageContext.request.contextPath}/teacher/students/employment">
                                    学生就业情况
                                </a>
                            </li>
                            <li>
                                <a class="dropdown-item"
                                   href="${pageContext.request.contextPath}/teacher/review/submissions">
                                    审核
                                </a>
                            </li>
                            <li>
                                <a class="dropdown-item"
                                   href="${pageContext.request.contextPath}/teacher/communicate/students">
                                    和学生沟通
                                </a>
                            </li>
                        </ul>
                    </li>
                </c:if>

                <!-- 辅导员导航 -->
                <c:if test="${sessionScope.isCounselor}">
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="counselorDropdown"
                           role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            辅导员
                        </a>
                        <ul class="dropdown-menu" aria-labelledby="counselorDropdown">
                            <li>
                                <a class="dropdown-item"
                                   href="${pageContext.request.contextPath}/counselor/students/employment">
                                    学生就业情况
                                </a>
                            </li>
                            <li>
                                <a class="dropdown-item"
                                   href="${pageContext.request.contextPath}/counselor/review/submissions">
                                    审核
                                </a>
                            </li>
                            <li>
                                <a class="dropdown-item"
                                   href="${pageContext.request.contextPath}/counselor/communicate/students">
                                    和学生沟通
                                </a>
                            </li>
                        </ul>
                    </li>
                </c:if>

                <!-- 班主任导航 -->
                <c:if test="${sessionScope.isClassTeacher}">
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="classTeacherDropdown"
                           role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            班主任
                        </a>
                        <ul class="dropdown-menu" aria-labelledby="classTeacherDropdown">
                            <li>
                                <a class="dropdown-item"
                                   href="${pageContext.request.contextPath}/class-teacher/students/employment">
                                    学生就业情况
                                </a>
                            </li>
                            <li>
                                <a class="dropdown-item"
                                   href="${pageContext.request.contextPath}/class-teacher/review/submissions">
                                    审核
                                </a>
                            </li>
                            <li>
                                <a class="dropdown-item"
                                   href="${pageContext.request.contextPath}/class-teacher/communicate/students">
                                    和学生沟通
                                </a>
                            </li>
                        </ul>
                    </li>
                </c:if>

                <!-- 管理员导航（已去掉“指导关系分配”项） -->
                <c:if test="${sessionScope.isAdmin}">
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="adminDropdown"
                           role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            管理员
                        </a>
                        <ul class="dropdown-menu" aria-labelledby="adminDropdown">
                            <li>
                                <a class="dropdown-item"
                                   href="${pageContext.request.contextPath}/admin/home">
                                    管理员首页 / 账号密码
                                </a>
                            </li>
                            <li>
                                <a class="dropdown-item"
                                   href="${pageContext.request.contextPath}/admin/student/list">
                                    学生管理
                                </a>
                            </li>
                            <li>
                                <a class="dropdown-item"
                                   href="${pageContext.request.contextPath}/admin/teacher/list">
                                    指导老师管理
                                </a>
                            </li>
                            <!-- 指导关系分配不再出现在导航栏，作为学生管理页面中的一个功能按钮 -->
                        </ul>
                    </li>
                </c:if>
            </ul>

            <!-- 右侧用户信息与登录/退出 -->
            <ul class="navbar-nav ms-auto mb-2 mb-lg-0">
                <c:choose>
                    <c:when test="${not empty sessionScope.currentUser}">
                        <li class="nav-item">
                            <span class="navbar-text me-3">
                                欢迎，${sessionScope.currentUser.realName}
                            </span>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link"
                               href="${pageContext.request.contextPath}/logout">
                                退出
                            </a>
                        </li>
                    </c:when>
                    <c:otherwise>
                        <li class="nav-item">
                            <a class="nav-link"
                               href="${pageContext.request.contextPath}/login">
                                登录
                            </a>
                        </li>
                    </c:otherwise>
                </c:choose>
            </ul>
        </div>
    </div>
</nav>