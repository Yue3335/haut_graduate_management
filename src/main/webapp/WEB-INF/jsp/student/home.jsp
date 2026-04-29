<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    request.setAttribute("pageTitle", "学生首页 - 毕业管理系统");
%>

<jsp:include page="/WEB-INF/jsp/common/header.jsp"/>
<jsp:include page="/WEB-INF/jsp/common/navbar.jsp"/>

<!-- 引入 ECharts -->
<script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>

<style>
    /* 学生首页专属样式 - 科研风格统一 */
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

    /* 警告提示样式 */
    .warning-alert {
        background-color: #fef7fb;
        border: 1px solid #ed8936;
        color: #744210;
        border-radius: 8px;
        padding: 12px 16px;
        font-size: 14px;
        margin-bottom: 24px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.02);
    }

    /* 信息卡片样式 - 科研风 */
    .info-card {
        border: 1px solid #e8eef4;
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
        overflow: hidden;
        transition: all 0.3s ease;
        height: 100%;
    }

    .info-card:hover {
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
        border-color: #d1e0f0;
    }

    .info-card-header {
        background-color: #f8fafc;
        border-bottom: 1px solid #e8eef4;
        color: #2c5282;
        padding: 14px 20px;
        font-weight: 500;
        font-size: 15px;
        display: flex;
        align-items: center;
    }

    .info-card-header::before {
        content: "";
        display: inline-block;
        width: 4px;
        height: 18px;
        background-color: #3182ce;
        border-radius: 2px;
        margin-right: 10px;
    }

    .info-card-body {
        padding: 20px;
        color: #4a5568;
        font-size: 14px;
    }

    .info-card-body p {
        margin-bottom: 12px;
        line-height: 1.6;
    }

    .info-card-body strong {
        color: #2d3748;
        min-width: 60px;
        display: inline-block;
    }

    /* 空数据提示 */
    .empty-info-tip {
        color: #718096;
        font-size: 14px;
        line-height: 1.6;
        margin: 0;
    }

    /* 图表卡片 */
    .chart-card {
        border: 1px solid #e8eef4;
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
        overflow: hidden;
        margin-bottom: 20px;
    }

    .chart-card-header {
        background-color: #f8fafc;
        border-bottom: 1px solid #e8eef4;
        color: #2c5282;
        padding: 12px 18px;
        font-weight: 500;
        font-size: 14px;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }

    .chart-card-header small {
        font-size: 12px;
        color: #6b7280;
    }

    .chart-card-body {
        background-color: #ffffff;
        padding: 12px;
    }

    .chart-container {
        width: 100%;
        height: 260px;
    }

    /* 响应式适配 */
    @media (max-width: 992px) {
        .info-card-body {
            padding: 16px;
        }
        .chart-container {
            height: 240px;
        }
    }

    @media (max-width: 576px) {
        .page-title {
            font-size: 20px;
        }
        .info-card-header {
            padding: 12px 16px;
            font-size: 14px;
        }
        .info-card-body {
            padding: 14px;
            font-size: 13px;
        }
        .chart-card-header {
            padding: 10px 14px;
        }
    }
</style>

<div class="container">
    <div class="row">
        <!-- 左侧学生导航 -->
        <jsp:include page="/WEB-INF/jsp/student/sidebar.jsp"/>

        <!-- 右侧主要内容 -->
        <div class="col-md-9">
            <h3 class="page-title">学生首页</h3>

            <c:if test="${empty student}">
                <div class="warning-alert">
                    未找到学生档案信息，请联系管理员。
                </div>
            </c:if>

            <c:if test="${not empty student}">
                <div class="row">
                    <!-- 基本信息 -->
                    <div class="col-lg-6 mb-4">
                        <div class="card info-card">
                            <div class="info-card-header">基本信息</div>
                            <div class="info-card-body">
                                <p><strong>姓名：</strong> ${sessionScope.currentUser.realName}</p>
                                <p><strong>学号：</strong> ${student.studentNo}</p>
                                <p><strong>学院：</strong> ${student.deptName}</p>
                                <p><strong>专业：</strong> ${student.majorName}</p>
                                <p><strong>班级：</strong> ${student.className}</p>
                                <p><strong>入学年份：</strong> ${student.enrollYear}</p>
                            </div>
                        </div>
                    </div>

                    <!-- 班主任信息 -->
                    <div class="col-lg-6 mb-4">
                        <div class="card info-card">
                            <div class="info-card-header">班主任信息</div>
                            <div class="info-card-body">
                                <c:if test="${empty classInfo or empty classInfo.classTeacherName}">
                                    <p class="empty-info-tip">暂未设置班主任。</p>
                                </c:if>
                                <c:if test="${not empty classInfo and not empty classInfo.classTeacherName}">
                                    <p><strong>班主任：</strong> ${classInfo.classTeacherName}</p>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 学习概况：雷达图 + GPA 折线图 -->
                <div class="row">
                    <div class="col-lg-6 mb-4">
                        <div class="chart-card">
                            <div class="chart-card-header">
                                <span>课程成绩雷达图</span>
                                <small>展示主要课程的平均分</small>
                            </div>
                            <div class="chart-card-body">
                                <div id="courseRadarChart" class="chart-container"></div>
                                <c:if test="${empty radarData}">
                                    <p class="empty-info-tip mt-2">暂未查询到课程成绩，无法生成雷达图。</p>
                                </c:if>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-6 mb-4">
                        <div class="chart-card">
                            <div class="chart-card-header">
                                <span>GPA 走势折线图</span>
                                <small>展示最近四个学期的 GPA 变化</small>
                            </div>
                            <div class="chart-card-body">
                                <div id="gpaLineChart" class="chart-container"></div>
                                <c:if test="${empty gpaByTerm}">
                                    <p class="empty-info-tip mt-2">暂未查询到 GPA 数据，无法生成折线图。</p>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>

            </c:if>
        </div>
    </div>
