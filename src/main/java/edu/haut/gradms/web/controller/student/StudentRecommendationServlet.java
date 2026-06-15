package edu.haut.gradms.web.controller.student;

import edu.haut.gradms.dao.StudentDao;
import edu.haut.gradms.dao.StudentGradeDao;
import edu.haut.gradms.model.GradeItem;
import edu.haut.gradms.model.Student;
import edu.haut.gradms.model.User;
import edu.haut.gradms.service.AiCareerService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet("/student/recommendation")
public class StudentRecommendationServlet extends HttpServlet {

    private final StudentDao studentDao = new StudentDao();
    private final StudentGradeDao studentGradeDao = new StudentGradeDao();
    private final AiCareerService aiCareerService = new AiCareerService();

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
        Boolean isStudent = (Boolean) session.getAttribute("isStudent");

        if (currentUser == null || isStudent == null || !isStudent) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无访问权限");
            return;
        }

        Student student = studentDao.findByUserId(currentUser.getUserId());
        if (student == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "未找到学生信息");
            return;
        }

        /*
         * 1. 查询课程成绩明细，用于页面展示
         */
        Map<String, List<GradeItem>> termGrades =
                studentGradeDao.findGradesByStudentIdForFourTerms(student.getStudentId());

        /*
         * 2. 查询 GPA 走势，用于页面折线图
         */
        Map<String, Double> gpaMap =
                studentGradeDao.findGpaTrendByStudentId(student.getStudentId());

        req.setAttribute("student", student);
        req.setAttribute("termGrades", termGrades);

        req.setAttribute("gpaTermList", new ArrayList<>(gpaMap.keySet()));
        req.setAttribute("gpaValueList", new ArrayList<>(gpaMap.values()));

        req.getRequestDispatcher("/WEB-INF/jsp/student/recommendation.jsp")
                .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

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

        String mbti = req.getParameter("mbti");
        if (mbti == null || mbti.trim().isEmpty()) {
            mbti = "未填写";
        } else {
            mbti = mbti.trim();
        }

        Student student = studentDao.findByUserId(currentUser.getUserId());
        if (student == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "未找到学生信息");
            return;
        }

        /*
         * 1. 课程成绩明细：用于 AI 分析，也用于页面继续显示课程表
         */
        Map<String, List<GradeItem>> termGrades =
                studentGradeDao.findGradesByStudentIdForFourTerms(student.getStudentId());

        /*
         * 2. GPA 走势：用于折线图，也可以加入 AI prompt
         */
        Map<String, Double> gpaMap =
                studentGradeDao.findGpaTrendByStudentId(student.getStudentId());

        String majorName = "软件工程";

        StringBuilder sb = new StringBuilder();

        sb.append("请根据以下学生信息，推荐适合的岗位，并分点给出具体建议。\n\n");

        sb.append("【基本信息】\n");
        sb.append("专业：").append(majorName).append("\n");
        sb.append("MBTI 类型：").append(mbti).append("\n\n");

        sb.append("【GPA 走势】\n");
        if (gpaMap == null || gpaMap.isEmpty()) {
            sb.append("暂无 GPA 数据。\n\n");
        } else {
            for (Map.Entry<String, Double> entry : gpaMap.entrySet()) {
                sb.append("学期 ").append(entry.getKey())
                        .append("：GPA ")
                        .append(entry.getValue())
                        .append("\n");
            }
            sb.append("\n");
        }

        sb.append("【课程成绩明细】\n");

        if (termGrades == null || termGrades.isEmpty()) {
            sb.append("暂无课程成绩数据。\n\n");
        } else {
            for (Map.Entry<String, List<GradeItem>> entry : termGrades.entrySet()) {
                String term = entry.getKey();
                List<GradeItem> grades = entry.getValue();

                sb.append("学期 ").append(term).append("：\n");

                if (grades == null || grades.isEmpty()) {
                    sb.append("  - 暂无成绩\n");
                } else {
                    for (GradeItem g : grades) {
                        sb.append("  - 课程：")
                                .append(g.getCourseName())
                                .append("，成绩：");

                        if (g.getScoreText() != null && !g.getScoreText().trim().isEmpty()) {
                            sb.append(g.getScoreText());
                        } else {
                            sb.append(g.getScore());
                        }

                        sb.append("，学分：")
                                .append(g.getCredit());

                        if (g.getCourseAttr() != null && !g.getCourseAttr().trim().isEmpty()) {
                            sb.append("，属性：").append(g.getCourseAttr());
                        }

                        if (g.getGradePoint() != null) {
                            sb.append("，绩点：").append(g.getGradePoint());
                        }

                        sb.append("\n");
                    }
                }

                sb.append("\n");
            }
        }

        sb.append("请你综合考虑专业、成绩结构、GPA 走势和 MBTI 类型，从以下几个方面进行分析：\n");
        sb.append("1. 适合的岗位类型，例如后台开发、前端开发、数据分析、算法工程师、测试工程师、产品经理等，列出 3 到 5 个备选方向。\n");
        sb.append("2. 每个岗位方向对应的核心技能要求，以及该学生当前的匹配度，简单说明理由。\n");
        sb.append("3. 根据成绩中的优势课程和薄弱课程，指出接下来 1 到 2 年内应该重点提升的课程或技能。\n");
        sb.append("4. 如果未来考虑考研或找工作，分别给出简要建议。\n");
        sb.append("请使用简体中文回答，并使用合适的 Markdown 标题和列表结构。");

        String prompt = sb.toString();

        String aiHtml = aiCareerService.generateCareerSuggestion(prompt);

        req.setAttribute("student", student);
        req.setAttribute("termGrades", termGrades);

        req.setAttribute("gpaTermList", new ArrayList<>(gpaMap.keySet()));
        req.setAttribute("gpaValueList", new ArrayList<>(gpaMap.values()));

        req.setAttribute("mbti", mbti);
        req.setAttribute("aiSuggestion", aiHtml);

        req.getRequestDispatcher("/WEB-INF/jsp/student/recommendation.jsp")
                .forward(req, resp);
    }
}