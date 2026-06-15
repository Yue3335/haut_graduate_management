<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
  request.setAttribute("pageTitle", "个人发展推荐 - 毕业管理系统");
%>

<jsp:include page="/WEB-INF/jsp/common/header.jsp"/>
<jsp:include page="/WEB-INF/jsp/common/navbar.jsp"/>

<style>
  body {
    background-color: #f3f6fb;
    font-family: "Microsoft YaHei", "PingFang SC", "Helvetica Neue", sans-serif;
  }

  .page-header-bar {
    background: #ffffff;
    color: #2d3748;
    border-radius: 10px;
    padding: 16px 20px;
    margin-bottom: 20px;
    border: 1px solid #e5e7eb;
    box-shadow: 0 2px 8px rgba(15, 23, 42, 0.06);
  }

  .page-header-bar h3 {
    margin: 0;
    font-size: 20px;
    font-weight: 600;
  }

  .page-header-bar .sub-text {
    font-size: 12px;
    opacity: 0.8;
    margin-top: 4px;
    color: #4a5568;
  }

  .ai-card {
    border-radius: 12px;
    border: 1px solid #e5e7eb;
    box-shadow: 0 3px 12px rgba(15, 23, 42, 0.08);
    overflow: hidden;
    margin-bottom: 20px;
    background: #ffffff;
  }

  .ai-card-header {
    background: #f9fafb;
    color: #2d3748;
    padding: 12px 20px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 1px solid #e5e7eb;
  }

  .ai-card-header h5 {
    margin: 0;
    font-size: 16px;
    font-weight: 600;
    display: flex;
    align-items: center;
  }

  .ai-card-header h5 i {
    color: #2563eb;
    margin-right: 8px;
    font-size: 14px;
  }

  .ai-card-header small {
    font-size: 12px;
    color: #4a5568;
    opacity: 0.9;
  }

  .ai-card-body {
    padding: 20px;
    background: #ffffff;
  }

  .term-card {
    border-radius: 10px;
    border: 1px solid #e5e7eb;
    box-shadow: 0 2px 8px rgba(15, 23, 42, 0.06);
    margin-bottom: 16px;
    background: #ffffff;
  }

  .term-card-header {
    padding: 10px 16px;
    background: #f9fafb;
    border-bottom: 1px solid #e5e7eb;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .term-title {
    font-weight: 600;
    font-size: 14px;
    color: #111827;
  }

  .term-summary {
    font-size: 12px;
    color: #6b7280;
  }

  .term-card .table thead th {
    background-color: #f9fafb;
    border-bottom-width: 1px;
    font-size: 12px;
    color: #6b7280;
    padding: 8px 12px;
    white-space: nowrap;
  }

  .term-card .table td {
    font-size: 13px;
    color: #111827;
    padding: 10px 12px;
    vertical-align: middle;
  }

  .term-card .table-striped > tbody > tr:nth-of-type(odd) > * {
    background-color: #f8f9fa;
  }

  .ai-markdown h1,
  .ai-markdown h2,
  .ai-markdown h3,
  .ai-markdown h4,
  .ai-markdown h5,
  .ai-markdown h6 {
    margin-top: 0.8rem;
    margin-bottom: 0.4rem;
    font-weight: 700;
    color: #2d3748;
  }

  .ai-markdown h1 { font-size: 18px; }
  .ai-markdown h2 { font-size: 16px; }
  .ai-markdown h3 { font-size: 14px; }

  .ai-markdown p {
    margin: 0.4rem 0;
    line-height: 1.8;
  }

  .ai-markdown ul,
  .ai-markdown ol {
    padding-left: 1.4rem;
    margin: 0.4rem 0 0.6rem;
  }

  .ai-markdown {
    font-size: 14px;
    line-height: 1.8;
    color: #4a5568;
  }

  .form-select {
    border-radius: 6px;
    border: 1px solid #e5e7eb;
    padding: 6px 12px;
    font-size: 13px;
    transition: border-color 0.2s ease;
  }

  .form-select:focus {
    border-color: #2563eb;
    box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.1);
    outline: none;
  }

  .form-control {
    border-radius: 6px;
    border: 1px solid #e5e7eb;
    font-size: 13px;
  }

  .form-label {
    font-size: 13px;
    font-weight: 500;
    color: #2d3748;
    margin-bottom: 6px;
  }

  .form-text {
    font-size: 12px;
    color: #6b7280;
    margin-top: 4px;
  }

  .btn-primary {
    background-color: #2563eb;
    border: none;
    border-radius: 6px;
    padding: 6px 16px;
    font-size: 13px;
    font-weight: 500;
    transition: background-color 0.2s ease;
  }

  .btn-primary:hover {
    background-color: #1d4ed8;
  }

  .btn-success {
    border-radius: 6px;
    padding: 6px 16px;
    font-size: 13px;
    font-weight: 500;
  }

  .ai-suggestion-card {
    border-radius: 8px;
    border: 1px solid #e5e7eb;
    background: #f9fafb;
  }

  .ai-suggestion-card .card-body {
    padding: 16px;
  }

  .grade-badge {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 999px;
    background: #eef2ff;
    color: #3730a3;
    font-size: 12px;
    font-weight: 500;
  }

  .attr-badge {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 999px;
    background: #ecfdf5;
    color: #047857;
    font-size: 12px;
    font-weight: 500;
  }

  .upload-tip {
    font-size: 12px;
    color: #6b7280;
    margin-top: 6px;
    line-height: 1.7;
  }

  hr {
    border-top: 1px solid #e5e7eb;
    margin: 16px 0;
  }

  h6 {
    font-size: 14px;
    font-weight: 600;
    color: #2d3748;
  }

  @media (max-width: 768px) {
    .ai-card-header {
      align-items: flex-start;
      flex-direction: column;
      gap: 4px;
    }

    .term-card .table {
      min-width: 760px;
    }
  }
