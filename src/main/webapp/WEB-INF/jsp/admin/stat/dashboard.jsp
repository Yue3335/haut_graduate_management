<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head>
  <title>统计仪表盘 - 管理员后台</title>
  <script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
  <style>
    /* 全局样式 - 白色基调+科研风格 */
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: "Microsoft YaHei", "PingFang SC", "Helvetica Neue", Arial, sans-serif;
      background-color: #ffffff;
      color: #333647;
      padding: 0;
      margin: 0;
    }

    /* 页面容器 */
    .page-container {
      max-width: 1400px;
      margin: 0 auto;
      padding: 30px 20px;
    }

    /* 标题样式 */
    .main-title {
      color: #2d3748;
      font-weight: 600;
      font-size: 24px;
      margin-bottom: 30px !important;
      position: relative;
      padding-bottom: 12px;
      border-bottom: 1px solid #f0f2f5;
    }

    .main-title::after {
      content: "";
      position: absolute;
      left: 0;
      bottom: -1px;
      width: 80px;
      height: 2px;
      background: #2c5282;
      border-radius: 1px;
    }

    .section-title {
      color: #2c5282;
      font-weight: 500;
      font-size: 18px;
      margin: 40px 0 20px 0;
      display: flex;
      align-items: center;
    }

    .section-title::before {
      content: "";
      display: inline-block;
      width: 4px;
      height: 20px;
      background-color: #3182ce;
      border-radius: 2px;
      margin-right: 10px;
    }

    /* 错误提示样式 */
    .error-tip {
      color: #e53e3e;
      font-size: 14px;
      padding: 12px 16px;
      background-color: #fff5f5;
      border: 1px solid #feb2b2;
      border-radius: 8px;
      margin-bottom: 20px;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.02);
    }

    /* 图表布局样式 */
    .chart-row {
      width: 100%;
      display: flex;
      flex-wrap: wrap;
      gap: 24px;
      margin-bottom: 20px;
    }

    .chart-card {
      flex: 1;
      min-width: 400px;
      background-color: #ffffff;
      border: 1px solid #e8eef4;
      border-radius: 12px;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
      padding: 20px;
      transition: all 0.3s ease;
    }

    .chart-card:hover {
      box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
      border-color: #d1e0f0;
    }

    .chart-card-title {
      font-size: 15px;
      font-weight: 500;
      color: #2d3748;
      margin-bottom: 15px;
      padding-bottom: 8px;
      border-bottom: 1px solid #f0f2f5;
    }

    .chart-container {
      width: 100%;
      height: 380px;
    }

    .chart-row-single {
      width: 100%;
      margin-top: 20px;
    }

    .single-chart-card {
      width: 100%;
      background-color: #ffffff;
      border: 1px solid #e8eef4;
      border-radius: 12px;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
      padding: 20px;
      transition: all 0.3s ease;
    }

    .single-chart-card:hover {
      box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
      border-color: #d1e0f0;
    }

    .single-chart-container {
      width: 100%;
      height: 450px;
    }

    /* 空数据提示 */
    .empty-chart-tip {
      color: #718096;
      font-size: 14px;
      text-align: center;
      padding: 80px 20px;
      height: 100%;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    /* 响应式适配 */
    @media (max-width: 992px) {
      .chart-card {
        min-width: 100%;
      }
      .chart-container {
        height: 320px;
      }
      .single-chart-container {
        height: 380px;
      }
    }

    @media (max-width: 576px) {
      .main-title {
        font-size: 20px;
      }
      .section-title {
        font-size: 16px;
      }
      .chart-container {
        height: 280px;
      }
      .single-chart-container {
        height: 320px;
      }
    }
  </style>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/admin/layout.jsp" />

<div class="page-container">
  <h1 class="main-title">统计仪表盘</h1>

  <c:if test="${not empty errorMessage}">
    <div class="error-tip">${errorMessage}</div>
  </c:if>

  <!-- 1. 各学院-各专业学生人数图表（每个学院一张图） -->
  <h2 class="section-title">各学院各专业学生人数分布</h2>
  <div class="chart-row" id="deptChartsContainer">
    <!-- 图表容器将由 JS 动态创建 -->
  </div>

  <hr style="border: none; border-top: 1px solid #f0f2f5; margin: 40px 0;"/>

  <!-- 2. 指导老师对应学生人数图表（单独一行展示） -->
  <h2 class="section-title">指导老师对应学生人数</h2>
  <div class="chart-row-single">
    <div class="single-chart-card">
      <div id="supervisorChart" class="single-chart-container"></div>
    </div>
  </div>
</div>

<script type="text/javascript">
  // 后端传来的 JSON 字符串（已是合法 JSON）
  var deptCharts = ${deptChartsJson};
  var supervisorChart = ${supervisorChartJson};

  // 科研风格配色方案
  var scienceColors = [
    'rgba(135,139,255,0.97)', '#ffda31', '#03baed', '#ed8936',
    '#9f7aea', '#4299e1', '#805ad5', '#38b2ac'
  ];

  // 1) 各学院-专业图表：一院一图
  (function initDeptCharts() {
    var container = document.getElementById("deptChartsContainer");

    // 清空容器
    container.innerHTML = "";

    if (!deptCharts || Object.keys(deptCharts).length === 0) {
      container.innerHTML = '<div class="empty-chart-tip">当前没有学院/专业学生数据。</div>';
      return;
    }

    Object.keys(deptCharts).forEach(function (deptId, index) {
      var data = deptCharts[deptId];
      var deptName = data.deptName;
      var majorNames  = data.majorNames || [];
      var majorCounts = data.majorCounts || [];

      // 创建图表卡片容器
      var chartCard = document.createElement("div");
      chartCard.className = "chart-card";

      // 创建卡片标题
      var cardTitle = document.createElement("div");
      cardTitle.className = "chart-card-title";
      cardTitle.innerText = deptName + " 各专业学生人数分布";
      chartCard.appendChild(cardTitle);

      // 创建图表DOM容器
      var chartDiv = document.createElement("div");
      chartDiv.id = "chart_dept_" + deptId;
      chartDiv.className = "chart-container";

      // 空数据处理
      if (!majorNames || majorNames.length === 0) {
        chartDiv.innerHTML = '<div class="empty-chart-tip">该学院暂无专业学生数据</div>';
        chartCard.appendChild(chartDiv);
        container.appendChild(chartCard);
        return;
      }

      chartCard.appendChild(chartDiv);
      container.appendChild(chartCard);

      // 初始化ECharts - 科研风格柱状图
      var chart = echarts.init(chartDiv);

      // 动态分配颜色
      var color = scienceColors[index % scienceColors.length];

      var option = {
        backgroundColor: 'transparent',
        title: {
          show: false
        },
        tooltip: {
          trigger: 'axis',
          textStyle: { fontSize: 12 },
          backgroundColor: 'rgba(255,255,255,0.95)',
          borderColor: '#e8eef4',
          borderWidth: 1,
          padding: 10,
          boxShadow: '0 2px 6px rgba(0,0,0,0.05)',
          formatter: '{b}<br/>人数：{c} 人'
        },
        grid: {
          left: '4%',
          right: '4%',
          bottom: '12%',
          top: '5%',
          containLabel: true
        },
        xAxis: {
          type: 'category',
          data: majorNames,
          axisLine: {
            lineStyle: { color: '#e8eef4' }
          },
          axisTick: {
            alignWithLabel: true,
            lineStyle: { color: '#e8eef4' }
          },
          axisLabel: {
            interval: 0,
            rotate: 30,
            fontSize: 11,
            color: '#4a5568',
            margin: 8
          }
        },
        yAxis: {
          type: 'value',
          name: '学生人数',
          nameTextStyle: {
            fontSize: 12,
            color: '#4a5568',
            padding: [0, 0, 5, 0]
          },
          axisLine: {
            show: false
          },
          axisTick: {
            show: false
          },
          splitLine: {
            lineStyle: { color: '#f0f2f5' }
          },
          axisLabel: {
            fontSize: 11,
            color: '#4a5568'
          },
          min: 0
        },
        series: [{
          name: '学生人数',
          type: 'bar',
          data: majorCounts,
          barWidth: '45%',
          itemStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
              {offset: 0, color: color},
              {offset: 1, color: color.replace(')', ', 0.8)').replace('rgb', 'rgba')}
            ]),
            borderRadius: [4, 4, 0, 0],
            barBorderRadius: [4, 4, 0, 0]
          },
          emphasis: {
            itemStyle: {
              shadowBlur: 6,
              shadowColor: 'rgba(0,0,0,0.1)'
            }
          }
        }]
      };

      chart.setOption(option);

      // 自适应窗口变化
      window.addEventListener('resize', function() {
        chart.resize();
      });
    });
  })();

  // 2) 指导老师-学生数 图表（单独一行）
  (function initSupervisorChart() {
    var dom = document.getElementById("supervisorChart");

    if (!supervisorChart || !supervisorChart.teacherNames || supervisorChart.teacherNames.length === 0) {
      dom.innerHTML = '<div class="empty-chart-tip">当前没有指导老师学生数据。</div>';
      return;
    }

    var teacherNames  = supervisorChart.teacherNames;
    var studentCounts = supervisorChart.studentCounts;

    var chart = echarts.init(dom);

    var option = {
      backgroundColor: 'transparent',
      title: {
        show: false
      },
      tooltip: {
        trigger: 'axis',
        textStyle: { fontSize: 12 },
        backgroundColor: 'rgba(255,255,255,0.95)',
        borderColor: '#e8eef4',
        borderWidth: 1,
        padding: 10,
        boxShadow: '0 2px 6px rgba(0,0,0,0.05)',
        formatter: '{b}<br/>带生数量：{c} 人'
      },
      grid: {
        left: '4%',
        right: '4%',
        bottom: '18%',
        top: '5%',
        containLabel: true
      },
      xAxis: {
        type: 'category',
        data: teacherNames,
        axisLine: {
          lineStyle: { color: '#e8eef4' }
        },
        axisTick: {
          alignWithLabel: true,
          lineStyle: { color: '#e8eef4' }
        },
        axisLabel: {
          rotate: 45,
          interval: 0,
          fontSize: 11,
          color: '#4a5568',
          margin: 8
        }
      },
      yAxis: {
        type: 'value',
        name: '学生人数',
        nameTextStyle: {
          fontSize: 12,
          color: '#4a5568',
          padding: [0, 0, 5, 0]
        },
        axisLine: {
          show: false
        },
        axisTick: {
          show: false
        },
        splitLine: {
          lineStyle: { color: '#f0f2f5' }
        },
        axisLabel: {
          fontSize: 11,
          color: '#4a5568'
        },
        min: 0
      },
      series: [{
        name: '学生人数',
        type: 'bar',
        data: studentCounts,
        barWidth: '40%',
        itemStyle: {
          color: function(params) {
            return scienceColors[params.dataIndex % scienceColors.length];
          },
          borderRadius: [4, 4, 0, 0],
          barBorderRadius: [4, 4, 0, 0]
        },
        emphasis: {
          itemStyle: {
            shadowBlur: 8,
            shadowColor: 'rgba(0,0,0,0.1)'
          }
        }
      }]
    };

    chart.setOption(option);

    // 自适应窗口变化
    window.addEventListener('resize', function() {
      chart.resize();
    });
  })();
</script>

</body>
</html>