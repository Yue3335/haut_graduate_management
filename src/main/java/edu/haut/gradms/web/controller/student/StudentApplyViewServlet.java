package edu.haut.gradms.web.controller.student;

import edu.haut.gradms.dao.ApplyMaterialDao;
import edu.haut.gradms.dao.StudentDao;
import edu.haut.gradms.model.ApplyMaterial;
import edu.haut.gradms.model.Student;
import edu.haut.gradms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * 学生端：查看申请材料详情
 * URL: /student/apply/view?applyId=...
 */
@WebServlet("/student/apply/view")
public class StudentApplyViewServlet extends HttpServlet {

    private final ApplyMaterialDao applyMaterialDao = new ApplyMaterialDao();
    private final StudentDao studentDao = new StudentDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        Student stu = studentDao.findByUserId(currentUser.getUserId());
        if (stu == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "未找到对应学生信息");
            return;
        }

        String idStr = req.getParameter("applyId");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "缺少 applyId 参数");
            return;
        }

        int applyId;
        try {
            applyId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "applyId 参数非法");
            return;
        }

        ApplyMaterial a = applyMaterialDao.findById(applyId);
        if (a == null || a.getStudentId() != stu.getStudentId()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "该申请材料不存在或不属于当前学生");
            return;
        }

        req.setAttribute("apply", a);
        req.getRequestDispatcher("/WEB-INF/jsp/student/apply_view.jsp")
                .forward(req, resp);
    }
}