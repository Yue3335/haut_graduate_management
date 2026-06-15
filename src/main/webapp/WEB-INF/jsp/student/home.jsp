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

    .empty-info-tip {
        color: #718096;
        font-size: 14px;
        line-height: 1.6;
        margin: 0;
    }

    .chart-card {
        border: 1px solid #e8eef4;
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
        overflow: hidden;
        margin-bottom: 20px;
        background: #ffffff;
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
        height: 300px;
    }

    .gpa-explain {
        font-size: 12px;
        color: #64748b;
        line-height: 1.7;
        padding: 0 4px 6px;
        margin-top: 4px;
    }

    @media (max-width: 992px) {
        .info-card-body {
            padding: 16px;
        }

        .chart-container {
            height: 280px;
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

        .chart-container {
            height: 260px;
        }
    }
</style>

<div class="container">
    <div class="row">
        <jsp:include page="/WEB-INF/jsp/student/sidebar.jsp"/>

        <div class="col-md-9">
            <h3 class="page-title">学生首页</h3>

            <c:if test="${empty student}">
                <div class="warning-alert">
                    未找到学生档案信息，请联系管理员。
                </div>
            </c:if>

            <c:if test="${not empty student}">
                <div class="row">
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
                                <small>根据最新成绩动态计算</small>
                            </div>

                            <div class="chart-card-body">
                                <div id="gpaLineChart" class="chart-container"></div>

                                <c:if test="${(empty gpaTermList or empty gpaValueList) and empty gpaByTerm}">
                                    <p class="empty-info-tip mt-2">暂未查询到 GPA 数据，无法生成折线图。</p>
                                </c:if>

                                <c:if test="${not ((empty gpaTermList or empty gpaValueList) and empty gpaByTerm)}">
                                    <div class="gpa-explain">
                                        绩点计算方式：课程绩点 = (成绩 - 50) / 10，60 分以下为 0，最高不超过 5.0。
                                        每学期 GPA = Σ（课程绩点 × 学分） / Σ 学分。
                                    </div>
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
    var radarCourseNames = [];
    var radarScores = [];

    <c:if test="${not empty radarData}">
    <c:forEach var="entry" items="${radarData}">
    radarCourseNames.push("${entry.key}");
    radarScores.push(${entry.value});
    </c:forEach>
    </c:if>

    /*
     * GPA 数据兼容两种后端传法：
     * 1. 新写法：gpaTermList + gpaValueList
     * 2. 旧写法：gpaByTerm
     */
    var gpaTerms = [];
    var gpaValues = [];

    <c:choose>
    <c:when test="${not empty gpaTermList and not empty gpaValueList}">
    <c:forEach var="term" items="${gpaTermList}" varStatus="s">
    gpaTerms.push("${term}");
    <c:choose>
    <c:when test="${gpaValueList[s.index] != null}">
    gpaValues.push(${gpaValueList[s.index]});
    </c:when>
    <c:otherwise>
    gpaValues.push(null);
    </c:otherwise>
    </c:choose>
    </c:forEach>
    </c:when>

    <c:when test="${not empty gpaByTerm}">
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
    </c:when>
    </c:choose>

    (function () {
        var dom = document.getElementById('courseRadarChart');

        if (!dom || radarCourseNames.length === 0) {
            return;
        }

        var chart = echarts.init(dom);

        var maxScore = 0;
        for (var i = 0; i < radarScores.length; i++) {
            if (radarScores[i] > maxScore) {
                maxScore = radarScores[i];
            }
        }

        var radarMax = Math.max(60, Math.ceil(maxScore / 10) * 10);

        var indicators = [];
        for (var j = 0; j < radarCourseNames.length; j++) {
            indicators.push({
                name: radarCourseNames[j],
                max: radarMax
            });
        }

        var option = {
            tooltip: {
                trigger: 'item',
                backgroundColor: 'rgba(15, 23, 42, 0.92)',
                borderWidth: 0,
                textStyle: {
                    color: '#ffffff',
                    fontSize: 13
                }
            },

            radar: {
                indicator: indicators,
                radius: '65%',
                splitNumber: 5,
                splitLine: {
                    lineStyle: {
                        color: '#e5e7eb'
                    }
                },
                splitArea: {
                    areaStyle: {
                        color: ['#ffffff', '#f9fafb']
                    }
                },
                axisLine: {
                    lineStyle: {
                        color: '#e5e7eb'
                    }
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

    (function () {
        var dom = document.getElementById('gpaLineChart');

        if (!dom || gpaTerms.length === 0) {
            return;
        }

        var chart = echarts.init(dom);

        var option = {
            tooltip: {
                trigger: 'axis',
                backgroundColor: 'rgba(15, 23, 42, 0.92)',
                borderWidth: 0,
                padding: 10,
                textStyle: {
                    color: '#ffffff',
                    fontSize: 13
                },
                formatter: function (params) {
                    var p = params[0];

                    if (p.value == null) {
                        return p.name + '<br/>GPA：暂无';
                    }

                    return p.name + '<br/>GPA：' + Number(p.value).toFixed(2);
                }
            },

            grid: {
                left: '6%',
                right: '5%',
                bottom: '12%',
                top: '12%',
                containLabel: true
            },

            xAxis: {
                type: 'category',
                boundaryGap: false,
                data: gpaTerms,
                axisLine: {
                    lineStyle: {
                        color: '#cbd5e1'
                    }
                },
                axisTick: {
                    show: false
                },
                axisLabel: {
                    fontSize: 11,
                    color: '#4b5563',
                    rotate: gpaTerms.length > 5 ? 25 : 0
                }
            },

            yAxis: {
                type: 'value',
                name: 'GPA',
                min: 0,
                max: 5,
                interval: 1,
                splitLine: {
                    lineStyle: {
                        color: '#e5e7eb',
                        type: 'dashed'
                    }
                },
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
                symbolSize: 8,
                lineStyle: {
                    width: 4,
                    color: '#2563eb'
                },
                itemStyle: {
                    color: '#2563eb',
                    borderColor: '#ffffff',
                    borderWidth: 2
                },
                areaStyle: {
                    color: {
                        type: 'linear',
                        x: 0,
                        y: 0,
                        x2: 0,
                        y2: 1,
                        colorStops: [
                            {
                                offset: 0,
                                color: 'rgba(37, 99, 235, 0.24)'
                            },
                            {
                                offset: 1,
                                color: 'rgba(37, 99, 235, 0.02)'
                            }
                        ]
                    }
                },
                label: {
                    show: true,
                    position: 'top',
                    color: '#1e3a8a',
                    fontSize: 11,
                    formatter: function (params) {
                        if (params.value == null) {
                            return '';
                        }

                        return Number(params.value).toFixed(2);
                    }
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