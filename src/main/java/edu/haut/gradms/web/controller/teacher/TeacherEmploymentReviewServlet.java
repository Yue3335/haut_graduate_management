package edu.haut.gradms.web.controller.teacher;

import edu.haut.gradms.dao.EmploymentInfoDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * 教师审核学生就业去向
 * URL: /teacher/employment/review
 */
@WebServlet("/teacher/employment/review")
public class TeacherEmploymentReviewServlet extends HttpServlet {

    private final EmploymentInfoDao employmentInfoDao = new EmploymentInfoDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        // 如需校验是否教师角色，可在这里加判断

        req.setCharacterEncoding("UTF-8");

        String employmentIdStr = req.getParameter("employmentId");
        String studentIdStr = req.getParameter("studentId");
        String reviewStatus = req.getParameter("reviewStatus");   // APPROVED / REJECTED
        String reviewRemark = req.getParameter("reviewRemark");   // 审核意见，可为空

        if (employmentIdStr == null || studentIdStr == null ||
                reviewStatus == null || reviewStatus.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "缺少必要参数");
            return;
        }

        int employmentId;
        int studentId;
        try {
            employmentId = Integer.parseInt(employmentIdStr);
            studentId = Integer.parseInt(studentIdStr);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "参数格式错误");
            return;
        }

        // 更新这条就业记录的审核状态和意见
        employmentInfoDao.updateReviewStatus(employmentId, reviewStatus, reviewRemark);

        // 审核完成后，重定向回该学生的详情页，方便查看最新状态
        resp.sendRedirect(req.getContextPath()
                + "/teacher/employment/detail?studentId=" + studentId);
    }
}