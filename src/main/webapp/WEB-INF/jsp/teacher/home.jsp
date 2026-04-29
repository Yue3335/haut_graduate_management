<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
  request.setAttribute("pageTitle", "教师首页 - 毕业管理系统");
%>

<jsp:include page="/WEB-INF/jsp/common/header.jsp"/>
<jsp:include page="/WEB-INF/jsp/common/navbar.jsp"/>

<!-- ECharts CDN，用于就业情况大屏 -->
<script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>

<style>
  /* 页面标题样式 - 统一科研风格 */
  .page-title {
    color: #2d3748;
    font-weight: 600;
    font-size: 22px;
    margin-bottom: 24px !important;
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

  /* 卡片通用样式 - 科研风升级 */
  .dashboard-card {
    border-radius: 12px;
    border: 1px solid #e8eef4;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
    overflow: hidden;
    transition: all 0.3s ease;
    margin-bottom: 20px;
    background-color: #ffffff;
  }

  .dashboard-card:hover {
    box-shadow: 0 6px 16px rgba(0, 0, 0, 0.06);
    border-color: #d1e0f0;
  }

  /* 卡片头部样式 */
  .dashboard-card-header {
    padding: 14px 20px;
    background-color: #f8fafc;
    border-bottom: 1px solid #f0f2f5;
    color: #2c5282;
    font-weight: 500;
    font-size: 15px;
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .dashboard-card-header::before {
    font-size: 16px;
  }

  /* 欢迎卡片头部图标 */
  .welcome-card .dashboard-card-header::before {
    content: "👋";
  }

  /* 快捷入口卡片头部图标 */
  .shortcut-card .dashboard-card-header::before {
    content: "⚡";
  }

  /* 统计卡片头部图标 */
  .stats-card .dashboard-card-header::before {
    content: "📊";
  }

  /* 卡片主体样式 */
  .dashboard-card-body {
    padding: 20px;
  }

  /* 欢迎信息样式 */
  .welcome-text {
    font-size: 16px;
    color: #2d3748;
    margin-bottom: 16px !important;
  }

  .welcome-text strong {
    color: #2c5282;
    font-weight: 600;
  }

  .role-desc {
    color: #4a5568;
    font-size: 14px;
    line-height: 1.6;
  }

  .role-desc ul {
    margin-top: 8px;
    padding-left: 20px;
  }

  .role-desc li {
    margin-bottom: 4px;
  }

  /* 快捷入口按钮样式 */
  .shortcut-btn {
    display: flex;
    align-items: center;
    gap: 8px;
    width: 100%;
    margin-bottom: 10px !important;
    padding: 10px 16px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    border-color: #3182ce;
    color: #3182ce;
    transition: all 0.2s ease;
    text-align: left;
  }

  .shortcut-btn:hover {
    background-color: #f0f7ff;
    border-color: #2c5282;
    color: #2c5282;
    transform: translateX(4px);
    box-shadow: 0 2px 8px rgba(49, 130, 206, 0.1);
  }

  .shortcut-btn::before {
    font-size: 16px;
  }

  .shortcut-btn:nth-child(1)::before {
    content: "📈";
  }

  .shortcut-btn:nth-child(2)::before {
    content: "✅";
  }

  .shortcut-btn:nth-child(3)::before {
    content: "💬";
  }

  /* 统计说明文本 */
  .stats-desc {
    color: #718096;
    font-size: 13px;
    line-height: 1.5;
    margin-bottom: 16px !important;
    padding: 8px 12px;
    background-color: #f8fafc;
    border-radius: 6px;
    border-left: 3px solid #3182ce;
  }

  .stats-desc strong {
    color: #2c5282;
  }

  /* 空数据提示 */
  .empty-stats-alert {
    background-color: #f0f7ff;
    border: 1px solid #3182ce;
    color: #2c5282;
    border-radius: 8px;
    padding: 12px 16px;
    font-size: 14px;
    margin-bottom: 16px;
    text-align: center;
  }

  /* 图表容器样式 */
  .chart-box {
    border-radius: 8px;
    background-color: #ffffff;
    border: 1px solid #f0f2f5;
    padding: 8px;
  }

  #employmentStatusBar,
  #employmentTypePie,
  #employmentStatusHBar {
    width: 100%;
    height: 320px;
  }

  @media (max-width: 992px) {
    #employmentStatusBar,
    #employmentTypePie,
    #employmentStatusHBar {
      height: 280px;
    }
  }

  /* 响应式适配 */
  @media (max-width: 768px) {
    .dashboard-card-body {
      padding: 16px;
    }
    .shortcut-btn {
      padding: 8px 12px;
      font-size: 13px;
    }
  }

  @media (max-width: 576px) {
    .page-title {
      font-size: 20px;
    }
    .dashboard-card-header {
      padding: 12px 16px;
      font-size: 14px;
    }
    #employmentStatusBar,
    #employmentTypePie,
    #employmentStatusHBar {
      height: 260px;
    }
  }
