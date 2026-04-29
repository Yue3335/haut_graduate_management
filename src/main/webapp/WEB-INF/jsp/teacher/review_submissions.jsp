<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
  request.setAttribute("pageTitle", "学生申请材料审批 - 教师端");
%>

<jsp:include page="/WEB-INF/jsp/common/header.jsp"/>
<jsp:include page="/WEB-INF/jsp/common/navbar.jsp"/>

<style>
  .page-title {
    color: #2d3748;
    font-weight: 600;
    font-size: 22px;
    margin: 20px 0 20px !important;
    position: relative;
    padding-bottom: 10px;
    border-bottom: 1px solid #edf2f7;
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

  .filter-card {
    border-radius: 10px;
    border: 1px solid #e2e8f0;
    background-color: #f8fafc;
    padding: 10px 14px;
    margin-bottom: 14px;
  }

  .filter-label {
    font-size: 13px;
    color: #4b5563;
    margin-right: 6px;
  }

  .btn-filter {
    font-size: 13px;
    padding: 6px 14px;
  }

  .approval-card {
    border-radius: 12px;
    border: 1px solid #e2e8f0;
    background-color: #ffffff;
    box-shadow: 0 2px 8px rgba(15, 23, 42, 0.03);
    overflow: hidden;
  }
  .approval-card-header {
    padding: 10px 16px;
    background-color: #f8fafc;
    border-bottom: 1px solid #e2e8f0;
    font-weight: 500;
    font-size: 14px;
    color: #1e293b;
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
  .approval-card-header-left {
    display: flex;
    align-items: center;
    gap: 8px;
  }
  .approval-card-header-left::before {
    content: "";
    display: inline-block;
    width: 4px;
    height: 18px;
    border-radius: 4px;
    background: #3b82f6; /* 浅蓝 */
  }

  .approval-card-body {
    padding: 0;
  }

  .table-submission {
    margin-bottom: 0;
    font-size: 13px;
  }
  .table-submission thead th {
    background-color: #f8fafc;
    border-bottom: 1px solid #e2e8f0;
    color: #4b5563;
    font-weight: 500;
    white-space: nowrap;
  }
  .table-submission tbody tr:hover {
    background-color: #f1f5f9;
  }

  .status-pill {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 999px;
    font-size: 12px;
    font-weight: 500;
    white-space: nowrap;
  }
  .status-pending {
    background-color: #fef3c7;  /* 浅黄 */
    color: #92400e;
  }
  .status-approved {
    background-color: #dcfce7;
    color: #15803d;
  }
  .status-rejected {
    background-color: #fee2e2;
    color: #b91c1c;
  }

  .type-pill {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 999px;
    font-size: 12px;
    white-space: nowrap;
    background-color: #e5e7eb;  /* 浅灰 */
    color: #374151;
  }

  .empty-text {
    color: #9ca3af;
    font-size: 13px;
    padding: 12px 16px;
    margin: 0;
  }

  @media (max-width: 768px) {
    .page-title {
      font-size: 20px;
      margin-top: 16px !important;
    }
    .table-submission {
      font-size: 12px;
    }
  }
</style>

<div class="container">
  <div class="row">
    <jsp:include page="/WEB-INF/jsp/teacher/sidebar.jsp"/>

    <div class="col-md-9">
      <h3 class="page-title">学生申请材料审批</h3>

      <!-- 筛选：只看待审批 / 已审批 -->
      <div class="filter-card">
        <form class="row g-2 align-items-center"
              method="get"
              action="${pageContext.request.contextPath}/teacher/review/submissions">
          <div class="col-md-5 col-sm-7">
            <label class="filter-label" for="statusSelect">审批状态：</label>
            <select name="status" id="statusSelect" class="form-select form-select-sm d-inline-block" style="width:auto;">
              <option value="">全部状态</option>
              <option value="PENDING"
                      <c:if test="${param.status == 'PENDING'}">selected</c:if>>
                待审批
              </option>
              <option value="APPROVED"
                      <c:if test="${param.status == 'APPROVED'}">selected</c:if>>
                已通过
              </option>
              <option value="REJECTED"
                      <c:if test="${param.status == 'REJECTED'}">selected</c:if>>
                已驳回
              </option>
            </select>
          </div>
          <div class="col-md-3 col-sm-5">
            <button type="submit" class="btn btn-primary btn-filter">
              查询
            </button>
          </div>
        </form>
      </div>

      <div class="approval-card">
        <div class="approval-card-header">
          <div class="approval-card-header-left">
            申请材料列表
          </div>
          <div class="text-muted" style="font-size: 12px;">
            <c:if test="${not empty submissions}">
              共 ${fn:length(submissions)} 条记录
            </c:if>
          </div>
        </div>
        <div class="approval-card-body">
          <c:if test="${empty submissions}">
            <p class="empty-text">暂无符合条件的申请材料。</p>
          </c:if>

          <c:if test="${not empty submissions}">
            <div class="table-responsive">
              <table class="table table-sm table-striped mb-0 align-middle table-submission">
                <thead>
                <tr>
                  <th style="width: 8%;">学生ID</th>
                  <th style="width: 12%;">学号</th>
                  <th style="width: 10%;">姓名</th>
                  <th style="width: 22%;">标题</th>
                  <th style="width: 10%;">类型</th>
                  <th style="width: 10%;">状态</th>
                  <th style="width: 18%;">最新提交时间</th>
                  <th style="width: 20%;">操作</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="s" items="${submissions}">
                  <tr>
                    <td>${s.studentId}</td>
                    <td>
                      <c:out value="${s.studentNo}" default="-"/>
                    </td>
                    <td>
                      <c:out value="${s.realName}" default="-"/>
                    </td>
                    <td>
                      <c:out value="${s.title}" default="-"/>
                    </td>
                    <td>
                      <span class="type-pill">
                        <c:out value="${s.type}" default="-" />
                      </span>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${s.overallStatus == 'PENDING'}">
                          <span class="status-pill status-pending">待审批（最新提交）</span>
                        </c:when>
                        <c:when test="${s.overallStatus == 'APPROVED'}">
                          <span class="status-pill status-approved">已通过</span>
                        </c:when>
                        <c:when test="${s.overallStatus == 'REJECTED'}">
                          <span class="status-pill status-rejected">已驳回</span>
                        </c:when>
                        <c:otherwise>
                          <span class="status-pill status-other">
                            <c:out value="${s.overallStatus}" default="-" />
                          </span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <!-- 这里的 createdAt 实际上映射的是 updated_at（最新提交/修改时间） -->
                      <span class="muted-text">
                        <c:out value="${s.createdAt}" default="-"/>
                      </span>
                    </td>
                    <td>
                      <!-- 查看详情：根据 studentId 打开该学生最新一次就业登记详情 -->
                      <a href="${pageContext.request.contextPath}/teacher/employment/detail?studentId=${s.studentId}"
                         class="btn btn-sm btn-outline-secondary">
                        查看详情
                      </a>

                      <!-- 审批操作：只有待审批时才显示 -->
                      <c:if test="${s.overallStatus == 'PENDING'}">
                        <form method="post"
                              action="${pageContext.request.contextPath}/teacher/review/submissions"
                              style="display:inline;">
                          <input type="hidden" name="submissionId" value="${s.submissionId}"/>
                          <input type="hidden" name="action" value="approve"/>
                          <button type="submit"
                                  class="btn btn-sm btn-outline-success mb-1">
                            通过
                          </button>
                        </form>
                        <form method="post"
                              action="${pageContext.request.contextPath}/teacher/review/submissions"
                              style="display:inline;">
                          <input type="hidden" name="submissionId" value="${s.submissionId}"/>
                          <input type="hidden" name="action" value="reject"/>
                          <button type="submit"
                                  class="btn btn-sm btn-outline-danger mb-1">
                            驳回
                          </button>
                        </form>
                      </c:if>
                    </td>
                  </tr>
                </c:forEach>
                </tbody>
              </table>
            </div>
          </c:if>
        </div>
      </div>

    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>