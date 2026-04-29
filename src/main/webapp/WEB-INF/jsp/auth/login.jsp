<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    request.setAttribute("pageTitle", "用户登录 - 河南工业大学毕业管理系统");
%>
<jsp:include page="/WEB-INF/jsp/common/header.jsp"/>

<style>
    /* 基础重置与全局样式 */
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    body {
        font-family: "Microsoft YaHei", "PingFang SC", "Helvetica Neue", Arial, sans-serif;
        overflow-x: hidden;
    }

    /* 整体布局：全高，左右两列 */
    .login-wrapper {
        min-height: 100vh;
        display: flex;
        flex-direction: row;
        background-color: #f8fafc;
    }

    /* 左侧：大图 + 渐变遮罩 + 动效 */
    .login-left {
        flex: 1.1;
        position: relative;
        background: url('<%=request.getContextPath()%>/static/imag/campus-bg.jpg') center center / cover no-repeat;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #fff;
        overflow: hidden;
        transition: all 0.5s ease;
    }

    .login-left::before {
        content: "";
        position: absolute;
        inset: 0;
        background: linear-gradient(135deg, rgba(0, 55, 128, 0.88), rgba(0, 115, 190, 0.72));
        mix-blend-mode: multiply;
        backdrop-filter: blur(1px);
    }

    .login-left-content {
        position: relative;
        max-width: 460px;
        padding: 32px 28px;
        text-align: left;
        transform: translateY(0);
        animation: fadeInUp 0.8s ease forwards;
        opacity: 0;
        animation-delay: 0.2s;
    }

    /* 左侧内容渐入动画 */
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(20px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    .login-left-logo {
        display: flex;
        align-items: center;
        margin-bottom: 28px;
    }

    .login-left-logo img {
        height: 58px;
        width: auto;
        border-radius: 8px;
        margin-right: 16px;
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.4);
        object-fit: cover;
        background: #fff;
        transition: transform 0.3s ease;
    }

    .login-left-logo img:hover {
        transform: scale(1.05);
    }

    .login-left-school-cn {
        font-size: 20px;
        font-weight: 600;
        letter-spacing: 0.1em;
        margin-bottom: 2px;
    }

    .login-left-school-en {
        font-size: 12px;
        opacity: 0.9;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }

    .login-left-title {
        font-size: 36px;
        font-weight: 700;
        margin: 12px 0 8px 0;
        line-height: 1.2;
        text-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
    }

    .login-left-subtitle {
        font-size: 14px;
        opacity: 0.95;
        margin-bottom: 32px;
        letter-spacing: 0.03em;
    }

    .login-left-feature {
        font-size: 14px;
        line-height: 1.8;
        opacity: 0.98;
        margin-bottom: 36px;
    }

    .login-left-feature-item {
        margin-bottom: 12px;
        padding-left: 20px;
        position: relative;
    }

    .login-left-feature-item::before {
        content: "●";
        position: absolute;
        left: 0;
        color: #4cc9f0;
        font-size: 16px;
    }

    .login-left-footer {
        font-size: 12px;
        opacity: 0.9;
        margin-top: 40px;
        border-top: 1px solid rgba(255, 255, 255, 0.3);
        padding-top: 16px;
        line-height: 1.6;
    }

    /* 右侧：登录卡片区域 */
    .login-right {
        flex: 0.9;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 40px 24px;
        background: radial-gradient(circle at top, rgba(0, 89, 214, 0.95), rgba(77, 144, 243, 0.95));
        position: relative;
    }

    /* 右侧背景装饰点 */
    .login-right::after {
        content: "";
        position: absolute;
        width: 100%;
        height: 100%;
        background-image:
                radial-gradient(circle at 20% 30%, rgba(255,255,255,0.05) 0%, transparent 5%),
                radial-gradient(circle at 80% 70%, rgba(255,255,255,0.03) 0%, transparent 5%);
        pointer-events: none;
    }

    /* 蓝色主题卡片 - 增强质感 */
    .login-card {
        width: 100%;
        max-width: 420px;
        background: linear-gradient(160deg, #f0f7ff, #f8fbff);
        border-radius: 24px;
        box-shadow: 0 24px 60px rgba(15, 23, 42, 0.18), 0 8px 24px rgba(15, 23, 42, 0.12);
        overflow: hidden;
        border: 1px solid rgba(147, 197, 253, 0.95);
        transform: translateY(0);
        animation: cardFloat 0.6s ease forwards;
        opacity: 0;
    }

    @keyframes cardFloat {
        from {
            opacity: 0;
            transform: translateY(15px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    .login-card-header {
        background: linear-gradient(135deg, #0056d6, #007bff);
        color: #fff;
        padding: 20px 28px;
        position: relative;
        overflow: hidden;
    }

    .login-card-header::after {
        content: "";
        position: absolute;
        top: 0;
        right: 0;
        width: 100px;
        height: 100px;
        background: radial-gradient(circle, rgba(255,255,255,0.15) 0%, transparent 70%);
        border-radius: 50%;
        transform: translate(30%, -30%);
    }

    .login-card-title {
        font-size: 22px;
        font-weight: 600;
        margin-bottom: 4px;
        position: relative;
        z-index: 1;
    }

    .login-card-subtitle {
        font-size: 14px;
        opacity: 0.95;
        position: relative;
        z-index: 1;
    }

    .login-card-body {
        padding: 28px 28px 20px 28px;
    }

    .login-card-body .form-label {
        font-size: 14px;
        color: #0f172a;
        font-weight: 500;
        margin-bottom: 8px;
        display: block;
    }

    .login-card-body .form-control {
        border-radius: 12px;
        border: 1px solid #cbd5f5;
        font-size: 15px;
        padding: 12px 16px;
        transition: all 0.3s ease;
        background-color: rgba(255, 255, 255, 0.85);
    }

    .login-card-body .form-control:focus {
        border-color: #2563eb;
        box-shadow: 0 0 0 0.2rem rgba(37, 99, 235, 0.2);
        background-color: #fff;
        transform: translateY(-1px);
    }

    .login-card-body .form-control:hover {
        border-color: #93c5fd;
    }

    .login-card-footer {
        padding: 0 28px 24px 28px;
    }

    .login-footer-text {
        font-size: 12px;
        color: #64748b;
        margin-top: 16px;
        text-align: center;
        line-height: 1.5;
    }

    .login-extra-row {
        font-size: 13px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-top: 8px;
        color: #475569;
    }

    .login-extra-row a {
        color: #1d4ed8;
        text-decoration: none;
        transition: color 0.2s ease;
    }

    .login-extra-row a:hover {
        text-decoration: underline;
        color: #0f172a;
    }

    /* 登录按钮增强 */
    .btn-login-primary {
        background: linear-gradient(130deg, #2563eb, #1d4ed8);
        border: none;
        border-radius: 12px;
        padding: 12px 0;
        font-size: 16px;
        font-weight: 500;
        box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3);
        transition: all 0.3s ease;
        position: relative;
        overflow: hidden;
    }

    .btn-login-primary::after {
        content: "";
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
        transition: left 0.6s ease;
    }

    .btn-login-primary:hover::after {
        left: 100%;
    }

    .btn-login-primary:hover {
        background: linear-gradient(130deg, #1d4ed8, #1e40af);
        box-shadow: 0 6px 16px rgba(37, 99, 235, 0.4);
        transform: translateY(-2px);
    }

    .btn-login-primary:active {
        transform: translateY(0);
        box-shadow: 0 2px 8px rgba(37, 99, 235, 0.3);
    }

    /* 错误提示框美化 */
    .alert-danger {
        border-radius: 10px;
        border: 1px solid #fecdd3;
        background-color: #fef2f2;
        color: #b91c1c;
        padding: 10px 16px;
        font-size: 14px;
        margin-bottom: 20px;
        box-shadow: 0 2px 8px rgba(185, 28, 28, 0.1);
    }

    /* 响应式优化 */
    @media (max-width: 992px) {
        .login-wrapper {
            flex-direction: column;
        }
        .login-left {
            display: none;
        }
        body {
            background: url('<%=request.getContextPath()%>/static/imag/campus-bg.jpg') center center / cover no-repeat fixed;
        }
        .login-right {
            min-height: 100vh;
            background: rgba(15, 23, 42, 0.85);
            padding: 40px 20px;
        }
        .login-card {
            max-width: 380px;
            margin: 0 auto;
            box-shadow: 0 16px 48px rgba(15, 23, 42, 0.25);
        }
    }

    @media (max-width: 576px) {
        .login-card-body {
            padding: 24px 20px 16px 20px;
        }
        .login-card-header {
            padding: 18px 20px;
        }
        .login-card-footer {
            padding: 0 20px 20px 20px;
        }
        .login-left-content {
            padding: 24px 20px;
        }
    }
</style>

<div class="login-wrapper">
    <!-- 左侧：照片 + 学校信息 -->
    <div class="login-left">
        <div class="login-left-content">
            <div class="login-left-logo">
                <img src="<%=request.getContextPath()%>/static/imag/school-logo.jpg"
                     alt="河南工业大学">
                <div>
                    <div class="login-left-school-cn">河南工业大学</div>
                    <div class="login-left-school-en">Henan University of Technology</div>
                </div>
            </div>

            <div class="login-left-title">毕业管理系统</div>
            <div class="login-left-subtitle">Graduate Management System</div>

            <div class="login-left-feature">
                <div class="login-left-feature-item">
                    支持学生、指导老师、辅导员、班主任等多角色协同完成毕业相关工作。
                </div>
                <div class="login-left-feature-item">
                    覆盖毕业设计、成绩管理、就业去向等关键业务，提供数据决策支撑。
                </div>
                <div class="login-left-feature-item">
                    安全、统一的身份认证入口，保障师生信息安全和系统稳定运行。
                </div>
            </div>

            <div class="login-left-footer">
                © 河南工业大学 教务处 / 信息化办公室<br/>
                如在使用过程中遇到问题，请联系学院系统管理员。
            </div>
        </div>
    </div>

    <!-- 右侧：蓝色主题登录卡片 -->
    <div class="login-right">
        <div class="login-card">
            <div class="login-card-header">
                <div class="login-card-title">用户登录</div>
                <div class="login-card-subtitle">
                    使用学号 / 工号登录系统，进行毕业设计、成绩与就业信息管理
                </div>
            </div>

            <div class="login-card-body">
                <c:if test="${not empty error}">
                    <div class="alert alert-danger" role="alert">
                            ${error}
                    </div>
                </c:if>

                <form method="post" action="${pageContext.request.contextPath}/login">
                    <div class="mb-4">
                        <label for="username" class="form-label">用户名（学号 / 工号）</label>
                        <input type="text"
                               class="form-control"
                               id="username"
                               name="username"
                               required autofocus
                               value="${param.username}">
                    </div>
                    <div class="mb-4">
                        <label for="password" class="form-label">密码</label>
                        <input type="password"
                               class="form-control"
                               id="password"
                               name="password"
                               required>
                    </div>

                    <button type="submit" class="btn btn-login-primary w-100 mb-2 text-white">
                        登录
                    </button>
                </form>
            </div>

            <div class="login-card-footer">
                <div class="login-extra-row">
                    <div>
                        忘记密码请联系辅导员或教务老师重置
                    </div>
                    <div>
                        还没有账号？
                        <a href="${pageContext.request.contextPath}/register">点击注册</a>
                    </div>
                </div>

                <div class="login-footer-text">
                    推荐使用 Chrome / Edge 浏览器访问以获得最佳体验。<br>
                    系统版本：v2.1.0 | 技术支持：信息化办公室
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>