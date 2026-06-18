<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!-- 通用底部组件 - 科研风格统一 -->
<style>
    /* 页脚样式 - 白色基调+科研风格 */
    footer {
        background-color: #f8fafc;
        border-top: 1px solid #e8eef4;
        padding: 20px 0;
        margin-top: 40px;
        font-size: 14px;
        color: #718096;
    }

    .footer-container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 0 20px;
        text-align: center;
    }

    .footer-text {
        line-height: 1.6;
    }

    /* 响应式适配 */
    @media (max-width: 576px) {
        footer {
            padding: 15px 0;
            font-size: 13px;
        }
    }
</style>

<!-- 引入Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>

<!-- 引入自定义JS -->
<script src="${pageContext.request.contextPath}/static/js/main.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/theme-toggle.js" defer></script>

<!-- 统一页脚 -->
<footer>
    <div class="footer-container">
        <p class="footer-text mb-0">
            © ${pageContext['request'].getAttribute('currentYear') != null ? pageContext['request'].getAttribute('currentYear') : 2025} 科研管理系统 | 管理员后台
        </p>
    </div>
</footer>

</body>
</html>