</style>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/font-awesome@4.7.0/css/font-awesome.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css">

<div class="container">
  <div class="row">

    <jsp:include page="/WEB-INF/jsp/student/sidebar.jsp"/>

    <div class="col-md-9">

      <div class="page-header-bar">
        <h3 class="mb-0">个人发展推荐</h3>
        <div class="sub-text">
          基于您的课程成绩、专业背景与 MBTI 性格偏好，智能生成岗位方向及发展建议
        </div>
      </div>

      <p class="text-muted" style="font-size: 13px; margin-bottom: 20px;">
        系统已汇总您当前各学期的成绩情况。您可以上传教务系统导出的成绩单 PDF，系统会自动识别课程、学分、成绩、课程属性和学年学期，并写入数据库。
      </p>

      <c:if test="${param.importSuccess == '1'}">
        <div class="alert alert-success" style="border-radius: 8px;">
          <i class="fa fa-check-circle me-1"></i>
          成绩单识别成功，已导入 ${param.count} 条课程成绩。
        </div>
      </c:if>

      <c:if test="${not empty param.importError}">
        <div class="alert alert-danger" style="border-radius: 8px;">
          <i class="fa fa-exclamation-circle me-1"></i>
            ${param.importError}
        </div>
      </c:if>

      <div class="ai-card">
        <div class="ai-card-header">
          <div>
            <h5 class="mb-0">
              <i class="fa fa-file-pdf-o"></i>
              成绩单 PDF 自动识别导入
            </h5>
            <small>上传教务系统导出的学生历年学习成绩单 PDF，系统自动解析并保存成绩数据</small>
          </div>
        </div>

        <div class="ai-card-body">
          <form method="post"
                action="${pageContext.request.contextPath}/student/grade/import"
                enctype="multipart/form-data">

            <div class="row align-items-end g-3">
              <div class="col-md-7 mb-2">
                <label class="form-label">选择成绩单 PDF</label>
                <input type="file"
                       name="scorePdf"
                       class="form-control"
                       accept="application/pdf"
                       required>

                <div class="upload-tip">
                  说明：系统会校验 PDF 中的学号是否与当前登录学生一致。重复上传时，同一学生、同一课程、同一学期的成绩会自动更新，不会重复插入。
                </div>
              </div>

              <div class="col-md-3 mb-2">
                <button type="submit" class="btn btn-success">
                  <i class="fa fa-upload me-1"></i>
                  识别并导入
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>

      <div class="ai-card">
        <div class="ai-card-header">
          <div>
            <h5 class="mb-0">
              <i class="fa fa-robot"></i>
              智能岗位推荐（基于成绩 + 专业 + MBTI）
            </h5>
            <small>选择或填写您的 MBTI 类型，点击按钮即可生成个性化建议</small>
          </div>
        </div>

        <div class="ai-card-body">
          <form method="post" action="${pageContext.request.contextPath}/student/recommendation">
            <div class="row align-items-end g-3">
              <div class="col-md-4 mb-2">
                <label class="form-label">我的 MBTI 类型</label>

                <select name="mbti" class="form-select">
                  <option value="">请选择或保留默认</option>

                  <c:set var="curMbti" value="${mbti}" />

                  <option value="INTJ" <c:if test="${curMbti == 'INTJ'}">selected</c:if>>INTJ</option>
                  <option value="INTP" <c:if test="${curMbti == 'INTP'}">selected</c:if>>INTP</option>
                  <option value="ENTJ" <c:if test="${curMbti == 'ENTJ'}">selected</c:if>>ENTJ</option>
                  <option value="ENTP" <c:if test="${curMbti == 'ENTP'}">selected</c:if>>ENTP</option>

                  <option value="INFJ" <c:if test="${curMbti == 'INFJ'}">selected</c:if>>INFJ</option>
                  <option value="INFP" <c:if test="${curMbti == 'INFP'}">selected</c:if>>INFP</option>
                  <option value="ENFJ" <c:if test="${curMbti == 'ENFJ'}">selected</c:if>>ENFJ</option>
                  <option value="ENFP" <c:if test="${curMbti == 'ENFP'}">selected</c:if>>ENFP</option>

                  <option value="ISTJ" <c:if test="${curMbti == 'ISTJ'}">selected</c:if>>ISTJ</option>
                  <option value="ISFJ" <c:if test="${curMbti == 'ISFJ'}">selected</c:if>>ISFJ</option>
                  <option value="ESTJ" <c:if test="${curMbti == 'ESTJ'}">selected</c:if>>ESTJ</option>
                  <option value="ESFJ" <c:if test="${curMbti == 'ESFJ'}">selected</c:if>>ESFJ</option>

                  <option value="ISTP" <c:if test="${curMbti == 'ISTP'}">selected</c:if>>ISTP</option>
                  <option value="ISFP" <c:if test="${curMbti == 'ISFP'}">selected</c:if>>ISFP</option>
                  <option value="ESTP" <c:if test="${curMbti == 'ESTP'}">selected</c:if>>ESTP</option>
                  <option value="ESFP" <c:if test="${curMbti == 'ESFP'}">selected</c:if>>ESFP</option>
                </select>

                <div class="form-text">
                  如果不知道自己的 MBTI，可以先在网上免费测评。
                </div>
              </div>

              <div class="col-md-4 mb-2">
                <button type="submit" class="btn btn-primary mt-2 mt-md-0">
                  <i class="fa fa-magic me-1"></i>
                  生成岗位推荐
                </button>
              </div>
            </div>
          </form>

          <c:if test="${not empty aiSuggestion}">
            <hr/>

            <h6 class="mb-2">AI 岗位推荐与发展建议</h6>

            <div class="ai-suggestion-card border-0 shadow-sm mb-0">
              <div class="card-body">
                <div class="ai-markdown">
                  <c:out value="${aiSuggestion}" escapeXml="false" />
                </div>
              </div>
            </div>
          </c:if>
        </div>
      </div>

      <c:if test="${empty termGrades}">
        <div class="alert alert-info" style="border-radius: 8px; border: 1px solid #cce5ff; background: #f8f9fa; color: #0c5460;">
          <i class="fa fa-info-circle me-2"></i>
          暂未查询到您的成绩数据。您可以先上传教务系统导出的成绩单 PDF，系统会自动识别并写入数据库。
        </div>
      </c:if>

      <c:if test="${not empty termGrades}">
        <c:forEach var="entry" items="${termGrades}">
          <c:set var="term" value="${entry.key}"/>
          <c:set var="grades" value="${entry.value}"/>

          <div class="term-card">
            <div class="term-card-header">
              <div class="term-title">
                学期：${term}
              </div>

              <div class="term-summary">
                学期课程成绩一览
              </div>
            </div>

            <div class="card-body p-0">
              <c:if test="${empty grades}">
                <p class="text-muted m-3">该学期暂无成绩数据。</p>
              </c:if>

              <c:if test="${not empty grades}">
                <div class="table-responsive">
                  <table class="table table-sm table-striped mb-0 align-middle">
                    <thead>
                    <tr>
                      <th style="width: 12%;">课程代码</th>
                      <th style="width: 34%;">课程名称</th>
                      <th style="width: 10%;">学分</th>
                      <th style="width: 12%;">成绩</th>
                      <th style="width: 12%;">属性</th>
                      <th style="width: 10%;">绩点</th>
                    </tr>
                    </thead>

                    <tbody>
                    <c:forEach var="g" items="${grades}">
                      <tr>
                        <td>
                          <c:out value="${g.courseCode}" default="-"/>
                        </td>

                        <td>
                          <c:out value="${g.courseName}" default="-"/>
                        </td>

                        <td>
                          <c:out value="${g.credit}" default="-"/>
                        </td>

                        <td>
                          <span class="grade-badge">
                            <c:choose>
                              <c:when test="${not empty g.scoreText}">
                                ${g.scoreText}
                              </c:when>
                              <c:otherwise>
                                ${g.score}
                              </c:otherwise>
                            </c:choose>
                          </span>
                        </td>

                        <td>
                          <c:choose>
                            <c:when test="${not empty g.courseAttr}">
                              <span class="attr-badge">${g.courseAttr}</span>
                            </c:when>
                            <c:otherwise>
                              -
                            </c:otherwise>
                          </c:choose>
                        </td>

                        <td>
                          <c:choose>
                            <c:when test="${g.gradePoint != null}">
                              ${g.gradePoint}
                            </c:when>
                            <c:otherwise>
                              -
                            </c:otherwise>
                          </c:choose>
                        </td>
                      </tr>
                    </c:forEach>
                    </tbody>
                  </table>
                </div>
              </c:if>
            </div>
          </div>
        </c:forEach>
      </c:if>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>