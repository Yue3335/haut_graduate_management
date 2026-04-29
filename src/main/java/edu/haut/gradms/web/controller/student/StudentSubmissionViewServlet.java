package edu.haut.gradms.web.controller.student;

import edu.haut.gradms.dao.StudentDao;
import edu.haut.gradms.dao.SubmissionDao;
import edu.haut.gradms.model.Student;
import edu.haut.gradms.model.Submission;
import edu.haut.gradms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * 学生端：查看某条提交材料详情
 * URL: /student/submission/view?submissionId=...
 */
@WebServlet("/student/submission/view")
public class StudentSubmissionViewServlet extends HttpServlet {

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
        Student stu = studentDao.findByUserId(currentUser.getUserId());
        if (stu == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "未找到对应学生信息");
            return;
        }

        String sidStr = req.getParameter("submissionId");
        if (sidStr == null || sidStr.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "缺少 submissionId 参数");
            return;
        }

        int submissionId;
        try {
            submissionId = Integer.parseInt(sidStr);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "submissionId 参数非法");
            return;
        }

        Submission submission = submissionDao.findById(submissionId);
        // 安全检查：只能看自己的记录
        if (submission == null || submission.getStudentId() != stu.getStudentId()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "该提交记录不存在或不属于当前学生");
            return;
        }

        req.setAttribute("submission", submission);

        req.getRequestDispatcher("/WEB-INF/jsp/student/submission_view.jsp")
                .forward(req, resp);
    }
}