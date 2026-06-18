package edu.haut.gradms.dao;

import edu.haut.gradms.config.DBUtil;
import edu.haut.gradms.model.EmploymentInfo;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EmploymentInfoDao {

    public static final String ROLE_SUPERVISOR = "SUPERVISOR";
    public static final String ROLE_CLASS_TEACHER = "CLASS_TEACHER";
    public static final String ROLE_COUNSELOR = "COUNSELOR";

    public List<EmploymentInfo> findLatestForReviewer(int reviewerUserId, String reviewerRole) {
        List<EmploymentInfo> list = new ArrayList<>();

        String joinSql;
        String stage;

        if (ROLE_SUPERVISOR.equals(reviewerRole)) {
            joinSql = "JOIN student_supervisor ss ON ss.student_id = s.student_id AND ss.supervisor_user_id = ? ";
            stage = ROLE_SUPERVISOR;
        } else if (ROLE_CLASS_TEACHER.equals(reviewerRole)) {
            joinSql = "JOIN class c ON c.class_id = s.class_id AND c.class_teacher_user_id = ? ";
            stage = ROLE_CLASS_TEACHER;
        } else if (ROLE_COUNSELOR.equals(reviewerRole)) {
            joinSql = "JOIN student_counselor sc ON sc.student_id = s.student_id AND sc.counselor_user_id = ? ";
            stage = ROLE_COUNSELOR;
        } else {
            return list;
        }

        String sql = "SELECT e.*, s.student_no " +
                "FROM employment_info e " +
                "JOIN ( " +
                "    SELECT student_id, MAX(employment_id) AS max_id " +
                "    FROM employment_info " +
                "    GROUP BY student_id " +
                ") t ON e.student_id = t.student_id AND e.employment_id = t.max_id " +
                "JOIN student s ON s.student_id = e.student_id " +
                joinSql +
                "WHERE e.review_stage = ? AND e.review_status = 'PENDING' " +
                "ORDER BY e.report_time DESC, e.employment_id DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, reviewerUserId);
            ps.setString(2, stage);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询当前审核人待审核就业记录失败", e);
        }

        return list;
    }

    private void updateFlow(Connection conn,
                            int employmentId,
                            String role,
                            String action,
                            String remark) throws SQLException {

        String nextStage;
        String finalStatus;

        // ========================
        // 1. 通过逻辑
        // ========================
        if ("APPROVED".equals(action)) {

            if (ROLE_SUPERVISOR.equals(role)) {
                nextStage = "CLASS_TEACHER";
                finalStatus = "PENDING";

            } else if (ROLE_CLASS_TEACHER.equals(role)) {
                nextStage = "COUNSELOR";
                finalStatus = "PENDING";

            } else {
                nextStage = "DONE";
                finalStatus = "APPROVED";
            }

        }
        // ========================
        // 2. 驳回逻辑（统一结束）
        // ========================
        else {
            nextStage = "DONE";
            finalStatus = "REJECTED";
        }

        String sql =
                "UPDATE employment_info " +
                        "SET review_stage = ?, " +
                        "    review_status = ?, " +
                        "    review_remark = ? " +
                        "WHERE employment_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, nextStage);
            ps.setString(2, finalStatus);
            ps.setString(3, remark);
            ps.setInt(4, employmentId);

            ps.executeUpdate();
        }
    }

    public boolean reviewByRole(int employmentId,
                                int reviewerUserId,
                                String reviewerRole,
                                String action,
                                String reviewRemark) {

        if (!"APPROVED".equals(action) && !"REJECTED".equals(action)) {
            return false;
        }

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);

            try {
                updateFlow(conn, employmentId, reviewerRole, action, reviewRemark);

                conn.commit();
                return true;

            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }

        } catch (SQLException e) {
            throw new RuntimeException("审核失败", e);
        }
    }

    private EmploymentInfo findReviewableForUpdate(Connection conn,
                                                   int employmentId,
                                                   int reviewerUserId,
                                                   String reviewerRole) throws SQLException {
        String joinSql;
        String stage;

        if (ROLE_SUPERVISOR.equals(reviewerRole)) {
            joinSql = "JOIN student_supervisor ss ON ss.student_id = s.student_id AND ss.supervisor_user_id = ? ";
            stage = ROLE_SUPERVISOR;
        } else if (ROLE_CLASS_TEACHER.equals(reviewerRole)) {
            joinSql = "JOIN class c ON c.class_id = s.class_id AND c.class_teacher_user_id = ? ";
            stage = ROLE_CLASS_TEACHER;
        } else if (ROLE_COUNSELOR.equals(reviewerRole)) {
            joinSql = "JOIN student_counselor sc ON sc.student_id = s.student_id AND sc.counselor_user_id = ? ";
            stage = ROLE_COUNSELOR;
        } else {
            return null;
        }

        String sql = "SELECT e.*, s.student_no " +
                "FROM employment_info e " +
                "JOIN student s ON s.student_id = e.student_id " +
                joinSql +
                "WHERE e.employment_id = ? " +
                "  AND e.review_stage = ? " +
                "  AND e.review_status = 'PENDING' " +
                "FOR UPDATE";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewerUserId);
            ps.setInt(2, employmentId);
            ps.setString(3, stage);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }

        return null;
    }


    private void approveCurrentStage(Connection conn,
                                     int employmentId,
                                     int studentId,
                                     String reviewerRole,
                                     String remark) throws SQLException {
        String sql;

        if (ROLE_SUPERVISOR.equals(reviewerRole)) {
            sql = "UPDATE employment_info SET " +
                    "supervisor_status = 'APPROVED', supervisor_remark = ?, supervisor_review_time = NOW(), " +
                    "class_teacher_status = 'PENDING', review_stage = 'CLASS_TEACHER', " +
                    "review_status = 'PENDING', review_remark = ? " +
                    "WHERE employment_id = ?";
        } else if (ROLE_CLASS_TEACHER.equals(reviewerRole)) {
            sql = "UPDATE employment_info SET " +
                    "class_teacher_status = 'APPROVED', class_teacher_remark = ?, class_teacher_review_time = NOW(), " +
                    "counselor_status = 'PENDING', review_stage = 'COUNSELOR', " +
                    "review_status = 'PENDING', review_remark = ? " +
                    "WHERE employment_id = ?";
        } else if (ROLE_COUNSELOR.equals(reviewerRole)) {
            sql = "UPDATE employment_info SET " +
                    "counselor_status = 'APPROVED', counselor_remark = ?, counselor_review_time = NOW(), " +
                    "review_stage = 'DONE', review_status = 'APPROVED', review_remark = ? " +
                    "WHERE employment_id = ?";
        } else {
            return;
        }

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, remark);
            ps.setString(2, remark);
            ps.setInt(3, employmentId);
            ps.executeUpdate();
        }
    }


    private void rejectCurrentStage(Connection conn,
                                    int employmentId,
                                    int studentId,
                                    String reviewerRole,
                                    String remark) throws SQLException {
        String sql;

        if (ROLE_SUPERVISOR.equals(reviewerRole)) {
            sql = "UPDATE employment_info SET " +
                    "supervisor_status = 'REJECTED', supervisor_remark = ?, supervisor_review_time = NOW(), " +
                    "review_stage = 'DONE', review_status = 'REJECTED', review_remark = ? " +
                    "WHERE employment_id = ?";
        } else if (ROLE_CLASS_TEACHER.equals(reviewerRole)) {
            sql = "UPDATE employment_info SET " +
                    "class_teacher_status = 'REJECTED', class_teacher_remark = ?, class_teacher_review_time = NOW(), " +
                    "review_stage = 'DONE', review_status = 'REJECTED', review_remark = ? " +
                    "WHERE employment_id = ?";
        } else if (ROLE_COUNSELOR.equals(reviewerRole)) {
            sql = "UPDATE employment_info SET " +
                    "counselor_status = 'REJECTED', counselor_remark = ?, counselor_review_time = NOW(), " +
                    "review_stage = 'DONE', review_status = 'REJECTED', review_remark = ? " +
                    "WHERE employment_id = ?";
        } else {
            return;
        }

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, remark);
            ps.setString(2, remark);
            ps.setInt(3, employmentId);
            ps.executeUpdate();
        }
    }

    private EmploymentInfo mapRow(ResultSet rs) throws SQLException {
        EmploymentInfo e = new EmploymentInfo();

        e.setEmploymentId(rs.getInt("employment_id"));
        e.setStudentId(rs.getInt("student_id"));

        // 基础信息
        e.setStatus(rs.getString("status"));
        e.setCompanyName(rs.getString("company_name"));
        e.setPosition(rs.getString("position"));
        e.setCity(rs.getString("city"));
        e.setSalaryMonth(rs.getBigDecimal("salary_month"));
        e.setReportTime(rs.getTimestamp("report_time"));
        e.setRemark(rs.getString("remark"));

        // 审核信息（核心保留）
        try {
            e.setReviewStatus(rs.getString("review_status"));
        } catch (SQLException ignored) {}

        try {
            e.setReviewRemark(rs.getString("review_remark"));
        } catch (SQLException ignored) {}

        // 学生信息（可选字段，防止报错）
        try {
            e.setStudentNo(rs.getString("student_no"));
        } catch (SQLException ignored) {}

        return e;
    }

    /**
     * 普通 SQL：按学生ID查询最新一条就业记录
     */
    public EmploymentInfo findLatestByStudentId(int studentId) {

        String sql = """
        SELECT *
        FROM employment_info
        WHERE student_id = ?
        ORDER BY employment_id DESC
        LIMIT 1
    """;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("查询最新就业失败", e);
        }

        return null;
    }

    /**
     * 使用存储过程：按学生ID查询最新一条就业记录
     * 对应 MySQL 中的存储过程：sp_get_latest_employment_by_student
     */
    public EmploymentInfo findLatestByStudentIdWithSP(int studentId) {
        String sql = "{ call sp_get_latest_employment_by_student(?) }";
        try (Connection conn = DBUtil.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setInt(1, studentId);

            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("通过存储过程查询最新就业去向失败", e);
        }
        return null;
    }

    /**
     * 首页统计：取所有学生的最新就业记录（普通 SQL）
     */
    /**
     * 首页/统计：取所有学生的最新就业记录
     * 通过视图 v_student_latest_employment 获取，
     * 视图在数据库 haut_graduate_management 中预先封装了
     * “按 student_id 分组，取 report_time 最大的一条记录”的逻辑。
     */
    public List<EmploymentInfo> findLatestForAllStudents() {
        List<EmploymentInfo> list = new ArrayList<>();

        // 原本是一大串 JOIN + 子查询，现在直接查询视图
        String sql = "SELECT * FROM v_student_latest_employment";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("通过视图查询所有学生最新就业去向失败", e);
        }
        return list;
    }

    /**
     * 普通 SQL：按学生ID查询该学生全部就业记录
     */
    public List<EmploymentInfo> findAllByStudentId(int studentId) {
        List<EmploymentInfo> list = new ArrayList<>();

        String sql = "SELECT * " +
                "FROM employment_info " +
                "WHERE student_id = ? " +
                "ORDER BY report_time DESC, employment_id DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("按学生ID查询全部就业去向记录失败", e);
        }

        return list;
    }

    /**
     * 使用存储过程：按学生ID查询该学生全部就业记录
     * 对应 MySQL 中的存储过程：sp_get_all_employments_by_student
     */
    public List<EmploymentInfo> findAllByStudentIdWithSP(int studentId) {
        List<EmploymentInfo> list = new ArrayList<>();
        String sql = "{ call sp_get_all_employments_by_student(?) }";

        try (Connection conn = DBUtil.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setInt(1, studentId);

            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("通过存储过程查询全部就业去向记录失败", e);
        }

        return list;
    }

    /**
     * 插入一条新的就业去向记录
     */
    /**
     * 插入一条新的就业去向记录
     */
    public void insert(EmploymentInfo info) {

        String sql =
                "INSERT INTO employment_info " +
                        "(student_id, status, company_name, position, salary_month, city, report_time, remark, " +
                        " review_status, review_stage, review_remark) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, info.getStudentId());
            ps.setString(2, info.getStatus());
            ps.setString(3, info.getCompanyName());
            ps.setString(4, info.getPosition());
            ps.setBigDecimal(5, info.getSalaryMonth());
            ps.setString(6, info.getCity());

            ps.setTimestamp(7,
                    info.getReportTime() == null
                            ? new Timestamp(System.currentTimeMillis())
                            : new Timestamp(info.getReportTime().getTime())
            );

            ps.setString(8, info.getRemark());

            // ⭐ 核心统一状态
            ps.setString(9, "PENDING");      // review_status
            ps.setString(10, "SUPERVISOR");  // review_stage
            ps.setString(11, null);          // review_remark

            ps.executeUpdate();

        } catch (SQLException e) {
            throw new RuntimeException("插入失败", e);
        }
    }

    /**
     * 教师审核：更新某条就业记录的审核状态和审核意见
     */
    public void updateReviewStatus(int employmentId, String reviewStatus, String reviewRemark) {
        String sql = "UPDATE employment_info " +
                "SET review_status = ?, review_remark = ? " +
                "WHERE employment_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, reviewStatus);    // 'APPROVED' 或 'REJECTED'
            ps.setString(2, reviewRemark);
            ps.setInt(3, employmentId);

            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("更新就业去向审核状态失败", e);
        }
    }





}