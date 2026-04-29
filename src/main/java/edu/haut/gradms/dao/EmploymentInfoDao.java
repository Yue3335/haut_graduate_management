package edu.haut.gradms.dao;

import edu.haut.gradms.config.DBUtil;
import edu.haut.gradms.model.EmploymentInfo;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EmploymentInfoDao {

    private EmploymentInfo mapRow(ResultSet rs) throws SQLException {
        EmploymentInfo e = new EmploymentInfo();
        e.setEmploymentId(rs.getInt("employment_id"));
        e.setStudentId(rs.getInt("student_id"));
        e.setStatus(rs.getString("status"));
        e.setCompanyName(rs.getString("company_name"));
        e.setPosition(rs.getString("position"));
        e.setCity(rs.getString("city"));
        e.setSalaryMonth(rs.getBigDecimal("salary_month"));
        e.setReportTime(rs.getTimestamp("report_time"));
        e.setRemark(rs.getString("remark"));
        e.setReviewStatus(rs.getString("review_status"));
        e.setReviewRemark(rs.getString("review_remark"));
        return e;
    }

    /**
     * 普通 SQL：按学生ID查询最新一条就业记录
     */
    public EmploymentInfo findLatestByStudentId(int studentId) {
        String sql = "SELECT * " +
                "FROM employment_info " +
                "WHERE student_id = ? " +
                "ORDER BY report_time DESC, employment_id DESC " +
                "LIMIT 1";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("按学生ID查询最新就业去向失败", e);
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
        String sql = "INSERT INTO employment_info " +
                "(student_id, status, company_name, position, salary_month, city, report_time, remark, review_status, review_remark) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, info.getStudentId());
            ps.setString(2, info.getStatus());
            ps.setString(3, info.getCompanyName());
            ps.setString(4, info.getPosition());
            ps.setBigDecimal(5, info.getSalaryMonth());
            ps.setString(6, info.getCity());
            ps.setTimestamp(7, info.getReportTime() == null
                    ? new java.sql.Timestamp(System.currentTimeMillis())
                    : new java.sql.Timestamp(info.getReportTime().getTime()));
            ps.setString(8, info.getRemark());

            // 关键：防止 review_status 为 null，设置默认值为 'PENDING'
            String reviewStatus = info.getReviewStatus();
            if (reviewStatus == null || reviewStatus.isEmpty()) {
                reviewStatus = "PENDING";  // 待审核
            }
            ps.setString(9, reviewStatus);

            ps.setString(10, info.getReviewRemark());

            ps.executeUpdate();

            // 回写自增主键（可选）
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    info.setEmploymentId(rs.getInt(1));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("插入就业去向记录失败", e);
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