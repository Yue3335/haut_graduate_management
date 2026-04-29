package edu.haut.gradms.dao;

import edu.haut.gradms.config.DBUtil;
import edu.haut.gradms.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserSimpleDao {

    public User findById(int userId) {
        String sql = "SELECT * FROM user WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
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
            throw new RuntimeException("根据 user_id 查询用户失败", e);
        }
        return null;
    }
}