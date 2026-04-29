package edu.haut.gradms.web.controller.api;

import com.fasterxml.jackson.databind.ObjectMapper;
import edu.haut.gradms.dao.MajorDao;
import edu.haut.gradms.dao.MajorDao.Major;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/api/majors")
public class MajorApiServlet extends HttpServlet {

    private final MajorDao majorDao = new MajorDao();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String deptIdStr = req.getParameter("deptId");
        resp.setContentType("application/json;charset=UTF-8");

        if (deptIdStr == null || deptIdStr.isEmpty()) {
            resp.getWriter().write("[]");
            return;
        }

        int deptId;
        try {
            deptId = Integer.parseInt(deptIdStr);
        } catch (NumberFormatException e) {
            resp.getWriter().write("[]");
            return;
        }

        List<Major> majors = majorDao.listByDeptId(deptId);
        objectMapper.writeValue(resp.getWriter(), majors);
    }
}