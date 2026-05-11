package edu.haut.gradms.dao;

import edu.haut.gradms.config.DBUtil;
import edu.haut.gradms.model.User;

import java.sql.*;
import java.util.HashSet;
import java.util.Set;

public class UserDao implements IUserDao {

    public User findByUsername(String username) {
        String sql = "SELECT * FROM user WHERE username = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setUserId(rs.getInt("user_id"));
                    u.setUsername(rs.getString("username"));
                    u.setPasswordHash(rs.getString("password_hash"));
                    u.setRealName(rs.getString("real_name"));
                    u.setGender(rs.getString("gender"));
                    u.setPhone(rs.getString("phone"));
                    u.setEmail(rs.getString("email"));
                    u.setStatus(rs.getInt("status"));
                    u.setRoles(findRoleNamesByUserId(u.getUserId()));
                    return u;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询用户失败", e);
        }
        return null;
    }

    public Set<String> findRoleNamesByUserId(int userId) {
        Set<String> roles = new HashSet<>();
        String sql = "SELECT r.role_name " +
                "FROM user_role ur " +
                "JOIN role r ON ur.role_id = r.role_id " +
                "WHERE ur.user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    roles.add(rs.getString("role_name"));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询用户角色失败", e);
        }
        return roles;
    }

    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setUsername(rs.getString("username"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setRealName(rs.getString("real_name"));
        u.setGender(rs.getString("gender"));
        u.setPhone(rs.getString("phone"));
        u.setEmail(rs.getString("email"));
        u.setStatus(rs.getInt("status"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        u.setLastLoginAt(rs.getTimestamp("last_login_at"));
        u.setUpdatedAt(rs.getTimestamp("updated_at"));
        return u;
    }

    public User findById(int userId) {
        String sql = "SELECT * FROM user WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("按ID查询用户失败", e);
        }
        return null;
    }

}