package edu.haut.gradms.web.controller.student;

import edu.haut.gradms.model.User;
import edu.haut.gradms.service.AiCareerService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/student/mock-interview/question")
public class StudentInterviewQuestionServlet extends HttpServlet {

    private final AiCareerService aiCareerService = new AiCareerService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("{\"question\":\"请先登录后再进行模拟面试。\"}");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null || !currentUser.hasRole("STUDENT")) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            resp.getWriter().write("{\"question\":\"无访问权限。\"}");
            return;
        }

        String jobDirection = safe(req.getParameter("jobDirection"));
        String interviewerStyle = safe(req.getParameter("interviewerStyle"));
        String interviewFocus = safe(req.getParameter("interviewFocus"));
        String currentQuestion = safe(req.getParameter("currentQuestion"));
        String answerText = safe(req.getParameter("answerText"));
        String mainEmotion = safe(req.getParameter("mainEmotion"));
        String questionCount = safe(req.getParameter("questionCount"));

        if (jobDirection.isEmpty()) {
            jobDirection = "后端开发";
        }

        if (interviewerStyle.isEmpty()) {
            interviewerStyle = "亲和引导型";
        }

        if (interviewFocus.isEmpty()) {
            interviewFocus = "偏项目经历";
        }

        if (mainEmotion.isEmpty()) {
            mainEmotion = "未识别";
        }

        StringBuilder prompt = new StringBuilder();

        prompt.append("你现在是一名高校就业指导系统中的AI面试官。\n");
        prompt.append("你的任务是根据岗位方向、面试官性格、面试特点、学生上一题回答和当前情绪状态，生成下一道面试问题。\n\n");

        prompt.append("【强制规则】\n");
        prompt.append("1. 严格一次只问一个问题。\n");
        prompt.append("2. 只输出问题本身，不要标题，不要解释，不要答案。\n");
        prompt.append("3. 问题长度控制在80字以内。\n");
        prompt.append("4. 如果学生上一题回答很短，要进行具体追问。\n");
        prompt.append("5. 如果当前情绪是紧张，语气要稍微引导，但仍保持面试真实感。\n");
        prompt.append("6. 如果面试特点是偏抗压追问，问题可以更尖锐一些。\n");
        prompt.append("7. 如果面试特点是偏技术细节，要追问项目实现、数据库、接口、性能或异常处理。\n");
        prompt.append("8. 如果这是第一题，请先让学生介绍项目经历或岗位匹配优势。\n\n");

        prompt.append("【岗位方向】").append(jobDirection).append("\n");
        prompt.append("【面试官性格】").append(interviewerStyle).append("\n");
        prompt.append("【面试特点】").append(interviewFocus).append("\n");
        prompt.append("【已提问数量】").append(questionCount).append("\n");
        prompt.append("【当前情绪】").append(mainEmotion).append("\n");
        prompt.append("【上一道问题】").append(currentQuestion).append("\n");
        prompt.append("【学生上一题回答】").append(answerText).append("\n\n");

        prompt.append("请直接输出下一道面试问题。");

        String aiResult = aiCareerService.generateCareerSuggestion(prompt.toString());
        String question = cleanAiQuestion(aiResult);

        if (question.length() > 120) {
            question = question.substring(0, 120);
        }

        if (question.isEmpty()) {
            question = fallbackQuestion(jobDirection, interviewerStyle, interviewFocus, mainEmotion);
        }

        resp.getWriter().write("{\"question\":\"" + escapeJson(question) + "\"}");
    }

    private String safe(String value) {
        return value == null ? "" : value.trim();
    }

    private String cleanAiQuestion(String text) {
        if (text == null) {
            return "";
        }

        String s = text;

        s = s.replaceAll("<[^>]+>", "");
        s = s.replace("&nbsp;", " ");
        s = s.replace("&lt;", "<");
        s = s.replace("&gt;", ">");
        s = s.replace("&amp;", "&");

        s = s.replace("下一道面试问题：", "");
        s = s.replace("问题：", "");
        s = s.replace("AI面试官：", "");
        s = s.replace("面试官：", "");

        s = s.trim();

        int idx = s.indexOf("\n");
        if (idx >= 0) {
            s = s.substring(0, idx).trim();
        }

        return s;
    }

    private String fallbackQuestion(String jobDirection,
                                    String interviewerStyle,
                                    String interviewFocus,
                                    String mainEmotion) {

        if ("紧张".equals(mainEmotion)) {
            return "不要着急，我们慢慢来。请你用三点说明一下，你最熟悉的一个项目中自己负责了哪些工作？";
        }

        if ("偏抗压追问".equals(interviewFocus)) {
            return "你刚才提到自己参与了项目，那么请说明这个项目中最难的问题是什么，你是否真正独立解决过？";
        }

        if ("偏技术细节".equals(interviewFocus)) {
            return "请你结合一个项目，具体说明你在数据库设计、接口实现或性能优化中做过哪些工作？";
        }

        if ("后端开发".equals(jobDirection)) {
            return "请你介绍一个后端项目，并说明你在数据库设计和接口开发中承担了哪些工作？";
        }

        if ("前端开发".equals(jobDirection)) {
            return "请你介绍一个前端页面，并说明你是如何设计交互和提升用户体验的？";
        }

        if ("数据分析".equals(jobDirection)) {
            return "请你介绍一次数据分析经历，并说明你如何清洗数据、选择指标和解释结论？";
        }

        if ("软件测试".equals(jobDirection)) {
            return "请你以登录功能为例，说明你会如何设计测试用例？";
        }

        if ("产品经理".equals(jobDirection)) {
            return "如果让你设计一个学生就业管理系统，你会优先设计哪些核心功能？为什么？";
        }

        return "请你先做一个简短的自我介绍，并说明你为什么适合这个岗位方向？";
    }

    private String escapeJson(String s) {
        if (s == null) {
            return "";
        }

        return s
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "")
                .replace("\n", "\\n");
    }
}