</div>

<script type="text/javascript">
    // 从 JSP 注入雷达图数据
    var radarCourseNames = [];
    var radarScores = [];
    <c:if test="${not empty radarData}">
    <c:forEach var="entry" items="${radarData}">
    radarCourseNames.push("${entry.key}");
    radarScores.push(${entry.value});
    </c:forEach>
    </c:if>

    // GPA 折线图数据
    var gpaTerms = [];
    var gpaValues = [];
    <c:if test="${not empty gpaByTerm}">
    <c:forEach var="entry" items="${gpaByTerm}">
    gpaTerms.push("${entry.key}");
    <c:choose>
    <c:when test="${entry.value != null}">
    gpaValues.push(${entry.value});
    </c:when>
    <c:otherwise>
    gpaValues.push(null);
    </c:otherwise>
    </c:choose>
    </c:forEach>
    </c:if>

    // 初始化雷达图
    (function () {
        var dom = document.getElementById('courseRadarChart');
        if (!dom || radarCourseNames.length === 0) return;

        var chart = echarts.init(dom);

        // 计算最大刻度（取最大分数向上取整到10的倍数）
        var maxScore = 0;
        for (var i = 0; i < radarScores.length; i++) {
            if (radarScores[i] > maxScore) {
                maxScore = radarScores[i];
            }
        }
        var radarMax = Math.max(60, Math.ceil(maxScore / 10) * 10); // 至少 60

        var indicators = [];
        for (var j = 0; j < radarCourseNames.length; j++) {
            indicators.push({ name: radarCourseNames[j], max: radarMax });
        }

        var option = {
            tooltip: {
                trigger: 'item'
            },
            radar: {
                indicator: indicators,
                radius: '65%',
                splitNumber: 5,
                splitLine: {
                    lineStyle: { color: '#e5e7eb' }
                },
                splitArea: {
                    areaStyle: { color: ['#ffffff', '#f9fafb'] }
                },
                axisLine: {
                    lineStyle: { color: '#e5e7eb' }
                },
                name: {
                    textStyle: {
                        color: '#374151',
                        fontSize: 11
                    }
                }
            },
            series: [{
                type: 'radar',
                data: [{
                    value: radarScores,
                    name: '平均成绩',
                    areaStyle: {
                        color: 'rgba(37, 99, 235, 0.25)'
                    },
                    lineStyle: {
                        color: '#2563eb',
                        width: 2
                    },
                    symbol: 'circle',
                    symbolSize: 4,
                    itemStyle: {
                        color: '#2563eb'
                    }
                }]
            }]
        };

        chart.setOption(option);
        window.addEventListener('resize', function () {
            chart.resize();
        });
    })();

    // 初始化 GPA 折线图
    (function () {
        var dom = document.getElementById('gpaLineChart');
        if (!dom || gpaTerms.length === 0) return;

        var chart = echarts.init(dom);

        var option = {
            tooltip: {
                trigger: 'axis',
                formatter: function (params) {
                    var p = params[0];
                    if (p.value == null) {
                        return p.name + '<br/>暂未计算 GPA';
                    }
                    return p.name + '<br/>GPA：' + p.value.toFixed(2);
                },
                backgroundColor: 'rgba(255,255,255,0.95)',
                borderColor: '#e5e7eb',
                borderWidth: 1,
                padding: 10
            },
            grid: {
                left: '6%',
                right: '4%',
                bottom: '10%',
                top: '10%',
                containLabel: true
            },
            xAxis: {
                type: 'category',
                data: gpaTerms,
                axisLine: { lineStyle: { color: '#d1d5db' } },
                axisTick: { alignWithLabel: true },
                axisLabel: {
                    fontSize: 11,
                    color: '#4b5563'
                }
            },
            yAxis: {
                type: 'value',
                name: 'GPA',
                min: 0,
                max: 4.5,
                splitLine: { lineStyle: { color: '#e5e7eb' } },
                axisLabel: {
                    fontSize: 11,
                    color: '#4b5563'
                },
                nameTextStyle: {
                    fontSize: 12,
                    color: '#4b5563',
                    padding: [0, 0, 6, 0]
                }
            },
            series: [{
                name: 'GPA',
                type: 'line',
                data: gpaValues,
                connectNulls: false,
                smooth: true,
                symbol: 'circle',
                symbolSize: 5,
                itemStyle: {
                    color: '#2563eb'
                },
                lineStyle: {
                    width: 2,
                    color: '#2563eb'
                },
                areaStyle: {
                    color: 'rgba(37, 99, 235, 0.12)'
                }
            }]
        };

        chart.setOption(option);
        window.addEventListener('resize', function () {
            chart.resize();
        });
    })();
</script>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>