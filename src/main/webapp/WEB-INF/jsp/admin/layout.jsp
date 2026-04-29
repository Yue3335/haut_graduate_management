<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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

    /* 容器布局优化 */
    .container {
        padding-top: 30px;
        padding-bottom: 50px;
        max-width: 1200px;
    }

    /* 右侧内容区域占位样式 - 科研风白色卡片 */
    .content-area {
        background-color: #ffffff;
        border: 1px solid #e8eef4;
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
        min-height: calc(100vh - 180px);
        padding: 24px;
        transition: all 0.3s ease;
    }

    .content-area:hover {
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
        border-color: #d1e0f0;
    }

    /* 响应式适配 */
    @media (max-width: 768px) {
        .content-area {
            padding: 18px;
            min-height: calc(100vh - 160px);
        }
    }
</style>

<div class="container">
    <div class="row">
        <jsp:include page="/WEB-INF/jsp/admin/sidebar.jsp"/>

        <!-- 右侧内容区域占位：由具体页面来填 -->
        <div class="col-md-9 content-area">

        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>