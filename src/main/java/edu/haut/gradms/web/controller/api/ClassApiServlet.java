package edu.haut.gradms.web.controller.api;

import com.fasterxml.jackson.databind.ObjectMapper;
import edu.haut.gradms.dao.ClassDao;
import edu.haut.gradms.model.ClassInfo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/api/classes")
public class ClassApiServlet extends HttpServlet {

    private final ClassDao classDao = new ClassDao();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String majorIdStr = req.getParameter("majorId");
        resp.setContentType("application/json;charset=UTF-8");

        if (majorIdStr == null || majorIdStr.isEmpty()) {
            resp.getWriter().write("[]");
            return;
        }

        int majorId;
        try {
            majorId = Integer.parseInt(majorIdStr);
        } catch (NumberFormatException e) {
            resp.getWriter().write("[]");
            return;
        }

        // 这里用 ClassInfo，而不是 ClassDao.Clazz
        List<ClassInfo> classes = classDao.listByMajorId(majorId);
        objectMapper.writeValue(resp.getWriter(), classes);
    }
}