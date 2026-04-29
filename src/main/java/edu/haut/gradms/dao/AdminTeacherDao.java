package edu.haut.gradms.dao;

import edu.haut.gradms.config.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 管理员用指导老师 / 辅导员 / 班主任查询 DAO
 */
public class AdminTeacherDao {

    private Connection getConnection() throws SQLException {
        return DBUtil.getConnection();
    }

    /**
     * 老师列表 + 当前带生数量 + 按身份过滤
     *
     * @param keyword  姓名/工号关键词，可为 null
     * @param deptName 学院名称关键词，可为 null
     * @param identity 身份：SUPERVISOR / COUNSELOR / CLASS_TEACHER / null(全部)
     */
    public List<TeacherView> listTeachers(String keyword, String deptName, String identity) {
        List<TeacherView> list = new ArrayList<>();

        // 先查出老师的基本信息和所有角色（用 GROUP_CONCAT 收集角色，后面再拆分判断）
        StringBuilder sql = new StringBuilder(
                "SELECT t.teacher_id, t.teacher_no, u.username, u.real_name, d.dept_name, " +
                        "       t.title, t.is_counselor, u.user_id, " +
                        "       GROUP_CONCAT(DISTINCT r.role_name) AS roles " +
                        "FROM teacher t " +
                        "JOIN user u ON u.user_id = t.user_id " +
                        "JOIN department d ON d.dept_id = t.dept_id " +
                        "LEFT JOIN user_role ur ON ur.user_id = u.user_id " +
                        "LEFT JOIN role r ON r.role_id = ur.role_id "
        );

        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.isEmpty()) {
            sql.append("AND (t.teacher_no LIKE ? OR u.real_name LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }
        if (deptName != null && !deptName.isEmpty()) {
            sql.append("AND d.dept_name LIKE ? ");
            params.add("%" + deptName.trim() + "%");
        }
        if (identity != null && !identity.isEmpty()) {
            // 这里在 SQL 里初步过滤某个角色，防止数据太多
            sql.append("AND EXISTS ( " +
                    "   SELECT 1 FROM user_role ur2 " +
                    "   JOIN role r2 ON r2.role_id = ur2.role_id " +
                    "   WHERE ur2.user_id = u.user_id AND r2.role_name = ? " +
                    ") ");
            params.add(identity.trim());
        }

        sql.append("GROUP BY t.teacher_id, t.teacher_no, u.username, u.real_name, d.dept_name, " +
                "         t.title, t.is_counselor, u.user_id ");
        sql.append("ORDER BY d.dept_name, u.real_name");

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TeacherView v = new TeacherView();
                    int teacherId = rs.getInt("teacher_id");
                    int userId = rs.getInt("user_id");
                    String rolesStr = rs.getString("roles"); // 可能为 null

                    v.setTeacherId(teacherId);
                    v.setTeacherNo(rs.getString("teacher_no"));
                    v.setUsername(rs.getString("username"));
                    v.setRealName(rs.getString("real_name"));
                    v.setDeptName(rs.getString("dept_name"));
                    v.setTitle(rs.getString("title"));
                    v.setIsCounselor(rs.getInt("is_counselor"));

                    int currentCount = 0;
                    if (rolesStr != null) {
                        // 按角色分别累加对应范围的学生数
                        if (rolesStr.contains("CLASS_TEACHER")) {
                            currentCount += countStudentsByClassTeacher(userId);
                        }
                        if (rolesStr.contains("COUNSELOR")) {
                            currentCount += countStudentsByCounselor(userId);
                        }
                        if (rolesStr.contains("SUPERVISOR")) {
                            currentCount += countStudentsBySupervisor(userId);
                        }
                    }

                    v.setCurrentStudentCount(currentCount);
                    // 最大带生数先留空，后续可从配置表读取
                    v.setMaxStudentCount(null);

                    list.add(v);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    // ========== 各角色对应的“带生数”统计方法 ==========

    /**
     * 班主任：统计其担任班主任的所有班级中的学生总数
     *
     * 通过 class.class_teacher_user_id = userId 关联出班级，再数 student.class_id 对应的学生数。
     */
    private int countStudentsByClassTeacher(int userId) {
        String sql =
                "SELECT COUNT(*) AS cnt " +
                        "FROM student s " +
                        "JOIN class c ON s.class_id = c.class_id " +
                        "WHERE c.class_teacher_user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cnt");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * 辅导员：统计 student_counselor 表中属于该辅导员的学生数
     */
    private int countStudentsByCounselor(int userId) {
        String sql =
                "SELECT COUNT(*) AS cnt " +
                        "FROM student_counselor sc " +
                        "WHERE sc.counselor_user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cnt");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * 指导老师（SUPERVISOR）：统计 student_supervisor 表中属于该导师的学生数
     */
    private int countStudentsBySupervisor(int userId) {
        String sql =
                "SELECT COUNT(*) AS cnt " +
                        "FROM student_supervisor ss " +
                        "WHERE ss.supervisor_user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cnt");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ========== 视图类 ==========

    // 简单视图类（可单独放在一个包里，这里为方便放内部）
    public static class TeacherView {
        private int teacherId;
        private String teacherNo;
        private String username;           // 新增：用户名
        private String realName;
        private String deptName;
        private String title;
        private int isCounselor;
        private int currentStudentCount;
        private Integer maxStudentCount;

        public int getTeacherId() { return teacherId; }
        public void setTeacherId(int teacherId) { this.teacherId = teacherId; }

        public String getTeacherNo() { return teacherNo; }
        public void setTeacherNo(String teacherNo) { this.teacherNo = teacherNo; }

        public String getUsername() { return username; }
        public void setUsername(String username) { this.username = username; }

        public String getRealName() { return realName; }
        public void setRealName(String realName) { this.realName = realName; }

        public String getDeptName() { return deptName; }
        public void setDeptName(String deptName) { this.deptName = deptName; }

        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }

        public int getIsCounselor() { return isCounselor; }
        public void setIsCounselor(int isCounselor) { this.isCounselor = isCounselor; }

        public int getCurrentStudentCount() { return currentStudentCount; }
        public void setCurrentStudentCount(int currentStudentCount) { this.currentStudentCount = currentStudentCount; }

        public Integer getMaxStudentCount() { return maxStudentCount; }
        public void setMaxStudentCount(Integer maxStudentCount) { this.maxStudentCount = maxStudentCount; }
    }

    /**
     * 只返回拥有 SUPERVISOR 角色的老师列表（指导老师）。
     * 用于：管理员“指导关系分配”页面的下拉框。
     */
    public List<TeacherView> listSupervisors() {
        List<TeacherView> list = new ArrayList<>();

        String sql =
                "SELECT t.teacher_id, t.teacher_no, u.username, u.real_name, d.dept_name, " +
                        "       t.title, t.is_counselor, u.user_id " +
                        "FROM teacher t " +
                        "JOIN user u ON t.user_id = u.user_id " +
                        "JOIN department d ON t.dept_id = d.dept_id " +
                        "JOIN user_role ur ON ur.user_id = u.user_id " +
                        "JOIN role r ON r.role_id = ur.role_id " +
                        "WHERE r.role_name = 'SUPERVISOR' " +
                        "ORDER BY d.dept_name, t.teacher_no";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                TeacherView v = new TeacherView();
                int userId = rs.getInt("user_id");

                v.setTeacherId(rs.getInt("teacher_id"));
                v.setTeacherNo(rs.getString("teacher_no"));
                v.setUsername(rs.getString("username"));
                v.setRealName(rs.getString("real_name"));
                v.setDeptName(rs.getString("dept_name"));
                v.setTitle(rs.getString("title"));
                v.setIsCounselor(rs.getInt("is_counselor"));

                // 对于 listSupervisors，这里“当前带生数”就用导师角色的学生数
                int currentCount = countStudentsBySupervisor(userId);
                v.setCurrentStudentCount(currentCount);

                v.setMaxStudentCount(null); // 仍然留空

                list.add(v);
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询指导老师列表失败", e);
        }

        return list;
    }
}