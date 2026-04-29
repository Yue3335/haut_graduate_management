package edu.haut.gradms.dao;

import edu.haut.gradms.config.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DepartmentDao {

    public static class Department {
        private int deptId;
        private String deptName;

        public int getDeptId() { return deptId; }
        public void setDeptId(int deptId) { this.deptId = deptId; }
        public String getDeptName() { return deptName; }
        public void setDeptName(String deptName) { this.deptName = deptName; }
    }

    public List<Department> listAll() {
        List<Department> list = new ArrayList<>();
        String sql = "SELECT dept_id, dept_name FROM department ORDER BY dept_name";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Department d = new Department();
                d.setDeptId(rs.getInt("dept_id"));
                d.setDeptName(rs.getString("dept_name"));
                list.add(d);
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询学院列表失败", e);
        }
        return list;
    }
}