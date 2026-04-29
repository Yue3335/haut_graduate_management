package edu.haut.gradms.dao;

import edu.haut.gradms.config.DBUtil;
import edu.haut.gradms.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class StudentSupervisorDao {

    /**
     * 根据 student_id 查找其指导老师 User 信息
     */
    public User findSupervisorByStudentId(int studentId) {
        String sql = "SELECT u.* " +
                "FROM student_supervisor ss " +
                "JOIN user u ON ss.supervisor_user_id = u.user_id " +
                "WHERE ss.student_id = ? " +
                "ORDER BY ss.created_at DESC " +
                "LIMIT 1";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setUserId(rs.getInt("user_id"));
                    u.setUsername(rs.getString("username"));
                    u.setRealName(rs.getString("real_name"));
                    u.setGender(rs.getString("gender"));
                    u.setPhone(rs.getString("phone"));
                    u.setEmail(rs.getString("email"));
                    u.setStatus(rs.getInt("status"));
                    return u;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询指导老师失败", e);
        }
        return null;
    }
}