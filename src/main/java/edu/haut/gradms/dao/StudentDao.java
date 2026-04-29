package edu.haut.gradms.dao;

import edu.haut.gradms.config.DBUtil;
import edu.haut.gradms.model.EmploymentInfo;
import edu.haut.gradms.model.Student;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class StudentDao {

    public Student findByUserId(int userId) {
        String sql = "SELECT s.*, d.dept_name, m.major_name, c.class_name " +
                "FROM student s " +
                "JOIN department d ON s.dept_id = d.dept_id " +
                "JOIN major m ON s.major_id = m.major_id " +
                "JOIN class c ON s.class_id = c.class_id " +
                "WHERE s.user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Student s = new Student();
                    s.setStudentId(rs.getInt("student_id"));
                    s.setUserId(rs.getInt("user_id"));
                    s.setStudentNo(rs.getString("student_no"));
                    s.setDeptId(rs.getInt("dept_id"));
                    s.setDeptName(rs.getString("dept_name"));
                    s.setMajorId(rs.getInt("major_id"));
                    s.setMajorName(rs.getString("major_name"));
                    s.setClassId(rs.getInt("class_id"));
                    s.setClassName(rs.getString("class_name"));
                    s.setEnrollYear(rs.getInt("enroll_year"));
                    return s;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询学生信息失败", e);
        }
        return null;
    }

    /**
     * 更新学生在 student 表中的信息（目前只开放手机号、邮箱、住址等可以扩展）
     * 这里假设在 student 表中有 phone/email/address 字段；
     * 如果你实际是在 user 表中存 phone/email，可在 UserDao 中改。
     */
    public void updateContactInfo(int userId, String phone, String email) {
        String sqlUser = "UPDATE user SET phone = ?, email = ? WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlUser)) {

            ps.setString(1, phone);
            ps.setString(2, email);
            ps.setInt(3, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("更新联系方式失败", e);
        }
    }

    public EmploymentInfo findById(int studentId) {
        String sql = "SELECT * FROM student WHERE student_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("按ID查询学生失败", e);
        }
        return null;
    }

    private EmploymentInfo mapRow(ResultSet rs) throws SQLException {
        EmploymentInfo info = new EmploymentInfo();

        // 主键
        try {
            info.setEmploymentId(rs.getInt("employment_id"));
        } catch (SQLException ignored) {}

        // 基本字段
        try {
            info.setStudentId(rs.getInt("student_id"));
        } catch (SQLException ignored) {}

        try {
            info.setStatus(rs.getString("status")); // 未就业 / 已就业 / 考研 / 出国 / 其他
        } catch (SQLException ignored) {}

        try {
            info.setCompanyName(rs.getString("company_name"));
        } catch (SQLException ignored) {}

        try {
            info.setPosition(rs.getString("position"));
        } catch (SQLException ignored) {}

        try {
            info.setCity(rs.getString("city"));
        } catch (SQLException ignored) {}

        try {
            info.setRemark(rs.getString("remark"));
        } catch (SQLException ignored) {}

        // 薪资
        try {
            info.setSalaryMonth(rs.getBigDecimal("salary_month"));
        } catch (SQLException ignored) {}

        // 登记时间
        try {
            info.setReportTime(rs.getTimestamp("report_time"));
        } catch (SQLException ignored) {}

        // 审核相关字段（如果表里有）
        try {
            info.setReviewStatus(rs.getString("review_status"));   // APPROVED / REJECTED / PENDING
        } catch (SQLException ignored) {}

        try {
            info.setReviewRemark(rs.getString("review_remark"));
        } catch (SQLException ignored) {}

        return info;
    }

    public List<Student> findStudentsByClassTeacherUserId(int teacherUserId) {
        List<Student> list = new ArrayList<>();
        String sql =
                "SELECT s.* " +
                        "FROM student s " +
                        "JOIN class c ON s.class_id = c.class_id " +
                        "WHERE c.class_teacher_user_id = ? " +
                        "ORDER BY s.student_no";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, teacherUserId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs)); // 这个 mapRow 就是你 StudentDao 里把一行转 Student 的方法
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("按班主任查询其管理的学生列表失败", e);
        }
        return list;
    }

}