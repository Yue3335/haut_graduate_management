package edu.haut.gradms.web.controller.student;

import edu.haut.gradms.dao.InterviewDao;
import edu.haut.gradms.dao.StudentDao;
import edu.haut.gradms.model.Student;
import edu.haut.gradms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/student/mock-interview/save")
public class StudentInterviewSaveServlet extends HttpServlet {

    private final StudentDao studentDao = new StudentDao();
    private final InterviewDao interviewDao = new InterviewDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/plain;charset=UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("请先登录");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        Boolean isStudent = (Boolean) session.getAttribute("isStudent");

        if (currentUser == null || isStudent == null || !isStudent) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            resp.getWriter().write("无访问权限");
            return;
        }

        Student student = studentDao.findByUserId(currentUser.getUserId());
        if (student == null) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            resp.getWriter().write("未找到学生信息");
            return;
        }

        String jobDirection = req.getParameter("jobDirection");
        String questionText = req.getParameter("questionText");
        String answerText = req.getParameter("answerText");
        String mainEmotion = req.getParameter("mainEmotion");
        String confidenceScoreText = req.getParameter("confidenceScore");

        double confidenceScore = 0;
        try {
            confidenceScore = Double.parseDouble(confidenceScoreText);
        } catch (Exception ignored) {
        }

        interviewDao.saveInterviewSession(
                student.getStudentId(),
                jobDirection,
                questionText,
                answerText,
                mainEmotion,
                0,
                confidenceScore,
                "第一版暂未生成完整 AI 反馈，后续可接入岗位推荐模型。"
        );

        resp.getWriter().write("本次模拟面试记录已保存。");
    }
}