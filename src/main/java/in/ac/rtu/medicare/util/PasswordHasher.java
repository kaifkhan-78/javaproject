package in.ac.rtu.medicare.util;
import java.security.*; import java.util.*; import javax.crypto.SecretKeyFactory; import javax.crypto.spec.PBEKeySpec;
public final class PasswordHasher {
 private static final String ALGO="PBKDF2WithHmacSHA256"; private static final int ITERATIONS=120_000, KEY_BITS=256;
 private PasswordHasher() { }
 public static String hash(char[] password) { try { byte[] salt=new byte[16]; SecureRandom.getInstanceStrong().nextBytes(salt); byte[] key=derive(password,salt,ITERATIONS); return ALGO+":"+ITERATIONS+":"+Base64.getEncoder().encodeToString(salt)+":"+Base64.getEncoder().encodeToString(key); } catch(GeneralSecurityException e){throw new IllegalStateException(e);} finally {Arrays.fill(password,'\0');} }
 public static boolean verify(char[] password,String stored) { try {String[] p=stored.split(":"); if(p.length!=4||!ALGO.equals(p[0])) return false; byte[] actual=derive(password,Base64.getDecoder().decode(p[2]),Integer.parseInt(p[1])); return MessageDigest.isEqual(actual,Base64.getDecoder().decode(p[3]));} catch(Exception e){return false;} finally {Arrays.fill(password,'\0');} }
 private static byte[] derive(char[] p,byte[] s,int i)throws GeneralSecurityException{return SecretKeyFactory.getInstance(ALGO).generateSecret(new PBEKeySpec(p,s,i,KEY_BITS)).getEncoded();}
}
