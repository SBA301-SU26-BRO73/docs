# Sprint 1 — Core Setup

> **Thời gian:** 2 tuần (~10 ngày làm việc)
> **Mục tiêu:** Happy path cơ bản chạy được: Admin setup sân → Customer tìm sân → chọn slot → tạo booking.
> **Tuần 1:** Dùng mock JWT. **Tuần 2:** Swap Auth thật (Nguyên deliver [BE] Auth trước Thứ 4 tuần 2).

> **Convention:** 1 feature = [BE] task + [FE] task = 2 PRs. Mỗi task tạo 2 sub-task bắt buộc: **[Study]** trước khi code, **[Review]** khi tạo PR.

---

## Nguyên · Auth + Super Admin + Dashboard (~10 ngày)

| Task | ~Ngày |
|---|---|
| [BE] Auth — Register, login, JWT, refresh token, role guard | 2 |
| [FE] Auth — Màn đăng ký, đăng nhập, profile | 1 |
| [BE] Super Admin — Duyệt / từ chối admin, khoá / mở tài khoản | 1 |
| [FE] Super Admin — Danh sách pending & chi tiết duyệt | 1 |
| [BE] Super Admin — CRUD court types & subscription plans | 1 |
| [FE] Super Admin — Quản lý danh mục loại sân & gói | 1 |
| [BE] Dashboard — Stats API (doanh thu hôm nay/tuần/tháng, booking by status) | 1.5 |
| [FE] Dashboard — Overview metrics & biểu đồ cơ bản | 1.5 |

---

## Tuấn · Admin Setup (~9 ngày)

| Task | ~Ngày |
|---|---|
| [BE] Branch — Entity, CRUD API, STK ngân hàng config | 1.5 |
| [FE] Branch — Danh sách & form tạo / sửa branch | 1.5 |
| [BE] Court — Entity, CRUD API, gắn court type, giá mặc định | 1.5 |
| [FE] Court — Danh sách & form tạo / sửa court | 1.5 |
| [BE] Slot — Time slot template CRUD, apply to court | 1.5 |
| [FE] Slot — Cấu hình template 30 phút & preview | 1.5 |

---

## Đăng · Customer Journey (~8 ngày)

| Task | ~Ngày |
|---|---|
| [BE] Branch — Public list, search, filter cơ bản API | 1 |
| [FE] Branch — Trang chủ, danh sách branch, chi tiết branch | 2 |
| [BE] Slot — Available slots by court & date API | 1 |
| [FE] Slot — Grid slot 30 phút, trạng thái trống / bận / đang giữ | 1 |
| [BE] Booking — Hold slot API (5 phút expiry) | 1.5 |
| [FE] Booking — Chọn slot, nhập SĐT (guest), tóm tắt đơn | 1.5 |

---

## Minh · Payment + QR (~9 ngày)

| Task | ~Ngày |
|---|---|
| [BE] Payment — Booking summary & branch STK API | 1 |
| [FE] Payment — Màn tóm tắt đơn + STK chuyển khoản + countdown 5 phút | 1 |
| [BE] Payment — Upload bill lên storage, cập nhật trạng thái | 1 |
| [FE] Payment — Màn upload ảnh bill & polling trạng thái chờ duyệt | 1 |
| [BE] Payment — Admin confirm / reject payment API | 1 |
| [FE] Payment — Admin danh sách booking cần duyệt & confirm UI | 1 |
| [BE] Payment — Generate QR khi confirmed, scheduler auto-cancel sau 5 phút | 2 |
| [FE] Payment — Hiển thị QR code sau khi được confirm | 1 |

---

## Khoa · Staff (~8 ngày)

| Task | ~Ngày |
|---|---|
| [BE] Staff — CRUD staff accounts, assign to branch | 1 |
| [FE] Staff — Danh sách & form tạo / sửa staff | 1 |
| [BE] Staff — Today schedule API & QR verify check-in | 1.5 |
| [FE] Staff — Lịch sân hôm nay & scan QR / nhập mã check-in | 1.5 |
| [BE] Staff — Walk-in booking & checkout API | 1.5 |
| [FE] Staff — Form walk-in tại quầy & màn checkout | 1.5 |

---

## Definition of Done — Sprint 1

- [ ] Demo được: **Login → Admin tạo Branch + Court + Slot → Customer tìm sân → chọn slot → hold 5p → tóm tắt đơn + STK**
- [ ] Auth thật hoạt động (không còn mock JWT)
- [ ] Mỗi task có PR merged vào `dev`, CI pass, ≥1 approval
- [ ] Sub-task [Study] điền đầy đủ trước khi code
