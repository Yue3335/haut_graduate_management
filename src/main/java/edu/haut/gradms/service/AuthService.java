package edu.haut.gradms.service;

import edu.haut.gradms.dao.UserDao;
import edu.haut.gradms.model.User;

public class AuthService {

    private final UserDao userDao = new UserDao();

    /**
     * 简单登录验证：明文密码比较（后续可替换为加密）
     */
    public User login(String username, String password) {
        User user = userDao.findByUsername(username);
        if (user == null) {
            return null;
        }
        if (user.getStatus() != 1) {
            return null; // 禁用
        }
        // TODO: 真实项目中应使用加密（如 BCrypt），这里先明文比较
        if (!password.equals(user.getPasswordHash())) {
            return null;
        }
        return user;
    }
}