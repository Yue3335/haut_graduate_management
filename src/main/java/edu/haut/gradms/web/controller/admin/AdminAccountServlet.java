package edu.haut.gradms.web.controller.admin;

import edu.haut.gradms.dao.AdminAccountDao;
import edu.haut.gradms.dao.AdminAccountDao.UserView;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * 管理员：账号与密码管理
 * URL: /admin/system/account
 */
@WebServlet("/admin/system/account")
public class AdminAccountServlet extends HttpServlet {

    private final AdminAccountDao accountDao = new AdminAccountDao();

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
        String role = req.getParameter("role"); // STUDENT / TEACHER / COUNSELOR / CLASS_TEACHER / ADMIN

        List<UserView> users = accountDao.listUsers(keyword, role);
        req.setAttribute("users", users);

        req.getRequestDispatcher("/WEB-INF/jsp/admin/system/account.jsp").forward(req, resp);
    }

    // 以后你可以在这里实现 POST，用于重置密码 / 启用禁用账号
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {


        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("isAdmin") == null
                || !(Boolean) session.getAttribute("isAdmin")) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无管理员访问权限");
            return;
        }

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        String userIdStr = req.getParameter("userId");

        if (userIdStr == null || userIdStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/system/account");
            return;
        }

        int userId;
        try {
            userId = Integer.parseInt(userIdStr);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/system/account");
            return;
        }

        // 用于操作完成后仍然保持当前筛选条件
        String keyword = req.getParameter("keyword");
        String role = req.getParameter("role");

        try {
            if ("resetPassword".equals(action)) {
                accountDao.resetUserPassword(userId);
            } else if ("toggleStatus".equals(action)) {
                // 先查出当前状态（简单起见，重新查一遍该用户）
                // 也可以在页面隐藏传一个当前 status，下例用 SQL 简单查。
                int currentStatus = getUserStatus(userId);
                int newStatus = (currentStatus == 1 ? 0 : 1);
                accountDao.updateUserStatus(userId, newStatus);
            }
        } catch (RuntimeException e) {
            e.printStackTrace();
            // 这里可以在重定向时带上错误提示参数
        }

        // 操作完成后重定向回列表，尽量保留原有查询条件
        String redirectUrl = req.getContextPath() + "/admin/system/account";
        StringBuilder qs = new StringBuilder();
        if (keyword != null && !keyword.isEmpty()) {
            qs.append("&keyword=").append(java.net.URLEncoder.encode(keyword, "UTF-8"));
        }
        if (role != null && !role.isEmpty()) {
            qs.append("&role=").append(java.net.URLEncoder.encode(role, "UTF-8"));
        }
        if (qs.length() > 0) {
            redirectUrl = redirectUrl + "?" + qs.substring(1);
        }

        resp.sendRedirect(redirectUrl);
    }

    /** 简单查一下当前用户状态 */
    private int getUserStatus(int userId) {
        String sql = "SELECT status FROM user WHERE user_id = ?";
        try (java.sql.Connection conn = accountDao.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("status");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 1; // 默认认为是正常
    }

}