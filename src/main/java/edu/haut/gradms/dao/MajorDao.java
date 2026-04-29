package edu.haut.gradms.dao;

import edu.haut.gradms.config.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MajorDao {

    public static class Major {
        private int majorId;
        private String majorName;

        public int getMajorId() {
            return majorId;
        }
        public void setMajorId(int majorId) {
            this.majorId = majorId;
        }

        public String getMajorName() {
            return majorName;
        }
        public void setMajorName(String majorName) {
            this.majorName = majorName;
        }
    }

    public List<Major> listByDeptId(int deptId) {
        List<Major> list = new ArrayList<>();
        String sql = "SELECT major_id, major_name " +
                "FROM major WHERE dept_id = ? " +
                "ORDER BY major_name";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, deptId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Major m = new Major();
                    m.setMajorId(rs.getInt("major_id"));
                    m.setMajorName(rs.getString("major_name"));
                    list.add(m);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("按学院查询专业列表失败", e);
        }
        return list;
    }
}