<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    request.setAttribute("pageTitle", "与学生沟通 - 毕业管理系统");
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

    /* 左侧学生列表卡片 */
    .student-list-card {
        border-radius: 12px;
        border: 1px solid #e2e8f0;
        background-color: #ffffff;
        box-shadow: 0 2px 8px rgba(15, 23, 42, 0.03);
        overflow: hidden;
    }
    .student-list-card .card-header {
        padding: 10px 16px;
        background-color: #f8fafc;
        border-bottom: 1px solid #e2e8f0;
        font-weight: 500;
        font-size: 14px;
        color: #1e293b;
    }
    .student-list-empty {
        padding: 14px 16px;
        font-size: 13px;
        color: #6b7280;
        background-color: #f9fafb;
    }
    .student-list {
        max-height: 420px;
        overflow-y: auto;
    }
    .student-item {
        border-bottom: 1px solid #e5e7eb;
        padding: 8px 12px;
        display: flex;
        align-items: center;
        gap: 10px;
        text-decoration: none;
        color: #111827;
        font-size: 13px;
        transition: background-color 0.15s;
    }
    .student-item:last-child {
        border-bottom: none;
    }
    .student-item:hover {
        background-color: #f3f4f6;
    }
    .student-item.active {
        background-color: #e0f2fe;
        border-left: 3px solid #3b82f6;
        padding-left: 9px;
    }
    .student-avatar {
        width: 32px;
        height: 32px;
        border-radius: 999px;
        background-color: #bfdbfe; /* 浅蓝 */
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
        color: #1d4ed8;
        font-weight: 600;
    }
    .student-info-name {
        font-weight: 600;
        color: #1f2937;
    }
    .student-info-no {
        font-size: 12px;
        color: #6b7280;
    }

    /* 右侧聊天卡片 */
    .chat-card {
        border-radius: 12px;
        border: 1px solid #e2e8f0;
        background-color: #ffffff;
        box-shadow: 0 2px 8px rgba(15, 23, 42, 0.03);
        overflow: hidden;
    }
    .chat-card-header {
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
    .chat-card-header span.sub {
        font-size: 12px;
        color: #6b7280;
    }

    .chat-wrapper {
        display: flex;
        flex-direction: column;
        height: 430px;
        padding: 10px 12px 12px;
    }
    .chat-messages {
        border-radius: 10px;
        border: 1px solid #e5e7eb;
        background-color: #f9fafb;
        padding: 8px;
        flex-grow: 1;
        overflow-y: auto;
    }
    .chat-empty-hint {
        font-size: 13px;
        color: #9ca3af;
        text-align: center;
        margin-top: 16px;
    }

    /* 消息气泡 */
    .msg-row {
        margin-bottom: 8px;
        display: flex;
    }
    .msg-row.teacher {
        justify-content: flex-end;
    }
    .msg-row.student {
        justify-content: flex-start;
    }

    .msg-bubble {
        max-width: 78%;
        border-radius: 10px;
        padding: 6px 8px;
        font-size: 13px;
        word-break: break-word;
    }
    .msg-bubble-teacher {
        background-color: #3b82f6;
        color: #ffffff;
    }
    .msg-bubble-student {
        background-color: #ffffff;
        border: 1px solid #e5e7eb;
        color: #111827;
    }

    .msg-meta {
        font-size: 11px;
        margin-top: 2px;
    }
    .msg-meta.teacher {
        color: #e5e7eb;
        text-align: right;
    }
    .msg-meta.student {
        color: #9ca3af;
        text-align: left;
    }

    /* 发送区域 */
    .chat-input-area {
        margin-top: 8px;
    }
    .chat-input-area textarea {
        resize: none;
        font-size: 13px;
    }
    .chat-input-area .btn-send {
        font-size: 13px;
        padding: 6px 14px;
        border-radius: 999px;
        margin-left: 6px;
    }

    @media (max-width: 768px) {
        .page-title {
            font-size: 20px;
            margin-top: 16px !important;
        }
        .chat-wrapper {
            height: 380px;
        }
        .student-item {
            padding: 8px 10px;
        }
    }
</style>

<div class="container">
    <div class="row">
        <!-- 左侧教师导航 -->
        <jsp:include page="/WEB-INF/jsp/teacher/sidebar.jsp"/>

        <!-- 右侧：聊天主界面 -->
        <div class="col-md-9">
            <h3 class="page-title">与学生沟通</h3>

            <div class="row">
                <!-- 左边：我能沟通的学生列表 -->
                <div class="col-md-4 mb-3">
                    <div class="student-list-card">
                        <div class="card-header">
                            我管理的学生
                        </div>
                        <div class="card-body p-0">
                            <c:if test="${empty students}">
                                <div class="student-list-empty">
                                    暂未查询到您管理范围内的学生。<br/>
                                    请确认您是否被设置为班主任 / 辅导员 / 指导老师。
                                </div>
                            </c:if>

                            <c:if test="${not empty students}">
                                <div class="student-list">
                                    <c:forEach var="stu" items="${students}">
                                        <a class="student-item
                                                   <c:if test='${stu.studentId == currentStudentId}'> active</c:if>"
                                           href="${pageContext.request.contextPath}/teacher/chat?studentId=${stu.studentId}">
                                            <div class="student-avatar">
                                                <c:out value="${fn:substring(stu.realName, 0, 1)}" default="学"/>
                                            </div>
                                            <div>
                                                <div class="student-info-name">${stu.realName}</div>
                                                <div class="student-info-no">${stu.studentNo}</div>
                                            </div>
                                        </a>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>

                <!-- 右边：和某个学生的聊天窗口 -->
                <div class="col-md-8 mb-3">
                    <div class="chat-card h-100">
                        <c:choose>
                            <c:when test="${empty currentStudent}">
                                <div class="d-flex align-items-center justify-content-center"
                                     style="height: 260px; padding: 20px;">
                                    <span class="text-muted" style="font-size: 14px;">
                                        请在左侧选择一名学生开始聊天。
                                    </span>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="chat-card-header">
                                    <div>
                                        正在和：
                                        <strong>${currentStudent.realName}</strong>
                                        （${currentStudent.studentNo}）
                                    </div>
                                    <span class="sub">
                                        共
                                        <c:out value="${fn:length(messages)}" default="0"/>
                                        条消息
                                    </span>
                                </div>
                                <div class="chat-wrapper">
                                    <!-- 聊天记录 -->
                                    <div id="messageList" class="chat-messages">
                                        <c:if test="${empty messages}">
                                            <div class="chat-empty-hint">
                                                暂无历史消息，可以开始发送第一条消息。
                                            </div>
                                        </c:if>

                                        <c:forEach var="msg" items="${messages}">
                                            <c:choose>
                                                <c:when test="${msg.fromTeacher}">
                                                    <!-- 老师发出的消息：右侧气泡 -->
                                                    <div class="msg-row teacher">
                                                        <div class="msg-bubble msg-bubble-teacher">
                                                                ${msg.content}
                                                            <div class="msg-meta teacher">
                                                                <fmt:formatDate value="${msg.sentAt}" pattern="yyyy-MM-dd HH:mm"/>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <!-- 学生发出的消息：左侧气泡 -->
                                                    <div class="msg-row student">
                                                        <div class="msg-bubble msg-bubble-student">
                                                                ${msg.content}
                                                            <div class="msg-meta student">
                                                                <fmt:formatDate value="${msg.sentAt}" pattern="yyyy-MM-dd HH:mm"/>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:forEach>
                                    </div>

                                    <!-- 发送消息表单 -->
                                    <form method="post"
                                          action="${pageContext.request.contextPath}/teacher/chat"
                                          class="chat-input-area">
                                        <input type="hidden" name="studentId" value="${currentStudent.studentId}"/>
                                        <div class="d-flex">
                                            <textarea name="content"
                                                      class="form-control"
                                                      rows="2"
                                                      placeholder="输入要发送的消息..."
                                                      required></textarea>
                                            <button type="submit"
                                                    class="btn btn-primary btn-send">
                                                发送
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>

<script>
    // 简单的自动滚动到底部，方便查看最新消息
    (function () {
        var list = document.getElementById('messageList');
        if (list) {
            list.scrollTop = list.scrollHeight;
        }
    })();
</script>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>