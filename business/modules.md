# Modules & Chức Năng — SBA301-BRO73

> Tài liệu này liệt kê toàn bộ chức năng theo module. Chưa chia người, chưa chia sprint.
> Mỗi chức năng có tag actor và tag priority.
>
> **Priority:** `CORE` Bắt buộc · `SHOULD` Nên có · `BONUS` Nếu còn thời gian

---

## 1. Auth & Account

| # | Chức năng | Actor | Priority |
|---|---|---|---|
| 1.1 | Đăng ký tài khoản Customer | Customer | CORE |
| 1.2 | Đăng ký tài khoản Admin (chủ sân) — chờ duyệt | Admin | CORE |
| 1.3 | Đăng nhập (email + password) | Tất cả | CORE |
| 1.4 | Đăng xuất | Tất cả | CORE |
| 1.5 | Refresh token (tự động gia hạn phiên) | Tất cả | CORE |
| 1.6 | Quên mật khẩu / Reset mật khẩu qua email | Tất cả | SHOULD |
| 1.7 | Đổi mật khẩu (khi đã đăng nhập) | Tất cả | SHOULD |
| 1.8 | Xem & cập nhật thông tin cá nhân (profile) | Tất cả | CORE |
| 1.9 | Nhập số điện thoại → đặt sân không cần tài khoản (Guest) | Guest | CORE |
| 1.10 | Đăng nhập bằng Google (OAuth2) | Customer | BONUS |

---

## 2. Super Admin — Quản trị hệ thống

| # | Chức năng | Actor | Priority |
|---|---|---|---|
| 2.1 | Xem danh sách đăng ký tài khoản Admin đang chờ duyệt | Super Admin | CORE |
| 2.2 | Duyệt / từ chối đăng ký chủ sân | Super Admin | CORE |
| 2.3 | Xem danh sách tất cả Admin (chủ sân) trên hệ thống | Super Admin | CORE |
| 2.4 | Khoá / mở khoá tài khoản bất kỳ | Super Admin | CORE |
| 2.5 | Xem danh sách tất cả Customer | Super Admin | SHOULD |
| 2.6 | Xem thống kê tổng quan toàn hệ thống (số branch, doanh thu, booking) | Super Admin | SHOULD |
| 2.7 | Quản lý danh mục loại sân (thêm/sửa/xóa: cầu lông, pickleball...) | Super Admin | CORE |
| 2.8 | Quản lý gói đăng ký (tháng/năm, theo số sân/cơ sở) | Super Admin | CORE |

---

## 3. Branch — Quản lý cơ sở

| # | Chức năng | Actor | Priority |
|---|---|---|---|
| 3.1 | Tạo Branch (cơ sở / địa điểm kinh doanh) | Admin | CORE |
| 3.2 | Sửa thông tin Branch (tên, địa chỉ, số điện thoại, giờ mở cửa) | Admin | CORE |
| 3.3 | Cấu hình STK ngân hàng nhận tiền của Branch | Admin | CORE |
| 3.4 | Upload ảnh Branch | Admin | SHOULD |
| 3.5 | Xoá / vô hiệu hoá Branch | Admin | CORE |
| 3.6 | Xem danh sách Branch của mình | Admin | CORE |
| 3.7 | Xem chi tiết Branch (thông tin, sân, đánh giá) | Customer | CORE |
| 3.8 | Tìm kiếm Branch theo tên / thành phố / loại sân | Customer | CORE |
| 3.9 | Lọc Branch (theo khu vực, loại sân, giá, giờ trống hôm nay) | Customer | CORE |
| 3.10 | Xem Branch trên bản đồ (Google Maps embed) | Customer | BONUS |

---

## 4. Court — Quản lý sân

| # | Chức năng | Actor | Priority |
|---|---|---|---|
| 4.1 | Thêm Court vào Branch (tên, loại sân, mô tả) | Admin | CORE |
| 4.2 | Sửa thông tin Court | Admin | CORE |
| 4.3 | Xoá / vô hiệu hoá Court | Admin | CORE |
| 4.4 | Upload ảnh Court | Admin | SHOULD |
| 4.5 | Đặt giá mặc định theo slot | Admin | CORE |
| 4.6 | Đặt giá theo khung giờ cao/thấp điểm (peak/off-peak) | Admin | SHOULD |
| 4.7 | Đặt giá theo ngày trong tuần (weekday/weekend) | Admin | SHOULD |
| 4.8 | Xem danh sách Court của Branch | Admin, Customer | CORE |

---

## 5. Time Slot — Cấu hình khung giờ

