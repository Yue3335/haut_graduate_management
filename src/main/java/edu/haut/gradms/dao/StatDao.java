package edu.haut.gradms.dao;

import edu.haut.gradms.config.DBUtil;

import java.sql.*;
import java.util.*;

/**
 * 各类统计 DAO
 */
public class StatDao {

    /**
     * 按专业统计学生人数，并带出所属学院名称
     * 返回的每条 Map 至少包含：
     *  - deptName  : 学院名称
     *  - majorName : 专业名称
     *  - count     : 该专业学生人数
     */
    public List<Map<String, Object>> countStudentsByMajor() {
        String sql =
                "SELECT d.dept_name AS deptName, " +
                        "       m.major_name AS majorName, " +
                        "       COUNT(*) AS count " +
                        "FROM student s " +
                        "JOIN major m ON s.major_id = m.major_id " +
                        "JOIN department d ON m.dept_id = d.dept_id " +
                        "GROUP BY d.dept_id, d.dept_name, m.major_id, m.major_name " +
                        "ORDER BY d.dept_id, m.major_id";

        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("deptName", rs.getString("deptName"));
                row.put("majorName", rs.getString("majorName"));
                row.put("count", rs.getInt("count"));
                list.add(row);
            }
        } catch (SQLException e) {
            throw new RuntimeException("统计各专业学生人数失败", e);
        }

        return list;
    }

    /**
     * 按指导老师统计带生人数
     * 假设你原来已经实现好了，这里给一个示例实现
     */
    public List<Map<String, Object>> countStudentsByTeacher() {
        String sql =
                "SELECT u.real_name AS teacherName, " +
                        "       COUNT(ss.student_id) AS count " +
                        "FROM student_supervisor ss " +
                        "JOIN user u ON u.user_id = ss.supervisor_user_id " +
                        "GROUP BY ss.supervisor_user_id, u.real_name " +
                        "ORDER BY count DESC, u.real_name";

        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("teacherName", rs.getString("teacherName"));
                row.put("count", rs.getInt("count"));
                list.add(row);
            }
        } catch (SQLException e) {
            throw new RuntimeException("统计指导老师带生人数失败", e);
        }

        return list;
    }
}