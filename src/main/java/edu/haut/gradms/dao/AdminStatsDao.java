package edu.haut.gradms.dao;

import edu.haut.gradms.model.dto.DeptMajorStudentCount;
import edu.haut.gradms.model.dto.SupervisorStudentCount;

import java.sql.SQLException;
import java.util.List;

public interface AdminStatsDao {

    /**
     * 按学院 + 专业统计学生人数
     */
    List<DeptMajorStudentCount> findDeptMajorStudentCounts() throws SQLException;

    /**
     * 指导老师对应学生数量统计（只含 SUPERVISOR）
     */
    List<SupervisorStudentCount> findSupervisorStudentCounts() throws SQLException;
}