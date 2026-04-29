package edu.haut.gradms.web.controller.teacher;

import edu.haut.gradms.config.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * 教师端：和学生沟通（聊天）
 * URL: /teacher/chat
 */
@WebServlet("/teacher/chat")
public class TeacherChatServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // 你这里用的是 session 里的 currentUserId，而不是 User 对象里的 userId
        Integer teacherUserIdObj = (Integer) session.getAttribute("currentUserId");
        if (teacherUserIdObj == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "未找到当前用户ID，请在登录成功后为 session 设置 currentUserId");
            return;
        }
        int teacherUserId = teacherUserIdObj;

        boolean isTeacher      = Boolean.TRUE.equals(session.getAttribute("isTeacher"));
        boolean isCounselor   = Boolean.TRUE.equals(session.getAttribute("isCounselor"));
        boolean isClassTeacher = Boolean.TRUE.equals(session.getAttribute("isClassTeacher"));

        req.setCharacterEncoding("UTF-8");

        try (Connection conn = DBUtil.getConnection()) {
            // 1. 我能沟通的学生列表（这里改了优先级）
            List<StudentView> students =
                    findMyStudents(conn, teacherUserId, isTeacher, isCounselor, isClassTeacher);
            req.setAttribute("students", students);

            // 2. 当前选中学生
            String sidStr = req.getParameter("studentId");
            StudentView currentStudent = null;
            List<MessageView> messages = Collections.emptyList();

            if (sidStr != null && !sidStr.isEmpty()) {
                try {
                    int studentId = Integer.parseInt(sidStr);
                    currentStudent = findStudentById(conn, studentId);
                    if (currentStudent != null) {
                        messages = findMessages(conn, teacherUserId, currentStudent.getUserId());
                        req.setAttribute("currentStudentId", currentStudent.getStudentId());
                    }
                } catch (NumberFormatException ignored) {
                }
            }

            req.setAttribute("currentStudent", currentStudent);
            req.setAttribute("messages", messages);

        } catch (SQLException e) {
            e.printStackTrace();
        }

        req.getRequestDispatcher("/WEB-INF/jsp/teacher/chat.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Integer teacherUserIdObj = (Integer) session.getAttribute("currentUserId");
        if (teacherUserIdObj == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "未找到当前用户ID，请在登录成功后为 session 设置 currentUserId");
            return;
        }
        int teacherUserId = teacherUserIdObj;

        req.setCharacterEncoding("UTF-8");
        String sidStr = req.getParameter("studentId");
        String content = req.getParameter("content");

        if (sidStr == null || sidStr.isEmpty()
                || content == null || content.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/teacher/chat");
            return;
        }

        int studentId;
        try {
            studentId = Integer.parseInt(sidStr);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/teacher/chat");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            int studentUserId = findStudentUserId(conn, studentId);
            if (studentUserId > 0) {
                saveMessage(conn, teacherUserId, studentUserId, content.trim());
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        resp.sendRedirect(req.getContextPath() + "/teacher/chat?studentId=" + studentId);
    }

    // ======= 关键改动在这里：按角色优先级选择 SQL =======

    private List<StudentView> findMyStudents(Connection conn,
                                             int teacherUserId,
                                             boolean isTeacher,
                                             boolean isCounselor,
                                             boolean isClassTeacher) throws SQLException {
        List<StudentView> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT DISTINCT s.student_id, s.student_no, u.real_name, s.user_id " +
                        "FROM student s " +
                        "JOIN user u ON u.user_id = s.user_id "
        );

        // 优先级：班主任 > 辅导员 > 指导老师
        if (isClassTeacher) {
            // 班主任：按 class.class_teacher_user_id
            sql.append("JOIN class c ON c.class_id = s.class_id ");
            sql.append("WHERE c.class_teacher_user_id = ? ");
        } else if (isCounselor) {
            // 辅导员：按 student_counselor
            sql.append("JOIN student_counselor sc ON sc.student_id = s.student_id ");
            sql.append("WHERE sc.counselor_user_id = ? ");
        } else if (isTeacher) {
            // 指导老师：按 student_supervisor
            sql.append("JOIN student_supervisor ss ON ss.student_id = s.student_id ");
            sql.append("WHERE ss.supervisor_user_id = ? ");
        } else {
            // 没有任何老师角色标记，不返回学生
            return list;
        }

        sql.append("ORDER BY s.student_no");

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setInt(1, teacherUserId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    StudentView sv = new StudentView();
                    sv.setStudentId(rs.getInt("student_id"));
                    sv.setStudentNo(rs.getString("student_no"));
                    sv.setRealName(rs.getString("real_name"));
                    sv.setUserId(rs.getInt("user_id"));
                    list.add(sv);
                }
            }
        }

        return list;
    }

    private StudentView findStudentById(Connection conn, int studentId) throws SQLException {
        String sql = "SELECT s.student_id, s.student_no, u.real_name, s.user_id " +
                "FROM student s " +
                "JOIN user u ON u.user_id = s.user_id " +
                "WHERE s.student_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    StudentView sv = new StudentView();
                    sv.setStudentId(rs.getInt("student_id"));
                    sv.setStudentNo(rs.getString("student_no"));
                    sv.setRealName(rs.getString("real_name"));
                    sv.setUserId(rs.getInt("user_id"));
                    return sv;
                }
            }
        }
        return null;
    }

    private List<MessageView> findMessages(Connection conn,
                                           int teacherUserId,
                                           int studentUserId) throws SQLException {
        List<MessageView> list = new ArrayList<>();

        String sql = "SELECT message_id, sender_user_id, receiver_user_id, content, sent_at " +
                "FROM message " +
                "WHERE (sender_user_id = ? AND receiver_user_id = ?) " +
                "   OR (sender_user_id = ? AND receiver_user_id = ?) " +
                "ORDER BY sent_at ASC";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, teacherUserId);
            ps.setInt(2, studentUserId);
            ps.setInt(3, studentUserId);
            ps.setInt(4, teacherUserId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MessageView mv = new MessageView();
                    mv.setMessageId(rs.getInt("message_id"));
                    mv.setSenderUserId(rs.getInt("sender_user_id"));
                    mv.setReceiverUserId(rs.getInt("receiver_user_id"));
                    mv.setContent(rs.getString("content"));
                    mv.setSentAt(rs.getTimestamp("sent_at"));
                    mv.setFromTeacher(mv.getSenderUserId() == teacherUserId);
                    list.add(mv);
                }
            }
        }

        return list;
    }

    private int findStudentUserId(Connection conn, int studentId) throws SQLException {
        String sql = "SELECT user_id FROM student WHERE student_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("user_id");
                }
            }
        }
        return 0;
    }

    private void saveMessage(Connection conn,
                             int teacherUserId,
                             int studentUserId,
                             String content) throws SQLException {
        String sql = "INSERT INTO message(sender_user_id, receiver_user_id, content) " +
                "VALUES (?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, teacherUserId);
            ps.setInt(2, studentUserId);
            ps.setString(3, content);
            ps.executeUpdate();
        }
    }

    public static class StudentView {
        private int studentId;
        private String studentNo;
        private String realName;
        private int userId;

        public int getStudentId() { return studentId; }
        public void setStudentId(int studentId) { this.studentId = studentId; }

        public String getStudentNo() { return studentNo; }
        public void setStudentNo(String studentNo) { this.studentNo = studentNo; }

        public String getRealName() { return realName; }
        public void setRealName(String realName) { this.realName = realName; }

        public int getUserId() { return userId; }
        public void setUserId(int userId) { this.userId = userId; }
    }

    public static class MessageView {
        private int messageId;
        private int senderUserId;
        private int receiverUserId;
        private String content;
        private java.util.Date sentAt;
        private boolean fromTeacher;

        public int getMessageId() { return messageId; }
        public void setMessageId(int messageId) { this.messageId = messageId; }

        public int getSenderUserId() { return senderUserId; }
        public void setSenderUserId(int senderUserId) { this.senderUserId = senderUserId; }

        public int getReceiverUserId() { return receiverUserId; }
        public void setReceiverUserId(int receiverUserId) { this.receiverUserId = receiverUserId; }

        public String getContent() { return content; }
        public void setContent(String content) { this.content = content; }

        public java.util.Date getSentAt() { return sentAt; }
        public void setSentAt(java.util.Date sentAt) { this.sentAt = sentAt; }

        public boolean isFromTeacher() { return fromTeacher; }
        public void setFromTeacher(boolean fromTeacher) { this.fromTeacher = fromTeacher; }
    }
}