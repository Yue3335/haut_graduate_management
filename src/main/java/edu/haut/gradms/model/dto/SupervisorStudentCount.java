package edu.haut.gradms.model.dto;

public class SupervisorStudentCount {
    private int teacherUserId;
    private String teacherUsername;
    private String teacherName;
    private int studentCount;

    public int getTeacherUserId() {
        return teacherUserId;
    }

    public void setTeacherUserId(int teacherUserId) {
        this.teacherUserId = teacherUserId;
    }

    public String getTeacherUsername() {
        return teacherUsername;
    }

    public void setTeacherUsername(String teacherUsername) {
        this.teacherUsername = teacherUsername;
    }

    public String getTeacherName() {
        return teacherName;
    }

    public void setTeacherName(String teacherName) {
        this.teacherName = teacherName;
    }

    public int getStudentCount() {
        return studentCount;
    }

    public void setStudentCount(int studentCount) {
        this.studentCount = studentCount;
    }
}