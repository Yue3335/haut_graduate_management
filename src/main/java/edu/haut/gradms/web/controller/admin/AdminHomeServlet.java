package edu.haut.gradms.web.controller.admin;

import edu.haut.gradms.dao.StatDao;
import edu.haut.gradms.web.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * 管理员首页：左侧导航 + 右侧首页内容 + 数据统计图表
 */
@WebServlet("/admin/home")
public class AdminHomeServlet extends HttpServlet {

    private final StatDao statDao = new StatDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!SessionUtil.requireAdmin(req, resp)) return;

        // 查询统计数据，用于首页图表
        List<Map<String, Object>> majorStudentCount = statDao.countStudentsByMajor();
        List<Map<String, Object>> teacherStudentCount = statDao.countStudentsByTeacher();

        req.setAttribute("majorStudentCount", majorStudentCount);
        req.setAttribute("teacherStudentCount", teacherStudentCount);

        req.getRequestDispatcher("/WEB-INF/jsp/admin/home.jsp").forward(req, resp);
    }
}