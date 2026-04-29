package edu.haut.gradms.web.controller;

import edu.haut.gradms.model.User;
import edu.haut.gradms.service.AuthService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/jsp/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        User user = authService.login(username, password);
        if (user == null) {
            req.setAttribute("error", "用户名或密码错误，或账号被禁用");
            req.getRequestDispatcher("/WEB-INF/jsp/auth/login.jsp").forward(req, resp);
            return;
        }

        HttpSession session = req.getSession();
        session.setAttribute("currentUser", user);
        session.setAttribute("roles", user.getRoles());

        // ===== 兼容你项目里已有的 session 标记 =====
        // currentUserId，供其他 Servlet 使用
        session.setAttribute("currentUserId", user.getUserId());

        // 基于 roles 设置布尔型标记（按你之前的用法保持一致）
        session.setAttribute("isStudent",      user.hasRole("STUDENT"));
        session.setAttribute("isTeacher",      user.hasRole("SUPERVISOR"));     // 指导老师（teacher 资源）
        session.setAttribute("isClassTeacher", user.hasRole("CLASS_TEACHER"));  // 班主任
        session.setAttribute("isCounselor",    user.hasRole("COUNSELOR"));      // 辅导员
        session.setAttribute("isAdmin",        user.hasRole("ADMIN"));
        // =======================================

        // ===== 登录成功后的统一跳转逻辑 =====
        // 1) 管理员
        if (user.hasRole("ADMIN")) {
            resp.sendRedirect(req.getContextPath() + "/admin/home");
            return;
        }

        // 2) 所有“老师类角色”：指导老师 / 班主任 / 辅导员 / (普通 TEACHER)
        //    都统一进入 /teacher/home
        if (user.hasRole("SUPERVISOR")
                || user.hasRole("CLASS_TEACHER")
                || user.hasRole("COUNSELOR")
                || user.hasRole("TEACHER")) {

            resp.sendRedirect(req.getContextPath() + "/teacher/home");
            return;
        }

        // 3) 学生
        if (user.hasRole("STUDENT")) {
            resp.sendRedirect(req.getContextPath() + "/student/home");
            return;
        }

        // 4) 没有任何已知角色
        session.invalidate();
        req.setAttribute("error", "当前账号没有可用角色，请联系管理员");
        req.getRequestDispatcher("/WEB-INF/jsp/auth/login.jsp").forward(req, resp);
    }
}