package edu.haut.gradms.web.controller.student;

import edu.haut.gradms.dao.StudentDao;
import edu.haut.gradms.model.Student;
import edu.haut.gradms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/student/mock-interview")
public class StudentMockInterviewServlet extends HttpServlet {

    private final StudentDao studentDao = new StudentDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null || !currentUser.hasRole("STUDENT")) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Student student = studentDao.findByUserId(currentUser.getUserId());
        if (student == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "未找到学生信息");
            return;
        }

        req.setAttribute("student", student);

        req.getRequestDispatcher("/WEB-INF/jsp/student/mock_interview.jsp")
                .forward(req, resp);
    }
}