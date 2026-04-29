package edu.haut.gradms.web.controller.teacher;

import edu.haut.gradms.dao.EmploymentInfoDao;
import edu.haut.gradms.dao.StudentDao;
import edu.haut.gradms.dao.SubmissionDao;
import edu.haut.gradms.dao.UserDao;
import edu.haut.gradms.model.EmploymentInfo;
import edu.haut.gradms.model.Student;
import edu.haut.gradms.model.Submission;
import edu.haut.gradms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * 教师端：查看某个学生的详细就业去向信息
 * URL: /teacher/employment/detail?studentId=...
 */

@WebServlet("/teacher/employment/detail")
public class TeacherEmploymentDetailServlet extends HttpServlet {

    private final StudentDao studentDao = new StudentDao();
    private final UserDao userDao = new UserDao();
    private final EmploymentInfoDao employmentInfoDao = new EmploymentInfoDao();
    private final SubmissionDao submissionDao = new SubmissionDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // 1. 登录校验
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        // 如需细分教师角色权限，可在此处根据 currentUser 的角色进一步判断

        // 2. 解析 studentId 参数
        String sidStr = req.getParameter("studentId");
        if (sidStr == null || sidStr.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "缺少 studentId 参数");
            return;
        }

        int studentId;
        try {
            studentId = Integer.parseInt(sidStr);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "studentId 参数非法");
            return;
        }

        // 3. 查询学生基本信息
        Student stu = studentDao.findById(studentId);
        if (stu == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "未找到该学生信息");
            return;
        }
        User stuUser = userDao.findById(stu.getUserId());

        // 4. 使用存储过程查询该学生最新一次就业去向记录
        EmploymentInfo latestEmployment =
                employmentInfoDao.findLatestByStudentIdWithSP(studentId);

        // 如需对比，也可以保留普通 SQL 的方式（仅注释说明）：
        // EmploymentInfo latestEmployment =
        //         employmentInfoDao.findLatestByStudentId(studentId);

        // 5. 查询该学生最新一次与就业去向相关的附件提交记录
        Submission latestSubmission =
                submissionDao.findLatestEmploymentSubmission(studentId);

        // 6. 将数据放入 request 作用域，转发到 JSP 展示
        req.setAttribute("student", stu);
        req.setAttribute("studentUser", stuUser);
        req.setAttribute("latestEmployment", latestEmployment);
        req.setAttribute("latestSubmission", latestSubmission);

        req.getRequestDispatcher("/WEB-INF/jsp/teacher/employment_detail.jsp")
                .forward(req, resp);
    }

}