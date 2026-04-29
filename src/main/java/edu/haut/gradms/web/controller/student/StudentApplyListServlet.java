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
import java.util.Collections;
import java.util.List;

/**
 * 学生端：申请材料列表
 * URL: /student/apply/list
 */
@WebServlet("/student/apply/list")
public class StudentApplyListServlet extends HttpServlet {

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

        // 根据 user_id 找到 student_id
        Student stu = studentDao.findByUserId(currentUser.getUserId());
        if (stu == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "未找到对应学生信息");
            return;
        }

        List<ApplyMaterial> list = applyMaterialDao.findByStudentId(stu.getStudentId());
        if (list == null) list = Collections.emptyList();

        req.setAttribute("applyList", list);
        req.getRequestDispatcher("/WEB-INF/jsp/student/apply_list.jsp")
                .forward(req, resp);
    }
}