package edu.haut.gradms.web.controller.teacher;

import edu.haut.gradms.dao.EmploymentStatsDao;
import edu.haut.gradms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.Map;
import java.util.Set;

/**
 * 教师/管理员主页（工作台），包含学生就业情况概览等信息。
 * URL: /teacher/home
 */
@WebServlet("/teacher/home")
public class TeacherHomeServlet extends HttpServlet {

    private final EmploymentStatsDao employmentStatsDao = new EmploymentStatsDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        @SuppressWarnings("unchecked")
        Set<String> roles = (Set<String>) session.getAttribute("roles");

        if (currentUser == null || roles == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int userId = currentUser.getUserId();

        Map<String, Long> employmentStats;
        String scopeLabel;

        // 根据角色决定统计范围 —— 注意这里全部用 countLatestStatusByXXX
        if (roles.contains("CLASS_TEACHER")) {
            // 班主任：只统计自己班级学生
            employmentStats = employmentStatsDao.countLatestStatusByClassTeacher(userId);
            scopeLabel = "您所带班级的学生";
        } else if (roles.contains("COUNSELOR")) {
            // 辅导员：只统计自己负责的学生
            employmentStats = employmentStatsDao.countLatestStatusByCounselor(userId);
            scopeLabel = "您负责范围内的学生";
        } else if (roles.contains("SUPERVISOR")) {
            // 导师：只统计自己指导的学生
            employmentStats = employmentStatsDao.countLatestStatusBySupervisor(userId);
            scopeLabel = "您指导的学生";
        } else if (roles.contains("TEACHER")) {
            // 普通教师：按你的业务需要，当前 DAO 里可以先返回全校或者按 teacher_id 过滤
            employmentStats = employmentStatsDao.countLatestStatusByTeacher(userId);
            scopeLabel = "与您相关的学生";
        } else if (roles.contains("ADMIN")) {
            // 管理员：全校学生
            employmentStats = employmentStatsDao.countLatestStatusAllStudents();
            scopeLabel = "全校学生";
        } else {
            // 其它角色：不给看或空
            employmentStats = java.util.Collections.emptyMap();
            scopeLabel = "无可查看学生范围";
        }

        req.setAttribute("employmentStats", employmentStats);
        req.setAttribute("employmentScopeLabel", scopeLabel);

        req.getRequestDispatcher("/WEB-INF/jsp/teacher/home.jsp").forward(req, resp);
    }
}