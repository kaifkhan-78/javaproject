package in.ac.rtu.medicare.rmi; import java.rmi.registry.*;
public final class RmiServer {public static void main(String[] a)throws Exception{Registry r=LocateRegistry.createRegistry(1099);r.rebind("MediCareAppointments",new RemoteAppointmentServiceImpl());System.out.println("RMI service bound as MediCareAppointments");}}
