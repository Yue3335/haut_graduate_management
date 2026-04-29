package edu.haut.gradms.web.controller.student;

import edu.haut.gradms.dao.StudentDao;
import edu.haut.gradms.model.Student;
import edu.haut.gradms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/student/profile")
public class StudentProfileServlet extends HttpServlet {

    private final StudentDao studentDao = new StudentDao();

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
        req.setAttribute("student", student);
        req.getRequestDispatcher("/WEB-INF/jsp/student/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
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

        req.setCharacterEncoding("UTF-8");
        String phone = req.getParameter("phone");
        String email = req.getParameter("email");

        studentDao.updateContactInfo(currentUser.getUserId(), phone, email);

        // 同步更新 session 里的 currentUser
        currentUser.setPhone(phone);
        currentUser.setEmail(email);

        req.setAttribute("success", "保存成功");
        Student student = studentDao.findByUserId(currentUser.getUserId());
        req.setAttribute("student", student);

        req.getRequestDispatcher("/WEB-INF/jsp/student/profile.jsp").forward(req, resp);
    }
}