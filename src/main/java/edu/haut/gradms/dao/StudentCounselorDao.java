package edu.haut.gradms.dao;

import edu.haut.gradms.config.DBUtil;
import edu.haut.gradms.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class StudentCounselorDao {

    /**
     * 根据 student_id 查找其辅导员 User 信息
     */
    /**
     * 根据 student_id 查找其辅导员 User 信息
     * 通过视图 v_student_latest_counselor 获取，
     * 视图在数据库中预先封装了“每个学生最新一条辅导员记录”的逻辑。
     */
    public User findCounselorByStudentId(int studentId) {
        String sql = "SELECT * FROM v_student_latest_counselor WHERE student_id = ?";

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
            throw new RuntimeException("通过视图查询辅导员失败", e);
        }
        return null;
    }
}