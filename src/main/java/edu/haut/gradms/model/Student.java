package edu.haut.gradms.model;

public class Student {
    private int studentId;
    private int userId;
    private String studentNo;
    private int deptId;
    private String deptName;
    private int majorId;
    private String majorName;
    private int classId;
    private String className;
    private int enrollYear;

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getStudentNo() { return studentNo; }
    public void setStudentNo(String studentNo) { this.studentNo = studentNo; }

    public int getDeptId() { return deptId; }
    public void setDeptId(int deptId) { this.deptId = deptId; }

    public String getDeptName() { return deptName; }
    public void setDeptName(String deptName) { this.deptName = deptName; }

    public int getMajorId() { return majorId; }
    public void setMajorId(int majorId) { this.majorId = majorId; }

    public String getMajorName() { return majorName; }
    public void setMajorName(String majorName) { this.majorName = majorName; }

    public int getClassId() { return classId; }
    public void setClassId(int classId) { this.classId = classId; }

    public String getClassName() { return className; }
    public void setClassName(String className) { this.className = className; }

    public int getEnrollYear() { return enrollYear; }
    public void setEnrollYear(int enrollYear) { this.enrollYear = enrollYear; }
}