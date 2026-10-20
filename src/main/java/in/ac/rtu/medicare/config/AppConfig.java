package in.ac.rtu.medicare.config;

import java.io.InputStream;
import java.util.Properties;

/** Configuration deliberately reads secrets from environment first; db.properties is ignored by Git. */
public final class AppConfig {
    private static final Properties FILE = new Properties();
    static { try (InputStream in = AppConfig.class.getClassLoader().getResourceAsStream("db.properties")) { if (in != null) FILE.load(in); } catch (Exception e) { throw new IllegalStateException("Cannot read db.properties", e); } }
    private AppConfig() { }
    public static String get(String key, String env) { String value = System.getenv(env); return value != null && !value.isBlank() ? value : FILE.getProperty(key); }
    public static String dbUrl() { return required("db.url", "MEDICARE_DB_URL"); }
    public static String dbUser() { return required("db.user", "MEDICARE_DB_USER"); }
    public static String dbPassword() { return required("db.password", "MEDICARE_DB_PASSWORD"); }
    private static String required(String key, String env) { String v = get(key, env); if (v == null || v.isBlank()) throw new IllegalStateException("Missing database setting " + env + " or " + key); return v; }
}
