package edu.haut.gradms.model;

import java.math.BigDecimal;
import java.util.Date;

/**
 * 对应表：employment_info
 */
public class EmploymentInfo extends Student {

    private int employmentId;
    private int studentId;
    /** 就业状态：'未就业', '已就业', '考研', '出国', '其他' */
    private String status;
    private String companyName;
    private String position;
    private BigDecimal salaryMonth;
    private String city;
    private Date reportTime;
    private String remark;

    /** 审核状态：PENDING, APPROVED, REJECTED */
    private String reviewStatus;
    /** 审核备注 */
    private String reviewRemark;

    public int getEmploymentId() {
        return employmentId;
    }

    public void setEmploymentId(int employmentId) {
        this.employmentId = employmentId;
    }

    public int getStudentId() {
        return studentId;
    }

    public void setStudentId(int studentId) {
        this.studentId = studentId;
    }

    public String getStatus() {
        return status;
    }

    /** 就业状态：'未就业', '已就业', '考研', '出国', '其他' */
    public void setStatus(String status) {
        this.status = status;
    }

    public String getCompanyName() {
        return companyName;
    }

    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }

    public String getPosition() {
        return position;
    }

    public void setPosition(String position) {
        this.position = position;
    }

    public BigDecimal getSalaryMonth() {
        return salaryMonth;
    }

    public void setSalaryMonth(BigDecimal salaryMonth) {
        this.salaryMonth = salaryMonth;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public Date getReportTime() {
        return reportTime;
    }

    public void setReportTime(Date reportTime) {
        this.reportTime = reportTime;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    public String getReviewStatus() {
        return reviewStatus;
    }

    public void setReviewStatus(String reviewStatus) {
        this.reviewStatus = reviewStatus;
    }

    public String getReviewRemark() {
        return reviewRemark;
    }

    public void setReviewRemark(String reviewRemark) {
        this.reviewRemark = reviewRemark;
    }
}