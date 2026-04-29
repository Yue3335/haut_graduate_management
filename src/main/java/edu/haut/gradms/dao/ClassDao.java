package edu.haut.gradms.dao;

import edu.haut.gradms.config.DBUtil;
import edu.haut.gradms.model.ClassInfo;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ClassDao {

    public static class Clazz {
        private int classId;
        private String className;
        private int majorId;
        private int enrollYear;

        public int getClassId() { return classId; }
        public void setClassId(int classId) { this.classId = classId; }

        public String getClassName() { return className; }
        public void setClassName(String className) { this.className = className; }

        public int getMajorId() { return majorId; }
        public void setMajorId(int majorId) { this.majorId = majorId; }

        public int getEnrollYear() { return enrollYear; }
        public void setEnrollYear(int enrollYear) { this.enrollYear = enrollYear; }
    }

    /** 按专业查询班级列表，返回 ClassInfo 列表（不含班主任信息，列表场景够用） */
    public List<ClassInfo> listByMajorId(int majorId) {
        List<ClassInfo> list = new ArrayList<>();
        String sql =
                "SELECT class_id, class_name, major_id, enroll_year " +
                        "FROM class " +
                        "WHERE major_id = ? " +
                        "ORDER BY class_name";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, majorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ClassInfo c = new ClassInfo();
                    c.setClassId(rs.getInt("class_id"));
                    c.setClassName(rs.getString("class_name"));
                    c.setMajorId(rs.getInt("major_id"));
                    c.setEnrollYear(rs.getInt("enroll_year"));
                    // 列表场景暂时不需要班主任信息
                    list.add(c);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("按专业查询班级列表失败", e);
        }
        return list;
    }

    /** 按班级ID查询单个班级，返回 ClassInfo（包含班主任信息） */
    public ClassInfo findById(int classId) {
        String sql =
                "SELECT " +
                        "  c.class_id, " +
                        "  c.class_name, " +
                        "  c.major_id, " +
                        "  c.enroll_year, " +
                        "  c.class_teacher_user_id, " +
                        "  u.real_name AS classTeacherName " +
                        "FROM class c " +
                        "LEFT JOIN user u ON u.user_id = c.class_teacher_user_id " +
                        "WHERE c.class_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, classId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ClassInfo c = new ClassInfo();
                    c.setClassId(rs.getInt("class_id"));
                    c.setClassName(rs.getString("class_name"));
                    c.setMajorId(rs.getInt("major_id"));
                    c.setEnrollYear(rs.getInt("enroll_year"));

                    int teacherUserId = rs.getInt("class_teacher_user_id");
                    if (rs.wasNull()) {
                        c.setClassTeacherUserId(null);
                    } else {
                        c.setClassTeacherUserId(teacherUserId);
                    }

                    c.setClassTeacherName(rs.getString("classTeacherName"));
                    return c;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("按班级ID查询班级失败", e);
        }
        return null;
    }
}