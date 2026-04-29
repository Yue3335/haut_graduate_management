package edu.haut.gradms.service;

import edu.haut.gradms.config.DBUtil;

import java.sql.*;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

public class RegisterService {

    /**
     * 注册用户（非管理员）
     *
     * @throws IllegalArgumentException 业务校验未通过（例如用户名已存在、班主任唯一性失败）
     */
    public boolean registerUser(String username,
                                String realName,
                                String rawPassword,
                                String gender,
                                String phone,
                                String email,
                                String[] roles,
                                String studentClassIdStr,
                                String studentEnrollYearStr,
                                String classTeacherClassIdStr,
                                String counselorMajorIdStr) throws Exception {

        // 禁止自助注册管理员角色
        Set<String> roleSet = new HashSet<>(Arrays.asList(roles));
        if (roleSet.contains("ADMIN")) {
            throw new IllegalArgumentException("不允许自助注册管理员账号");
        }

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // 1. 检查用户名是否已存在
                if (existsUsername(conn, username)) {
                    throw new IllegalArgumentException("该用户名已存在，请更换一个");
                }

                // 2. 创建 user
                int userId = insertUser(conn, username, realName, rawPassword, gender, phone, email);

                // 3. 绑定角色（触发器会在插入 STUDENT 角色时自动插 student）
                for (String roleName : roleSet) {
                    int roleId = findRoleIdByName(conn, roleName);
                    if (roleId <= 0) {
                        throw new IllegalArgumentException("角色不存在：" + roleName);
                    }
                    insertUserRole(conn, userId, roleId);
                }

                // 4. 角色相关业务

                // 4.1 学生：根据选择的班级，更新 student 信息
                if (roleSet.contains("STUDENT")) {
                    if (studentClassIdStr == null || studentClassIdStr.isEmpty()
                            || studentEnrollYearStr == null || studentEnrollYearStr.isEmpty()) {
                        throw new IllegalArgumentException("选择学生角色时，必须选择班级并填写入学年份");
                    }

                    int classId;
                    int enrollYear;
                    try {
                        classId = Integer.parseInt(studentClassIdStr.trim());
                        enrollYear = Integer.parseInt(studentEnrollYearStr.trim());
                    } catch (NumberFormatException e) {
                        throw new IllegalArgumentException("班级ID或入学年份格式不正确");
                    }

                    int[] deptMajor = findDeptMajorByClassId(conn, classId);
                    if (deptMajor == null) {
                        throw new IllegalArgumentException("无效的班级ID：" + classId);
                    }

                    // 触发器已插入一条默认 student，这里更新该记录为实际学院/专业/班级/入学年份
                    updateStudentByUserId(conn, userId, deptMajor[0], deptMajor[1], classId, enrollYear);
                }

                // 4.2 班主任：一个班只有一个班主任（使用 class.class_teacher_user_id）
                if (roleSet.contains("CLASS_TEACHER")) {
                    if (classTeacherClassIdStr == null || classTeacherClassIdStr.isEmpty()) {
                        throw new IllegalArgumentException("选择班主任角色时，必须指定班级ID");
                    }
                    int classId;
                    try {
                        classId = Integer.parseInt(classTeacherClassIdStr.trim());
                    } catch (NumberFormatException e) {
                        throw new IllegalArgumentException("班级ID格式不正确");
                    }
                    ensureClassTeacherUniqueAndBind(conn, classId, userId);
                }

                // 4.3 辅导员：你目前只有 student_counselor 这张表，按“学生-辅导员”关系设计。
                //      不涉及“专业唯一辅导员”的字段，这里暂时不做唯一性限制，只是保留 counselor 角色本身。
                //      如果未来你加了 major_counselor 或 major.counselor_user_id，再来补逻辑。

                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    private boolean existsUsername(Connection conn, String username) throws SQLException {
        String sql = "SELECT COUNT(*) FROM user WHERE username = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1) > 0;
            }
        }
    }

    private int insertUser(Connection conn,
                           String username,
                           String realName,
                           String rawPassword,
                           String gender,
                           String phone,
                           String email) throws SQLException {

        // TODO: 这里直接存明文密码到 password_hash，你可以替换为加密后的值
        String sql = "INSERT INTO user (username, password_hash, real_name, gender, phone, email, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, 1)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, username);
            ps.setString(2, rawPassword);
            ps.setString(3, realName);
            ps.setString(4, gender != null ? gender : "男");
            ps.setString(5, phone);
            ps.setString(6, email);
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        throw new SQLException("创建用户失败，未获取到自增ID");
    }

    private int findRoleIdByName(Connection conn, String roleName) throws SQLException {
        String sql = "SELECT role_id FROM role WHERE role_name = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roleName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("role_id");
                }
            }
        }
        return -1;
    }

    private void insertUserRole(Connection conn, int userId, int roleId) throws SQLException {
        String sql = "INSERT INTO user_role (user_id, role_id) VALUES (?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, roleId);
            ps.executeUpdate();
        }
    }

    /** 根据 class_id 查出 dept_id, major_id */
    private int[] findDeptMajorByClassId(Connection conn, int classId) throws SQLException {
        String sql = "SELECT dept.dept_id, m.major_id " +
                "FROM class c " +
                "JOIN major m ON c.major_id = m.major_id " +
                "JOIN department dept ON m.dept_id = dept.dept_id " +
                "WHERE c.class_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, classId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new int[]{rs.getInt("dept_id"), rs.getInt("major_id")};
                }
            }
        }
        return null;
    }

    /** 更新 student 表中该 user 对应的记录 */
    private void updateStudentByUserId(Connection conn,
                                       int userId,
                                       int deptId,
                                       int majorId,
                                       int classId,
                                       int enrollYear) throws SQLException {
        String sql = "UPDATE student SET dept_id = ?, major_id = ?, class_id = ?, enroll_year = ? " +
                "WHERE user_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, deptId);
            ps.setInt(2, majorId);
            ps.setInt(3, classId);
            ps.setInt(4, enrollYear);
            ps.setInt(5, userId);
            int updated = ps.executeUpdate();
            if (updated == 0) {
                throw new SQLException("更新 student 失败：未找到对应用户");
            }
        }
    }

    /** 班主任唯一性绑定：class.class_teacher_user_id 为空才允许绑定 */
    private void ensureClassTeacherUniqueAndBind(Connection conn, int classId, int userId) throws SQLException {
        String checkSql = "SELECT class_teacher_user_id FROM class WHERE class_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setInt(1, classId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new IllegalArgumentException("无效的班级ID：" + classId);
                }
                int existing = rs.getInt("class_teacher_user_id");
                if (!rs.wasNull()) {
                    throw new IllegalArgumentException("该班级已存在班主任，无法再次注册为该班主任");
                }
            }
        }

        String updateSql = "UPDATE class SET class_teacher_user_id = ? WHERE class_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
            ps.setInt(1, userId);
            ps.setInt(2, classId);
            ps.executeUpdate();
        }
    }
}