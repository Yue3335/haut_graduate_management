package edu.haut.gradms.dao;

import edu.haut.gradms.config.DBUtil;
import edu.haut.gradms.model.GradeItem;

import java.sql.*;
import java.util.*;

public class StudentGradeDao {

    /**
     * 查询某个学生四个学期（2022-1, 2022-2, 2023-1, 2023-2）的所有课程成绩，
     * 返回按 term 分组的 Map，key 为学期，value 为该学期课程列表。
     */
    public Map<String, List<GradeItem>> findGradesByStudentIdForFourTerms(int studentId) {
        // 这里先写死四个学期，你也可以之后根据入学年动态生成
        List<String> terms = Arrays.asList("2022-1", "2022-2", "2023-1", "2023-2");

        String sql = "SELECT g.term, c.course_code, c.course_name, c.credit, " +
                "       g.score, g.grade_point " +
                "FROM student_course_grade g " +
                "JOIN course c ON g.course_id = c.course_id " +
                "WHERE g.student_id = ? AND g.term IN (?,?,?,?) " +
                "ORDER BY g.term, c.course_code";

        // 用 LinkedHashMap 保证学期顺序
        Map<String, List<GradeItem>> result = new LinkedHashMap<>();
        for (String term : terms) {
            result.put(term, new ArrayList<>());
        }

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, studentId);
            ps.setString(2, terms.get(0));
            ps.setString(3, terms.get(1));
            ps.setString(4, terms.get(2));
            ps.setString(5, terms.get(3));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    GradeItem item = new GradeItem();
                    String term = rs.getString("term");
                    item.setTerm(term);
                    item.setCourseCode(rs.getString("course_code"));
                    item.setCourseName(rs.getString("course_name"));
                    item.setCredit(rs.getDouble("credit"));
                    item.setScore(rs.getDouble("score"));
                    double gp = rs.getDouble("grade_point");
                    if (!rs.wasNull()) {
                        item.setGradePoint(gp);
                    }

                    result.computeIfAbsent(term, k -> new ArrayList<>()).add(item);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询学生成绩失败", e);
        }

        return result;
    }

    /**
     * 统计某个学生在所有课程上的成绩，取前 N 门主课做雷达图。
     * 这里简化：按课程名称排序取前 6 门课程的平均分（如果有多学期开课）。
     */
    public Map<String, Double> findCourseRadarData(int studentId, int maxCourses) {
        String sql =
                "SELECT c.course_name, AVG(g.score) AS avg_score " +
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
            throw new RuntimeException("查询学生雷达图数据失败", e);
        }

        return result;
    }

    /**
     * 统计某个学生在四个学期的 GPA（或平均绩点）。
     * 这里用 student_course_grade 表中的 grade_point * credit / sum(credit) 来计算。
     * termList 例如：["2022-1","2022-2","2023-1","2023-2"]
     */
    public Map<String, Double> findGpaByTerms(int studentId, List<String> termList) {
        if (termList == null || termList.isEmpty()) {
            return Collections.emptyMap();
        }

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT g.term, ");
        sql.append("       SUM(COALESCE(g.grade_point,0) * c.credit) AS sum_gp, ");
        sql.append("       SUM(c.credit) AS sum_credit ");
        sql.append("FROM student_course_grade g ");
        sql.append("JOIN course c ON g.course_id = c.course_id ");
        sql.append("WHERE g.student_id = ? ");
        sql.append("  AND g.term IN (");

        for (int i = 0; i < termList.size(); i++) {
            if (i > 0) sql.append(",");
            sql.append("?");
        }
        sql.append(") ");
        sql.append("GROUP BY g.term ");
        sql.append("ORDER BY g.term");

        Map<String, Double> result = new LinkedHashMap<>();
        // 先初始化，保证顺序 & 即使没有成绩也有点位（可选）
        for (String t : termList) {
            result.put(t, null);
        }

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            ps.setInt(1, studentId);
            int idx = 2;
            for (String t : termList) {
                ps.setString(idx++, t);
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
            throw new RuntimeException("查询学生 GPA 走势失败", e);
        }

        return result;
    }

}