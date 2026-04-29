package edu.haut.gradms.config;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * 数据库连接工具类。
 * 连接参数从 classpath 下的 config.properties 读取，
 * 避免将数据库密码硬编码在源码中。
 */
public class DBUtil {

    private static final String URL;
    private static final String USER;
    private static final String PASSWORD;

    static {
        try (InputStream in = DBUtil.class.getClassLoader()
                .getResourceAsStream("config.properties")) {
            if (in == null) {
                throw new RuntimeException(
                        "未找到 config.properties，请将 config.properties.example 复制为 config.properties 并填写配置");
            }
            Properties props = new Properties();
            props.load(in);
            URL      = props.getProperty("db.url");
            USER     = props.getProperty("db.user");
            PASSWORD = props.getProperty("db.password");
            Class.forName(props.getProperty("db.driver", "com.mysql.cj.jdbc.Driver"));
        } catch (IOException | ClassNotFoundException e) {
            throw new RuntimeException("数据库配置加载失败", e);
        }
    }

    /**
     * 获取数据库连接。
     *
     * @return 新的 JDBC Connection，调用方负责关闭
     * @throws SQLException 连接失败时抛出
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}