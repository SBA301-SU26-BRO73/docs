# Sprint 3 — Polish & SHOULD Features

> **Thời gian:** 2 tuần (~10 ngày làm việc)
> **Mục tiêu:** SHOULD features, fix bug từ Sprint 1–2, integration test toàn luồng, seed data demo.

> **Convention:** 1 feature = [BE] task + [FE] task = 2 PRs. Mỗi task tạo 2 sub-task bắt buộc: **[Study]** trước khi code, **[Review]** khi tạo PR.

---

## Nguyên · Dashboard nâng cao + Super Admin stats (~8 ngày)

| Task | ~Ngày |
|---|---|
| [BE] Dashboard — Top courts, peak hours, analytics API | 1.5 |
| [FE] Dashboard — Analytics charts: sân đặt nhiều nhất, biểu đồ peak hours | 1.5 |
| [BE] Dashboard — Export doanh thu ra CSV / Excel | 1.5 |
| [FE] Dashboard — Nút export & download file | 0.5 |
| [BE] Super Admin — System overview API: tổng branch, doanh thu, booking toàn hệ thống | 1.5 |
| [FE] Super Admin — Trang thống kê tổng quan toàn hệ thống | 1.5 |

---

## Tuấn · Pricing nâng cao (~8 ngày)

| Task | ~Ngày |
|---|---|
| [BE] Court — Peak / off-peak pricing config & tính giá theo khung giờ | 2 |
| [FE] Court — UI cấu hình giá peak / off-peak theo Court | 2 |
| [BE] Court — Weekday / weekend pricing config & tính giá theo ngày | 2 |
| [FE] Court — UI cấu hình giá theo ngày trong tuần | 2 |

---

## Đăng · Voucher (~8 ngày)

| Task | ~Ngày |
|---|---|
| [BE] Voucher — CRUD voucher (%, số tiền cố định, giới hạn lượt, hạn dùng) | 1.5 |
| [FE] Voucher — Admin màn quản lý voucher | 1.5 |
| [BE] Voucher — Validate & apply mã voucher khi thanh toán, tính giá sau giảm | 1.5 |
| [FE] Booking — Nhập mã voucher & hiển thị giá sau giảm | 1.5 |
| [BE] Voucher — Voucher usage history API | 1 |
| [FE] Voucher — Admin xem lịch sử sử dụng voucher | 1 |

---

## Minh · Refund (~7 ngày)

| Task | ~Ngày |
|---|---|
| [BE] Refund — Customer gửi refund request API | 1.5 |
| [FE] Refund — Màn gửi yêu cầu hoàn tiền & xem trạng thái | 1.5 |
| [BE] Refund — Admin duyệt / từ chối refund, cập nhật trạng thái | 1.5 |
| [FE] Refund — Admin màn xem & duyệt yêu cầu hoàn tiền | 1 |
| [BE] Payment — Hoàn thiện transaction history đủ loại giao dịch | 0.5 |
| [FE] Payment — Hoàn thiện transaction history UI | 1 |

---

## Khoa · Staff SHOULD + Integration (~8 ngày)

| Task | ~Ngày |
|---|---|
| [BE] Notification — Email nhắc lịch trước 2h khi sắp đến giờ chơi | 1.5 |
| [Test] Integration — Full flow: Register → Setup → Book → Pay → Check-in → Checkout | 3 |
| [Data] Seed data — 2–3 branch, 10 court, booking mẫu thực tế | 2 |
| Buffer — Bug fix từ Sprint 1–2 | 1.5 |

---

## Definition of Done — Sprint 3

- [ ] Tất cả CORE + SHOULD ưu tiên cao done
- [ ] Integration test pass toàn bộ happy path
- [ ] Không còn P0/P1 bug
- [ ] Seed data sẵn sàng cho demo
