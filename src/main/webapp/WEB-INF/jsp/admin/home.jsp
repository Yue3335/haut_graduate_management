<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    request.setAttribute("pageTitle", "管理员首页 - 毕业管理系统");
%>

<jsp:include page="/WEB-INF/jsp/common/header.jsp"/>
<jsp:include page="/WEB-INF/jsp/common/navbar.jsp"/>

<!-- ECharts CDN，用于首页图表 -->
<script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
<!-- Font Awesome 确保图标正常显示 -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/font-awesome@4.7.0/css/font-awesome.min.css">
<!-- Bootstrap 确保样式正常 -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css">

<style>
    /* 全局样式重置与基础配置 */
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    body {
        background-color: #f9fafb;
        font-family: "Microsoft YaHei", "PingFang SC", "Helvetica Neue", sans-serif;
    }

    /* 管理员首页整体布局 */
    .admin-home-container {
        padding-top: 30px;
        padding-bottom: 40px;
        max-width: 1400px;
        margin: 0 auto;
    }

    /* 主标题样式 - 简约风格 */
    .page-title {
        color: #2d3748;
        font-weight: 600;
        font-size: 24px;
        margin-bottom: 20px !important;
        position: relative;
        padding-bottom: 10px;
        border-bottom: 1px solid #e5e7eb;
    }

    .page-title::after {
        content: "";
        position: absolute;
        left: 0;
        bottom: -1px;
        width: 80px;
        height: 2px;
        background: #4b5563;
        border-radius: 1px;
    }

    /* 描述文本样式 */
    .text-description {
        color: #4b5563;
        line-height: 1.6;
        font-size: 13px;
        margin-bottom: 12px;
    }

    /* 功能卡片核心样式 - 简约白色风格 */
    .function-card {
        border: 1px solid #e5e7eb !important;
        border-radius: 8px;
        background-color: #ffffff !important;
    }

    .function-card .card-body {
        display: flex;
        flex-direction: column;
        justify-content: center;
        min-height: 150px;
        padding: 20px !important;
    }

    /* 快捷按钮布局 */
    .shortcut-buttons {
        display: grid;
        grid-template-columns: 1fr;
        gap: 8px;
    }

    /* 图表容器样式 - 简约浅色 */
    .chart-container {
        width: 100%;
        height: 260px;
        background-color: #ffffff;
        border-radius: 8px;
        padding: 10px;
        border: 1px solid #e5e7eb;
        transition: border-color 0.2s ease;
    }

    .chart-container:hover {
        border-color: #cbd5e1;
    }

    /* 内容卡片样式 - 统一白色简约风格 */
    .content-card {
        animation: fadeIn 0.2s ease-out;
        border-radius: 8px;
        overflow: hidden;
        border: 1px solid #e5e7eb !important;
        background-color: #ffffff !important;
        margin-bottom: 20px;
    }

    /* 卡片头部 */
    .content-card .card-header {
        background-color: #ffffff !important;
        color: #111827;
        font-weight: 600;
        font-size: 14px;
        border-bottom: 1px solid #e5e7eb !important;
        padding: 10px 14px !important;
    }

    .function-card .card-header {
        background-color: #ffffff !important;
        color: #2d3748;
        border-bottom: 1px solid #e5e7eb !important;
        padding: 12px 16px !important;
    }

    .content-card .card-body {
        background-color: #ffffff !important;
        padding: 16px !important;
    }

    /* 按钮样式 - 简约扁平风格 */
    .btn-custom {
        background-color: #4b5563;
        color: #ffffff !important;
        border: none;
        border-radius: 4px;
        padding: 6px 12px;
        font-weight: 500;
        transition: background-color 0.2s ease;
    }

    .btn-custom:hover {
        background-color: #1f2937;
        color: #ffffff !important;
    }

    .btn-shortcut {
        border: 1px solid #4b5563;
        color: #4b5563 !important;
        border-radius: 4px;
        padding: 5px 10px;
        font-weight: 500;
        transition: all 0.2s ease;
    }

    .btn-shortcut:hover {
        background-color: #4b5563;
        color: #ffffff !important;
    }

    /* 提示框样式 */
    .alert-custom {
        border-radius: 8px;
        border: 1px solid #fecaca;
        background-color: #ffffff;
        color: #dc2626;
        padding: 12px 16px;
    }

    /* 左侧侧边栏容器 */
    .sidebar-col {
        display: flex;
        flex-direction: column;
        gap: 15px;
    }

    /* 淡入动画 */
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(4px); }
        to   { opacity: 1; transform: translateY(0); }
    }

    /* 响应式布局 */
    @media (max-width: 992px) {
        .sidebar-col {
            margin-bottom: 1.5rem;
        }
        .admin-home-container {
            padding-top: 20px;
            padding-bottom: 30px;
        }
    }

    @media (max-width: 768px) {
        .chart-container {
            height: 240px;
        }
        .page-title {
            font-size: 20px;
        }
        .function-card .card-body {
            min-height: 140px;
        }
    }

    @media (max-width: 576px) {
        .admin-home-container {
            padding-left: 15px;
            padding-right: 15px;
        }
        .chart-container {
            height: 220px;
        }
    }
