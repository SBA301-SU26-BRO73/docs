# Project Overview

## Dự án là gì

Nền tảng đặt sân thể thao trực tuyến dạng **multi-venue SaaS** — cho phép nhiều chủ sân đăng ký và vận hành hệ thống đặt lịch của riêng mình trên cùng một platform.

Khách hàng có thể tìm kiếm sân, xem lịch trống và đặt sân trực tuyến. Chủ sân quản lý toàn bộ hoạt động: sân, lịch, nhân viên, doanh thu.

## Bài toán giải quyết

- Khách phải gọi điện hoặc nhắn tin để đặt sân, không biết lịch trống real-time
- Chủ sân quản lý lịch thủ công bằng sổ hoặc Zalo, dễ trùng lịch
- Không có công cụ thống kê doanh thu, tỉ lệ lấp đầy sân

## Actors

| Actor | Mô tả |
|---|---|
| **Guest** | Khách vãng lai — đặt sân qua số điện thoại + OTP, không cần tạo tài khoản |
| **Customer** | Người dùng có tài khoản — đặt sân, xem lịch sử, nhận thông báo |
| **Staff** | Nhân viên sân — check-in QR, tạo booking walk-in, thu tiền offline |
| **Admin** | Chủ sân — quản lý venue, sân, nhân viên, cấu hình giá & cọc, xem dashboard |
| **Super Admin** | Quản trị hệ thống — duyệt đăng ký chủ sân, quản lý danh mục |

## Business Model

Một **Admin** có thể sở hữu nhiều **Venue** (thương hiệu/chuỗi), mỗi Venue có nhiều **Branch** (cơ sở), mỗi Branch có nhiều **Court** (sân).

```
Admin
 └── Venue (VD: "Hệ thống sân BRO Sport")
      └── Branch (VD: "Cơ sở Thủ Đức", "Cơ sở Bình Thạnh")
           └── Court (VD: "Sân cầu lông 1", "Sân pickleball 2")
```

## Phạm vi (Scope)

**Trong scope:**
- Đặt sân theo khung giờ cố định (fixed time slots)
- Thanh toán online (PayOS) và offline
- Quản lý đa cơ sở (multi-branch)
- QR check-in tại sân
- Dashboard doanh thu cho chủ sân

**Ngoài scope (giai đoạn này):**
- Mobile app (iOS/Android)
- Đặt sân theo tháng (monthly recurring)
- AI gợi ý khung giờ
- Tích hợp Google Maps

## Luồng nghiệp vụ chính

### Booking Flow (Customer / Guest)
```
1. Tìm Branch theo khu vực / loại sân
2. Chọn Court → chọn ngày → chọn slot trống
3. Xem tóm tắt đơn (slot, giá, chính sách cọc)
4. Thanh toán online (PayOS) hoặc chọn trả offline tại sân
5. Nhận xác nhận booking + QR code
6. Đến sân → Staff scan QR → check-in
```

### Onboarding Chủ Sân (Admin)
```
1. Đăng ký tài khoản Admin trên platform
2. Super Admin duyệt → Admin nhận email xác nhận
3. Tạo Venue → tạo Branch → thêm Court
4. Cấu hình time slots và giá cho từng Court
5. Cấu hình chính sách đặt cọc (tuỳ chọn)
6. Tạo tài khoản Staff và phân công Branch
7. Bắt đầu nhận booking
```

---

## Glossary

| Thuật ngữ | Định nghĩa |
|---|---|
| **Venue** | Thương hiệu hoặc chuỗi sân của 1 Admin. VD: "BRO Sport Center" |
| **Branch** | Một cơ sở vật lý cụ thể thuộc Venue. VD: "BRO Sport - Thủ Đức" |
| **Court** | Một sân đơn lẻ trong Branch. VD: "Sân cầu lông số 3" |
| **Booking** | Một đơn đặt sân gồm 1 hoặc nhiều Slot liên tiếp trên cùng 1 Court |
| **Walk-in** | Booking được tạo tại quầy bởi Staff cho khách đến trực tiếp |
| **Deposit** | Tiền cọc — % trên tổng giá trị booking, do Admin mỗi Branch tự cấu hình |
| **Peak hours** | Khung giờ cao điểm Admin có thể set giá cao hơn. VD: 17:00–21:00 |
| **Occupancy rate** | Tỉ lệ lấp đầy sân = số slot đã đặt / tổng slot có thể đặt trong kỳ |

---

## Tài liệu liên quan

- [Danh sách module & chức năng chi tiết](./modules.md)
