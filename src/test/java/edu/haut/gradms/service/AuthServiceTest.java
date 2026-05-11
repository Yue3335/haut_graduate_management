package edu.haut.gradms.service;

import edu.haut.gradms.dao.IUserDao;
import edu.haut.gradms.model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class AuthServiceTest {

    private IUserDao mockUserDao;
    private AuthService authService;

    @BeforeEach
    void setUp() {
        mockUserDao = Mockito.mock(IUserDao.class);
        authService = new AuthService(mockUserDao); // 注入Mock，无需数据库
    }

    /** 正常登录成功 */
    @Test
    void login_success() {
        when(mockUserDao.findByUsername("alice"))
                .thenReturn(buildUser("alice", "pass123", 1));
        User result = authService.login("alice", "pass123");
        assertNotNull(result);
        assertEquals("alice", result.getUsername());
        verify(mockUserDao, times(1)).findByUsername("alice");
    }

    /** 边界条件：用户名为空或null */
    @Test
    void login_emptyUsername_returnsNull() {
        assertNull(authService.login("", "pass123"));
        assertNull(authService.login(null, "pass123"));
        verifyNoInteractions(mockUserDao); // 不应查询数据库
    }

    /** 异常路径：用户不存在 */
    @Test
    void login_userNotFound_returnsNull() {
        when(mockUserDao.findByUsername("ghost")).thenReturn(null);
        assertNull(authService.login("ghost", "anypass"));
    }

    /** 异常路径：账号被禁用 */
    @Test
    void login_disabledUser_returnsNull() {
        when(mockUserDao.findByUsername("bob"))
                .thenReturn(buildUser("bob", "pass123", 0)); // status=0已禁用
        assertNull(authService.login("bob", "pass123"));
    }

    /** 异常路径：密码错误 */
    @Test
    void login_wrongPassword_returnsNull() {
        when(mockUserDao.findByUsername("carol"))
                .thenReturn(buildUser("carol", "correctPass", 1));
        assertNull(authService.login("carol", "wrongPass"));
    }

    /** 边界条件：密码为空或null */
    @Test
    void login_emptyPassword_returnsNull() {
        assertNull(authService.login("alice", ""));
        assertNull(authService.login("alice", null));
        verifyNoInteractions(mockUserDao); // 不应查询数据库
    }

    /** 构造测试用 User 对象 */
    private User buildUser(String username, String password, int status) {
        User u = new User();
        u.setUsername(username);
        u.setPasswordHash(password);
        u.setStatus(status);
        return u;
    }
}