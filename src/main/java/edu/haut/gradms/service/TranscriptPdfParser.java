package edu.haut.gradms.service;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 河南工业大学学生历年学习成绩单 PDF 解析器。
 * 适合教务系统导出的文本型 PDF。
 */
public class TranscriptPdfParser {

    private static final Pattern COURSE_PATTERN = Pattern.compile(
            "(.+?)\\s+(\\d+(?:\\.\\d+)?)\\s+([0-9]{1,3}|优|良|中|及格|不及格|合格|不合格)\\s+(必修|选修|公选)\\s+(\\d{4}-\\d{4}-[12])",
            Pattern.DOTALL
    );

    public TranscriptParseResult parse(InputStream inputStream, String originalFileName) {
        try (PDDocument document = PDDocument.load(inputStream)) {
            PDFTextStripper stripper = new PDFTextStripper();
            String text = stripper.getText(document);

            if (text == null || text.trim().isEmpty()) {
                throw new RuntimeException("PDF 中没有可识别的文本，可能是扫描图片版，需要 OCR。");
            }

            TranscriptParseResult result = new TranscriptParseResult();
            result.setOriginalFileName(originalFileName);
            result.setRawText(text);

            String compactText = text.replaceAll("\\s+", "");

            result.setStudentName(extractBetween(compactText, "姓名", "学号"));
            result.setStudentNo(extractBetween(compactText, "学号", "性别"));
            result.setCollegeName(extractBetween(compactText, "学院名", "专业名"));
            result.setMajorName(extractBetween(compactText, "专业名", "班级"));
            result.setClassName(extractBetween(compactText, "班级", "入学日期"));
            result.setGpa(extractAfter(compactText, "平均绩点成绩", "计划选修学分"));

            List<TranscriptCourseRow> courseRows = parseCourses(text);
            result.setCourseRows(courseRows);

            if (result.getStudentNo() == null || result.getStudentNo().trim().isEmpty()) {
                throw new RuntimeException("未能识别出成绩单中的学号，请确认 PDF 格式是否正确。");
            }

            if (courseRows.isEmpty()) {
                throw new RuntimeException("未能识别出课程成绩，请确认 PDF 是否为教务系统导出的成绩单。");
            }

            return result;
        } catch (Exception e) {
            throw new RuntimeException("解析成绩单 PDF 失败：" + e.getMessage(), e);
        }
    }

    private List<TranscriptCourseRow> parseCourses(String text) {
        List<TranscriptCourseRow> list = new ArrayList<>();

        String body = text;

        int start = body.indexOf("程序设计基础");
        int end = body.indexOf("计划总学分");

        if (start >= 0 && end > start) {
            body = body.substring(start, end);
        }

        Matcher matcher = COURSE_PATTERN.matcher(body);
        while (matcher.find()) {
            String courseName = cleanCourseName(matcher.group(1));
            String creditText = matcher.group(2);
            String scoreText = matcher.group(3);
            String attr = matcher.group(4);
            String term = matcher.group(5);

            if (courseName == null || courseName.length() < 2) {
                continue;
            }

            TranscriptCourseRow row = new TranscriptCourseRow();
            row.setCourseName(courseName);
            row.setCredit(Double.parseDouble(creditText));
            row.setScoreText(scoreText);
            row.setScore(scoreTextToNumber(scoreText));
            row.setCourseAttr(attr);
            row.setTerm(term);
            row.setGradePoint(calcGradePoint(row.getScore()));

            list.add(row);
        }

        return list;
    }

    private String cleanCourseName(String value) {
        if (value == null) {
            return null;
        }

        String s = value.replaceAll("\\s+", " ").trim();

        s = s.replace("课 程 名 学分 成绩 属性 学年学期", "");
        s = s.replace("课程名 学分 成绩 属性 学年学期", "");
        s = s.replace("课 程 名", "");

        return s.trim();
    }

