package edu.haut.gradms.dao;

import edu.haut.gradms.config.DBUtil;
import edu.haut.gradms.model.GradeItem;
import edu.haut.gradms.service.TranscriptPdfParser;

import java.sql.*;
import java.util.*;

/**
 * 学生成绩 DAO
 *
 * 功能：
 * 1. 查询学生成绩，用于个人发展推荐页面展示
 * 2. 导入 PDF 成绩单识别出来的成绩
 * 3. 自动创建不存在的课程
 * 4. 重复上传时，自动更新同一学生、同一课程、同一学期的成绩
 */
public class StudentGradeDao {

    /**
     * 查询学生所有成绩，并按学期分组。
     *
     * 页面 recommendation.jsp 使用：
     * ${termGrades}
     */
    public Map<String, Double> findGpaTrendByStudentId(int studentId) {
        String sql =
                "SELECT g.term, " +
                        "       ROUND( " +
                        "           SUM( " +
                        "               (CASE " +
                        "                   WHEN g.score >= 60 THEN LEAST(5.0, (g.score - 50) / 10) " +
                        "                   ELSE 0.0 " +
                        "                END) * c.credit " +
                        "           ) / NULLIF(SUM(c.credit), 0), 2 " +
                        "       ) AS gpa " +
                        "FROM student_course_grade g " +
                        "JOIN course c ON g.course_id = c.course_id " +
                        "WHERE g.student_id = ? " +
                        "GROUP BY g.term " +
                        "ORDER BY g.term";

        Map<String, Double> result = new LinkedHashMap<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String term = rs.getString("term");
                    double gpa = rs.getDouble("gpa");

                    if (!rs.wasNull()) {
                        result.put(term, gpa);
                    }
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException("查询学生 GPA 走势失败：" + e.getMessage(), e);
        }

