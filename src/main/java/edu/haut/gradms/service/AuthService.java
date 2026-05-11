package edu.haut.gradms.service;

import edu.haut.gradms.dao.IUserDao;
import edu.haut.gradms.dao.UserDao;
import edu.haut.gradms.model.User;
import java.util.logging.Logger;

/**
 * 认证服务：处理用户登录校验。
 * 通过构造注入 IUserDao，支持测试时传入 Mock 对象，无需真实数据库。
 */
public class AuthService {

    private static final Logger log =
            Logger.getLogger(AuthService.class.getName());

    private final IUserDao userDao;

    /** 生产环境使用：内部创建真实 UserDao */
    public AuthService() {
        this(new UserDao());
    }

    /** 测试环境使用：外部注入 Mock UserDao */
    public AuthService(IUserDao userDao) {
        this.userDao = userDao;
    }

    /**
     * 用户登录校验。
     *
     * @param username 用户名
     * @param password 前端传入的明文密码
     * @return 校验通过返回 User 实体，失败返回 null
     */
    public User login(String username, String password) {
        log.info("[login] 尝试登录，用户名：" + username);

        if (username == null || username.isEmpty()
                || password == null || password.isEmpty()) {
            log.warning("[login] 用户名或密码为空，拒绝登录");
            return null;
        }

        User user = userDao.findByUsername(username);
        if (user == null) {
            log.warning("[login] 用户不存在：" + username);
            return null;
        }
        if (user.getStatus() != 1) {
            log.warning("[login] 账号已被禁用，用户名：" + username);
            return null;
        }
        if (!password.equals(user.getPasswordHash())) {
            log.warning("[login] 密码错误，用户名：" + username);
            return null;
        }

        log.info("[login] 登录成功，用户名：" + username
                + "，角色：" + user.getRoles());
        return user;
    }
}