</style>

<div class="container admin-home-container">
    <div class="row g-4">
        <!-- 左侧管理员导航 -->
        <div class="col-md-4 col-lg-3 sidebar-col">
            <jsp:include page="/WEB-INF/jsp/admin/sidebar.jsp"/>
        </div>

        <!-- 右侧内容 -->
        <div class="col-md-8 col-lg-9">
            <div class="content-wrapper" style="background-color:#ffffff;padding:25px;border-radius:8px;border:1px solid #e5e7eb;">
                <h3 class="page-title">管理员首页</h3>

                <!-- 错误提示框 -->
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-custom" role="alert">
                        <i class="fa fa-exclamation-circle me-2"></i>
                            ${errorMessage}
                    </div>
                </c:if>

                <p class="text-description">
                    欢迎使用毕业管理系统管理员后台。您可以在此对学生、指导老师和账号进行统一维护，
                    并查看各学院及各指导老师的带生情况统计。
                </p>

                <!-- 功能入口区域 -->
                <div class="row g-3">
                    <!-- 账号与密码管理卡片 -->
                    <div class="col-md-6 mb-3">
                        <div class="card function-card content-card">
                            <div class="card-header">
                                <i class="fa fa-user-cog me-2"></i>
                                账号与密码管理
                            </div>
                            <div class="card-body">
                                <p class="text-description mb-3">
                                    维护系统用户账号和密码，包括重置学生/老师登录密码，创建新的管理员账号等。
                                </p>
                                <a class="btn btn-custom btn-sm"
                                   href="${pageContext.request.contextPath}/admin/system/account">
                                    进入账号与密码管理
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- 快捷入口 -->
                    <div class="col-md-6 mb-3">
                        <div class="card function-card content-card">
                            <div class="card-header">
                                <i class="fa fa-rocket me-2"></i>
                                快捷入口
                            </div>
                            <div class="card-body">
                                <div class="shortcut-buttons">
                                    <a class="btn btn-shortcut btn-sm"
                                       href="${pageContext.request.contextPath}/admin/student/list">
                                        <i class="fa fa-user-graduate me-1"></i>
                                        学生管理
                                    </a>
                                    <a class="btn btn-shortcut btn-sm"
                                       href="${pageContext.request.contextPath}/admin/teacher/list">
                                        <i class="fa fa-chalkboard-teacher me-1"></i>
                                        指导老师管理
                                    </a>
                                    <a class="btn btn-shortcut btn-sm"
                                       href="${pageContext.request.contextPath}/admin/system/account">
                                        <i class="fa fa-cog me-1"></i>
                                        账号与密码管理
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 数据统计图表 -->
                <div class="row g-3">
                    <div class="col-12">
                        <!-- 各学院学生人数分布：饼图 -->
                        <div class="card content-card">
                            <div class="card-header">
                                <i class="fa fa-chart-pie me-2"></i>
                                各学院学生人数分布（饼图）
                            </div>
                            <div class="card-body">
                                <div class="row g-3" id="deptChartsRow">
                                    <!-- 由 JS 动态生成 -->
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-12">
                        <!-- 指导老师带生数量统计：柱状图 -->
                        <div class="card content-card">
                            <div class="card-header">
                                <i class="fa fa-chart-bar me-2"></i>
                                指导老师带生数量统计（柱状图）
                            </div>
                            <div class="card-body p-2">
                                <div id="teacherStudentChart" class="chart-container" style="height:320px;"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    // ================= 从 JSP 注入原始数据 =================
    var rawMajorData = [];
    <c:forEach var="m" items="${majorStudentCount}">
    rawMajorData.push({
        majorName: "${m.majorName}",
        deptName: "${m.deptName}",
        count: ${m.count}
    });
    </c:forEach>

    var teacherNames = [];
    var teacherCounts = [];
    <c:forEach var="t" items="${teacherStudentCount}">
    teacherNames.push("${t.teacherName}");
    teacherCounts.push(${t.count});
    </c:forEach>

    // ================= 浅色系配色：浅蓝、浅黄、浅灰 =================
    var PIE_COLORS = [
        '#bfdbfe', // 浅蓝
        '#fde68a', // 浅黄
        '#e5e7eb', // 浅灰
        '#93c5fd', // 稍深一点的浅蓝
        '#fef3c7', // 更浅的黄
        '#d1d5db'  // 稍深一点的灰
    ];

    var BAR_COLOR       = '#93c5fd';   // 浅蓝
    var BAR_BORDER      = '#60a5fa';   // 稍深浅蓝用于边框
    var GRID_LINE_COLOR = '#e5e7eb';   // 浅灰

    // ================= 按学院分组数据 =================
    var deptMap = {};
    rawMajorData.forEach(function(item) {
        var dept = item.deptName || '未分配学院';
        if (!deptMap[dept]) {
            deptMap[dept] = {
                total: 0,
                majors: []
            };
        }
        deptMap[dept].majors.push({
            name: item.majorName,
            value: item.count
        });
        deptMap[dept].total += item.count;
    });

    // ================= 为每个学院生成一个浅色饼图 =================
    (function renderDeptCharts() {
        var row = document.getElementById('deptChartsRow');
        if (!row) return;

        var deptNames = Object.keys(deptMap);
        if (deptNames.length === 0) {
            row.innerHTML =
                '<div class="col-12 text-muted small" style="padding: 20px; text-align: center;">暂无学生数据。</div>';
            return;
        }

        deptNames.forEach(function(deptName, idx) {
            var chartId = 'deptChart_' + idx;

            var col = document.createElement('div');
            col.className = 'col-lg-4 col-md-6 mb-3';

            col.innerHTML =
                '<div class="card h-100" style="border-radius: 8px; border: 1px solid #e5e7eb;">' +
                '  <div class="card-header py-2" style="background-color:#ffffff;border-bottom:1px solid #e5e7eb;color:#111827;font-weight:600;font-size:13px;padding:8px 10px;display:flex;justify-content:space-between;align-items:center;">' +
                '    <span>' + deptName + '</span>' +
                '    <span style="font-size:11px;color:#6b7280;">总人数：' + deptMap[deptName].total + '</span>' +
                '  </div>' +
                '  <div class="card-body p-2" style="background-color:#ffffff;">' +
                '    <div id="' + chartId + '" class="chart-container" style="height:230px;"></div>' +
                '  </div>' +
                '</div>';

            row.appendChild(col);

            var dom = document.getElementById(chartId);
            if (!dom) return;

            var chart = echarts.init(dom);
            var data = deptMap[deptName].majors;

            var option = {
                backgroundColor: 'transparent',
                tooltip: {
                    trigger: 'item',
                    textStyle: { fontSize: 11 },
                    formatter: function (p) {
                        return deptName + '<br/>' +
                            p.name + '：' + p.value + ' 人（' + p.percent + '%）';
                    },
                    backgroundColor: 'rgba(255,255,255,0.96)',
                    borderColor: '#e5e7eb',
                    borderWidth: 1,
                    padding: 8,
                    borderRadius: 4
                },
                legend: {
                    bottom: 0,
                    left: 'center',
                    textStyle: { fontSize: 11, color: '#4b5563' },
                    itemGap: 4,
                    itemWidth: 10,
                    itemHeight: 10
                },
                color: PIE_COLORS,
                series: [
                    {
                        name: deptName,
                        type: 'pie',
                        radius: '65%',
                        center: ['50%', '45%'],
                        avoidLabelOverlap: true,
                        itemStyle: {
                            borderRadius: 4,
                            borderColor: '#ffffff',
                            borderWidth: 1
                        },
                        label: {
                            show: false
                        },
                        labelLine: {
                            show: false
                        },
                        emphasis: {
                            scale: true,
                            scaleSize: 3,
                            label: {
                                show: true,
                                fontSize: 11,
                                formatter: '{b}\n{c}人'
                            }
                        },
                        data: data
                    }
                ]
            };

            chart.setOption(option);
            window.addEventListener('resize', function () {
                chart.resize();
            });
        });
    })();

    // ================= 指导老师带生数量统计图表（浅色柱状图 + 平均值辅助线） =================
    (function () {
        var dom = document.getElementById('teacherStudentChart');
        if (!dom) return;
        var chart = echarts.init(dom);

        // 计算平均值，用于辅助线
        var sum = 0;
        var validCount = 0;
        teacherCounts.forEach(function (v) {
            if (typeof v === 'number') {
                sum += v;
                validCount++;
            }
        });
        var avg = validCount > 0 ? sum / validCount : 0;

        var option = {
            backgroundColor: 'transparent',
            tooltip: {
                trigger: 'axis',
                axisPointer: {
                    type: 'shadow',
                    shadowStyle: { color: 'rgba(148, 163, 184, 0.14)' }
                },
                textStyle: { fontSize: 11 },
                backgroundColor: 'rgba(255,255,255,0.96)',
                borderColor: '#e5e7eb',
                borderWidth: 1,
                padding: 8,
                borderRadius: 4,
                formatter: function (p) {
                    var d = p[0];
                    return d.name + '<br/>带生数量：' + d.value + ' 人';
                }
            },
            grid: {
                left: '4%',
                right: '4%',
                bottom: '18%',
                top: '8%',
                containLabel: true
            },
            xAxis: {
                type: 'category',
                data: teacherNames,
                axisLine: { lineStyle: { color: GRID_LINE_COLOR } },
                axisTick: { alignWithLabel: true },
                axisLabel: {
                    interval: 0,
                    rotate: 30,
                    fontSize: 11,
                    color: '#4b5563',
                    margin: 8
                }
            },
            yAxis: {
                type: 'value',
                name: '带生人数',
                nameTextStyle: {
                    fontSize: 11,
                    color: '#4b5563',
                    padding: [0, 0, 4, 0]
                },
                splitLine: { lineStyle: { color: GRID_LINE_COLOR } },
                axisLine: { show: false },
                axisTick: { show: false },
                axisLabel: { fontSize: 11, color: '#4b5563' },
                min: 0
            },
            series: [
                {
                    name: '带生数量',
                    type: 'bar',
                    data: teacherCounts,
                    barWidth: '55%',
                    itemStyle: {
                        color: BAR_COLOR,
                        borderColor: BAR_BORDER,
                        borderWidth: 1,
                        borderRadius: [4, 4, 0, 0]
                    },
                    markLine: {
                        symbol: 'none',
                        lineStyle: {
                            type: 'dashed',
                            color: '#9ca3af'
                        },
                        label: {
                            show: true,
                            formatter: function () {
                                return '平均值 ' + (avg.toFixed ? avg.toFixed(1) : avg);
                            },
                            fontSize: 11,
                            color: '#6b7280'
                        },
                        data: [
                            { yAxis: avg }
                        ]
                    }
                }
            ]
        };

        chart.setOption(option);
        window.addEventListener('resize', function () {
            chart.resize();
        });
    })();
</script>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>