package edu.haut.gradms.web.controller.student;

import edu.haut.gradms.dao.StudentDao;
import edu.haut.gradms.dao.SubmissionDao;
import edu.haut.gradms.model.Student;
import edu.haut.gradms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * 学生端：查看历次登记记录 / 审核状态列表
 * URL: /student/submission/status
 */
@WebServlet("/student/submission/status")
public class StudentSubmissionStatusServlet extends HttpServlet {

    private final SubmissionDao submissionDao = new SubmissionDao();
    private final StudentDao studentDao = new StudentDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        // 通过 user_id 找 student 对象
        Student stu = studentDao.findByUserId(currentUser.getUserId());
        if (stu == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "未找到对应学生信息");
            return;
        }

        // 查这一位学生所有 submission 记录
        List<SubmissionDao.SubmissionItem> list =
                submissionDao.findByStudentId(stu.getStudentId());

        req.setAttribute("submissionList", list);

        req.getRequestDispatcher("/WEB-INF/jsp/student/submission_status.jsp")
                .forward(req, resp);
    }
}