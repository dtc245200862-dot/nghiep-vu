# Báo cáo Chẩn đoán Khoảng trống (Gap Analysis Report) - Hệ thống HealthSync

Sau khi đối chiếu chi tiết giữa **UML Activity Diagram** quy trình nghiệp vụ "Đặt lịch và Khám bệnh" của phòng khám HealthSync và đoạn mã `Legacy SQL Script`, hệ thống cũ đang vấp phải **3 điểm vênh cốt lõi** khiến phần mềm liên tục báo lỗi:

### 1. Sai lầm trong việc quản lý vòng đời trạng thái (Dùng kiểu Boolean)
* **Thực trạng cũ:** Bảng `Appointments` sử dụng cột `is_active BOOLEAN DEFAULT TRUE`.
* **Sự bất cập:** Quy trình nghiệp vụ yêu cầu lịch hẹn phải đi qua 5 trạng thái riêng biệt: `PENDING` -> `CONFIRMED` -> `CHECKED_IN` -> `COMPLETED` -> `CANCELLED`. Một biến kiểu Boolean chỉ có giá trị `TRUE` hoặc `FALSE` hoàn toàn không đủ không gian biểu diễn trạng thái đa cấp, dẫn đến việc không thể lưu vết tiến trình khám bệnh của bệnh nhân.

### 2. Sự thiếu hụt trầm trọng các thuộc tính tài chính và quản lý hủy lịch
* **Thực trạng cũ:** Bảng `Appointments` không hề có các cột liên quan đến tiền cọc, phí phạt hay lý do hủy.
* **Sự bất cập:** Khi quy trình thực tế phát sinh tình huống bệnh nhân đặt lịch phải đóng cọc (`deposit_amount`), hoặc khi bệnh nhân hủy lịch sau khi xác nhận cần phải tính phí phạt (`penalty_fee`) trừ vào tiền cọc và ghi nhận lý do (`cancel_reason`), cơ sở dữ liệu cũ không có ô nhớ nào để lưu trữ, làm sai lệch kết toán doanh thu tài chính cuối tháng.

### 3. Vắng mặt hoàn toàn thực thể Đơn thuốc (Prescription Entity)
* **Thực trạng cũ:** Thiết kế cũ chỉ có bảng `Patients`, `Doctors`, và `Appointments`.
* **Sự bất cập:** Khi bác sĩ khám xong trạng thái `COMPLETED`, quy trình yêu cầu phải kê một `Đơn thuốc` đi kèm lịch hẹn đó. Việc không thiết kế bảng `Prescriptions` với khóa ngoại trỏ về `Appointments` khiến bác sĩ hoàn toàn "bế tắc" không có chỗ nhập dữ liệu toa thuốc cho bệnh nhân trên hệ thống.