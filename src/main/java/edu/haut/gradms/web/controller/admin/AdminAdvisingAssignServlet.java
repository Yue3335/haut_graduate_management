package edu.haut.gradms.web.controller.admin;

import edu.haut.gradms.config.DBUtil;
import edu.haut.gradms.dao.AdminStudentDao;
import edu.haut.gradms.dao.AdminStudentDao.StudentView;
import edu.haut.gradms.dao.AdminTeacherDao;
import edu.haut.gradms.dao.AdminTeacherDao.TeacherView;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 管理员：指导关系分配（只管理学生 ↔ 指导老师）
 * URL: /admin/advising/assign
 */
@WebServlet("/admin/advising/assign")
public class AdminAdvisingAssignServlet extends HttpServlet {

    private final AdminTeacherDao teacherDao = new AdminTeacherDao();
    private final AdminStudentDao studentDao = new AdminStudentDao();

    private Connection getConnection() throws SQLException {
        return DBUtil.getConnection();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("isAdmin") == null
                || !(Boolean) session.getAttribute("isAdmin")) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无管理员访问权限");
            return;
        }

        req.setCharacterEncoding("UTF-8");

        // 1. 只取“指导老师（SUPERVISOR 角色）”列表用于下拉选择
        List<TeacherView> teachers = teacherDao.listSupervisors();
        req.setAttribute("teachers", teachers);

        // 2. 当前选中的老师
        String teacherIdStr = req.getParameter("teacherId");
        Integer currentTeacherId = null;
        if (teacherIdStr != null && !teacherIdStr.isEmpty()) {
            try {
                currentTeacherId = Integer.parseInt(teacherIdStr);
            } catch (NumberFormatException ignored) {}
        }
        req.setAttribute("currentTeacherId", currentTeacherId);

        TeacherView currentTeacher = null;
        if (currentTeacherId != null) {
            for (TeacherView t : teachers) {
                if (t.getTeacherId() == currentTeacherId) {
                    currentTeacher = t;
                    break;
                }
            }
        }
        req.setAttribute("currentTeacher", currentTeacher);

        // 如果没选老师，直接展示页面（只显示下拉和提示）
        if (currentTeacherId == null) {
            req.getRequestDispatcher("/WEB-INF/jsp/admin/advising/assign.jsp").forward(req, resp);
            return;
        }

        // 3. teacher_id -> supervisor_user_id
        Integer supervisorUserId = findSupervisorUserIdByTeacherId(currentTeacherId);

        List<StudentView> assignedStudents = new ArrayList<>();
        List<StudentView> unassignedStudents = new ArrayList<>();

        if (supervisorUserId != null) {
            assignedStudents = listAssignedStudents(supervisorUserId);
            unassignedStudents = listUnassignedStudents(supervisorUserId);
        }

        req.setAttribute("assignedStudents", assignedStudents);
        req.setAttribute("unassignedStudents", unassignedStudents);

        req.getRequestDispatcher("/WEB-INF/jsp/admin/advising/assign.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("isAdmin") == null
                || !(Boolean) session.getAttribute("isAdmin")) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无管理员访问权限");
            return;
        }

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        String teacherIdStr = req.getParameter("teacherId");

        System.out.println("[POST] /admin/advising/assign action=" + action + ", teacherId=" + teacherIdStr);

        if (teacherIdStr == null || teacherIdStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/advising/assign");
            return;
        }

        int teacherId;
        try {
            teacherId = Integer.parseInt(teacherIdStr);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/advising/assign");
            return;
        }

        Integer supervisorUserId = findSupervisorUserIdByTeacherId(teacherId);
        if (supervisorUserId == null) {
            System.out.println("[POST] supervisorUserId is null for teacherId=" + teacherId);
            resp.sendRedirect(req.getContextPath() + "/admin/advising/assign?teacherId=" + teacherId);
            return;
        }

        try {
            if ("assign".equals(action)) {
                String[] assignIds = req.getParameterValues("assignIds");
                if (assignIds != null && assignIds.length > 0) {
                    assignStudentsToSupervisor(supervisorUserId, assignIds);
                } else {
                    System.out.println("[POST] no assignIds selected");
                }
            } else if ("remove".equals(action)) {
                String[] removeIds = req.getParameterValues("removeIds");
                if (removeIds != null && removeIds.length > 0) {
                    removeStudentsFromSupervisor(supervisorUserId, removeIds);
                } else {
                    System.out.println("[POST] no removeIds selected");
                }
            } else {
                System.out.println("[POST] unknown action=" + action);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // 操作完成后，回到管理员首页，让首页图表基于最新数据刷新
        resp.sendRedirect(req.getContextPath() + "/admin/home?msg=advisingUpdated");
    }

    /** teacher_id -> 对应的 user_id（作为 student_supervisor.supervisor_user_id 使用） */
    private Integer findSupervisorUserIdByTeacherId(int teacherId) {
        String sql = "SELECT user_id FROM teacher WHERE teacher_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int uid = rs.getInt("user_id");
                    System.out.println("[findSupervisorUserIdByTeacherId] teacherId=" + teacherId + ", user_id=" + uid);
                    return uid;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /** 查询：已分配给该导师的学生列表 */
    private List<StudentView> listAssignedStudents(int supervisorUserId) {
        List<StudentView> list = new ArrayList<>();

        String sql = "SELECT s.student_id, s.student_no, u.real_name, " +
                "       m.major_name, c.class_name, s.enroll_year, s.status " +
                "FROM student_supervisor ss " +
                "JOIN student s ON s.student_id = ss.student_id " +
                "JOIN user u ON u.user_id = s.user_id " +
                "JOIN major m ON m.major_id = s.major_id " +
                "JOIN class c ON c.class_id = s.class_id " +
                "WHERE ss.supervisor_user_id = ? " +
                "ORDER BY m.major_name, c.class_name, s.student_no";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, supervisorUserId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    StudentView v = new StudentView();
                    v.setStudentId(rs.getInt("student_id"));
                    v.setStudentNo(rs.getString("student_no"));
                    v.setRealName(rs.getString("real_name"));
                    v.setMajorName(rs.getString("major_name"));
                    v.setClassName(rs.getString("class_name"));
                    v.setEnrollYear(rs.getString("enroll_year"));
                    v.setStatus(rs.getInt("status"));
                    list.add(v);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        System.out.println("[listAssignedStudents] supervisor_user_id=" + supervisorUserId + ", size=" + list.size());
        return list;
    }

    /** 查询：尚未由该导师指导的学生列表（排除 student_supervisor 中已有该导师的记录） */
    private List<StudentView> listUnassignedStudents(int supervisorUserId) {
        List<StudentView> list = new ArrayList<>();

        String sql = "SELECT s.student_id, s.student_no, u.real_name, " +
                "       m.major_name, c.class_name, s.enroll_year, s.status " +
                "FROM student s " +
                "JOIN user u ON u.user_id = s.user_id " +
                "JOIN major m ON m.major_id = s.major_id " +
                "JOIN class c ON c.class_id = s.class_id " +
                "WHERE s.student_id NOT IN ( " +
                "   SELECT ss.student_id FROM student_supervisor ss WHERE ss.supervisor_user_id = ? " +
                ") " +
                "ORDER BY m.major_name, c.class_name, s.student_no";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, supervisorUserId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    StudentView v = new StudentView();
                    v.setStudentId(rs.getInt("student_id"));
                    v.setStudentNo(rs.getString("student_no"));
                    v.setRealName(rs.getString("real_name"));
                    v.setMajorName(rs.getString("major_name"));
                    v.setClassName(rs.getString("class_name"));
                    v.setEnrollYear(rs.getString("enroll_year"));
                    v.setStatus(rs.getInt("status"));
                    list.add(v);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        System.out.println("[listUnassignedStudents] supervisor_user_id=" + supervisorUserId + ", size=" + list.size());
        return list;
    }

    /** 为该导师新增若干学生指导关系（INSERT INTO student_supervisor） */
    private void assignStudentsToSupervisor(int supervisorUserId, String[] studentIdStrs) throws SQLException {
        String sql = "INSERT IGNORE INTO student_supervisor (student_id, supervisor_user_id, relation_type) " +
                "VALUES (?, ?, '毕业设计')";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            for (String idStr : studentIdStrs) {
                try {
                    int sid = Integer.parseInt(idStr);
                    System.out.println("[ASSIGN] supervisor_user_id=" + supervisorUserId + ", student_id=" + sid);
                    ps.setInt(1, sid);
                    ps.setInt(2, supervisorUserId);
                    ps.addBatch();
                } catch (NumberFormatException ignored) {}
            }
            int[] results = ps.executeBatch();
            System.out.println("[ASSIGN] batch result length = " + results.length);
        }
    }

    /** 从该导师名下移除若干学生（DELETE FROM student_supervisor） */
    private void removeStudentsFromSupervisor(int supervisorUserId, String[] studentIdStrs) throws SQLException {
        String sql = "DELETE FROM student_supervisor WHERE supervisor_user_id = ? AND student_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            for (String idStr : studentIdStrs) {
                try {
                    int sid = Integer.parseInt(idStr);
                    System.out.println("[REMOVE] supervisor_user_id=" + supervisorUserId + ", student_id=" + sid);
                    ps.setInt(1, supervisorUserId);
                    ps.setInt(2, sid);
                    ps.addBatch();
                } catch (NumberFormatException ignored) {}
            }
            int[] results = ps.executeBatch();
            System.out.println("[REMOVE] batch result length = " + results.length);
        }
    }
}