    private String extractBetween(String compactText, String left, String right) {
        int start = compactText.indexOf(left);
        if (start < 0) {
            return "";
        }

        start += left.length();

        int end = compactText.indexOf(right, start);
        if (end < 0 || end <= start) {
            return "";
        }

        return compactText.substring(start, end).trim();
    }

    private String extractAfter(String compactText, String left, String right) {
        int start = compactText.indexOf(left);
        if (start < 0) {
            return "";
        }

        start += left.length();

        int end = compactText.indexOf(right, start);
        if (end < 0 || end <= start) {
            end = Math.min(start + 10, compactText.length());
        }

        return compactText.substring(start, end).trim();
    }

    private double scoreTextToNumber(String scoreText) {
        if (scoreText == null) {
            return 0;
        }

        scoreText = scoreText.trim();

        if (scoreText.matches("\\d+(\\.\\d+)?")) {
            return Double.parseDouble(scoreText);
        }

        switch (scoreText) {
            case "优":
                return 95;
            case "良":
                return 85;
            case "中":
                return 75;
            case "及格":
            case "合格":
                return 65;
            case "不及格":
            case "不合格":
                return 50;
            default:
                return 0;
        }
    }

    private Double calcGradePoint(double score) {
        if (score < 60) {
            return 0.0;
        }

        double gp = (score - 50.0) / 10.0;

        if (gp > 5.0) {
            gp = 5.0;
        }

        return gp;
    }

    public static class TranscriptParseResult {
        private String studentName;
        private String studentNo;
        private String collegeName;
        private String majorName;
        private String className;
        private String gpa;
        private String originalFileName;
        private String rawText;
        private List<TranscriptCourseRow> courseRows = new ArrayList<>();

        public String getStudentName() {
            return studentName;
        }

        public void setStudentName(String studentName) {
            this.studentName = studentName;
        }

        public String getStudentNo() {
            return studentNo;
        }

        public void setStudentNo(String studentNo) {
            this.studentNo = studentNo;
        }

        public String getCollegeName() {
            return collegeName;
        }

        public void setCollegeName(String collegeName) {
            this.collegeName = collegeName;
        }

        public String getMajorName() {
            return majorName;
        }

        public void setMajorName(String majorName) {
            this.majorName = majorName;
        }

        public String getClassName() {
            return className;
        }

        public void setClassName(String className) {
            this.className = className;
        }

        public String getGpa() {
            return gpa;
        }

        public void setGpa(String gpa) {
            this.gpa = gpa;
        }

        public String getOriginalFileName() {
            return originalFileName;
        }

        public void setOriginalFileName(String originalFileName) {
            this.originalFileName = originalFileName;
        }

        public String getRawText() {
            return rawText;
        }

        public void setRawText(String rawText) {
            this.rawText = rawText;
        }

        public List<TranscriptCourseRow> getCourseRows() {
            return courseRows;
        }

        public void setCourseRows(List<TranscriptCourseRow> courseRows) {
            this.courseRows = courseRows;
        }
    }

    public static class TranscriptCourseRow {
        private String courseName;
        private double credit;
        private String scoreText;
        private double score;
        private String courseAttr;
        private String term;
        private Double gradePoint;

        public String getCourseName() {
            return courseName;
        }

        public void setCourseName(String courseName) {
            this.courseName = courseName;
        }

        public double getCredit() {
            return credit;
        }

        public void setCredit(double credit) {
            this.credit = credit;
        }

        public String getScoreText() {
            return scoreText;
        }

        public void setScoreText(String scoreText) {
            this.scoreText = scoreText;
        }

        public double getScore() {
            return score;
        }

        public void setScore(double score) {
            this.score = score;
        }

        public String getCourseAttr() {
            return courseAttr;
        }

        public void setCourseAttr(String courseAttr) {
            this.courseAttr = courseAttr;
        }

        public String getTerm() {
            return term;
        }

        public void setTerm(String term) {
            this.term = term;
        }

        public Double getGradePoint() {
            return gradePoint;
        }

        public void setGradePoint(Double gradePoint) {
            this.gradePoint = gradePoint;
        }
    }
}