> Hệ thống tạo slot cố định với chu kỳ **30 phút** (VD: 6:00, 6:30, 7:00...).

| # | Chức năng | Actor | Priority |
|---|---|---|---|
| 5.1 | Tạo template khung giờ cho Court (chu kỳ 30 phút, VD: 6:00–6:30, 6:30–7:00...) | Admin | CORE |
| 5.2 | Sửa / xóa template khung giờ | Admin | CORE |
| 5.3 | Áp dụng template cho nhiều Court cùng lúc | Admin | SHOULD |
| 5.4 | Khoá slot cụ thể (bảo trì, nghỉ lễ) | Admin | SHOULD |
| 5.5 | Xem lịch slot theo ngày / tuần (calendar view) | Admin, Staff | CORE |

---

## 6. Booking — Đặt sân

| # | Chức năng | Actor | Priority |
|---|---|---|---|
| 6.1 | Xem lịch sân trống theo ngày | Customer, Guest | CORE |
| 6.2 | Chọn Court + chọn ngày + chọn slot (1 hoặc nhiều slot liên tiếp) | Customer, Guest | CORE |
| 6.3 | Điền số điện thoại nếu chưa đăng nhập | Guest | CORE |
| 6.4 | Giữ slot tạm thời 5 phút trong khi khách thực hiện thanh toán | System | CORE |
| 6.5 | Xem tóm tắt đơn trước khi xác nhận (slot, giá, STK chủ sân) | Customer, Guest | CORE |
| 6.6 | Huỷ đặt sân (theo policy: trước X tiếng) | Customer | CORE |
| 6.7 | Xem lịch sử booking của bản thân | Customer | CORE |
| 6.8 | Xem chi tiết booking (trạng thái, QR, thông tin sân) | Customer, Guest | CORE |
| 6.9 | Tạo booking walk-in tại quầy (cho khách đến trực tiếp) | Staff, Admin | CORE |
| 6.10 | Admin xem toàn bộ booking của Branch | Admin | CORE |
| 6.11 | Admin / Staff sửa trạng thái booking thủ công | Admin, Staff | SHOULD |
| 6.12 | Đặt sân theo tháng (monthly recurring booking) | Customer | BONUS |
| 6.13 | Đặt nhóm (nhiều sân cùng lúc trong 1 booking) | Customer | BONUS |

---

## 7. Payment — Thanh toán

> Toàn bộ thanh toán qua **chuyển khoản ngân hàng**. Không hỗ trợ tiền mặt, đặt cọc, hay cổng thanh toán (PayOS).

| # | Chức năng | Actor | Priority |
|---|---|---|---|
| 7.1 | Hiển thị thông tin STK ngân hàng của chủ sân để khách chuyển khoản | System | CORE |
| 7.2 | Upload ảnh bill / biên lai chuyển khoản | Customer, Guest | CORE |
| 7.3 | Admin xác nhận / từ chối thanh toán (trong 10–15 phút) | Admin | CORE |
| 7.4 | Tự động huỷ booking nếu session hold 5 phút hết hạn mà chưa upload bill | System | CORE |
| 7.5 | Xem trạng thái thanh toán của booking | Customer, Guest, Admin | CORE |
| 7.6 | Áp dụng mã voucher khi thanh toán | Customer | SHOULD |
| 7.7 | Yêu cầu hoàn tiền (refund request) | Customer | SHOULD |
| 7.8 | Admin duyệt / từ chối hoàn tiền | Admin | SHOULD |
| 7.9 | Lịch sử giao dịch của Customer | Customer | SHOULD |
| 7.10 | Lịch sử giao dịch của Branch | Admin | CORE |

---

## 8. Voucher — Mã giảm giá

| # | Chức năng | Actor | Priority |
|---|---|---|---|
| 8.1 | Tạo voucher (% hoặc số tiền cố định, giới hạn lượt dùng, ngày hết hạn) | Admin | SHOULD |
| 8.2 | Sửa / xóa voucher | Admin | SHOULD |
| 8.3 | Xem danh sách voucher của Branch | Admin | SHOULD |
| 8.4 | Validate mã voucher khi checkout | Customer | SHOULD |
| 8.5 | Xem lịch sử sử dụng voucher | Admin | SHOULD |

---

## 9. Staff — Nhân viên sân

| # | Chức năng | Actor | Priority |
|---|---|---|---|
| 9.1 | Tạo tài khoản Staff gắn với Branch | Admin | CORE |
| 9.2 | Sửa thông tin / xóa Staff | Admin | CORE |
| 9.3 | Xem danh sách Staff của Branch | Admin | CORE |
| 9.4 | Xem lịch sân hôm nay (booking list theo ngày) | Staff | CORE |
| 9.5 | Scan QR / nhập mã để check-in booking cho khách | Staff | CORE |
| 9.6 | Tạo walk-in booking tại quầy | Staff | CORE |
| 9.7 | Checkout khi khách về → cập nhật trạng thái sân về trống | Staff | CORE |

