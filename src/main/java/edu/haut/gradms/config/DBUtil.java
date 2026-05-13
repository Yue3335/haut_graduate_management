package edu.haut.gradms.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

/**
 * 数据库连接工具类（HikariCP 连接池版本）。
 * 使用连接池替代每次请求都新建连接的方式，
 * 显著提升高并发场景下的数据库访问性能。
 */
public class DBUtil {

    private static final HikariDataSource dataSource;

    static {
        try (InputStream in = DBUtil.class.getClassLoader()
                .getResourceAsStream("config.properties")) {
            if (in == null) {
                throw new RuntimeException("未找到 config.properties");
            }
            Properties props = new Properties();
            props.load(in);

            HikariConfig config = new HikariConfig();
            config.setDriverClassName(props.getProperty("db.driver",
                    "com.mysql.cj.jdbc.Driver"));
            config.setJdbcUrl(props.getProperty("db.url"));
            config.setUsername(props.getProperty("db.user"));
            config.setPassword(props.getProperty("db.password"));

            // 连接池核心参数
            config.setMaximumPoolSize(20);       // 最大连接数
            config.setMinimumIdle(5);            // 最小空闲连接数
            config.setConnectionTimeout(30000);  // 连接超时 30 秒
            config.setIdleTimeout(600000);       // 空闲连接超时 10 分钟
            config.setMaxLifetime(1800000);      // 连接最大生命周期 30 分钟
            config.setPoolName("GradMsHikariPool");

            dataSource = new HikariDataSource(config);
        } catch (IOException e) {
            throw new RuntimeException("数据库配置加载失败", e);
        }
    }

    /**
     * 从连接池获取数据库连接。
     *
     * @return 数据库连接，调用方负责关闭（归还到连接池）
     * @throws SQLException 获取连接失败时抛出
     */
    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }
}