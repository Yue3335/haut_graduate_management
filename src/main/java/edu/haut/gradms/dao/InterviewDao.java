package edu.haut.gradms.dao;

import edu.haut.gradms.config.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class InterviewDao {

    public void saveInterviewSession(int studentId,
                                     String jobDirection,
                                     String questionText,
                                     String answerText,
                                     String mainEmotion,
                                     double nervousScore,
                                     double confidenceScore,
                                     String feedback) {

        String sql = "INSERT INTO interview_session " +
                "(student_id, job_direction, question_text, answer_text, main_emotion, nervous_score, confidence_score, feedback, created_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, studentId);
            ps.setString(2, jobDirection);
            ps.setString(3, questionText);
            ps.setString(4, answerText);
            ps.setString(5, mainEmotion);
            ps.setDouble(6, nervousScore);
            ps.setDouble(7, confidenceScore);
            ps.setString(8, feedback);

            ps.executeUpdate();

        } catch (SQLException e) {
            throw new RuntimeException("保存模拟面试记录失败：" + e.getMessage(), e);
        }
    }
}