</style>

<div class="container">
  <div class="row">
    <!-- 左侧教师导航 -->
    <jsp:include page="/WEB-INF/jsp/teacher/sidebar.jsp"/>

    <!-- 右侧内容 -->
    <div class="col-md-9">
      <h3 class="page-title">教师首页</h3>

      <div class="row">
        <!-- 欢迎 & 角色说明 -->
        <div class="col-md-6">
          <div class="dashboard-card welcome-card">
            <div class="dashboard-card-header">
              欢迎
            </div>
            <div class="dashboard-card-body">
              <p class="welcome-text">
                欢迎您，
                <strong>
                  <c:out value="${sessionScope.currentUser.realName}"/>
                </strong>
                ！
              </p>
              <div class="role-desc">
                <p>根据您的角色，不同的学生范围会显示在本系统中：</p>
                <ul>
                  <li>指导老师：仅显示您指导的学生；</li>
                  <li>班主任：显示您所在班级的学生；</li>
                  <li>辅导员：显示您负责年级或学生的范围。</li>
                </ul>
              </div>
            </div>
          </div>
        </div>

        <!-- 快捷入口卡片 -->
        <div class="col-md-6">
          <div class="dashboard-card shortcut-card">
            <div class="dashboard-card-header">
              快捷入口
            </div>
            <div class="dashboard-card-body">
              <a class="btn btn-outline-primary shortcut-btn"
                 href="${pageContext.request.contextPath}/teacher/students/employment">
                查看学生就业情况列表
              </a>
              <a class="btn btn-outline-primary shortcut-btn"
                 href="${pageContext.request.contextPath}/teacher/review/submissions">
                学生申请材料审批
              </a>
              <a class="btn btn-outline-primary shortcut-btn"
                 href="${pageContext.request.contextPath}/teacher/chat">
                和学生沟通（聊天）
              </a>
            </div>
          </div>
        </div>
      </div>

      <!-- 就业情况可视化大屏 -->
      <div class="row">
        <div class="col-md-12">
          <div class="dashboard-card stats-card">
            <div class="dashboard-card-header">
              学生就业情况概览
            </div>
            <div class="dashboard-card-body">
              <p class="stats-desc">
                统计范围：
                <strong>
                  <c:out value="${employmentScopeLabel}" default="全校学生"/>
                </strong>
                （每位学生仅按其最近一次就业登记记录统计）
              </p>

              <c:if test="${empty employmentStats}">
                <div class="empty-stats-alert">
                  暂无就业登记数据。
                </div>
              </c:if>

              <c:if test="${not empty employmentStats}">
                <div class="row">
                  <!-- 左：按状态统计柱状图 -->
                  <div class="col-lg-7 mb-3">
                    <div class="chart-box">
                      <div id="employmentStatusBar"></div>
                    </div>
                  </div>
                  <!-- 右：就业去向饼图（升学/就业/其他） -->
                  <div class="col-lg-5 mb-3">
                    <div class="chart-box">
                      <div id="employmentTypePie"></div>
                    </div>
                  </div>
                </div>
              </c:if>
            </div>
          </div>
        </div>
      </div>

      <!-- 第二排：横向条形图 -->
      <c:if test="${not empty employmentStats}">
        <div class="row">
          <div class="col-md-12">
            <div class="dashboard-card stats-card">
              <div class="dashboard-card-header">
                按就业状态对比（横向条形图）
              </div>
              <div class="dashboard-card-body">
                <div class="chart-box">
                  <div id="employmentStatusHBar"></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </c:if>

    </div>
  </div>
