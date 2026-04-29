package edu.haut.gradms.web.controller.student;

import edu.haut.gradms.dao.MessageDao;
import edu.haut.gradms.dao.UserSimpleDao;
import edu.haut.gradms.model.Message;
import edu.haut.gradms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/student/chat")
public class StudentChatServlet extends HttpServlet {

    private final MessageDao messageDao = new MessageDao();
    private final UserSimpleDao userSimpleDao = new UserSimpleDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User currentUser = (User) session.getAttribute("currentUser");
        Boolean isStudent = (Boolean) session.getAttribute("isStudent");
        if (currentUser == null || isStudent == null || !isStudent) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无访问权限");
            return;
        }

        String toUserIdParam = req.getParameter("toUserId");
        if (toUserIdParam == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "缺少 toUserId 参数");
            return;
        }

        int toUserId;
        try {
            toUserId = Integer.parseInt(toUserIdParam);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "非法的 toUserId");
            return;
        }

        User targetUser = userSimpleDao.findById(toUserId);
        if (targetUser == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "找不到目标用户");
            return;
        }

        List<Message> conversation =
                messageDao.findConversation(currentUser.getUserId(), toUserId);

        req.setAttribute("targetUser", targetUser);
        req.setAttribute("conversation", conversation);

        req.getRequestDispatcher("/WEB-INF/jsp/student/chat.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User currentUser = (User) session.getAttribute("currentUser");
        Boolean isStudent = (Boolean) session.getAttribute("isStudent");
        if (currentUser == null || isStudent == null || !isStudent) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无访问权限");
            return;
        }

        req.setCharacterEncoding("UTF-8");
        String toUserIdParam = req.getParameter("toUserId");
        String content = req.getParameter("content");

        if (toUserIdParam == null || content == null || content.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "缺少参数或内容为空");
            return;
        }

        int toUserId;
        try {
            toUserId = Integer.parseInt(toUserIdParam);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "非法的 toUserId");
            return;
        }

        messageDao.saveMessage(currentUser.getUserId(), toUserId, content.trim());

        resp.sendRedirect(req.getContextPath() + "/student/chat?toUserId=" + toUserId);
    }
}