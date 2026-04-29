package edu.haut.gradms.filter;

import edu.haut.gradms.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.Set;

@WebFilter(urlPatterns = {"/student/*", "/teacher/*", "/counselor/*", "/admin/*"})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        @SuppressWarnings("unchecked")
        Set<String> roles = (Set<String>) session.getAttribute("roles");

        // 未登录或没有角色信息 -> 重新登录
        if (user == null || roles == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getRequestURI().substring(req.getContextPath().length());

        // 学生模块：必须有 STUDENT 角色
        if (path.startsWith("/student/") && !roles.contains("STUDENT")) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无访问学生模块的权限");
            return;
        }

        // 教师模块：允许多个教师相关角色访问
        // 比如：普通教师 TEACHER、班主任 CLASS_TEACHER、导师 SUPERVISOR、辅导员 COUNSELOR 等
        if (path.startsWith("/teacher/")) {
            boolean canVisitTeacher =
                    roles.contains("TEACHER")       // 普通教师
                            || roles.contains("CLASS_TEACHER") // 班主任
                            || roles.contains("SUPERVISOR")    // 导师
                            || roles.contains("COUNSELOR");    // 辅导员

            if (!canVisitTeacher) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无访问教师模块的权限");
                return;
            }
        }

        // 辅导员模块：单独 counselor 相关 JSP，如果你有的话
        if (path.startsWith("/counselor/") && !roles.contains("COUNSELOR")) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无访问辅导员模块的权限");
            return;
        }

        // 管理员模块
        if (path.startsWith("/admin/") && !roles.contains("ADMIN")) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无访问管理员模块的权限");
            return;
        }

        // 全部检查通过，继续后面的 Servlet / JSP
        chain.doFilter(request, response);
    }
}