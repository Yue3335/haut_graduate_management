<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>${pageTitle != null ? pageTitle : "毕业管理系统 - 管理平台"}</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="毕业管理系统 - 指导关系管理平台">
    <meta name="author" content="Admin">

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">

    <!-- 自定义样式 - 科研风格基础样式 -->
    <style>
        /* 全局重置与基础样式 - 白色基调+科研风格 */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: "Microsoft YaHei", "PingFang SC", "Helvetica Neue", Arial, sans-serif;
            background-color: #ffffff !important; /* 统一白色基调 */
            color: #333647;
            line-height: 1.6;
        }

        /* 全局链接样式 */
        a {
            color: rgb(7, 112, 255);
            text-decoration: none;
            transition: all 0.2s ease;
        }

        a:hover {
            color: rgb(0, 89, 214);
            text-decoration: none;
        }

        /* 全局滚动条样式 - 科研风格极简设计 */
        ::-webkit-scrollbar {
            width: 8px;
            height: 8px;
        }

        ::-webkit-scrollbar-track {
            background: #f8fafc;
            border-radius: 4px;
        }

        ::-webkit-scrollbar-thumb {
            background: #e2e8f0;
            border-radius: 4px;
        }

        ::-webkit-scrollbar-thumb:hover {
            background: #cbd5e1;
        }

        /* 通用容器样式 */
        .container {
            max-width: 1200px;
        }

        /* 响应式优化 */
        @media (max-width: 768px) {
            body {
                font-size: 14px;
            }
        }
    </style>

    <!-- 引入自定义CSS（优先级高于基础样式） -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/custom.css">

    <!-- 引入 GitHub-like 主题 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/github-like.css">
</head>
<body>
