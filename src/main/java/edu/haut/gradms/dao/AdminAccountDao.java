package edu.haut.gradms.dao;

import edu.haut.gradms.config.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 管理员：账号与密码管理相关 DAO
 */
public class AdminAccountDao {

    public Connection getConnection() throws SQLException {
        return DBUtil.getConnection();
    }

    /**
     * 按关键字和角色查询用户列表
     *
     * @param keyword  用户名或真实姓名模糊查询，可为 null
     * @param roleName 角色名（STUDENT / SUPERVISOR / COUNSELOR / CLASS_TEACHER / ADMIN），可为 null
     */
    public List<UserView> listUsers(String keyword, String roleName) {
        List<UserView> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT u.user_id, u.username, u.real_name, u.status, " +
                        "       GROUP_CONCAT(DISTINCT r.role_name ORDER BY r.role_name SEPARATOR ',') AS roles " +
                        "FROM user u " +
                        "LEFT JOIN user_role ur ON ur.user_id = u.user_id " +
                        "LEFT JOIN role r ON r.role_id = ur.role_id " +
                        "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.isEmpty()) {
            sql.append("AND (u.username LIKE ? OR u.real_name LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }

        if (roleName != null && !roleName.isEmpty()) {
            sql.append("AND EXISTS ( " +
                    "   SELECT 1 FROM user_role ur2 " +
                    "   JOIN role r2 ON r2.role_id = ur2.role_id " +
                    "   WHERE ur2.user_id = u.user_id AND r2.role_name = ? " +
                    ") ");
            params.add(roleName.trim());
        }

        sql.append("GROUP BY u.user_id, u.username, u.real_name, u.status ");
        sql.append("ORDER BY u.created_at DESC ");

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    UserView v = new UserView();
                    v.setUserId(rs.getInt("user_id"));
                    v.setUsername(rs.getString("username"));
                    v.setRealName(rs.getString("real_name"));
                    v.setStatus(rs.getInt("status"));
                    v.setRoles(rs.getString("roles")); // 可能是 "ADMIN,TEACHER"
                    list.add(v);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    /** 查询单个用户当前状态（1=正常,0=禁用） */
    public int getUserStatus(int userId) {
        String sql = "SELECT status FROM user WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("status");
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询用户状态失败", e);
        }
        return 1;
    }

    /** 更新用户状态：1=正常，0=禁用 */
    public void updateUserStatus(int userId, int status) {
        String sql = "UPDATE user SET status = ? WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, status);
            ps.setInt(2, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("更新用户状态失败", e);
        }
    }

    /** 重置用户密码为默认值（示例为明文 123456，真实项目请改为加密） */
    public void resetUserPassword(int userId) {
        // TODO: 这里应该使用你项目统一的密码加密工具，
        // 例如 BCrypt.hashpw("123456", BCrypt.gensalt())
        String defaultPasswordHash = "123456";

        String sql = "UPDATE user SET password_hash = ? WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, defaultPasswordHash);
            ps.setInt(2, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("重置用户密码失败", e);
        }
    }

    public static class UserView {
        private int userId;
        private String username;
        private String realName;
        private String roles;
        private int status; // 1=正常,0=禁用

        public int getUserId() { return userId; }
        public void setUserId(int userId) { this.userId = userId; }

        public String getUsername() { return username; }
        public void setUsername(String username) { this.username = username; }

        public String getRealName() { return realName; }
        public void setRealName(String realName) { this.realName = realName; }

        public String getRoles() { return roles; }
        public void setRoles(String roles) { this.roles = roles; }

        public int getStatus() { return status; }
        public void setStatus(int status) { this.status = status; }
    }
}