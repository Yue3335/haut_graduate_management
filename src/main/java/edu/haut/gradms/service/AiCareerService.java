package edu.haut.gradms.service;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

// 新增：flexmark 的导入
import com.vladsch.flexmark.parser.Parser;
import com.vladsch.flexmark.util.ast.Node;
import com.vladsch.flexmark.html.HtmlRenderer;

public class AiCareerService {

    private static final String API_URL = "https://api.deepseek.com/chat/completions";
    private static final String API_KEY = "sk-9407a19216384899ad21159fca6f0504";
    private static final String MODEL   = "deepseek-chat";

    private static final int CONNECT_TIMEOUT_MS = 15000;
    private static final int READ_TIMEOUT_MS    = 60000;
    private static final int MAX_RETRIES_ON_TIMEOUT = 1;

    // 新增：Markdown 解析器和渲染器（静态初始化一次即可）
    private static final Parser MD_PARSER = Parser.builder().build();
    private static final HtmlRenderer MD_RENDERER = HtmlRenderer.builder().build();

    public String generateCareerSuggestion(String prompt) {
        int attempt = 0;
        while (true) {
            attempt++;
            try {
                return callOnce(prompt);
            } catch (java.net.SocketTimeoutException e) {
                if (attempt > MAX_RETRIES_ON_TIMEOUT) {
                    return "<p>调用 DeepSeek 接口超时，请稍后重试或联系管理员检查网络连接。</p>";
                }
                continue;
            } catch (Exception e) {
                // 这里返回 HTML 文本（简单包一层 <p>），避免 JSP 里再做转义
                String msg = e.getClass().getSimpleName() + " - " + e.getMessage();
                return "<p>调用 DeepSeek 接口失败：" + escapeHtmlSimple(msg) + "</p>";
            }
        }
    }

    private String callOnce(String prompt) throws Exception {
        URL url = new URL(API_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setConnectTimeout(CONNECT_TIMEOUT_MS);
        conn.setReadTimeout(READ_TIMEOUT_MS);
        conn.setDoOutput(true);

        conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
        conn.setRequestProperty("Authorization", "Bearer " + API_KEY);

        JSONObject body = new JSONObject();
        body.put("model", MODEL);

        JSONArray messages = new JSONArray();
        messages.put(new JSONObject()
                .put("role", "system")
                .put("content", "你是一名专业的职业规划顾问，会根据学生的专业、成绩和MBTI性格类型，推荐适合的岗位，并给出具体建议。回答请使用简体中文，并使用合理的 Markdown 标题和列表格式。")
        );
        messages.put(new JSONObject()
                .put("role", "user")
                .put("content", prompt)
        );
        body.put("messages", messages);
        body.put("stream", false);
        body.put("temperature", 0.7);

        String jsonBody = body.toString();

        try (OutputStream os = conn.getOutputStream()) {
            byte[] input = jsonBody.getBytes(StandardCharsets.UTF_8);
            os.write(input);
        }

        int status = conn.getResponseCode();
        InputStream is = (status >= 200 && status < 300)
                ? conn.getInputStream()
                : conn.getErrorStream();

        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = new BufferedReader(
                new InputStreamReader(is, StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
        }

        String response = sb.toString();

        JSONObject respJson = new JSONObject(response);

        // error 处理
        if (respJson.has("error")) {
            JSONObject err = respJson.getJSONObject("error");
            String errMsg  = err.optString("message", "未知错误");
            String errCode = err.optString("code", "");

            if ("Insufficient Balance".equalsIgnoreCase(errMsg)) {
                return "<p>DeepSeek 返回错误：余额不足，请联系管理员为 AI 服务充值后再试。</p>";
            }

            String full = "DeepSeek 返回错误：" + errMsg +
                    (errCode.isEmpty() ? "" : "（code: " + errCode + "）");
            return "<p>" + escapeHtmlSimple(full) + "</p>";
        }

        // 正常内容：choices[0].message.content
        JSONArray choices = respJson.optJSONArray("choices");
        if (choices != null && choices.length() > 0) {
            JSONObject msg = choices.getJSONObject(0).optJSONObject("message");
            if (msg != null) {
                String markdown = msg.optString("content", "").trim();
                if (markdown.isEmpty()) {
                    return "<p>AI 没有返回内容。</p>";
                }
                // 核心：Markdown -> HTML
                Node document = MD_PARSER.parse(markdown);
                String html = MD_RENDERER.render(document);
                return html;
            }
        }

        // 兜底：看不懂响应时，原样转义输出
        String fallback = "未能从 DeepSeek 响应中解析到内容，原始响应：" + response;
        return "<p>" + escapeHtmlSimple(fallback) + "</p>";
    }

    // 简单 HTML 转义（只在构造错误提示等地方用）
    private String escapeHtmlSimple(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }
}