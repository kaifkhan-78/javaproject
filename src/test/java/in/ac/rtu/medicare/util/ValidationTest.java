package in.ac.rtu.medicare.util; import static org.junit.jupiter.api.Assertions.*; import org.junit.jupiter.api.Test; import java.time.*;
class ValidationTest { @Test void rejectsBadEmailAndPastAppointments(){assertThrows(IllegalArgumentException.class,()->Validation.email("bad"));assertThrows(IllegalArgumentException.class,()->Validation.future(LocalDateTime.now().minusMinutes(1)));} }