        return result;
    }

    /**
     * 导入 PDF 成绩单识别出来的课程成绩。
     *
     * 注意：
     * 这里不校验 PDF 里的学号。
     * 谁登录系统，成绩就导入到谁的 student_id 下。
     */

    public Map<String, List<GradeItem>> findGradesByStudentIdForFourTerms(int studentId) {
        String sql =
                "SELECT g.term, " +
                        "       c.course_code, " +
                        "       c.course_name, " +
                        "       c.credit, " +
                        "       g.score, " +
                        "       g.score_text, " +
                        "       g.grade_point, " +
                        "       g.course_attr " +
                        "FROM student_course_grade g " +
                        "JOIN course c ON g.course_id = c.course_id " +
                        "WHERE g.student_id = ? " +
                        "ORDER BY g.term, c.course_name";

        Map<String, List<GradeItem>> result = new LinkedHashMap<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    GradeItem item = new GradeItem();

                    String term = rs.getString("term");

                    item.setTerm(term);
                    item.setCourseCode(rs.getString("course_code"));
                    item.setCourseName(rs.getString("course_name"));
                    item.setCredit(rs.getDouble("credit"));
                    item.setScore(rs.getDouble("score"));
                    item.setScoreText(rs.getString("score_text"));

                    double gp = rs.getDouble("grade_point");
                    if (!rs.wasNull()) {
                        item.setGradePoint(gp);
                    }

                    item.setCourseAttr(rs.getString("course_attr"));

                    result.computeIfAbsent(term, k -> new ArrayList<>()).add(item);
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException("查询学生成绩失败：" + e.getMessage(), e);
        }

        return result;
    }

    public int importTranscript(int studentId,
                                List<TranscriptPdfParser.TranscriptCourseRow> rows,
                                String sourceFileName) {
        if (rows == null || rows.isEmpty()) {
            return 0;
        }

        int count = 0;

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);

            try {
                for (TranscriptPdfParser.TranscriptCourseRow row : rows) {
                    if (row == null || row.getCourseName() == null || row.getCourseName().trim().isEmpty()) {
                        continue;
                    }

                    int courseId = findOrCreateCourse(conn, row);
                    upsertGrade(conn, studentId, courseId, row, sourceFileName);
                    count++;
                }

                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }

        } catch (Exception e) {
            throw new RuntimeException("导入成绩失败：" + e.getMessage(), e);
        }

        return count;
    }

    /**
     * 根据课程名查找课程。
     * 如果课程不存在，则自动创建。
     *
     * 这里不插入 dept_id。
     * 所以你的 course.dept_id 必须允许 NULL。
     */
    private int findOrCreateCourse(Connection conn,
                                   TranscriptPdfParser.TranscriptCourseRow row) throws SQLException {
        String courseName = normalizeCourseName(row.getCourseName());

        String selectSql = "SELECT course_id FROM course WHERE course_name = ? LIMIT 1";

        try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
            ps.setString(1, courseName);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int courseId = rs.getInt("course_id");

                    // 如果课程已存在，顺手更新学分和推荐学期，避免旧模拟数据不准确
                    updateCourseBasicInfo(conn, courseId, row);

                    return courseId;
                }
            }
        }

        String insertSql = "INSERT INTO course " +
                "(course_code, course_name, credit, semester_no, created_at, updated_at) " +
                "VALUES (?, ?, ?, ?, NOW(), NOW())";

        try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, buildCourseCode(courseName));
            ps.setString(2, courseName);
            ps.setDouble(3, row.getCredit());
            ps.setInt(4, termToSemesterNo(row.getTerm()));

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        throw new SQLException("创建课程失败：" + courseName);
    }

    /**
     * 更新已有课程的学分和推荐学期。
     */
    private void updateCourseBasicInfo(Connection conn,
                                       int courseId,
                                       TranscriptPdfParser.TranscriptCourseRow row) throws SQLException {
        String sql = "UPDATE course " +
                "SET credit = ?, semester_no = ?, updated_at = NOW() " +
                "WHERE course_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, row.getCredit());
            ps.setInt(2, termToSemesterNo(row.getTerm()));
            ps.setInt(3, courseId);

            ps.executeUpdate();
        }
    }

    /**
     * 插入或更新学生成绩。
     *
     * 前提：
     * student_course_grade 表里有唯一索引：
     * uk_student_course_term(student_id, course_id, term)
     */
    private void upsertGrade(Connection conn,
                             int studentId,
                             int courseId,
                             TranscriptPdfParser.TranscriptCourseRow row,
                             String sourceFileName) throws SQLException {
        String sql = "INSERT INTO student_course_grade " +
                "(student_id, course_id, term, score, score_text, grade_point, course_attr, import_source, created_at, updated_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW()) " +
                "ON DUPLICATE KEY UPDATE " +
                "score = VALUES(score), " +
                "score_text = VALUES(score_text), " +
                "grade_point = VALUES(grade_point), " +
                "course_attr = VALUES(course_attr), " +
                "import_source = VALUES(import_source), " +
                "updated_at = NOW()";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.setInt(2, courseId);
            ps.setString(3, row.getTerm());
            ps.setDouble(4, row.getScore());
            ps.setString(5, row.getScoreText());

            if (row.getGradePoint() == null) {
                ps.setNull(6, Types.DOUBLE);
            } else {
                ps.setDouble(6, row.getGradePoint());
            }

            ps.setString(7, row.getCourseAttr());
            ps.setString(8, sourceFileName);

            ps.executeUpdate();
        }
    }

    /**
     * 生成自动课程代码。
     *
     * 例如：
     * 程序设计基础 -> AUTO_xxxxxxxx
     */
    private String buildCourseCode(String courseName) {
        String safeName = courseName == null ? "UNKNOWN" : courseName.trim();
        String hex = Integer.toHexString(Math.abs(safeName.hashCode()));
        return "AUTO_" + hex;
    }

    /**
     * 清理课程名，避免前后空格、换行等导致同一课程重复入库。
     */
    private String normalizeCourseName(String courseName) {
        if (courseName == null) {
            return "";
        }

        String name = courseName.replaceAll("\\s+", " ").trim();

        if (name.length() > 100) {
            name = name.substring(0, 100);
        }

        return name;
    }

    /**
     * 把成绩单学期转换成推荐学期序号。
     *
     * 成绩单里的格式：
     * 2023-2024-1
     * 2023-2024-2
     * 2024-2025-1
     * 2024-2025-2
     *
     * 转换结果：
     * 2023-2024-1 -> 1
     * 2023-2024-2 -> 2
     * 2024-2025-1 -> 3
     * 2024-2025-2 -> 4
     * 2025-2026-1 -> 5
     * 2025-2026-2 -> 6
     */
    private int termToSemesterNo(String term) {
        if (term == null || !term.matches("\\d{4}-\\d{4}-[12]")) {
            return 0;
        }

        String[] parts = term.split("-");
        int startYear = Integer.parseInt(parts[0]);
        int termPart = Integer.parseInt(parts[2]);

        int baseYear = 2023;
        int semesterNo = (startYear - baseYear) * 2 + termPart;

        if (semesterNo < 1) {
            return 0;
        }

        if (semesterNo > 8) {
            return 8;
        }

        return semesterNo;
    }

    /**
     * 查询课程雷达图数据。
     */
    public Map<String, Double> findCourseRadarData(int studentId, int maxCourses) {
        String sql = "SELECT c.course_name, AVG(g.score) AS avg_score " +
                "FROM student_course_grade g " +
                "JOIN course c ON g.course_id = c.course_id " +
                "WHERE g.student_id = ? " +
                "GROUP BY c.course_name " +
                "ORDER BY c.course_name " +
                "LIMIT ?";

        Map<String, Double> result = new LinkedHashMap<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, studentId);
            ps.setInt(2, maxCourses);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String courseName = rs.getString("course_name");
                    double avgScore = rs.getDouble("avg_score");

                    result.put(courseName, avgScore);
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException("查询学生雷达图数据失败：" + e.getMessage(), e);
        }

        return result;
    }

    /**
     * 查询学生不同学期的 GPA。
     */
    public Map<String, Double> findGpaByTerms(int studentId, List<String> termList) {
        if (termList == null || termList.isEmpty()) {
            return Collections.emptyMap();
        }

        StringBuilder sql = new StringBuilder();

        sql.append("SELECT g.term, ");
        sql.append("       SUM(COALESCE(g.grade_point, 0) * c.credit) AS sum_gp, ");
        sql.append("       SUM(c.credit) AS sum_credit ");
        sql.append("FROM student_course_grade g ");
        sql.append("JOIN course c ON g.course_id = c.course_id ");
        sql.append("WHERE g.student_id = ? ");
        sql.append("  AND g.term IN (");

        for (int i = 0; i < termList.size(); i++) {
            if (i > 0) {
                sql.append(",");
            }
            sql.append("?");
        }

        sql.append(") ");
        sql.append("GROUP BY g.term ");
        sql.append("ORDER BY g.term");

        Map<String, Double> result = new LinkedHashMap<>();

        for (String term : termList) {
            result.put(term, null);
        }

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            ps.setInt(1, studentId);

            int idx = 2;
            for (String term : termList) {
                ps.setString(idx++, term);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String term = rs.getString("term");
                    double sumGp = rs.getDouble("sum_gp");
                    double sumCredit = rs.getDouble("sum_credit");

                    Double gpa = null;

                    if (sumCredit > 0.0001) {
                        gpa = sumGp / sumCredit;
                    }

                    result.put(term, gpa);
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException("查询学生 GPA 走势失败：" + e.getMessage(), e);
        }

        return result;
    }



}