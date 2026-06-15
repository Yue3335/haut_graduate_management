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
import java.util.ArrayList;
import java.util.Map;

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

        req.setCharacterEncoding("UTF-8");

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

        if (student != null) {
            int studentId = student.getStudentId();

            /*
             * 1. 雷达图数据
             * 仍然使用原来的方法，展示主要课程平均分。
             */
            Map<String, Double> radarData =
                    studentGradeDao.findCourseRadarData(studentId, 6);

            req.setAttribute("radarData", radarData);

            /*
             * 2. GPA 走势数据
             * 不再写死 2022-1、2022-2、2023-1、2023-2。
             * 改成从 student_course_grade 表中动态读取所有已有学期。
             *
             * GPA 计算公式在 StudentGradeDao.findGpaTrendByStudentId() 里：
             * 每学期 GPA = Σ（课程绩点 × 学分） / Σ 学分
             */
            Map<String, Double> gpaMap =
                    studentGradeDao.findGpaTrendByStudentId(studentId);

            /*
             * 兼容旧 JSP：
             * 你的 home.jsp 原来读取的是 gpaByTerm。
             */
            req.setAttribute("gpaByTerm", gpaMap);

            /*
             * 兼容新 ECharts JSP：
             * 如果你后面把图表改成 gpaTermList / gpaValueList，也能直接用。
             */
            req.setAttribute("gpaTermList", new ArrayList<>(gpaMap.keySet()));
            req.setAttribute("gpaValueList", new ArrayList<>(gpaMap.values()));
        }

        req.getRequestDispatcher("/WEB-INF/jsp/student/home.jsp").forward(req, resp);
    }
}