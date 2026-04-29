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

        Map<String, List<GradeItem>> termGrades =
                studentGradeDao.findGradesByStudentIdForFourTerms(student.getStudentId());

        req.setAttribute("student", student);
        req.setAttribute("termGrades", termGrades);

        req.getRequestDispatcher("/WEB-INF/jsp/student/recommendation.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
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

        req.setCharacterEncoding("UTF-8");

        String mbti = req.getParameter("mbti");
        if (mbti == null || mbti.isEmpty()) {
            mbti = "未填写";
        }

        Student student = studentDao.findByUserId(currentUser.getUserId());
        if (student == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "未找到学生信息");
            return;
        }

        Map<String, List<GradeItem>> termGrades =
                studentGradeDao.findGradesByStudentIdForFourTerms(student.getStudentId());

        // TODO：建议从专业表查中文名，这里先写一个占位
        String majorName = "计算机科学与技术"; // 示例，你可以换成真正查询结果

        // 构造 prompt
        StringBuilder sb = new StringBuilder();
        sb.append("请根据以下学生信息，推荐适合的岗位，并分点给出具体建议：\n\n");
        sb.append("【基本信息】\n");
        sb.append("专业：").append(majorName).append("\n");
        sb.append("MBTI 类型：").append(mbti).append("\n\n");

        sb.append("【成绩概况】\n");
        for (Map.Entry<String, List<GradeItem>> entry : termGrades.entrySet()) {
            String term = entry.getKey();
            List<GradeItem> grades = entry.getValue();
            sb.append("学期 ").append(term).append("：\n");
            for (GradeItem g : grades) {
                sb.append("  - 课程：").append(g.getCourseName())
                        .append("，成绩：").append(g.getScore())
                        .append("，学分：").append(g.getCredit())
                        .append("\n");
            }
            sb.append("\n");
        }
        sb.append("请你综合考虑专业、成绩、MBTI 类型，从以下几个方面进行分析：\n");
        sb.append("1. 适合的岗位类型（例如：后台开发、前端开发、数据分析、算法工程师、测试工程师、产品经理等），列出 3~5 个备选方向。\n");
        sb.append("2. 每个岗位方向对应的核心技能要求，以及该学生当前的匹配度（简单说明理由）。\n");
        sb.append("3. 接下来 1~2 年内可以重点提升的课程/技能（给出具体建议）。\n");
        sb.append("4. 如果未来考虑考研或找工作，分别给一句简要建议。\n");
        sb.append("请使用简体中文回答，并使用合适的 Markdown 标题和列表结构。");

        String prompt = sb.toString();

        // 调用 AI：返回的是 HTML（已经处理过 Markdown）
        String aiHtml = aiCareerService.generateCareerSuggestion(prompt);

        // 设置属性，转发回 JSP
        req.setAttribute("student", student);
        req.setAttribute("termGrades", termGrades);
        req.setAttribute("mbti", mbti);
        req.setAttribute("aiSuggestion", aiHtml);

        req.getRequestDispatcher("/WEB-INF/jsp/student/recommendation.jsp").forward(req, resp);
    }
}