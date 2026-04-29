package edu.haut.gradms.web.controller.student;

import edu.haut.gradms.dao.ClassDao;
import edu.haut.gradms.dao.StudentDao;
import edu.haut.gradms.dao.StudentGradeDao;
import edu.haut.gradms.model.ClassInfo;
import edu.haut.gradms.model.Student;
import edu.haut.gradms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.*;

/**
 * 学生首页：基本信息 + 班主任信息 + 成绩雷达图 & GPA 折线图
 */
@WebServlet("/student/home")
public class StudentHomeServlet extends HttpServlet {

    private final StudentDao studentDao = new StudentDao();
    private final ClassDao classDao = new ClassDao();
    private final StudentGradeDao studentGradeDao = new StudentGradeDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null || !currentUser.hasRole("STUDENT")) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Student student = studentDao.findByUserId(currentUser.getUserId());
        ClassInfo classInfo = null;
        if (student != null) {
            classInfo = classDao.findById(student.getClassId());
        }

        req.setAttribute("student", student);
        req.setAttribute("classInfo", classInfo);

        // ===== 新增：如果有学生信息，就查询成绩统计，用于图表 =====
        if (student != null) {
            int studentId = student.getStudentId();

            // 1) 雷达图数据：取前 6 门课程的平均分
            Map<String, Double> radarData =
                    studentGradeDao.findCourseRadarData(studentId, 6);

            // 2) GPA 折线图数据：你已有四个学期的方法，用同样学期列表
            List<String> terms = Arrays.asList("2022-1", "2022-2", "2023-1", "2023-2");
            Map<String, Double> gpaByTerm =
                    studentGradeDao.findGpaByTerms(studentId, terms);

            req.setAttribute("radarData", radarData);
            req.setAttribute("gpaByTerm", gpaByTerm);
        }

        req.getRequestDispatcher("/WEB-INF/jsp/student/home.jsp").forward(req, resp);
    }
}