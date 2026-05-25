# Project Overview

## Dự án là gì

Nền tảng đặt sân thể thao trực tuyến dạng **multi-branch SaaS** — cho phép nhiều chủ sân đăng ký và vận hành hệ thống đặt lịch của riêng mình trên cùng một platform.

Khách hàng có thể tìm kiếm sân, xem lịch trống và đặt sân trực tuyến. Chủ sân quản lý toàn bộ hoạt động: sân, lịch, nhân viên, doanh thu.

## Bài toán giải quyết

- Khách phải gọi điện hoặc nhắn tin để đặt sân, không biết lịch trống real-time
- Chủ sân quản lý lịch thủ công bằng sổ hoặc Zalo, dễ trùng lịch
- Không có công cụ thống kê doanh thu, tỉ lệ lấp đầy sân

## Actors

| Actor | Mô tả |
|---|---|
| **Guest** | Khách vãng lai — đặt sân qua số điện thoại, không cần tạo tài khoản |
| **Customer** | Người dùng có tài khoản — đặt sân, xem lịch sử, nhận thông báo |
| **Staff** | Nhân viên sân — check-in QR cho khách, quản lý trạng thái sân, checkout khi khách về |
| **Admin** | Chủ sân — quản lý cơ sở, sân, nhân viên, cấu hình giá & STK ngân hàng, xem dashboard |
| **Super Admin** | Quản trị hệ thống — duyệt đăng ký chủ sân, quản lý gói đăng ký, quản lý danh mục |

## Business Model

Một **Admin** có thể sở hữu nhiều **Branch** (cơ sở), mỗi Branch có nhiều **Court** (sân).

```
Admin
 └── Branch (VD: "Cơ sở Thủ Đức", "Cơ sở Bình Thạnh")
      └── Court (VD: "Sân cầu lông 1", "Sân pickleball 2")
```

Admin đăng ký sử dụng platform theo **gói tháng/năm**, phí phụ thuộc vào số lượng sân hoặc cơ sở.

## Phạm vi (Scope)

**Trong scope:**
- Đặt sân theo khung giờ cố định, mỗi slot cách nhau **30 phút**
- Thanh toán **chuyển khoản ngân hàng** → upload bill → chủ sân xác nhận (trong 10–15 phút)
- Giữ slot tạm thời **5 phút** trong khi khách thực hiện chuyển khoản
- Quản lý đa cơ sở (multi-branch)
- QR check-in: Staff quét QR của khách khi vào sân
- Staff checkout khi khách về → cập nhật sân trống
- Dashboard doanh thu cho chủ sân

**Ngoài scope (giai đoạn này):**
- Mobile app (iOS/Android)
- Đặt sân theo tháng (monthly recurring)
- AI gợi ý khung giờ
- Tích hợp Google Maps
- Thanh toán online qua cổng (PayOS, Momo...)
- Thanh toán tiền mặt tại sân
- Đặt cọc (deposit)

## Luồng nghiệp vụ chính

### Booking Flow (Customer / Guest)
```
1. Tìm Branch theo khu vực / loại sân
2. Chọn Court → chọn ngày → chọn slot trống
3. Điền số điện thoại (nếu chưa đăng nhập)
4. Hệ thống giữ slot trong 5 phút
5. Chuyển khoản theo STK ngân hàng của chủ sân
6. Upload ảnh bill / biên lai chuyển khoản
7. Chờ 10–15 phút — chủ sân xác nhận thanh toán
8. Nhận xác nhận booking + QR code
9. Đến sân → Staff quét QR → check-in
10. Khách về → Staff checkout → sân trở về trạng thái trống
```

### Onboarding Chủ Sân (Admin)
```
1. Đăng ký tài khoản Admin trên platform
2. Chọn gói đăng ký (tháng / năm, theo số sân / cơ sở)
3. Super Admin duyệt → Admin nhận email xác nhận
4. Tạo Branch → thêm Court
5. Cấu hình time slots (30-phút) và giá cho từng Court
6. Cấu hình STK ngân hàng nhận tiền của Branch
7. Tạo tài khoản Staff và phân công Branch
8. Bắt đầu nhận booking
```

---

## Glossary

| Thuật ngữ | Định nghĩa |
|---|---|
| **Branch** | Một cơ sở vật lý cụ thể của Admin. VD: "BRO Sport - Thủ Đức" |
| **Court** | Một sân đơn lẻ trong Branch. VD: "Sân cầu lông số 3" |
| **Booking** | Một đơn đặt sân gồm 1 hoặc nhiều Slot liên tiếp trên cùng 1 Court |
| **Walk-in** | Booking được tạo tại quầy bởi Staff cho khách đến trực tiếp |
| **Session hold** | Trạng thái slot bị giữ tạm thời 5 phút khi khách đang thanh toán |
| **Bill upload** | Ảnh biên lai chuyển khoản khách upload để chủ sân xác nhận |
| **Peak hours** | Khung giờ cao điểm Admin có thể set giá cao hơn. VD: 17:00–21:00 |
| **Occupancy rate** | Tỉ lệ lấp đầy sân = số slot đã đặt / tổng slot có thể đặt trong kỳ |
| **Subscription** | Gói đăng ký platform của Admin (tháng/năm), phí theo số sân / cơ sở |

---

## Tài liệu liên quan

- [Danh sách module & chức năng chi tiết](./modules.md)
