CREATE DATABASE IF NOT EXISTS medicare_hms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE medicare_hms;

CREATE TABLE users (
 id BIGINT PRIMARY KEY AUTO_INCREMENT, full_name VARCHAR(100) NOT NULL, email VARCHAR(150) NOT NULL UNIQUE,
 password_hash VARCHAR(255) NOT NULL, role ENUM('PATIENT','DOCTOR','ADMIN','RECEPTIONIST') NOT NULL,
 phone VARCHAR(20), active BOOLEAN NOT NULL DEFAULT TRUE, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE patients (
 id BIGINT PRIMARY KEY AUTO_INCREMENT, user_id BIGINT NOT NULL UNIQUE, date_of_birth DATE, gender VARCHAR(20), address VARCHAR(500), blood_group VARCHAR(5), emergency_contact VARCHAR(100),
 CONSTRAINT fk_patient_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);
CREATE TABLE doctors (
 id BIGINT PRIMARY KEY AUTO_INCREMENT, user_id BIGINT NOT NULL UNIQUE, specialization VARCHAR(100) NOT NULL, qualification VARCHAR(150), consultation_fee DECIMAL(10,2) NOT NULL CHECK(consultation_fee >= 0), room_no VARCHAR(20),
 CONSTRAINT fk_doctor_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);
CREATE TABLE doctor_availability (
 id BIGINT PRIMARY KEY AUTO_INCREMENT, doctor_id BIGINT NOT NULL, day_of_week TINYINT NOT NULL CHECK(day_of_week BETWEEN 1 AND 7), start_time TIME NOT NULL, end_time TIME NOT NULL, slot_minutes SMALLINT NOT NULL DEFAULT 30 CHECK(slot_minutes BETWEEN 10 AND 120),
 CONSTRAINT ck_availability_time CHECK(start_time < end_time), CONSTRAINT uq_doctor_schedule UNIQUE(doctor_id, day_of_week, start_time),
 CONSTRAINT fk_availability_doctor FOREIGN KEY(doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
);
CREATE TABLE appointments (
 id BIGINT PRIMARY KEY AUTO_INCREMENT, patient_id BIGINT NOT NULL, doctor_id BIGINT NOT NULL, appointment_at DATETIME NOT NULL, reason VARCHAR(500) NOT NULL, status ENUM('BOOKED','COMPLETED','CANCELLED','NO_SHOW') NOT NULL DEFAULT 'BOOKED', created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, cancelled_at DATETIME NULL,
 CONSTRAINT fk_appointment_patient FOREIGN KEY(patient_id) REFERENCES patients(id), CONSTRAINT fk_appointment_doctor FOREIGN KEY(doctor_id) REFERENCES doctors(id), INDEX ix_appointment_doctor_time(doctor_id, appointment_at), INDEX ix_appointment_patient(patient_id, appointment_at)
);
CREATE TABLE medical_records (
 id BIGINT PRIMARY KEY AUTO_INCREMENT, appointment_id BIGINT NOT NULL UNIQUE, diagnosis TEXT NOT NULL, notes TEXT, created_by BIGINT NOT NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_record_appointment FOREIGN KEY(appointment_id) REFERENCES appointments(id), CONSTRAINT fk_record_doctor FOREIGN KEY(created_by) REFERENCES doctors(id)
);
CREATE TABLE prescriptions (
 id BIGINT PRIMARY KEY AUTO_INCREMENT, medical_record_id BIGINT NOT NULL, medicine VARCHAR(150) NOT NULL, dosage VARCHAR(100) NOT NULL, duration VARCHAR(100) NOT NULL, instructions VARCHAR(500),
 CONSTRAINT fk_prescription_record FOREIGN KEY(medical_record_id) REFERENCES medical_records(id) ON DELETE CASCADE
);
CREATE TABLE invoices (
 id BIGINT PRIMARY KEY AUTO_INCREMENT, appointment_id BIGINT NOT NULL UNIQUE, amount DECIMAL(10,2) NOT NULL CHECK(amount >= 0), status ENUM('PENDING','PAID','VOID') NOT NULL DEFAULT 'PENDING', issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, paid_at DATETIME NULL,
 CONSTRAINT fk_invoice_appointment FOREIGN KEY(appointment_id) REFERENCES appointments(id)
);
CREATE TABLE payments (
 id BIGINT PRIMARY KEY AUTO_INCREMENT, invoice_id BIGINT NOT NULL, amount DECIMAL(10,2) NOT NULL CHECK(amount > 0), method ENUM('CASH','CARD','UPI','INSURANCE') NOT NULL, reference_no VARCHAR(100) NOT NULL UNIQUE, paid_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_payment_invoice FOREIGN KEY(invoice_id) REFERENCES invoices(id)
);
CREATE TABLE notifications (
 id BIGINT PRIMARY KEY AUTO_INCREMENT, user_id BIGINT NOT NULL, message VARCHAR(500) NOT NULL, read_at DATETIME NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_notification_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);
