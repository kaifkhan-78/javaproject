package in.ac.rtu.medicare.model; import java.time.LocalDateTime; public record Appointment(long id,long patientId,long doctorId,LocalDateTime appointmentAt,String reason,String status) { }
