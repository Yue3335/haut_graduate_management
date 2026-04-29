package edu.haut.gradms.web.controller.teacher;

import edu.haut.gradms.dao.EmploymentStatsDao;
import edu.haut.gradms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.Map;

/**
 * 教师/管理员：就业概览（按每个学生最新记录统计）。
 * URL: /teacher/employment/overview
 */
@WebServlet("/teacher/employment/overview")
public class TeacherEmploymentOverviewServlet extends HttpServlet {

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
        Boolean isTeacher      = (Boolean) session.getAttribute("isTeacher");
        Boolean isAdmin        = (Boolean) session.getAttribute("isAdmin");
        Boolean isCounselor    = (Boolean) session.getAttribute("isCounselor");
        Boolean isClassTeacher = (Boolean) session.getAttribute("isClassTeacher");
        Boolean isSupervisor   = (Boolean) session.getAttribute("isSupervisor");

        if (currentUser == null || (!Boolean.TRUE.equals(isTeacher) && !Boolean.TRUE.equals(isAdmin))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无访问权限");
            return;
        }

        int userId = currentUser.getUserId();
        Map<String, Long> stats;
        String scopeLabel; // 给 JSP 显示当前统计范围

        // 简单优先级示例：Admin > 辅导员 > 班主任 > 指导老师 > 普通教师（全校）
        if (Boolean.TRUE.equals(isAdmin)) {
            stats = employmentStatsDao.countLatestStatusAllStudents();
            scopeLabel = "全校学生";
        } else if (Boolean.TRUE.equals(isCounselor)) {
            stats = employmentStatsDao.countLatestStatusByCounselor(userId);
            scopeLabel = "我负责的学生（辅导员）";
        } else if (Boolean.TRUE.equals(isClassTeacher)) {
            stats = employmentStatsDao.countLatestStatusByClassTeacher(userId);
            scopeLabel = "我带的班级学生（班主任）";
        } else if (Boolean.TRUE.equals(isSupervisor)) {
            stats = employmentStatsDao.countLatestStatusBySupervisor(userId);
            scopeLabel = "我指导的学生（指导老师）";
        } else {
            // 普通教师暂时看全校，你也可以改成“无权限查看”
            stats = employmentStatsDao.countLatestStatusAllStudents();
            scopeLabel = "全校学生（教师）";
        }

        req.setAttribute("employmentStats", stats);
        req.setAttribute("scopeLabel", scopeLabel);

        req.getRequestDispatcher("/WEB-INF/jsp/teacher/employment_overview.jsp")
                .forward(req, resp);
    }
}