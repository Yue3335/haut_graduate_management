package edu.haut.gradms.web.controller.student;

import edu.haut.gradms.dao.EmploymentInfoDao;
import edu.haut.gradms.dao.StudentDao;
import edu.haut.gradms.dao.StudentSupervisorDao;
import edu.haut.gradms.dao.SubmissionDao;
import edu.haut.gradms.model.EmploymentInfo;
import edu.haut.gradms.model.Student;
import edu.haut.gradms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Paths;

/**
 * 学生：就业去向登记 + 可选附件上传
 * URL: /student/submission
 */
@WebServlet("/student/submission")
@MultipartConfig(
        fileSizeThreshold   = 1024 * 1024,      // 1MB
        maxFileSize         = 1024 * 1024 * 50, // 50MB
        maxRequestSize      = 1024 * 1024 * 80  // 80MB
)
public class StudentEmploymentServlet extends HttpServlet {

    private final StudentDao studentDao = new StudentDao();
    private final EmploymentInfoDao employmentInfoDao = new EmploymentInfoDao();
    private final StudentSupervisorDao studentSupervisorDao = new StudentSupervisorDao();
    private final SubmissionDao submissionDao = new SubmissionDao();

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

        User supervisor = studentSupervisorDao.findSupervisorByStudentId(student.getStudentId());
        EmploymentInfo latest = employmentInfoDao.findLatestByStudentId(student.getStudentId());

        req.setAttribute("student", student);
        req.setAttribute("supervisor", supervisor);
        req.setAttribute("latestEmployment", latest);

        req.getRequestDispatcher("/WEB-INF/jsp/student/submission.jsp").forward(req, resp);
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

        Student student = studentDao.findByUserId(currentUser.getUserId());
        if (student == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "未找到学生信息");
            return;
        }

        // ===== 1. 写入就业去向到 employment_info（每次填报一条） =====
        String status = req.getParameter("status");
        String companyName = req.getParameter("companyName");
        String position = req.getParameter("position");
        String salaryStr = req.getParameter("salaryMonth");
        String city = req.getParameter("city");
        String remark = req.getParameter("remark");

        if (status == null || status.isEmpty()) {
            req.setAttribute("error", "请选择就业状态");
            doGet(req, resp);
            return;
        }

        EmploymentInfo info = new EmploymentInfo();
        info.setStudentId(student.getStudentId());
        info.setStatus(status);
        info.setCompanyName(companyName);
        info.setPosition(position);
        info.setCity(city);
        info.setRemark(remark);

        if (salaryStr != null && !salaryStr.isEmpty()) {
            try {
                info.setSalaryMonth(new BigDecimal(salaryStr));
            } catch (NumberFormatException ignored) {
            }
        }

        employmentInfoDao.insert(info); // review_status 默认 PENDING

        // ===== 2. 处理附件上传：同一学生 + type=就业去向 只保留一条 submission 记录 =====
        Part filePart = null;
        try {
            filePart = req.getPart("file");
        } catch (IllegalStateException e) {
            // 上传过大或配置问题，可按需记录日志
        }

        if (filePart != null && filePart.getSize() > 0) {
            String submittedFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

            String studentNo = student.getStudentNo();
            String uploadDirRelative = "/uploads/" + studentNo;
            String appPath = req.getServletContext().getRealPath("");
            if (appPath == null) {
                appPath = System.getProperty("catalina.base") + File.separator + "webapps" +
                        File.separator + req.getContextPath().replaceFirst("^/", "");
            }
            String uploadDirAbsolute = appPath + uploadDirRelative;

            File uploadDir = new File(uploadDirAbsolute);
            if (!uploadDir.exists()) {
                Files.createDirectories(uploadDir.toPath());
            }

            String storedFileName = System.currentTimeMillis() + "_" + submittedFileName;
            String fileAbsolutePath = uploadDirAbsolute + File.separator + storedFileName;

            filePart.write(fileAbsolutePath);

            String relativePath = uploadDirRelative + "/" + storedFileName;

            String fileTitle = req.getParameter("fileTitle");
            if (fileTitle == null || fileTitle.isEmpty()) {
                fileTitle = "就业去向相关材料";
            }
            String fileType = req.getParameter("fileType");
            if (fileType == null || fileType.isEmpty()) {
                fileType = "就业去向";
            }

            Integer existingId = submissionDao.findIdByStudentAndType(student.getStudentId(), fileType);
            if (existingId != null) {
                submissionDao.updateSubmissionFile(existingId, fileTitle, fileType, relativePath);
            } else {
                submissionDao.createSubmission(student.getStudentId(), fileTitle, fileType, relativePath);
            }
        }

        resp.sendRedirect(req.getContextPath() + "/student/submission?msg=ok");
    }
}