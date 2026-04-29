package edu.haut.gradms.model;

public class ClassInfo {
    private int classId;
    private int majorId;
    private String className;
    private int enrollYear;
    private Integer classTeacherUserId;
    private String classTeacherName;

    public int getClassId() { return classId; }
    public void setClassId(int classId) { this.classId = classId; }

    public int getMajorId() { return majorId; }
    public void setMajorId(int majorId) { this.majorId = majorId; }

    public String getClassName() { return className; }
    public void setClassName(String className) { this.className = className; }

    public int getEnrollYear() { return enrollYear; }
    public void setEnrollYear(int enrollYear) { this.enrollYear = enrollYear; }

    public Integer getClassTeacherUserId() { return classTeacherUserId; }
    public void setClassTeacherUserId(Integer classTeacherUserId) {
        this.classTeacherUserId = classTeacherUserId;
    }

    public String getClassTeacherName() { return classTeacherName; }
    public void setClassTeacherName(String classTeacherName) { this.classTeacherName = classTeacherName; }
}