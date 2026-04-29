package edu.haut.gradms.dao;

import edu.haut.gradms.config.DBUtil;
import edu.haut.gradms.model.Submission;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SubmissionDao {

    /**
     * 用于在页面上展示提交记录的简单 DTO。
     * 字段名请根据你的 submission 表结构调整。
     */
    public static class SubmissionItem {
        private int submissionId;
        private int studentId;
        private String title;
        private String type;
        private String contentPath;
        private String overallStatus;
        private Timestamp createdAt;
        private Timestamp updatedAt;

        public int getSubmissionId() {
            return submissionId;
        }

        public void setSubmissionId(int submissionId) {
            this.submissionId = submissionId;
        }

        public int getStudentId() {
            return studentId;
        }

        public void setStudentId(int studentId) {
            this.studentId = studentId;
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        public String getType() {
            return type;
        }

        public void setType(String type) {
            this.type = type;
        }

        public String getContentPath() {
            return contentPath;
        }

        public void setContentPath(String contentPath) {
            this.contentPath = contentPath;
        }

        public String getOverallStatus() {
            return overallStatus;
        }

        public void setOverallStatus(String overallStatus) {
            this.overallStatus = overallStatus;
        }

        public Timestamp getCreatedAt() {
            return createdAt;
        }

        public void setCreatedAt(Timestamp createdAt) {
            this.createdAt = createdAt;
        }

        public Timestamp getUpdatedAt() {
            return updatedAt;
        }

        public void setUpdatedAt(Timestamp updatedAt) {
            this.updatedAt = updatedAt;
        }
    }

    /**
     * 按 student_id 查询该学生的所有提交记录（论文/作业/就业材料等）。
     * 老师或学生查看“提交状态”列表时可以使用。
     * 这里按 updated_at DESC, submission_id DESC 排序，保证最新修改的在最前面。
     */
    public List<SubmissionItem> findByStudentId(int studentId) {
        List<SubmissionItem> list = new ArrayList<>();
        String sql = "SELECT * FROM submission " +
                "WHERE student_id = ? " +
                "ORDER BY updated_at DESC, submission_id DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SubmissionItem item = new SubmissionItem();
                    item.setSubmissionId(rs.getInt("submission_id"));
                    item.setStudentId(rs.getInt("student_id"));
                    item.setTitle(rs.getString("title"));
                    item.setType(rs.getString("type"));
                    item.setContentPath(rs.getString("content_path"));
                    try {
                        item.setOverallStatus(rs.getString("overall_status"));
                    } catch (SQLException ignored) {}
                    try {
                        item.setCreatedAt(rs.getTimestamp("created_at"));
                    } catch (SQLException ignored) {}
                    try {
                        item.setUpdatedAt(rs.getTimestamp("updated_at"));
                    } catch (SQLException ignored) {}
                    list.add(item);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询学生提交记录失败", e);
        }
        return list;
    }

    /**
     * 根据 student_id + type 查找一条 submission 记录的主键 id。
     * 用于判断该学生此类型材料是否已经存在（比如 就业去向）。
     * 只要存在就返回其中一条（一人一条，通过 UPDATE 复用）。
     */
    public Integer findIdByStudentAndType(int studentId, String type) {
        String sql = "SELECT submission_id FROM submission " +
                "WHERE student_id = ? AND type = ? LIMIT 1";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, studentId);
            ps.setString(2, type);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("submission_id");
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("按 studentId 和 type 查询提交记录失败", e);
        }
        return null;
    }

    /**
     * 更新某条 submission 的标题、类型、附件路径。
     * 用于“学生重新上传同一类型材料时覆盖旧的附件”。
     * 同时：
     *  - 将 overall_status 重置为 'PENDING'，让老师重新审核；
     *  - 更新 updated_at 为当前时间，便于列表按照最新修改时间排序。
     */
    public void updateSubmissionFile(int submissionId, String title, String type, String contentPath) {
        String sql = "UPDATE submission " +
                "SET title = ?, " +
                "    type = ?, " +
                "    content_path = ?, " +
                "    overall_status = 'PENDING', " +
                "    updated_at = NOW() " +
                "WHERE submission_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, title);
            ps.setString(2, type);
            ps.setString(3, contentPath);
            ps.setInt(4, submissionId);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("更新提交的附件信息失败", e);
        }
    }

    /**
     * 插入新提交记录（第一次提交该类型材料时用）。
     */
    public void createSubmission(int studentId, String title, String type, String contentPath) {
        String sql = "INSERT INTO submission " +
                "(student_id, title, type, content_path, overall_status, created_at, updated_at) " +
                "VALUES (?, ?, ?, ?, 'PENDING', NOW(), NOW())";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, studentId);
            ps.setString(2, title);
            ps.setString(3, type);
            ps.setString(4, contentPath);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("新增提交记录失败", e);
        }
    }

    /**
     * 按 ID 查询一条提交记录。
     */
    public Submission findById(int submissionId) {
        String sql = "SELECT * FROM submission WHERE submission_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, submissionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Submission s = new Submission();
                    s.setSubmissionId(rs.getInt("submission_id"));
                    s.setStudentId(rs.getInt("student_id"));
                    s.setTitle(rs.getString("title"));
                    s.setType(rs.getString("type"));
                    s.setContentPath(rs.getString("content_path"));
                    s.setOverallStatus(rs.getString("overall_status"));
                    s.setCreatedAt(rs.getTimestamp("created_at"));
                    s.setUpdatedAt(rs.getTimestamp("updated_at"));
                    return s;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("按ID查询提交记录失败", e);
        }
        return null;
    }

    /**
     * 查询某学生“就业去向”类型的最新一条提交记录。
     * 这里按 updated_at DESC, submission_id DESC 排序，以最近修改时间为准。
     */
    public Submission findLatestEmploymentSubmission(int studentId) {
        String sql = "SELECT * FROM submission " +
                "WHERE student_id = ? AND type = ? " +
                "ORDER BY updated_at DESC, submission_id DESC " +
                "LIMIT 1";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, studentId);
            ps.setString(2, "就业去向");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Submission s = new Submission();
                    s.setSubmissionId(rs.getInt("submission_id"));
                    s.setStudentId(rs.getInt("student_id"));
                    s.setTitle(rs.getString("title"));
                    s.setType(rs.getString("type"));
                    s.setContentPath(rs.getString("content_path"));
                    s.setOverallStatus(rs.getString("overall_status"));
                    s.setCreatedAt(rs.getTimestamp("created_at"));
                    s.setUpdatedAt(rs.getTimestamp("updated_at"));
                    return s;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询最新就业去向提交记录失败", e);
        }
        return null;
    }

}