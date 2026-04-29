package edu.haut.gradms.dao;

import edu.haut.gradms.config.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AdminStudentDao {

    private Connection getConnection() throws SQLException {
        return DBUtil.getConnection();
    }

    public List<StudentView> listStudents(String keyword, String majorName, String className) {
        List<StudentView> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT s.student_id, s.student_no, u.real_name, " +
                        "       m.major_name, c.class_name, s.enroll_year, s.status " +
                        "FROM student s " +
                        "JOIN user u ON u.user_id = s.user_id " +
                        "JOIN major m ON m.major_id = s.major_id " +
                        "JOIN class c ON c.class_id = s.class_id " +
                        "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.isEmpty()) {
            sql.append("AND (s.student_no LIKE ? OR u.real_name LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }
        if (majorName != null && !majorName.isEmpty()) {
            sql.append("AND m.major_name LIKE ? ");
            params.add("%" + majorName.trim() + "%");
        }
        if (className != null && !className.isEmpty()) {
            sql.append("AND c.class_name LIKE ? ");
            params.add("%" + className.trim() + "%");
        }

        sql.append("ORDER BY s.enroll_year DESC, m.major_name, c.class_name, s.student_no");

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    StudentView v = new StudentView();
                    v.setStudentId(rs.getInt("student_id"));
                    v.setStudentNo(rs.getString("student_no"));
                    v.setRealName(rs.getString("real_name"));
                    v.setMajorName(rs.getString("major_name"));
                    v.setClassName(rs.getString("class_name"));
                    v.setEnrollYear(rs.getString("enroll_year"));
                    v.setStatus(rs.getInt("status"));
                    list.add(v);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public static class StudentView {
        private int studentId;
        private String studentNo;
        private String realName;
        private String majorName;
        private String className;
        private String enrollYear;
        private int status;

        public int getStudentId() { return studentId; }
        public void setStudentId(int studentId) { this.studentId = studentId; }
        public String getStudentNo() { return studentNo; }
        public void setStudentNo(String studentNo) { this.studentNo = studentNo; }
        public String getRealName() { return realName; }
        public void setRealName(String realName) { this.realName = realName; }
        public String getMajorName() { return majorName; }
        public void setMajorName(String majorName) { this.majorName = majorName; }
        public String getClassName() { return className; }
        public void setClassName(String className) { this.className = className; }
        public String getEnrollYear() { return enrollYear; }
        public void setEnrollYear(String enrollYear) { this.enrollYear = enrollYear; }
        public int getStatus() { return status; }
        public void setStatus(int status) { this.status = status; }
    }
}