package edu.haut.gradms.dao;

import edu.haut.gradms.model.User;
import java.util.Set;

/**
 * UserDao 接口。
 * Service 层依赖此接口而非具体实现，
 * 测试时可注入 Mock 对象，无需真实数据库连接。
 */
public interface IUserDao {
    User findByUsername(String username);
    User findById(int userId);
    Set<String> findRoleNamesByUserId(int userId);
}