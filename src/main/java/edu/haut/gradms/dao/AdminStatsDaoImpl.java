package edu.haut.gradms.dao;

import edu.haut.gradms.config.DBUtil;
import edu.haut.gradms.model.dto.DeptMajorStudentCount;
import edu.haut.gradms.model.dto.SupervisorStudentCount;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 管理员统计 DAO 实现
 */
public class AdminStatsDaoImpl implements AdminStatsDao {

    private Connection getConnection() throws SQLException {
        return DBUtil.getConnection();
    }

    @Override
    public List<DeptMajorStudentCount> findDeptMajorStudentCounts() throws SQLException {
        String sql =
                "SELECT " +
                        "    d.dept_id    AS dept_id, " +
                        "    d.dept_name  AS dept_name, " +
                        "    m.major_id   AS major_id, " +
                        "    m.major_name AS major_name, " +
                        "    COUNT(s.student_id) AS student_count " +
                        "FROM department d " +
                        "LEFT JOIN major m ON m.dept_id = d.dept_id " +
                        "LEFT JOIN student s ON s.major_id = m.major_id " +
                        "GROUP BY d.dept_id, d.dept_name, m.major_id, m.major_name " +
                        "ORDER BY d.dept_id, m.major_id";

        List<DeptMajorStudentCount> list = new ArrayList<>();

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                DeptMajorStudentCount dto = new DeptMajorStudentCount();
                dto.setDeptId(rs.getInt("dept_id"));
                dto.setDeptName(rs.getString("dept_name"));

                int majorId = rs.getInt("major_id");
                if (rs.wasNull()) {
                    dto.setMajorId(null);
                } else {
                    dto.setMajorId(majorId);
                }

                dto.setMajorName(rs.getString("major_name"));
                dto.setStudentCount(rs.getInt("student_count"));
                list.add(dto);
            }
        }
        return list;
    }

    @Override
    public List<SupervisorStudentCount> findSupervisorStudentCounts() throws SQLException {
        String sql =
                "SELECT " +
                        "    u.user_id      AS teacher_user_id, " +
                        "    u.username     AS teacher_username, " +
                        "    u.real_name    AS teacher_name, " +
                        "    COUNT(DISTINCT ss.student_id) AS student_count " +
                        "FROM user u " +
                        "JOIN user_role ur ON ur.user_id = u.user_id " +
                        "JOIN role r ON r.role_id = ur.role_id AND r.role_name = 'SUPERVISOR' " +
                        "LEFT JOIN student_supervisor ss ON ss.supervisor_user_id = u.user_id " +
                        "GROUP BY u.user_id, u.username, u.real_name " +
                        "HAVING COUNT(DISTINCT ss.student_id) >= 1 " +
                        "ORDER BY student_count DESC, u.user_id";

        List<SupervisorStudentCount> list = new ArrayList<>();

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                SupervisorStudentCount dto = new SupervisorStudentCount();
                dto.setTeacherUserId(rs.getInt("teacher_user_id"));
                dto.setTeacherUsername(rs.getString("teacher_username"));
                dto.setTeacherName(rs.getString("teacher_name"));
                dto.setStudentCount(rs.getInt("student_count"));
                list.add(dto);
            }
        }

        return list;
    }
}