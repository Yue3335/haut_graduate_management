package edu.haut.gradms.web.util;

import edu.haut.gradms.model.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Session 校验工具类。
 * 将各 Servlet 中重复的权限校验逻辑集中到此处，
 * 遵循 DRY 原则，权限逻辑变更时只需修改一处。
 */
public class SessionUtil {

    private SessionUtil() {
        // 工具类，禁止实例化
    }

    /**
     * 校验当前请求是否具有管理员权限。
     * 不满足时自动返回 403，调用方直接 return 即可。
     *
     * @return true 表示校验通过，false 表示已发送错误响应
     */
    public static boolean requireAdmin(HttpServletRequest req,
                                       HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null
                && Boolean.TRUE.equals(session.getAttribute("isAdmin"))) {
            return true;
        }
        resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无管理员访问权限");
        return false;
    }

    /**
     * 校验当前请求是否具有学生权限。
     * 不满足时重定向到登录页，调用方直接 return 即可。
     *
     * @return true 表示校验通过，false 表示已发送重定向
     */
    public static boolean requireStudent(HttpServletRequest req,
                                         HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null
                && Boolean.TRUE.equals(session.getAttribute("isStudent"))) {
            return true;
        }
        resp.sendRedirect(req.getContextPath() + "/login");
        return false;
    }

    /**
     * 校验当前请求是否具有教师权限（含班主任、导师、辅导员）。
     * 不满足时返回 403，调用方直接 return 即可。
     *
     * @return true 表示校验通过，false 表示已发送错误响应
     */
    public static boolean requireTeacher(HttpServletRequest req,
                                         HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null
                && Boolean.TRUE.equals(session.getAttribute("isTeacher"))) {
            return true;
        }
        resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无教师访问权限");
        return false;
    }

    /**
     * 获取当前登录用户，未登录返回 null。
     */
    public static User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        return (User) session.getAttribute("currentUser");
    }
}