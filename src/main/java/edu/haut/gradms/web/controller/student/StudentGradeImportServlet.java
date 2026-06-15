package edu.haut.gradms.web.controller.student;

import edu.haut.gradms.dao.StudentDao;
import edu.haut.gradms.dao.StudentGradeDao;
import edu.haut.gradms.model.Student;
import edu.haut.gradms.model.User;
import edu.haut.gradms.service.TranscriptPdfParser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.InputStream;

@WebServlet("/student/grade/import")
@MultipartConfig(
        maxFileSize = 10 * 1024 * 1024,
        maxRequestSize = 12 * 1024 * 1024
)
public class StudentGradeImportServlet extends HttpServlet {

    private final StudentDao studentDao = new StudentDao();
    private final StudentGradeDao studentGradeDao = new StudentGradeDao();
    private final TranscriptPdfParser transcriptPdfParser = new TranscriptPdfParser();

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

        Student student = studentDao.findByUserId(currentUser.getUserId());
        if (student == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "未找到学生信息");
            return;
        }

        Part filePart = req.getPart("scorePdf");
        if (filePart == null || filePart.getSize() == 0) {
            resp.sendRedirect(req.getContextPath()
                    + "/student/recommendation?importError="
                    + urlEncode("请选择要上传的成绩单 PDF"));
            return;
        }

        String fileName = getSubmittedFileName(filePart);

        if (fileName == null || !fileName.toLowerCase().endsWith(".pdf")) {
            resp.sendRedirect(req.getContextPath()
                    + "/student/recommendation?importError="
                    + urlEncode("只支持上传 PDF 格式成绩单"));
            return;
        }

        try (InputStream inputStream = filePart.getInputStream()) {

            TranscriptPdfParser.TranscriptParseResult parseResult =
                    transcriptPdfParser.parse(inputStream, fileName);

            /*
             * 这里不再校验 PDF 中的学号。
             * 谁登录系统，成绩就导入到谁的 student_id 下。
             *
             * 原来的逻辑是：
             * PDF 学号必须等于当前登录学生学号。
             *
             * 现在改为：
             * 只要 PDF 能识别出课程成绩，就直接导入当前登录学生账号。
             */
            int count = studentGradeDao.importTranscript(
                    student.getStudentId(),
                    parseResult.getCourseRows(),
                    fileName
            );

            resp.sendRedirect(req.getContextPath()
                    + "/student/recommendation?importSuccess=1&count=" + count);

        } catch (Exception e) {
            String msg = e.getMessage();

            if (msg == null || msg.trim().isEmpty()) {
                msg = "成绩单识别失败";
            }

            resp.sendRedirect(req.getContextPath()
                    + "/student/recommendation?importError="
                    + urlEncode(msg));
        }
    }

    private String getSubmittedFileName(Part part) {
        String header = part.getHeader("content-disposition");

        if (header == null) {
            return null;
        }

        String[] items = header.split(";");

        for (String item : items) {
            item = item.trim();

            if (item.startsWith("filename")) {
                String fileName = item.substring(item.indexOf("=") + 1)
                        .trim()
                        .replace("\"", "");

                fileName = fileName.replace("\\", "/");

                int slash = fileName.lastIndexOf("/");
                if (slash >= 0) {
                    fileName = fileName.substring(slash + 1);
                }

                return fileName;
            }
        }

        return null;
    }

    private String urlEncode(String value) {
        try {
            return java.net.URLEncoder.encode(value, "UTF-8");
        } catch (Exception e) {
            return value;
        }
    }
}