package edu.haut.gradms.web.controller.admin;

import edu.haut.gradms.dao.AdminTeacherDao;
import edu.haut.gradms.dao.AdminTeacherDao.TeacherView;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * 管理员：指导老师 / 辅导员 / 班主任 列表
 * URL: /admin/teacher/list
 */
@WebServlet("/admin/teacher/list")
public class AdminTeacherListServlet extends HttpServlet {

    private final AdminTeacherDao teacherDao = new AdminTeacherDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("isAdmin") == null
                || !(Boolean) session.getAttribute("isAdmin")) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无管理员访问权限");
            return;
        }

        req.setCharacterEncoding("UTF-8");
        String keyword = req.getParameter("keyword");
        String dept = req.getParameter("dept");
        String identity = req.getParameter("identity"); // SUPERVISOR / COUNSELOR / CLASS_TEACHER

        List<TeacherView> teachers = teacherDao.listTeachers(keyword, dept, identity);
        req.setAttribute("teachers", teachers);

        req.getRequestDispatcher("/WEB-INF/jsp/admin/teacher/list.jsp").forward(req, resp);
    }
}