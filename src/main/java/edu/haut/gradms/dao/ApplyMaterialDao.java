package edu.haut.gradms.dao;

import edu.haut.gradms.config.DBUtil;
import edu.haut.gradms.model.ApplyMaterial;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ApplyMaterialDao {

    private ApplyMaterial mapRow(ResultSet rs) throws SQLException {
        ApplyMaterial a = new ApplyMaterial();
        a.setApplyId(rs.getInt("apply_id"));
        a.setStudentId(rs.getInt("student_id"));
        a.setTitle(rs.getString("title"));
        a.setType(rs.getString("type"));
        a.setFilePath(rs.getString("file_path"));
        a.setStatus(rs.getString("status"));
        a.setRemark(rs.getString("remark"));
        a.setCreatedAt(rs.getTimestamp("created_at"));
        a.setUpdatedAt(rs.getTimestamp("updated_at"));
        return a;
    }

    public ApplyMaterial findById(int applyId) {
        String sql = "SELECT * FROM apply_material WHERE apply_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, applyId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("按ID查询申请材料失败", e);
        }
        return null;
    }

    public List<ApplyMaterial> findByStudentId(int studentId) {
        List<ApplyMaterial> list = new ArrayList<>();
        String sql = "SELECT * FROM apply_material WHERE student_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("按学生ID查询申请材料失败", e);
        }
        return list;
    }

    public List<ApplyMaterial> findAll() {
        List<ApplyMaterial> list = new ArrayList<>();
        String sql = "SELECT * FROM apply_material ORDER BY created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询全部申请材料失败", e);
        }
        return list;
    }

    public void insert(ApplyMaterial a) {
        String sql = "INSERT INTO apply_material(student_id, title, type, file_path, status, remark) " +
                "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, a.getStudentId());
            ps.setString(2, a.getTitle());
            ps.setString(3, a.getType());
            ps.setString(4, a.getFilePath());
            ps.setString(5, a.getStatus());
            ps.setString(6, a.getRemark());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    a.setApplyId(rs.getInt(1));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("插入申请材料失败", e);
        }
    }

    public void updateStatus(int applyId, String status, String remark) {
        String sql = "UPDATE apply_material SET status = ?, remark = ? WHERE apply_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, remark);
            ps.setInt(3, applyId);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("更新申请材料状态失败", e);
        }
    }
}