package edu.haut.gradms.model;

public class GradeItem {
    private String term;        // 学期，如 2022-1
    private String courseName;  // 课程名
    private String courseCode;  // 课程代码
    private double credit;      // 学分
    private double score;       // 分数
    private Double gradePoint;  // 绩点（可以是 null）

    public String getTerm() { return term; }
    public void setTerm(String term) { this.term = term; }

    public String getCourseName() { return courseName; }
    public void setCourseName(String courseName) { this.courseName = courseName; }

    public String getCourseCode() { return courseCode; }
    public void setCourseCode(String courseCode) { this.courseCode = courseCode; }

    public double getCredit() { return credit; }
    public void setCredit(double credit) { this.credit = credit; }

    public double getScore() { return score; }
    public void setScore(double score) { this.score = score; }

    public Double getGradePoint() { return gradePoint; }
    public void setGradePoint(Double gradePoint) { this.gradePoint = gradePoint; }
}