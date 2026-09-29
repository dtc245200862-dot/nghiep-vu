# Nhật ký Tương tác AI (AI Prompt Log) - HealthSync Project

Dưới đây là nhật ký ghi lại các câu hỏi và trao đổi trực tiếp với Trợ lý AI trong suốt quá trình phân tích và tối ưu hóa cơ sở dữ liệu HealthSync.

### 1. Thảo luận về thiết kế trạng thái đa cấp
* **Người dùng (Prompt):** "Trong thiết kế cơ sở dữ liệu quan hệ, tại sao việc dùng một cột `is_active` (kiểu TINYINT/BOOLEAN) để theo dõi vòng đời của một Đơn hàng/Lịch hẹn lại là một thiết kế tồi (Anti-pattern)? Tôi nên thay thế bằng cấu trúc nào?"
* **Phản hồi từ AI:** Giải thích rằng kiểu Boolean chỉ lưu được 2 trạng thái (Bật/Tắt), trong khi vòng đời nghiệp vụ có nhiều bước tuần tự hoặc nhánh rẽ (`PENDING`, `CONFIRMED`, `CHECKED_IN`, `COMPLETED`, `CANCELLED`). Đề xuất sử dụng kiểu dữ liệu `ENUM` trong MySQL để giới hạn chặt chẽ các giá trị hợp lệ ngay tại tầng cơ sở dữ liệu, đảm bảo tính toàn vẹn ngữ nghĩa.

### 2. Lựa chọn kiểu dữ liệu tài chính
* **Người dùng (Prompt):** "Khi thiết kế cột `deposit_amount` và `penalty_fee` trong MySQL phục vụ tính toán tài chính, tôi nên dùng kiểu dữ liệu `FLOAT`, `DOUBLE` hay `DECIMAL`? Tại sao?"
* **Phản hồi từ AI:** Khuyên dùng kiểu `DECIMAL(10, 2)` thay vì `FLOAT` hay `DOUBLE`. Lý do là `FLOAT` và `DOUBLE` lưu số thực theo dạng dấu chấm động nhị phân, dễ gây ra lỗi làm tròn số học (Floating-point precision errors) nguy hiểm trong các bài toán tính toán tiền tệ, tài chính. `DECIMAL` lưu dưới dạng chuỗi chính xác tuyệt đối.

### 3. Cú pháp thêm cột trạng thái `ENUM`
* **Người dùng (Prompt):** "Hãy cho tôi xem cú pháp chuẩn trong MySQL để thêm một cột `status` với kiểu dữ liệu `ENUM` chứa các giá trị (`'PENDING'`, `'CONFIRMED'`, `'CHECKED_IN'`, `'COMPLETED'`, `'CANCELLED'`) vào một bảng có sẵn."
* **Phản hồi từ AI:** Cung cấp mẫu câu lệnh chuẩn `ALTER TABLE Appointments ADD COLUMN status ENUM(...) DEFAULT 'PENDING';` và hướng dẫn cách xử lý thay thế cột `is_active` cũ.

### 4. Xây dựng truy vấn tổng hợp dữ liệu
* **Người dùng (Prompt):** "Viết cho tôi một câu lệnh SQL SELECT kết hợp JOIN giữa bảng `Appointments` và `Prescriptions` để lấy ra danh sách tất cả các bệnh nhân đã hoàn tất khám bệnh và chi tiết đơn thuốc của họ."
* **Phản hồi từ AI:** Cung cấp đoạn lệnh `INNER JOIN` kết hợp giữa `Appointments`, `Patients`, `Doctors` và `Prescriptions` với điều kiện lọc `WHERE a.status = 'COMPLETED'` nhằm xuất ra báo cáo dữ liệu sạch khớp với Activity Diagram.