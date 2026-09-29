-- HỆ THỐNG HEALTHSYNC (OPTIMIZED DATABASE SCHEMA & DML SCRIPT)
-- Vai trò: System Analyst & Database Administrator

CREATE DATABASE IF NOT EXISTS healthsync_db;
USE healthsync_db;

-- Xóa bảng theo thứ tự phụ thuộc khóa ngoại nếu đã tồn tại để chạy lại từ đầu
DROP TABLE IF EXISTS Prescriptions;
DROP TABLE IF EXISTS Appointments;
DROP TABLE IF EXISTS Doctors;
DROP TABLE IF EXISTS Patients;

-- 1. Bảng Patients (Bệnh nhân)
CREATE TABLE Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL
);

-- 2. Bảng Doctors (Bác sĩ)
CREATE TABLE Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(50)
);

-- 3. Bảng Appointments (Lịch hẹn - Đã tối ưu hóa theo Activity Diagram)
CREATE TABLE Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    
    -- Sử dụng ENUM để quản lý chính xác 5 trạng thái vòng đời của lịch hẹn
    status ENUM('PENDING', 'CONFIRMED', 'CHECKED_IN', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING',
    
    -- Bổ sung các cột tài chính và lý do hủy
    deposit_amount DECIMAL(10, 2) DEFAULT 0.00,
    penalty_fee DECIMAL(10, 2) DEFAULT 0.00,
    cancel_reason VARCHAR(255) NULL,
    
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

-- 4. Bảng Prescriptions (Đơn thuốc - Giải quyết vấn đề thiếu chỗ lưu đơn thuốc của Bác sĩ)
CREATE TABLE Prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL UNIQUE, -- Quan hệ 1-1 với lịch hẹn hoàn tất
    medication_details TEXT NOT NULL,
    issued_date DATETIME NOT NULL,
    
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id)
);

-- ==========================================
-- DML: CHÈN DỮ LIỆU MẪU VÀ MÔ PHỎNG KỊCH BẢN
-- ==========================================

-- Thêm dữ liệu nền tảng cho Bệnh nhân và Bác sĩ
INSERT INTO Patients (full_name, phone) VALUES 
('Nguyễn Văn A', '0912345678'),
('Trần Thị B', '0987654321');

INSERT INTO Doctors (full_name, specialty) VALUES 
('Dr. Hoàng Minh', 'Nội tổng quát'),
('Dr. Lê Thu', 'Tim mạch');

-- KỊCH BẢN 1: KHÁM THÀNH CÔNG (SUCCESS FLOW)
-- Bước 1.1: Bệnh nhân 1 đặt lịch, trạng thái PENDING, cọc 500.000đ
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, deposit_amount) 
VALUES (1, 1, '2026-06-10 09:00:00', 'PENDING', 500000.00);

-- Bước 1.2: Hệ thống duyệt, chuyển sang CHECKED_IN khi bệnh nhân đến
UPDATE Appointments 
SET status = 'CHECKED_IN' 
WHERE appointment_id = 1;

-- Bước 1.3: Khám xong, cập nhật trạng thái COMPLETED
UPDATE Appointments 
SET status = 'COMPLETED' 
WHERE appointment_id = 1;

-- Bước 1.4: Bác sĩ kê đơn thuốc cho lịch hẹn hoàn tất số 1
INSERT INTO Prescriptions (appointment_id, medication_details, issued_date) 
VALUES (1, 'Paracetamol 500mg (2 lần/ngày), Vitamin C 1000mg (1 viên/ngày)', '2026-06-10 09:45:00');


-- KỊCH BẢN 2: HỦY LỊCH VÀ PHẠT TIỀN CỌC (CANCELLATION FLOW)
-- Bước 2.1: Bệnh nhân 2 đặt lịch, đã CONFIRMED cọc 300.000đ
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, deposit_amount) 
VALUES (2, 2, '2026-06-11 14:00:00', 'CONFIRMED', 300000.00);

-- Bước 2.2: Bệnh nhân hủy lịch muộn, ghi nhận lý do và tính phí phạt 150.000đ
UPDATE Appointments 
SET status = 'CANCELLED', 
    cancel_reason = 'Bận việc đột xuất, xin hủy lịch', 
    penalty_fee = 150000.00 
WHERE appointment_id = 2;


-- ==========================================
-- KIỂM TRA DỮ LIỆU BẰNG CÂU LỆNH TRUY VẤN (SELECT & JOIN)
-- ==========================================

-- Truy vấn danh sách bệnh nhân đã hoàn tất khám và chi tiết đơn thuốc của họ
SELECT 
    a.appointment_id,
    p.full_name AS patient_name,
    d.full_name AS doctor_name,
    a.appointment_date,
    a.status,
    a.deposit_amount,
    pr.medication_details,
    pr.issued_date
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id
JOIN Prescriptions pr ON a.appointment_id = pr.appointment_id
WHERE a.status = 'COMPLETED';

-- Truy vấn danh sách lịch hẹn bị hủy và thông tin phí phạt
SELECT 
    a.appointment_id,
    p.full_name AS patient_name,
    a.status,
    a.deposit_amount,
    a.penalty_fee,
    a.cancel_reason
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
WHERE a.status = 'CANCELLED';