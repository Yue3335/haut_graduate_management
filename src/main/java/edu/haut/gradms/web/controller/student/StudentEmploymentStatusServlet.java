package edu.haut.gradms.web.controller.student;

import edu.haut.gradms.dao.EmploymentInfoDao;
import edu.haut.gradms.dao.StudentDao;
import edu.haut.gradms.model.EmploymentInfo;
import edu.haut.gradms.model.Student;
import edu.haut.gradms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * 学生：就业去向登记记录 / 审核状态查看
 * URL: /student/submission/status
 */
//@WebServlet("/student/submission/status")
public class StudentEmploymentStatusServlet extends HttpServlet {

    private final StudentDao studentDao = new StudentDao();
    private final EmploymentInfoDao employmentInfoDao = new EmploymentInfoDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        Boolean isStudent = (Boolean) session.getAttribute("isStudent");
        if (currentUser == null || isStudent == null || !isStudent) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无访问权限");
            return;
        }

        Student student = studentDao.findByUserId(currentUser.getUserId());
        if (student == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "未找到学生信息");
            return;
        }

        List<EmploymentInfo> employmentList =
                employmentInfoDao.findAllByStudentId(student.getStudentId());

        req.setAttribute("student", student);
        req.setAttribute("employmentList", employmentList);

        req.getRequestDispatcher("/WEB-INF/jsp/student/submission_status.jsp")
                .forward(req, resp);
    }
}