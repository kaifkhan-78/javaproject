package in.ac.rtu.medicare.rmi; import java.rmi.*; import java.time.*; import java.util.*;
public interface RemoteAppointmentService extends Remote { String book(long patientUserId,long doctorId,LocalDateTime appointmentAt,String reason)throws RemoteException; List<String> availability(long doctorId,LocalDate date)throws RemoteException; }
