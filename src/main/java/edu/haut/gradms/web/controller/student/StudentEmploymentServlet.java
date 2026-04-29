package edu.haut.gradms.web.controller.student;

import edu.haut.gradms.dao.EmploymentInfoDao;
import edu.haut.gradms.dao.StudentDao;
import edu.haut.gradms.dao.StudentSupervisorDao;
import edu.haut.gradms.dao.SubmissionDao;
import edu.haut.gradms.model.EmploymentInfo;
import edu.haut.gradms.model.Student;
import edu.haut.gradms.model.User;
import edu.haut.gradms.web.util.SessionUtil;
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
 * 学生就业去向登记 Servlet。
 * GET：展示填报表单及当前最新就业状态。
 * POST：保存就业信息（saveEmploymentInfo）+ 可选附件上传（handleFileUpload）。
 */
@WebServlet("/student/submission")
@MultipartConfig(
        fileSizeThreshold   = 1024 * 1024,
        maxFileSize         = 1024 * 1024 * 50,
        maxRequestSize      = 1024 * 1024 * 80
)
public class StudentEmploymentServlet extends HttpServlet {

    private final StudentDao            studentDao            = new StudentDao();
    private final EmploymentInfoDao     employmentInfoDao     = new EmploymentInfoDao();
    private final StudentSupervisorDao  studentSupervisorDao  = new StudentSupervisorDao();
    private final SubmissionDao         submissionDao         = new SubmissionDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!SessionUtil.requireStudent(req, resp)) return;

        Student student = resolveStudent(req, resp);
        if (student == null) return;

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

        if (!SessionUtil.requireStudent(req, resp)) return;

        req.setCharacterEncoding("UTF-8");

        Student student = resolveStudent(req, resp);
        if (student == null) return;

        // 校验必填字段
        String status = req.getParameter("status");
        if (status == null || status.isEmpty()) {
            req.setAttribute("error", "请选择就业状态");
            doGet(req, resp);
            return;
        }

        saveEmploymentInfo(req, student, status);   // 职责1：保存就业信息
        handleFileUpload(req, resp, student);       // 职责2：处理附件上传

        resp.sendRedirect(req.getContextPath() + "/student/submission?msg=ok");
    }

    /**
     * 从 Session 中解析当前学生实体。
     * 找不到时发送 403 并返回 null，调用方应立即 return。
     */
    private Student resolveStudent(HttpServletRequest req,
                                   HttpServletResponse resp)
            throws IOException {
        User currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        Student student = studentDao.findByUserId(currentUser.getUserId());
        if (student == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "未找到学生信息");
            return null;
        }
        return student;
    }

    /**
     * 解析表单参数并将就业信息写入数据库。
     * review_status 默认为 PENDING（待审核）。
     */
    private void saveEmploymentInfo(HttpServletRequest req,
                                    Student student,
                                    String status) {
        EmploymentInfo info = new EmploymentInfo();
        info.setStudentId(student.getStudentId());
        info.setStatus(status);
        info.setCompanyName(req.getParameter("companyName"));
        info.setPosition(req.getParameter("position"));
        info.setCity(req.getParameter("city"));
        info.setRemark(req.getParameter("remark"));

        String salaryStr = req.getParameter("salaryMonth");
        if (salaryStr != null && !salaryStr.isEmpty()) {
            try {
                info.setSalaryMonth(new BigDecimal(salaryStr));
            } catch (NumberFormatException ignored) {
                // 薪资格式非法时忽略，不影响主流程
            }
        }

        employmentInfoDao.insert(info); // review_status 在 DAO 层默认设为 PENDING
    }

    /**
     * 处理就业材料附件上传。
     * 同一学生同一 fileType 只保留一条 submission 记录（覆盖旧文件路径）。
     */
    private void handleFileUpload(HttpServletRequest req,
                                  HttpServletResponse resp,
                                  Student student)
            throws IOException, ServletException {
        Part filePart = null;
        try {
            filePart = req.getPart("file");
        } catch (IllegalStateException e) {
            // 文件过大或 multipart 配置问题，跳过上传不中断主流程
            return;
        }

        if (filePart == null || filePart.getSize() == 0) return;

        String submittedFileName = Paths.get(
                filePart.getSubmittedFileName()).getFileName().toString();

        String uploadDirRelative = "/uploads/" + student.getStudentNo();
        String appPath = req.getServletContext().getRealPath("");
        if (appPath == null) {
            appPath = System.getProperty("catalina.base") + File.separator
                    + "webapps" + File.separator
                    + req.getContextPath().replaceFirst("^/", "");
        }
        String uploadDirAbsolute = appPath + uploadDirRelative;
        Files.createDirectories(Paths.get(uploadDirAbsolute));

        String storedFileName    = System.currentTimeMillis() + "_" + submittedFileName;
        String fileAbsolutePath  = uploadDirAbsolute + File.separator + storedFileName;
        filePart.write(fileAbsolutePath);

        String relativePath = uploadDirRelative + "/" + storedFileName;

        String fileTitle = req.getParameter("fileTitle");
        if (fileTitle == null || fileTitle.isEmpty()) fileTitle = "就业去向相关材料";

        String fileType = req.getParameter("fileType");
        if (fileType == null || fileType.isEmpty()) fileType = "就业去向";

        Integer existingId = submissionDao.findIdByStudentAndType(
                student.getStudentId(), fileType);
        if (existingId != null) {
            submissionDao.updateSubmissionFile(existingId, fileTitle, fileType, relativePath);
        } else {
            submissionDao.createSubmission(
                    student.getStudentId(), fileTitle, fileType, relativePath);
        }
    }
}