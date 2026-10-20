package in.ac.rtu.medicare.config;
import java.sql.*;
public final class Database {
 static { try { Class.forName("com.mysql.cj.jdbc.Driver"); } catch (ClassNotFoundException e) { throw new IllegalStateException("MySQL JDBC driver unavailable", e); } }
 private Database() { }
 public static Connection connection() throws SQLException { return DriverManager.getConnection(AppConfig.dbUrl(), AppConfig.dbUser(), AppConfig.dbPassword()); }
}