</div>

<script>
  // ===== 1. 从 JSP 注入原始 Map 数据：状态 -> 人数 =====
  var empStatus = [];
  var empCounts = [];

  <c:forEach var="entry" items="${employmentStats}">
  empStatus.push("${entry.key}");
  empCounts.push(${entry.value});
  </c:forEach>

  // ===== 2. 浅色系配色：浅蓝、浅黄、浅灰 =====
  var COLOR_LIGHT_BLUE  = '#93c5fd';
  var COLOR_BLUE_BORDER = '#60a5fa';
  var COLOR_LIGHT_YELLOW = '#fde68a';
  var COLOR_LIGHT_GRAY   = '#e5e7eb';

  // ===== 3. 计算平均值（给柱状图加辅助线） =====
  var sum = 0, cnt = 0;
  for (var i = 0; i < empCounts.length; i++) {
    if (typeof empCounts[i] === 'number') {
      sum += empCounts[i];
      cnt++;
    }
  }
  var avg = cnt > 0 ? sum / cnt : 0;

  // ===== 4. 基于原始状态聚合出“去向类型：升学/就业/其他” =====
  var studyCount = 0;   // 升学
  var jobCount   = 0;   // 就业
  var otherCount = 0;   // 其他/未就业

  function normalizeStatusToType(status, count) {
    if (!status) {
      otherCount += count;
      return;
    }
    // 全部转小写便于匹配（这里只是演示，用中文直接包含也行）
    var s = status;
    // 升学类关键字
    if (s.indexOf("升学") >= 0 || s.indexOf("考研") >= 0 || s.indexOf("读研") >= 0 || s.indexOf("研究生") >= 0) {
      studyCount += count;
    }
    // 就业类关键字
    else if (s.indexOf("就业") >= 0 || s.indexOf("签约") >= 0 || s.indexOf("录用") >= 0 || s.indexOf("已就业") >= 0 || s.indexOf("工作") >= 0) {
      jobCount += count;
    }
    // 其他：未就业/待就业/无记录等
    else {
      otherCount += count;
    }
  }

  for (var i = 0; i < empStatus.length; i++) {
    normalizeStatusToType(empStatus[i], empCounts[i]);
  }

  var pieLabels = ['升学', '就业', '其他/未就业'];
  var pieData = [
    {name: '升学', value: studyCount},
    {name: '就业', value: jobCount},
    {name: '其他/未就业', value: otherCount}
  ];

  // ===== 5. 图 1：按就业状态的浅色柱状图 =====
  var barDom = document.getElementById('employmentStatusBar');
  if (barDom) {
    var barChart = echarts.init(barDom);
    var barOption = {
      backgroundColor: 'transparent',
      tooltip: {
        trigger: 'axis',
        backgroundColor: 'rgba(255,255,255,0.96)',
        borderColor: '#e5e7eb',
        borderWidth: 1,
        textStyle: { color: '#2d3748' },
        padding: 8,
        borderRadius: 6,
        axisPointer: {
          type: 'shadow',
          shadowStyle: { color: 'rgba(148, 163, 184, 0.14)' }
        }
      },
      grid: {
        left: '4%',
        right: '4%',
        bottom: '10%',
        top: '8%',
        containLabel: true
      },
      xAxis: {
        type: 'category',
        data: empStatus,
        axisLine: { lineStyle: { color: '#e5e7eb' } },
        axisLabel: {
          color: '#4b5563',
          fontSize: 12,
          interval: 0,
          rotate: 25
        },
        axisTick: { alignWithLabel: true }
      },
      yAxis: {
        type: 'value',
        name: '人数',
        nameTextStyle: { color: '#718096', fontSize: 12 },
        axisLine: { show: false },
        axisTick: { show: false },
        axisLabel: { color: '#4b5563', fontSize: 12 },
        splitLine: { lineStyle: { color: '#e5e7eb' } },
        min: 0
      },
      series: [{
        name: '人数',
        type: 'bar',
        data: empCounts,
        barWidth: '50%',
        itemStyle: {
          color: COLOR_LIGHT_BLUE,
          borderColor: COLOR_BLUE_BORDER,
          borderWidth: 1,
          borderRadius: [6, 6, 0, 0]
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
          data: avg > 0 ? [{ yAxis: avg }] : []
        }
      }]
    };
    barChart.setOption(barOption);
  }

  // ===== 6. 图 2：就业去向饼图（升学/就业/其他），浅蓝/浅黄/浅灰 =====
  var pieDom = document.getElementById('employmentTypePie');
  if (pieDom) {
    var pieChart = echarts.init(pieDom);
    var pieOption = {
      backgroundColor: 'transparent',
      tooltip: {
        trigger: 'item',
        backgroundColor: 'rgba(255,255,255,0.96)',
        borderColor: '#e5e7eb',
        borderWidth: 1,
        textStyle: { color: '#2d3748', fontSize: 12 },
        padding: 8,
        borderRadius: 6,
        formatter: function (p) {
          return p.name + '<br/>人数：' + p.value + ' 人（' + p.percent + '%）';
        }
      },
      legend: {
        bottom: 0,
        left: 'center',
        textStyle: { fontSize: 11, color: '#4b5563' },
        itemWidth: 10,
        itemHeight: 10,
        itemGap: 6
      },
      color: [COLOR_LIGHT_BLUE, COLOR_LIGHT_YELLOW, COLOR_LIGHT_GRAY],
      series: [{
        type: 'pie',
        radius: '70%',
        center: ['50%', '45%'],
        data: pieData,
        itemStyle: {
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
          scaleSize: 4,
          label: {
            show: true,
            formatter: '{b}\n{c}人',
            fontSize: 12,
            color: '#111827'
          }
        }
      }]
    };
    pieChart.setOption(pieOption);
  }

  // ===== 7. 图 3：按状态的横向条形图（同一组数据） =====
  var hbarDom = document.getElementById('employmentStatusHBar');
  if (hbarDom) {
    var hbarChart = echarts.init(hbarDom);
    var hbarOption = {
      backgroundColor: 'transparent',
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'shadow',
          shadowStyle: { color: 'rgba(148, 163, 184, 0.14)' }
        },
        backgroundColor: 'rgba(255,255,255,0.96)',
        borderColor: '#e5e7eb',
        borderWidth: 1,
        textStyle: { color: '#2d3748', fontSize: 12 },
        padding: 8,
        borderRadius: 6
      },
      grid: {
        left: '20%',
        right: '6%',
        bottom: '8%',
        top: '8%',
        containLabel: true
      },
      xAxis: {
        type: 'value',
        axisLine: { show: false },
        axisTick: { show: false },
        axisLabel: { color: '#4b5563', fontSize: 12 },
        splitLine: { lineStyle: { color: '#e5e7eb' } },
        min: 0
      },
      yAxis: {
        type: 'category',
        data: empStatus,
        axisLine: { show: false },
        axisTick: { show: false },
        axisLabel: { color: '#4b5563', fontSize: 12 }
      },
      series: [{
        name: '人数',
        type: 'bar',
        data: empCounts,
        barWidth: '40%',
        itemStyle: {
          color: COLOR_LIGHT_BLUE,
          borderColor: COLOR_BLUE_BORDER,
          borderWidth: 1,
          borderRadius: [0, 6, 6, 0]
        }
      }]
    };
    hbarChart.setOption(hbarOption);
  }

  // ===== 8. 响应式 =====
  window.addEventListener('resize', function () {
    if (barDom)  echarts.getInstanceByDom(barDom)?.resize();
    if (pieDom)  echarts.getInstanceByDom(pieDom)?.resize();
    if (hbarDom) echarts.getInstanceByDom(hbarDom)?.resize();
  });
</script>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>