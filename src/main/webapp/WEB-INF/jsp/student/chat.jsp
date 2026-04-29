<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
  request.setAttribute("pageTitle", "与老师聊天 - 毕业管理系统");
%>

<jsp:include page="/WEB-INF/jsp/common/header.jsp"/>
<jsp:include page="/WEB-INF/jsp/common/navbar.jsp"/>

<style>
  /* 页面标题样式 - 统一科研风格 */
  .page-title {
    color: #2d3748;
    font-weight: 600;
    font-size: 22px;
    margin-bottom: 20px !important;
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

  /* 聊天容器核心样式 - 科研风优化 */
  .chat-wrapper {
    height: 600px;
    display: flex;
    flex-direction: column;
    border-radius: 12px;
    background: #ffffff;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
    overflow: hidden;
    border: 1px solid #e8eef4;
  }

  /* 聊天头部 - 科研蓝渐变 */
  .chat-header {
    padding: 14px 20px;
    background: linear-gradient(135deg, #2c5282, #3182ce);
    color: #ffffff;
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 1px solid #e8eef4;
  }

  .chat-header-title {
    font-size: 16px;
    font-weight: 500;
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .chat-header-title::before {
    content: "👨‍🏫";
    font-size: 18px;
  }

  .chat-header-user {
    font-size: 12px;
    opacity: 0.9;
    background-color: rgba(255, 255, 255, 0.1);
    padding: 4px 8px;
    border-radius: 4px;
  }

  /* 聊天内容区域 */
  .chat-body {
    flex: 1;
    padding: 20px;
    overflow-y: auto;
    background-color: #f8fafc;
    /* 科研风格滚动条 */
    scrollbar-width: thin;
    scrollbar-color: #cbd5e1 #f8fafc;
  }

  .chat-body::-webkit-scrollbar {
    width: 8px;
  }

  .chat-body::-webkit-scrollbar-track {
    background: #f8fafc;
    border-radius: 4px;
  }

  .chat-body::-webkit-scrollbar-thumb {
    background: #e2e8f0;
    border-radius: 4px;
  }

  .chat-body::-webkit-scrollbar-thumb:hover {
    background: #cbd5e1;
  }

  /* 消息行样式 */
  .chat-message-row {
    margin-bottom: 16px;
    display: flex;
    align-items: flex-end;
  }

  .chat-message-row.left {
    justify-content: flex-start;
  }

  .chat-message-row.right {
    justify-content: flex-end;
  }

  /* 消息气泡样式 - 差异化设计 */
  .chat-bubble {
    max-width: 75%;
    padding: 10px 14px;
    border-radius: 12px;
    word-break: break-word;
    font-size: 14px;
    line-height: 1.5;
    position: relative;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  }

  .chat-bubble.left {
    background: #ffffff;
    border: 1px solid #e8eef4;
    color: #2d3748;
    border-bottom-left-radius: 4px;
  }

  .chat-bubble.right {
    background: linear-gradient(135deg, #3182ce, #2c5282);
    color: #ffffff;
    border-bottom-right-radius: 4px;
  }

  /* 消息时间样式 */
  .chat-time {
    font-size: 11px;
    margin-top: 4px;
    padding: 0 6px;
  }

  .chat-time.left {
    color: #94a3b8;
    text-align: left;
  }

  .chat-time.right {
    color: rgba(255, 255, 255, 0.7);
    text-align: right;
  }

  /* 空消息提示 */
  .chat-empty-tip {
    text-align: center;
    color: #94a3b8;
    font-size: 14px;
    margin-top: 80px;
    padding: 20px;
    background-color: #ffffff;
    border-radius: 8px;
    border: 1px dashed #e2e8f0;
  }

  .chat-empty-tip::before {
    content: "💬";
    font-size: 24px;
    display: block;
    margin-bottom: 8px;
  }

  /* 聊天输入区域 */
  .chat-footer {
    padding: 16px 20px;
    background: #ffffff;
    border-top: 1px solid #e8eef4;
  }

  .chat-footer textarea {
    resize: none;
    font-size: 14px;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    padding: 10px 14px;
    transition: all 0.2s ease;
    background-color: #f8fafc;
  }

  .chat-footer textarea:focus {
    border-color: #3182ce;
    box-shadow: 0 0 0 2px rgba(49, 130, 206, 0.1);
    outline: none;
    background-color: #ffffff;
  }

  /* 操作按钮区域 */
  .chat-footer-actions {
    margin-top: 10px;
    display: flex;
    justify-content: flex-end;
    gap: 10px;
  }

  .btn-send {
    background: linear-gradient(135deg, #3182ce, #2c5282);
    border: none;
    border-radius: 6px;
    padding: 8px 20px;
    font-size: 14px;
    font-weight: 500;
    color: #ffffff;
    transition: all 0.2s ease;
  }

  .btn-send:hover {
    background: linear-gradient(135deg, #2c5282, #1a365d);
    box-shadow: 0 2px 8px rgba(49, 130, 206, 0.2);
  }

  .btn-back {
    color: #718096;
    font-size: 14px;
    text-decoration: none;
    padding: 8px 16px;
    border-radius: 6px;
    transition: all 0.2s ease;
  }

  .btn-back:hover {
    color: #3182ce;
    background-color: #f8fafc;
  }

  /* 响应式适配 */
  @media (max-width: 768px) {
    .chat-wrapper {
      height: 500px;
    }
    .chat-header {
      padding: 12px 16px;
      flex-direction: column;
      gap: 8px;
      align-items: flex-start;
    }
    .chat-header-user {
      font-size: 11px;
    }
    .chat-body {
      padding: 16px;
    }
    .chat-bubble {
      max-width: 85%;
    }
  }

  @media (max-width: 576px) {
    .chat-wrapper {
      height: 450px;
    }
    .chat-footer {
      padding: 12px 16px;
    }
    .chat-footer-actions {
      flex-direction: column;
    }
    .btn-send, .btn-back {
      width: 100%;
      text-align: center;
    }
  }
</style>

<div class="container">
  <div class="row">
    <!-- 左侧学生导航 -->
    <jsp:include page="/WEB-INF/jsp/student/sidebar.jsp"/>

    <!-- 右侧聊天区域 -->
    <div class="col-md-9">
      <h3 class="page-title">与老师聊天</h3>

      <div class="chat-wrapper mb-4">
        <!-- 顶部栏 -->
        <div class="chat-header">
          <div class="chat-header-title">
            ${targetUser.realName} 老师
            <span style="font-size: 12px; opacity: 0.8;">(${targetUser.username})</span>
          </div>
          <div class="chat-header-user">
            我：${sessionScope.currentUser.realName}（${sessionScope.currentUser.username}）
          </div>
        </div>

        <!-- 消息区域 -->
        <div class="chat-body" id="chatBody">
          <c:if test="${empty conversation}">
            <div class="chat-empty-tip">
              还没有任何聊天记录<br>
              可以给老师发送第一条消息开始沟通
            </div>
          </c:if>

          <c:forEach var="m" items="${conversation}">
            <c:choose>
              <c:when test="${m.senderUserId == sessionScope.currentUser.userId}">
                <div class="chat-message-row right">
                  <div>
                    <div class="chat-bubble right">
                      <c:out value="${m.content}"/>
                    </div>
                    <div class="chat-time right">
                        ${m.sentAt}
                    </div>
                  </div>
                </div>
              </c:when>
              <c:otherwise>
                <div class="chat-message-row left">
                  <div>
                    <div class="chat-bubble left">
                      <c:out value="${m.content}"/>
                    </div>
                    <div class="chat-time left">
                        ${m.sentAt}
                    </div>
                  </div>
                </div>
              </c:otherwise>
            </c:choose>
          </c:forEach>
        </div>

        <!-- 底部输入区域 -->
        <div class="chat-footer">
          <form method="post" action="${pageContext.request.contextPath}/student/chat">
            <input type="hidden" name="toUserId" value="${targetUser.userId}">
            <div class="mb-2">
              <textarea name="content" class="form-control" rows="3"
                        placeholder="请输入要发送给老师的内容，可咨询毕业相关问题..." required></textarea>
            </div>
            <div class="chat-footer-actions">
              <a href="${pageContext.request.contextPath}/student/contact-teacher"
                 class="btn-back">返回联系老师</a>
              <button type="submit" class="btn-send">发送消息</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>

<script>
  (function () {
    // 自动滚动到底部
    var chatBody = document.getElementById('chatBody');
    if (chatBody) {
      chatBody.scrollTop = chatBody.scrollHeight;

      // 优化输入框聚焦体验
      const textarea = document.querySelector('.chat-footer textarea');
      if (textarea) {
        textarea.addEventListener('focus', function() {
          this.style.borderColor = '#3182ce';
        });
        textarea.addEventListener('blur', function() {
          if (!this.value) {
            this.style.borderColor = '#e2e8f0';
          }
        });
      }
    }
  })();
</script>