package in.ac.rtu.medicare.model; import java.math.BigDecimal; public record Invoice(long id,long appointmentId,BigDecimal amount,String status) { }
