package edu.haut.gradms.dao;

import edu.haut.gradms.config.DBUtil;

import java.sql.*;
import java.util.HashMap;
import java.util.Map;

/**
 * 就业统计 DAO：
 * 按“每个学生最新一条 employment_info 记录”来统计不同就业状态的人数分布，
 * 并支持按不同教师角色（班主任、辅导员、导师、普通教师）过滤学生范围。
 */
public class EmploymentStatsDao {

    /**
     * 统计【全校所有学生】的最新就业状态人数分布。
     * 返回 Map<status, count>，status 对应 employment_info.status 字段。
     */
    public Map<String, Long> countLatestStatusAllStudents() {
        String sql =
                "SELECT ei.status, COUNT(*) AS cnt " +
                        "FROM employment_info ei " +
                        "JOIN ( " +
                        "   SELECT student_id, MAX(report_time) AS max_report_time " +
                        "   FROM employment_info " +
                        "   GROUP BY student_id " +
                        ") t ON ei.student_id = t.student_id AND ei.report_time = t.max_report_time " +
                        "GROUP BY ei.status";

        return executeStatusCountQuery(sql);
    }

    /**
     * 班主任：只统计【自己班级学生】的最新就业状态。
     *
     * 班主任信息在 class 表：
     *   class.class_teacher_user_id = 当前班主任的 user_id
     *
     * 关联路径：
     *   employment_info -> student (student_id) -> class (class_id)
     */
    public Map<String, Long> countLatestStatusByClassTeacher(int teacherUserId) {
        String sql =
                "SELECT ei.status, COUNT(*) AS cnt " +
                        "FROM employment_info ei " +
                        "JOIN ( " +
                        "   SELECT student_id, MAX(report_time) AS max_report_time " +
                        "   FROM employment_info " +
                        "   GROUP BY student_id " +
                        ") t ON ei.student_id = t.student_id AND ei.report_time = t.max_report_time " +
                        "JOIN student s ON ei.student_id = s.student_id " +
                        "JOIN class c ON s.class_id = c.class_id " +
                        "WHERE c.class_teacher_user_id = ? " +
                        "GROUP BY ei.status";

        return executeStatusCountQuery(sql, teacherUserId);
    }

    /**
     * 辅导员：只统计【自己负责学生】的最新就业状态。
     *
     * 辅导员关系在 student_counselor 表：
     *   student_counselor(student_id, counselor_user_id)
     *
     * 关联路径：
     *   employment_info -> student (student_id) -> student_counselor (student_id, counselor_user_id)
     */
    public Map<String, Long> countLatestStatusByCounselor(int counselorUserId) {
        String sql =
                "SELECT ei.status, COUNT(*) AS cnt " +
                        "FROM employment_info ei " +
                        "JOIN ( " +
                        "   SELECT student_id, MAX(report_time) AS max_report_time " +
                        "   FROM employment_info " +
                        "   GROUP BY student_id " +
                        ") t ON ei.student_id = t.student_id AND ei.report_time = t.max_report_time " +
                        "JOIN student_counselor sc ON ei.student_id = sc.student_id " +
                        "WHERE sc.counselor_user_id = ? " +
                        "GROUP BY ei.status";

        return executeStatusCountQuery(sql, counselorUserId);
    }

    /**
     * 指导老师（SUPERVISOR）：只统计【自己指导的学生】最新就业状态。
     *
     * 导师关系在 student_supervisor 表：
     *   student_supervisor(student_id, supervisor_user_id)
     *
     * 关联路径：
     *   employment_info -> student_supervisor (student_id, supervisor_user_id)
     */
    public Map<String, Long> countLatestStatusBySupervisor(int supervisorUserId) {
        String sql =
                "SELECT ei.status, COUNT(*) AS cnt " +
                        "FROM employment_info ei " +
                        "JOIN ( " +
                        "   SELECT student_id, MAX(report_time) AS max_report_time " +
                        "   FROM employment_info " +
                        "   GROUP BY student_id " +
                        ") t ON ei.student_id = t.student_id AND ei.report_time = t.max_report_time " +
                        "JOIN student_supervisor ss ON ei.student_id = ss.student_id " +
                        "WHERE ss.supervisor_user_id = ? " +
                        "GROUP BY ei.status";

        return executeStatusCountQuery(sql, supervisorUserId);
    }

    /**
     * 普通教师（TEACHER）：你这边没有“普通教师 ↔ 学生”的直接关系表，
     * 所以这里暂时先按“所在学院的学生”来统计，或者你可以按业务需要调整。
     *
     * 这里给两种思路：
     *   A. 如果你以后建了 teacher_class / teacher_student 表，可以改成按那个表过滤；
     *   B. 目前先统计“本学院所有学生”的就业情况（teacher.dept_id = student.dept_id）。
     */
    public Map<String, Long> countLatestStatusByTeacher(int teacherUserId) {
        // 思路 B：按学院过滤（teacher.dept_id -> student.dept_id）
        String sql =
                "SELECT ei.status, COUNT(*) AS cnt " +
                        "FROM employment_info ei " +
                        "JOIN ( " +
                        "   SELECT student_id, MAX(report_time) AS max_report_time " +
                        "   FROM employment_info " +
                        "   GROUP BY student_id " +
                        ") t ON ei.student_id = t.student_id AND ei.report_time = t.max_report_time " +
                        "JOIN student s ON ei.student_id = s.student_id " +
                        "JOIN teacher t2 ON s.dept_id = t2.dept_id " +
                        "WHERE t2.user_id = ? " +
                        "GROUP BY ei.status";

        return executeStatusCountQuery(sql, teacherUserId);
    }

    // ================= 通用执行方法 =================

    /**
     * 通用执行方法（无 userId 条件）
     */
    private Map<String, Long> executeStatusCountQuery(String sql) {
        Map<String, Long> result = new HashMap<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String status = rs.getString("status");
                long cnt = rs.getLong("cnt");
                result.put(status, cnt);
            }
        } catch (SQLException e) {
            throw new RuntimeException("统计就业状态分布失败", e);
        }
        return result;
    }

    /**
     * 通用执行方法（带单个 userId 条件）
     */
    private Map<String, Long> executeStatusCountQuery(String sql, int userId) {
        Map<String, Long> result = new HashMap<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String status = rs.getString("status");
                    long cnt = rs.getLong("cnt");
                    result.put(status, cnt);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("带 userId 的就业状态统计失败", e);
        }
        return result;
    }
}