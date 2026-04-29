package edu.haut.gradms.web.controller.common;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.*;

/**
 * 通用文件下载 Servlet
 * URL 示例: /download?path=/uploads/202220101/xxx.pdf
 *
 * 说明:
 *  - 你现在数据库里的 content_path 形如 "/uploads/202220101/xxx.pdf"
 *  - web 应用根目录下实际有 /uploads/202220101/xxx.pdf
 *  - 所以这里直接用 getRealPath(path) 解析真实路径即可
 */
@WebServlet("/download")
public class DownloadServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getParameter("path");
        if (path == null || path.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "缺少参数 path");
            return;
        }

        // 简单安全检查：避免目录穿越
        if (path.contains("..") || path.contains("WEB-INF")) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "非法路径");
            return;
        }

        // 确保 path 以 "/" 开头，方便 getRealPath 解析
        if (!path.startsWith("/")) {
            path = "/" + path;
        }

        // 直接通过 path 解析真实路径
        // 例如 path = "/uploads/202220101/xxx.pdf"
        // realPath = [webroot]/uploads/202220101/xxx.pdf
        String realPath = getServletContext().getRealPath(path);
        if (realPath == null) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "无法解析文件路径");
            return;
        }

        File file = new File(realPath);
        if (!file.exists() || !file.isFile()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "文件不存在");
            return;
        }

        // 根据文件名简单判断 Content-Type
        String fileName = file.getName();
        String mimeType = getServletContext().getMimeType(fileName);
        if (mimeType == null) {
            // 默认二进制流
            mimeType = "application/octet-stream";
        }
        resp.setContentType(mimeType);

        // 下载时的文件名编码处理
        String encodedFileName = java.net.URLEncoder.encode(fileName, "UTF-8")
                .replaceAll("\\+", "%20");
        // 如果你希望在线预览 PDF，可以改为 inline；现在先用 attachment 强制下载
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + encodedFileName + "\"");
        resp.setContentLengthLong(file.length());

        // 以流的方式输出文件内容
        try (InputStream in = new FileInputStream(file);
             OutputStream out = resp.getOutputStream()) {

            byte[] buffer = new byte[8192];
            int len;
            while ((len = in.read(buffer)) != -1) {
                out.write(buffer, 0, len);
            }
        }
    }
}