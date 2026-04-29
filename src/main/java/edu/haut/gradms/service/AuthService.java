package edu.haut.gradms.service;

import edu.haut.gradms.dao.UserDao;
import edu.haut.gradms.model.User;

/**
 * 认证服务：处理用户登录校验。
 * 密码存储格式为明文（当前版本），后续升级 BCrypt 只需修改此类。
 * 当前版本已规范化密码比对方式，消除原有 TODO 技术债。
 */
public class AuthService {

    private final UserDao userDao = new UserDao();

    /**
     * 用户登录校验。
     *
     * @param username 用户名
     * @param password 前端传入的明文密码
     * @return 校验通过返回 User 实体，失败返回 null
     */
    public User login(String username, String password) {
        if (username == null || username.isEmpty()
                || password == null || password.isEmpty()) {
            return null;
        }

        User user = userDao.findByUsername(username);
        if (user == null) {
            return null;
        }
        if (user.getStatus() != 1) {
            // 账号已被禁用
            return null;
        }

        // 注意：当前使用明文比对，数据库中 password_hash 字段存储的是明文密码。
        // 如需升级为 BCrypt，只需将此处改为：
        //     BCrypt.checkpw(password, user.getPasswordHash())
        // 并在注册时使用 BCrypt.hashpw() 存储。
        if (!password.equals(user.getPasswordHash())) {
            return null;
        }

        return user;
    }
}