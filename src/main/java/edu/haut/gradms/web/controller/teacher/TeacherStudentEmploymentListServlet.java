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

        // 当前版本：全校所有学生最新就业记录
        List<EmploymentInfo> latestList = employmentInfoDao.findLatestForAllStudents();

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