---

## 10. QR Check-in

| # | Chức năng | Actor | Priority |
|---|---|---|---|
| 10.1 | Tự động tạo QR code khi booking được xác nhận | System | CORE |
| 10.2 | Hiển thị QR code trong chi tiết booking (khách xem trên điện thoại) | Customer, Guest | CORE |
| 10.3 | Staff scan QR của khách → hệ thống xác nhận check-in | Staff | CORE |
| 10.4 | Nhập mã booking thủ công thay thế scan (fallback) | Staff | SHOULD |

---

## 11. Dashboard & Báo cáo

| # | Chức năng | Actor | Priority |
|---|---|---|---|
| 11.1 | Tổng quan: doanh thu hôm nay / tuần / tháng | Admin | CORE |
| 11.2 | Biểu đồ doanh thu theo thời gian | Admin | CORE |
| 11.3 | Tổng số booking theo trạng thái (confirmed, cancelled, completed) | Admin | CORE |
| 11.4 | Tỉ lệ lấp đầy sân (occupancy rate) theo Court / Branch | Admin | SHOULD |
| 11.5 | Sân được đặt nhiều nhất | Admin | SHOULD |
| 11.6 | Giờ cao điểm (peak hours) | Admin | SHOULD |
| 11.7 | Export báo cáo doanh thu ra CSV / Excel | Admin | SHOULD |
| 11.8 | Tổng quan toàn hệ thống (số branch, doanh thu, booking) | Super Admin | SHOULD |

---

## 12. Notification — Thông báo

| # | Chức năng | Actor | Priority |
|---|---|---|---|
| 12.1 | Email xác nhận đặt sân thành công | Customer | SHOULD |
| 12.2 | Email xác nhận huỷ sân | Customer | SHOULD |
| 12.3 | Email nhắc lịch trước khi chơi (VD: trước 2h) | Customer | SHOULD |
| 12.4 | Email thông báo kết quả duyệt tài khoản Admin | Admin | SHOULD |
| 12.5 | Thông báo cho Admin khi có booking mới cần xác nhận thanh toán | Admin | CORE |
| 12.6 | In-app notification (thông báo trong ứng dụng) | Tất cả | BONUS |
| 12.7 | Push notification (mobile) | Customer | BONUS |

---

## 13. Rating & Review — Đánh giá

| # | Chức năng | Actor | Priority |
|---|---|---|---|
| 13.1 | Customer đánh giá sao + bình luận sau khi chơi | Customer | BONUS |
| 13.2 | Admin phản hồi đánh giá | Admin | BONUS |
| 13.3 | Hiển thị rating trung bình trên trang Branch / Court | Customer | BONUS |
| 13.4 | Ẩn đánh giá vi phạm | Admin, Super Admin | BONUS |

---

## 14. Loyalty Points — Tích điểm

| # | Chức năng | Actor | Priority |
|---|---|---|---|
| 14.1 | Tích điểm sau mỗi lần đặt sân thành công | Customer | BONUS |
| 14.2 | Xem số điểm hiện tại và lịch sử tích điểm | Customer | BONUS |
| 14.3 | Đổi điểm lấy voucher giảm giá | Customer | BONUS |
| 14.4 | Admin cấu hình tỉ lệ tích điểm | Admin | BONUS |

---

## 15. Real-time Features

| # | Chức năng | Actor | Priority |
|---|---|---|---|
| 15.1 | Cập nhật trạng thái slot real-time khi có người đặt / slot bị giữ (WebSocket) | Customer | BONUS |
| 15.2 | Thông báo real-time cho Admin khi có booking mới cần xác nhận | Admin | BONUS |

---

## 16. AI / Smart Features

| # | Chức năng | Actor | Priority |
|---|---|---|---|
| 16.1 | Gợi ý khung giờ phù hợp dựa trên lịch sử đặt sân | Customer | BONUS |
| 16.2 | Gợi ý sân tương tự khi slot đã full | Customer | BONUS |

---

## Tổng hợp theo Priority

| Priority | Số chức năng |
|---|---|
| CORE | ~47 |
| SHOULD | ~28 |
| BONUS | ~18 |
| **Tổng** | **~93** |

---

> **Bước tiếp theo:** Review danh sách này, điều chỉnh priority nếu cần, sau đó sẽ chia module cho từng người.
