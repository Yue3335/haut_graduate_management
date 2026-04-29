package edu.haut.gradms.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {

    private static final String URL =
            "jdbc:mysql://localhost:3306/haut_graduate_management" +
                    "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=utf8";
    private static final String USER = "root";
    private static final String PASSWORD = "Huiyuechen6!"; // TODO: 改成你自己的

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver"); // MySQL 8 驱动
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("加载数据库驱动失败", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}