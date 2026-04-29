package edu.haut.gradms.web.controller.teacher;

import edu.haut.gradms.config.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/teacher/review/submissions")
public class TeacherReviewSubmissionsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Integer userIdObj = (Integer) session.getAttribute("currentUserId");
        if (userIdObj == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "未找到当前用户ID，请在登录成功后为 session 设置 currentUserId");
            return;
        }
        int userId = userIdObj;

        boolean isTeacher = Boolean.TRUE.equals(session.getAttribute("isTeacher"));
        boolean isClassTeacher = Boolean.TRUE.equals(session.getAttribute("isClassTeacher"));
        boolean isCounselor = Boolean.TRUE.equals(session.getAttribute("isCounselor"));

        req.setCharacterEncoding("UTF-8");
        String status = req.getParameter("status"); // PENDING / APPROVED / REJECTED / null

        List<SubmissionView> submissions = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection()) {
            if (isTeacher) {
                submissions = listSubmissionsForSupervisor(conn, userId, status);
            } else if (isClassTeacher) {
                submissions = listSubmissionsForClassTeacher(conn, userId, status);
            } else if (isCounselor) {
                submissions = listSubmissionsForCounselor(conn, userId, status);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        req.setAttribute("submissions", submissions);
        req.getRequestDispatcher("/WEB-INF/jsp/teacher/review_submissions.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Integer userIdObj = (Integer) session.getAttribute("currentUserId");
        if (userIdObj == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "未找到当前用户ID，请在登录成功后为 session 设置 currentUserId");
            return;
        }

        req.setCharacterEncoding("UTF-8");
        String submissionIdStr = req.getParameter("submissionId");
        String action = req.getParameter("action"); // approve / reject
        String statusFilter = req.getParameter("status"); // 保留原来的筛选条件

        if (submissionIdStr == null || submissionIdStr.isEmpty()
                || action == null || action.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/teacher/review/submissions");
            return;
        }

        int submissionId;
        try {
            submissionId = Integer.parseInt(submissionIdStr);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/teacher/review/submissions");
            return;
        }

        String newStatus;
        if ("approve".equals(action)) {
            newStatus = "APPROVED";
        } else if ("reject".equals(action)) {
            newStatus = "REJECTED";
        } else {
            resp.sendRedirect(req.getContextPath() + "/teacher/review/submissions");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            updateSubmissionStatus(conn, submissionId, newStatus);
        } catch (SQLException e) {
            e.printStackTrace();
        }

        if (statusFilter != null && !statusFilter.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/teacher/review/submissions?status=" + statusFilter);
        } else {
            resp.sendRedirect(req.getContextPath() + "/teacher/review/submissions");
        }
    }

    /**
     * 导师：只看自己负责学生的最新材料（每个学生每种 type 仅一条），按最近更新时间倒序。
     */
    private List<SubmissionView> listSubmissionsForSupervisor(Connection conn,
                                                              int supervisorUserId,
                                                              String statusFilter) throws SQLException {
        List<SubmissionView> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT sub.submission_id, sub.student_id, sub.title, sub.type, " +
                        "       sub.content_path, sub.overall_status, sub.created_at, sub.updated_at, " +
                        "       s.student_no, u.real_name " +
                        "FROM submission sub " +
                        "JOIN ( " +
                        "    SELECT student_id, type, MAX(updated_at) AS max_updated " +
                        "    FROM submission " +
                        "    GROUP BY student_id, type " +
                        ") t ON sub.student_id = t.student_id " +
                        "     AND sub.type = t.type " +
                        "     AND sub.updated_at = t.max_updated " +
                        "JOIN student s ON s.student_id = sub.student_id " +
                        "JOIN user u ON u.user_id = s.user_id " +
                        "JOIN student_supervisor ss ON ss.student_id = s.student_id " +
                        "WHERE ss.supervisor_user_id = ? "
        );

        List<Object> params = new ArrayList<>();
        params.add(supervisorUserId);

        if (statusFilter != null && !statusFilter.isEmpty()) {
            sql.append("AND sub.overall_status = ? ");
            params.add(statusFilter);
        }

        // 按最近更新时间倒序，让最新的排在前面
        sql.append("ORDER BY sub.updated_at DESC, sub.submission_id DESC");

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapSubmission(rs));
                }
            }
        }

        return list;
    }

    /**
     * 班主任：只看自己班级学生的最新材料（每个学生每种 type 仅一条）。
     */
    private List<SubmissionView> listSubmissionsForClassTeacher(Connection conn,
                                                                int classTeacherUserId,
                                                                String statusFilter) throws SQLException {
        List<SubmissionView> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT sub.submission_id, sub.student_id, sub.title, sub.type, " +
                        "       sub.content_path, sub.overall_status, sub.created_at, sub.updated_at, " +
                        "       s.student_no, u.real_name " +
                        "FROM submission sub " +
                        "JOIN ( " +
                        "    SELECT student_id, type, MAX(updated_at) AS max_updated " +
                        "    FROM submission " +
                        "    GROUP BY student_id, type " +
                        ") t ON sub.student_id = t.student_id " +
                        "     AND sub.type = t.type " +
                        "     AND sub.updated_at = t.max_updated " +
                        "JOIN student s ON s.student_id = sub.student_id " +
                        "JOIN user u ON u.user_id = s.user_id " +
                        "JOIN class c ON c.class_id = s.class_id " +
                        "WHERE c.class_teacher_user_id = ? "
        );

        List<Object> params = new ArrayList<>();
        params.add(classTeacherUserId);

        if (statusFilter != null && !statusFilter.isEmpty()) {
            sql.append("AND sub.overall_status = ? ");
            params.add(statusFilter);
        }

        sql.append("ORDER BY sub.updated_at DESC, sub.submission_id DESC");

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapSubmission(rs));
                }
            }
        }

        return list;
    }

    /**
     * 辅导员：只看自己负责学生的最新材料（每个学生每种 type 仅一条）。
     */
    private List<SubmissionView> listSubmissionsForCounselor(Connection conn,
                                                             int counselorUserId,
                                                             String statusFilter) throws SQLException {
        List<SubmissionView> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT sub.submission_id, sub.student_id, sub.title, sub.type, " +
                        "       sub.content_path, sub.overall_status, sub.created_at, sub.updated_at, " +
                        "       s.student_no, u.real_name " +
                        "FROM submission sub " +
                        "JOIN ( " +
                        "    SELECT student_id, type, MAX(updated_at) AS max_updated " +
                        "    FROM submission " +
                        "    GROUP BY student_id, type " +
                        ") t ON sub.student_id = t.student_id " +
                        "     AND sub.type = t.type " +
                        "     AND sub.updated_at = t.max_updated " +
                        "JOIN student s ON s.student_id = sub.student_id " +
                        "JOIN user u ON u.user_id = s.user_id " +
                        "JOIN student_counselor sc ON sc.student_id = s.student_id " +
                        "WHERE sc.counselor_user_id = ? "
        );

        List<Object> params = new ArrayList<>();
        params.add(counselorUserId);

        if (statusFilter != null && !statusFilter.isEmpty()) {
            sql.append("AND sub.overall_status = ? ");
            params.add(statusFilter);
        }

        sql.append("ORDER BY sub.updated_at DESC, sub.submission_id DESC");

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapSubmission(rs));
                }
            }
        }

        return list;
    }

    private void updateSubmissionStatus(Connection conn,
                                        int submissionId,
                                        String newStatus) throws SQLException {
        String sql = "UPDATE submission " +
                "SET overall_status = ?, updated_at = CURRENT_TIMESTAMP " +
                "WHERE submission_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, submissionId);
            ps.executeUpdate();
        }
    }

    private SubmissionView mapSubmission(ResultSet rs) throws SQLException {
        SubmissionView v = new SubmissionView();
        v.setSubmissionId(rs.getInt("submission_id"));
        v.setStudentId(rs.getInt("student_id"));
        v.setStudentNo(rs.getString("student_no"));
        v.setRealName(rs.getString("real_name"));
        v.setTitle(rs.getString("title"));
        v.setType(rs.getString("type"));
        v.setContentPath(rs.getString("content_path"));
        v.setOverallStatus(rs.getString("overall_status"));
        // 你可以根据需要在 JSP 显示 created_at 还是 updated_at
        v.setCreatedAt(rs.getTimestamp("updated_at"));
        return v;
    }

    public static class SubmissionView {
        private int submissionId;
        private int studentId;
        private String studentNo;
        private String realName;
        private String title;
        private String type;
        private String contentPath;
        private String overallStatus;
        private java.util.Date createdAt; // 这里我沿用 createdAt 字段名，实际存的是 updated_at

        public int getSubmissionId() { return submissionId; }
        public void setSubmissionId(int submissionId) { this.submissionId = submissionId; }

        public int getStudentId() { return studentId; }
        public void setStudentId(int studentId) { this.studentId = studentId; }

        public String getStudentNo() { return studentNo; }
        public void setStudentNo(String studentNo) { this.studentNo = studentNo; }

        public String getRealName() { return realName; }
        public void setRealName(String realName) { this.realName = realName; }

        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }

        public String getType() { return type; }
        public void setType(String type) { this.type = type; }

        public String getContentPath() { return contentPath; }
        public void setContentPath(String contentPath) { this.contentPath = contentPath; }

        public String getOverallStatus() { return overallStatus; }
        public void setOverallStatus(String overallStatus) { this.overallStatus = overallStatus; }

        public java.util.Date getCreatedAt() { return createdAt; }
        public void setCreatedAt(java.util.Date createdAt) { this.createdAt = createdAt; }
    }
}