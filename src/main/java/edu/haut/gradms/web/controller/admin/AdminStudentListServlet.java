package edu.haut.gradms.web.controller.admin;

import edu.haut.gradms.dao.AdminStudentDao;
import edu.haut.gradms.dao.AdminStudentDao.StudentView;
import edu.haut.gradms.web.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/student/list")
public class AdminStudentListServlet extends HttpServlet {

    private final AdminStudentDao studentDao = new AdminStudentDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {


        if (!SessionUtil.requireAdmin(req, resp)) return;

        req.setCharacterEncoding("UTF-8");
        String keyword = req.getParameter("keyword");
        String major = req.getParameter("major");
        String className = req.getParameter("className");

        List<StudentView> students = studentDao.listStudents(keyword, major, className);
        req.setAttribute("students", students);

        req.getRequestDispatcher("/WEB-INF/jsp/admin/student/list.jsp").forward(req, resp);
    }
}