package edu.haut.gradms.web.controller.teacher;

import edu.haut.gradms.dao.EmploymentInfoDao;
import edu.haut.gradms.dao.StudentDao;
import edu.haut.gradms.model.EmploymentInfo;
import edu.haut.gradms.model.Student;
import edu.haut.gradms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 教师查看学生最新就业情况列表
 * URL: /teacher/students/employment
 */
@WebServlet("/teacher/students/employment")
public class TeacherStudentEmploymentListServlet extends HttpServlet {

    private final EmploymentInfoDao employmentInfoDao = new EmploymentInfoDao();
    private final StudentDao studentDao = new StudentDao();


    private String getCurrentReviewerRole(HttpSession session) {
        if (Boolean.TRUE.equals(session.getAttribute("isSupervisor"))
                || Boolean.TRUE.equals(session.getAttribute("isTeacher"))) {
            return EmploymentInfoDao.ROLE_SUPERVISOR;
        }

        if (Boolean.TRUE.equals(session.getAttribute("isClassTeacher"))) {
            return EmploymentInfoDao.ROLE_CLASS_TEACHER;
        }

        if (Boolean.TRUE.equals(session.getAttribute("isCounselor"))) {
            return EmploymentInfoDao.ROLE_COUNSELOR;
        }

        return null;
    }

    private String getRoleLabel(String reviewerRole) {
        if (EmploymentInfoDao.ROLE_SUPERVISOR.equals(reviewerRole)) {
            return "指导老师待审核";
        }
        if (EmploymentInfoDao.ROLE_CLASS_TEACHER.equals(reviewerRole)) {
            return "班主任待审核";
        }
        if (EmploymentInfoDao.ROLE_COUNSELOR.equals(reviewerRole)) {
            return "导员待审核";
        }
        return "待审核";
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String reviewerRole = getCurrentReviewerRole(session);

        if (reviewerRole == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "当前账号没有就业审核权限");
            return;
        }

        List<EmploymentInfo> latestList = employmentInfoDao.findLatestForReviewer(
                currentUser.getUserId(),
                reviewerRole
        );

        req.setAttribute("latestEmploymentList", latestList);
        req.setAttribute("scopeLabel", getRoleLabel(reviewerRole));

        // student_id -> Student 对象
        Map<Integer, Student> studentMap = new HashMap<>();
        for (EmploymentInfo info : latestList) {
            int sid = info.getStudentId();
            if (!studentMap.containsKey(sid)) {
                Student stu = studentDao.findById(sid); // 注意这里一定要返回 Student
                if (stu != null) {
                    studentMap.put(sid, stu);
                }
            }
        }

        req.setAttribute("latestEmploymentList", latestList);
        req.setAttribute("studentMap", studentMap);

        req.getRequestDispatcher("/WEB-INF/jsp/teacher/student_employment_list.jsp")
                .forward(req, resp);
    }
}