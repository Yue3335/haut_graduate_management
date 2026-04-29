package edu.haut.gradms.service;

import edu.haut.gradms.dao.AdminStatsDao;
import edu.haut.gradms.model.dto.DeptMajorStudentCount;
import edu.haut.gradms.model.dto.SupervisorStudentCount;

import java.sql.SQLException;
import java.util.*;

/**
 * 管理员统计服务（为首页图表提供数据）
 */
public class AdminStatsService {

    private final AdminStatsDao adminStatsDao;

    public AdminStatsService(AdminStatsDao adminStatsDao) {
        this.adminStatsDao = adminStatsDao;
    }

    /**
     * 首页用：各专业学生人数（不分学院，直接合成一个列表）
     * 返回 List<Map<String,Object>>，每个元素有 majorName, count
     */
    public List<Map<String, Object>> getMajorStudentCountForHome() throws SQLException {
        List<DeptMajorStudentCount> list = adminStatsDao.findDeptMajorStudentCounts();
        Map<String, Integer> majorToCount = new LinkedHashMap<>();

        for (DeptMajorStudentCount row : list) {
            if (row.getMajorName() == null) continue;
            String majorName = row.getMajorName();
            int count = row.getStudentCount();
            majorToCount.merge(majorName, count, Integer::sum);
        }

        List<Map<String, Object>> result = new ArrayList<>();
        for (Map.Entry<String, Integer> e : majorToCount.entrySet()) {
            Map<String, Object> m = new HashMap<>();
            m.put("majorName", e.getKey());
            m.put("count", e.getValue());
            result.add(m);
        }
        return result;
    }

    /**
     * 首页用：指导老师-学生数
     * 返回 List<Map<String,Object>>，每个元素有 teacherName, count
     */
    public List<Map<String, Object>> getSupervisorStudentCountForHome() throws SQLException {
        List<SupervisorStudentCount> list = adminStatsDao.findSupervisorStudentCounts();
        List<Map<String, Object>> result = new ArrayList<>();

        for (SupervisorStudentCount row : list) {
            Map<String, Object> m = new HashMap<>();
            // 显示名：真实姓名(用户名)
            String displayName = row.getTeacherName() + "（" + row.getTeacherUsername() + "）";
            m.put("teacherName", displayName);
            m.put("count", row.getStudentCount());
            result.add(m);
        }
        return result;
    }
}