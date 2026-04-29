package edu.haut.gradms.web.controller;

import edu.haut.gradms.dao.DepartmentDao;
import edu.haut.gradms.dao.DepartmentDao.Department;
import edu.haut.gradms.dao.UserDao;
import edu.haut.gradms.service.RegisterService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private final RegisterService registerService = new RegisterService();
    private final UserDao userDao = new UserDao();
    private final DepartmentDao departmentDao = new DepartmentDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // 查询所有学院，注册页用来渲染“学院下拉”
        List<Department> departments = departmentDao.listAll();
        req.setAttribute("departments", departments);

        req.getRequestDispatcher("/WEB-INF/jsp/auth/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String username = req.getParameter("username");
        String realName = req.getParameter("realName");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");
        String gender = req.getParameter("gender");
        String phone = req.getParameter("phone");
        String email = req.getParameter("email");
        String[] roles = req.getParameterValues("roles");

        String studentClassIdStr = req.getParameter("studentClassId");
        String studentEnrollYearStr = req.getParameter("studentEnrollYear");
        String classTeacherClassIdStr = req.getParameter("classTeacherClassId");
        String counselorMajorIdStr = req.getParameter("counselorMajorId");

        // 为了回显学院列表
        req.setAttribute("departments", departmentDao.listAll());

        // 基本校验
        if (username == null || username.isEmpty()
                || realName == null || realName.isEmpty()
                || password == null || password.isEmpty()
                || confirmPassword == null || confirmPassword.isEmpty()) {

            req.setAttribute("error", "用户名、姓名和密码为必填项");
            req.getRequestDispatcher("/WEB-INF/jsp/auth/register.jsp").forward(req, resp);
            return;
        }

        if (!password.equals(confirmPassword)) {
            req.setAttribute("error", "两次输入的密码不一致");
            req.getRequestDispatcher("/WEB-INF/jsp/auth/register.jsp").forward(req, resp);
            return;
        }

        if (roles == null || roles.length == 0) {
            req.setAttribute("error", "请至少选择一个角色（管理员不能自助注册）");
            req.getRequestDispatcher("/WEB-INF/jsp/auth/register.jsp").forward(req, resp);
            return;
        }

        try {
            boolean ok = registerService.registerUser(
                    username, realName, password, gender, phone, email,
                    roles,
                    studentClassIdStr, studentEnrollYearStr,
                    classTeacherClassIdStr, counselorMajorIdStr
            );

            if (!ok) {
                req.setAttribute("error", "注册失败：未知原因");
                req.getRequestDispatcher("/WEB-INF/jsp/auth/register.jsp").forward(req, resp);
                return;
            }

            // 注册成功，跳回登录页
            req.setAttribute("success", "注册成功，请使用新账号登录");
            req.getRequestDispatcher("/WEB-INF/jsp/auth/login.jsp").forward(req, resp);

        } catch (IllegalArgumentException e) {
            // 业务校验失败，例如班主任唯一性不通过
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/jsp/auth/register.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "注册过程发生系统错误，请稍后重试");
            req.getRequestDispatcher("/WEB-INF/jsp/auth/register.jsp").forward(req, resp);
        }
    }
}