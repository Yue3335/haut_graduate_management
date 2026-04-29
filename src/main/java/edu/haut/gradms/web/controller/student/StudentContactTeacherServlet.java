package edu.haut.gradms.web.controller.student;

import edu.haut.gradms.dao.ClassDao;
import edu.haut.gradms.dao.StudentCounselorDao;
import edu.haut.gradms.dao.StudentDao;
import edu.haut.gradms.dao.StudentSupervisorDao;
import edu.haut.gradms.dao.UserSimpleDao;
import edu.haut.gradms.model.ClassInfo;
import edu.haut.gradms.model.Student;
import edu.haut.gradms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/student/contact-teacher")
public class StudentContactTeacherServlet extends HttpServlet {

    private final StudentDao studentDao = new StudentDao();
    private final ClassDao classDao = new ClassDao();
    private final StudentSupervisorDao studentSupervisorDao = new StudentSupervisorDao();
    private final StudentCounselorDao studentCounselorDao = new StudentCounselorDao();
    private final UserSimpleDao userSimpleDao = new UserSimpleDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User currentUser = (User) session.getAttribute("currentUser");
        Boolean isStudent = (Boolean) session.getAttribute("isStudent");
        if (currentUser == null || isStudent == null || !isStudent) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无访问权限");
            return;
        }

        Student student = studentDao.findByUserId(currentUser.getUserId());
        ClassInfo classInfo = null;
        User classTeacher = null;
        User supervisor = null;
        User counselor = null;

        if (student != null) {
            // 班主任信息（class）
            classInfo = classDao.findById(student.getClassId());
            if (classInfo != null && classInfo.getClassTeacherUserId() != null) {
                classTeacher = userSimpleDao.findById(classInfo.getClassTeacherUserId());
            }

            // 指导老师
            supervisor = studentSupervisorDao.findSupervisorByStudentId(student.getStudentId());

            // 辅导员
            counselor = studentCounselorDao.findCounselorByStudentId(student.getStudentId());
        }

        req.setAttribute("student", student);
        req.setAttribute("classInfo", classInfo);
        req.setAttribute("classTeacher", classTeacher);
        req.setAttribute("supervisor", supervisor);
        req.setAttribute("counselor", counselor);

        req.getRequestDispatcher("/WEB-INF/jsp/student/contact_teacher.jsp").forward(req, resp);
    }
}