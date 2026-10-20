# MediCare Hospital Management System

MediCare is a Java Advanced Java project built as a Jakarta Servlet 6.1 / JSP Maven WAR for Apache Tomcat 11. It demonstrates MVC-style controllers, services and DAOs; MySQL JDBC; role-based access control; secure sessions; a Swing reception client; a socket notification example; and a Java RMI appointment interface.

## What is implemented

| Area | Implementation |
|---|---|
| Authentication | Patient registration, PBKDF2-HMAC-SHA256 password hashes, login/logout, session-ID rotation, timeout, CSRF tokens |
| Data design | Normalized MySQL schema for users, patient/doctor profiles, availability, appointments, records, prescriptions, invoices, payments, notifications |
| Appointments | Patient/doctor history queries, future-date validation, cancellation ownership check, transaction with serializable conflict detection |
| Clinical and billing | Transactional record/prescription save only against doctor-owned completed appointments; invoice only for completed appointments; exact, single pending-invoice payment |
| Administration | RBAC enforcement path for `/app/admin/*`; user DAO supports listing and enable/disable for an admin screen extension |
| Advanced Java | `ReceptionDesk`, `NotificationServer`/`NotificationClient`, and RMI `RemoteAppointmentService`/`RmiServer` |

## Setup

1. Install Java 21+ (Tomcat 11 requires Java 17+) and Maven 3.9+.
2. Install MySQL 8.0+, then run:

   ```sql
   mysql -u root -p < database/schema.sql
   mysql -u root -p < database/seed.sql
   ```

3. Create a least-privilege account, for example:

   ```sql
   CREATE USER 'medicare_app'@'localhost' IDENTIFIED BY 'choose-a-secret';
   GRANT SELECT, INSERT, UPDATE, DELETE ON medicare_hms.* TO 'medicare_app'@'localhost';
   ```

4. Either copy `src/main/resources/db.properties.example` to `src/main/resources/db.properties` and set values (it is ignored by Git), or export `MEDICARE_DB_URL`, `MEDICARE_DB_USER`, and `MEDICARE_DB_PASSWORD`.
5. Run `mvn clean test package`.
6. Deploy `target/medicare.war` to Tomcat 11 `webapps/`, then open `http://localhost:8080/medicare/login`.

Use real registration for a patient account. For an admin or doctor demo, create a user through the database bootstrap process, assign the required role, and insert the mandatory linked `doctors`/`patients` profile row before accessing that role's workflow. This separation is intentional: role promotion must remain an admin-only operation.

## Project map

```
medicare-hms/
├── database/
│   ├── schema.sql                  # Normalized MySQL tables, keys, constraints, indexes
│   └── seed.sql                    # Demo administrator seed account
├── src/
│   ├── main/
│   │   ├── java/in/ac/rtu/medicare/
│   │   │   ├── config/             # Environment-based DB configuration and JDBC factory
│   │   │   ├── dao/                # PreparedStatement DAO classes and transactions
│   │   │   ├── desktop/            # Java Swing reception desk application
│   │   │   ├── model/              # Domain models and role enum
│   │   │   ├── network/            # Socket notification server and client
│   │   │   ├── rmi/                # RMI appointment service contract and server
│   │   │   ├── service/            # Business validation and workflow services
│   │   │   ├── util/               # Password hashing and input validation
│   │   │   └── web/                # Servlet controllers and authentication/CSRF filters
│   │   ├── resources/
│   │   │   └── db.properties.example # Safe database configuration template
│   │   └── webapp/
│   │       ├── assets/             # Application CSS
│   │       └── WEB-INF/views/      # Protected JSP pages
│   └── test/java/                  # JUnit validation and password-security tests
├── .gitignore                      # Excludes credentials and generated files
├── pom.xml                         # Maven dependencies and WAR configuration
└── README.md                       # Setup, security, testing, viva, and documentation
```

## Security notes

All SQL values use `PreparedStatement`; passwords are salted PBKDF2 hashes; sensitive configuration is external; session IDs rotate after login; protected URLs require login; CSRF is required on protected POSTs; and DAO queries bind the patient/doctor identity so one account cannot operate on another account’s appointment. The unique schedule key plus serializable transaction/row locking prevents concurrent double booking for the configured 30-minute slot. The database account must not be a MySQL root account.

## Run demonstrations

After `mvn package`, run with Maven exec support or your IDE classpath:

```bash
java -cp target/classes in.ac.rtu.medicare.network.NotificationServer
java -cp target/classes in.ac.rtu.medicare.desktop.ReceptionDesk
java -cp target/classes in.ac.rtu.medicare.rmi.RmiServer
```

The socket server is deliberately separate from Tomcat. Production notification delivery would add authentication, TLS, a queue and persistent delivery status.

## RTU Advanced Java syllabus mapping

- JDBC: `Database`, DAO classes, prepared statements, batch writes, transactions.
- Servlet/JSP: `AuthServlet`, `AppServlet`, filters and JSP views (Jakarta namespace/Tomcat 11).
- MVC: model records, DAO persistence, service rules, servlet controllers, JSP views.
- Swing: `ReceptionDesk`.
- Socket programming: `NotificationServer` and `NotificationClient`.
- RMI: `RemoteAppointmentService` and server binding.

## Test plan and current verification

`PasswordHasherTest` checks valid/invalid password verification and no plaintext persistence. `ValidationTest` checks malformed email and past appointment rejection. Manual integration checks after MySQL/Tomcat setup should include registration/login, unauthenticated `/app/*` redirect, cross-patient cancellation rejection, concurrent same-doctor booking, completed-only invoice creation, double/partial payment rejection, and admin-only URLs.

This workspace’s initial inspection found Java 26 but **no Maven, MySQL client/server, or Tomcat executable**, so a full WAR build, servlet deployment, and database integration test could not be run here. The source-level security utility compilation is checked locally; run the commands above in a machine with the required tools to perform the documented integration tests. No database claim is made without that execution.

## Viva questions

1. **Why PreparedStatement?** It separates SQL structure from data and prevents injection through bound parameters.
2. **Why transactions?** Registration must create both user and patient, and payment must create a payment and mark the invoice paid atomically.
3. **Why hash passwords?** Passwords must never be stored or compared in plaintext; PBKDF2 slows offline guessing with a salt and iterations.
4. **How is double booking prevented?** The appointment insert executes in a serializable transaction after locking/checking active time conflicts.
5. **Why RMI and sockets separately?** RMI demonstrates remote Java method invocation; sockets demonstrate lower-level message-based communication.
