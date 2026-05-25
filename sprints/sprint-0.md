# Sprint 0 — Foundation

> **Thời gian:** 1 tuần
> **Mục tiêu:** Chuẩn bị đủ để Sprint 1 bắt đầu code ngay — không bị vấp do thiếu design, thiếu schema, thiếu repo.
> **Không có feature code trong sprint này.**
> **Deadline:** Thứ 6 nộp hết → Chủ nhật họp review + assign Sprint 1.

---

## Nguyên tắc chia task Sprint 0

> **Ai thiết kế màn nào → người đó code màn đó trong Sprint 1–2.**
> Mỗi người làm 2 việc song song: **(1) Figma màn của mình** + **(2) 1 task infrastructure chung**.

| Người | Slice | Figma | Infra task | Deadline |
|---|---|---|---|---|
| **Nguyên** | Auth + Super Admin + Dashboard | A-01→05, SA-01→05, AD-01 (11 màn) | ADR Tech Stack + System Design + Repo Init + CI/CD (cùng Tuấn) | **Thứ 5** |
| **Tuấn** | Admin Setup | AD-04→08 (5 màn) | System Design + Repo Init + CI/CD (cùng Nguyên) | **Thứ 5** |
| **Đăng** | Customer Journey | C-01→05, C-10→12 (8 màn) | API Contract (phần Customer) | Thứ 6 |
| **Minh** | Payment + QR | C-06→09, AD-02→03, AD-11 (7 màn) | ERD + DB Schema (cùng Khoa) + API Contract (phần Payment) | Thứ 6 |
| **Khoa** | Staff | ST-01→05, AD-09→10 (7 màn) | ERD + DB Schema (cùng Minh) + API Contract (phần Staff) | Thứ 6 |

> **API Contract:** Mỗi người tự viết phần API của mình vào `docs/design/api-contract.md` theo format chuẩn. Nguyên review + compile cuối tuần.

---

## Figma — Danh sách màn theo người

### Nguyên · Auth + Super Admin + Dashboard

| ID | Màn |
|---|---|
| A-01 | Login (email + password) |
| A-02 | Register — Customer |
| A-03 | Register — Admin (form + note "chờ duyệt") |
| A-04 | Quên mật khẩu |
| A-05 | Profile (xem + chỉnh sửa thông tin cá nhân) |
| SA-01 | Danh sách Admin đang chờ duyệt |
| SA-02 | Chi tiết đăng ký Admin + nút Duyệt / Từ chối |
| SA-03 | Danh sách tất cả Admin trên hệ thống |
| SA-04 | Quản lý danh mục loại sân (CRUD) |
| SA-05 | Quản lý gói đăng ký (tháng/năm, số sân/cơ sở) |
| AD-01 | Dashboard tổng quan (doanh thu hôm nay/tuần/tháng + biểu đồ) |

---

### Tuấn · Admin Setup

| ID | Màn |
|---|---|
| AD-04 | Danh sách Branch của Admin |
| AD-05 | Tạo / Sửa Branch (tên, địa chỉ, giờ mở cửa, STK ngân hàng) |
| AD-06 | Danh sách Court trong Branch |
| AD-07 | Tạo / Sửa Court (tên, loại sân, giá mặc định) |
| AD-08 | Cấu hình Time Slot (template 30 phút, chọn giờ hoạt động) |

---

### Đăng · Customer Journey

| ID | Màn |
|---|---|
| C-01 | Trang chủ / Landing (tìm sân nhanh) |
| C-02 | Danh sách Branch (search + filter) |
| C-03 | Chi tiết Branch (ảnh, thông tin, danh sách Court) |
| C-04 | Xem slot trống theo ngày (grid 30 phút) |
| C-05 | Chọn slot → nhập SĐT (Guest) hoặc tự điền (Customer) |
| C-10 | Lịch sử booking (danh sách) |
| C-11 | Chi tiết booking (trạng thái, QR, thông tin sân) |
| C-12 | Màn huỷ booking (confirm dialog + policy) |

---

### Minh · Payment + QR + Admin Confirm

| ID | Màn |
|---|---|
| C-06 | Tóm tắt đơn + STK chuyển khoản + countdown 5 phút |
| C-07 | Upload ảnh bill / biên lai |
| C-08 | Chờ xác nhận (trạng thái pending) |
| C-09 | Booking confirmed → hiển thị QR code |
| AD-02 | Danh sách booking của Branch (filter theo ngày / trạng thái) |
| AD-03 | Chi tiết booking + xem ảnh bill + nút Xác nhận / Từ chối |
| AD-11 | Lịch sử giao dịch Branch |

---

### Khoa · Staff

| ID | Màn |
|---|---|
| AD-09 | Danh sách Staff của Branch |
| AD-10 | Tạo / Sửa tài khoản Staff |
| ST-01 | Lịch sân hôm nay (danh sách booking theo giờ) |
| ST-02 | Scan QR / nhập mã booking để check-in |
| ST-03 | Xác nhận check-in thành công |
| ST-04 | Tạo walk-in booking (nhập SĐT + chọn slot + xác nhận) |
| ST-05 | Checkout — đánh dấu khách về → sân trống |

**Nộp Figma:** Share link vào Discord `#design` trước Thứ 6 17:00

---

## Infrastructure Tasks

### Minh + Khoa · ERD + DB Schema (cộng tác)

**Phân công:**
- **Minh:** Draft entity Payment, Booking, BookingSlot, SlotHold — map với luồng chuyển khoản
- **Khoa:** Draft entity Staff, User, Subscription — map với luồng check-in
- **Cả hai:** Ghép lại, review chéo, Nguyên final review trước họp Chủ nhật

**Entities cần có**
- [ ] `users` — id, email, password_hash, phone, role, status, created_at, updated_at, deleted_at
- [ ] `branches` — id, admin_id, name, address, city, phone, open_time, close_time, bank_account_number, bank_account_name, bank_name, status
- [ ] `courts` — id, branch_id, name, court_type_id, description, status
- [ ] `court_types` — id, name
- [ ] `time_slot_templates` — id, court_id, start_time, end_time, price, day_of_week
- [ ] `bookings` — id, court_id, customer_id (nullable), guest_phone (nullable), date, status, total_price, created_at
- [ ] `booking_slots` — id, booking_id, slot_start, slot_end
- [ ] `slot_holds` — id, court_id, date, slot_start, slot_end, expired_at
- [ ] `payments` — id, booking_id, bill_image_url, status, confirmed_at, confirmed_by
- [ ] `staff` — id, user_id, branch_id
- [ ] `subscriptions` — id, admin_id, plan, max_courts, max_branches, start_date, end_date

**Yêu cầu kỹ thuật**
- [ ] Chốt UUID hoặc BIGINT cho primary key (thống nhất toàn bộ)
- [ ] Tất cả table có `created_at`, `updated_at`
- [ ] Soft delete bằng `deleted_at` cho branch, court, user
- [ ] Index FK và field query thường xuyên

**Output**
- [ ] ERD diagram trên [dbdiagram.io](https://dbdiagram.io)
- [ ] File `docs/database/schema.md`
- [ ] File `V1__init.sql` (Flyway)

---

### Nguyên · ADR Tech Stack

**ADR Tech Stack** — Dùng template tại `docs/adr/TEMPLATE.md`:
- [ ] `ADR-001` — Backend: Spring Boot 3.x + Java 21
- [ ] `ADR-002` — Frontend: React + Vite / Next.js (chốt 1)
- [ ] `ADR-003` — Database: PostgreSQL 16
- [ ] `ADR-004` — Auth: JWT access token + refresh token
- [ ] `ADR-005` — File storage cho bill upload: S3 / Cloudinary / local (chốt 1)
- [ ] `ADR-006` — Deployment: AWS EC2 / Railway / Render (chốt 1)

**Output:** `docs/adr/`

> ⚠️ Nguyên chốt ADR trước **Thứ 4** để Tuấn setup repo đúng stack, không phải chờ đến Thứ 5.

---

### Nguyên + Tuấn · System Design + Repo Init + CI/CD

**Phân công:**
- **Nguyên:** System Design diagram + review toàn bộ setup trước khi push
- **Tuấn:** Hands-on setup repo, CI/CD pipeline — Nguyên pair/review

**System Design (Nguyên lead):**
- [ ] Component diagram: FE → BE → DB + Storage
- [ ] Luồng đặt sân: chọn slot → hold → chuyển khoản → upload bill → Admin confirm → QR
- [ ] Luồng check-in: Staff scan QR → BE verify → update status → checkout

**Output:** `docs/design/system-design.md`

**GitHub (Tuấn hands-on):**
- [ ] Tạo GitHub Organization
- [ ] Repo `backend` + `frontend`: branch `main` + `dev`, bật branch protection
- [ ] Add toàn team làm member

**Backend (Tuấn setup, Nguyên review):**
- [ ] Init Spring Boot 3.x + Java 21
- [ ] Dependencies: Web, Security, JPA, PostgreSQL, Validation, Lombok
- [ ] Package: `controller / service / repository / entity / dto / config / exception`
- [ ] `application.yml` dùng env variables
- [ ] Flyway: `resources/db/migration/`
- [ ] `GET /api/v1/health` → `{ "status": "ok" }`

**Frontend (Tuấn setup):**
- [ ] Init React + Vite (hoặc Next.js — theo ADR-002)
- [ ] Setup: Axios, Router, Tailwind CSS
- [ ] Folder: `pages / components / hooks / services / stores / types`
- [ ] Proxy → `localhost:8080`

**CI/CD (Nguyên lead, Tuấn implement):**
- [ ] GitHub Actions: build + test on PR to `dev`
- [ ] Status badge trên README

**⚠️ Deadline: Thứ 5 17:00** — Team cần repo để push Figma + docs cuối tuần.

---

### API Contract — Mỗi người tự viết phần của mình

> Format chung: ghi vào `docs/design/api-contract.md`, theo đúng cấu trúc bên dưới.
> **Nguyên review + merge** trước buổi họp Chủ nhật.

**Nguyên** viết phần Auth + Super Admin + Dashboard:

| Method | Endpoint |
|---|---|
| POST | `/api/v1/auth/register` |
| POST | `/api/v1/auth/login` |
| POST | `/api/v1/auth/refresh` |
| GET | `/api/v1/users/me` |
| GET | `/api/v1/superadmin/pending-admins` |
| POST | `/api/v1/superadmin/admins/{id}/approve` |
| GET | `/api/v1/admin/dashboard` |

**Tuấn** viết phần Admin Setup:

| Method | Endpoint |
|---|---|
| GET | `/api/v1/branches` |
| GET | `/api/v1/branches/{id}` |
| POST | `/api/v1/admin/branches` |
| PUT | `/api/v1/admin/branches/{id}` |
| POST | `/api/v1/admin/courts` |
| PUT | `/api/v1/admin/courts/{id}` |
| POST | `/api/v1/admin/time-slots/template` |

**Đăng** viết phần Customer Journey:

| Method | Endpoint |
|---|---|
| GET | `/api/v1/courts/{id}/slots?date=` |
| POST | `/api/v1/bookings/hold` |
| GET | `/api/v1/bookings/{id}` |
| GET | `/api/v1/me/bookings` |
| DELETE | `/api/v1/bookings/{id}` |

**Minh** viết phần Payment + QR:

| Method | Endpoint |
|---|---|
| POST | `/api/v1/payments/upload-bill` |
| POST | `/api/v1/admin/payments/{id}/confirm` |
| POST | `/api/v1/admin/payments/{id}/reject` |
| GET | `/api/v1/bookings/{id}/qr` |
| GET | `/api/v1/admin/branches/{id}/transactions` |
| GET | `/api/v1/me/transactions` |

**Khoa** viết phần Staff:

| Method | Endpoint |
|---|---|
| POST | `/api/v1/admin/staff` |
| GET | `/api/v1/admin/branches/{id}/staff` |

| POST | `/api/v1/staff/checkin` |
| POST | `/api/v1/staff/checkout` |
| GET | `/api/v1/staff/schedule?date=` |

**Response format chuẩn** (áp dụng cho tất cả):
```json
// Success
{ "success": true, "data": {}, "message": "OK" }

// Error
{ "success": false, "error": { "code": "BOOKING_NOT_FOUND", "message": "..." } }
```

---

## Chủ nhật — Buổi họp chốt (2 tiếng)

- [ ] **0:00–0:20** Review ERD (Minh + Khoa present) → chốt schema
- [ ] **0:20–0:40** Review Figma của từng người → feedback nhanh
- [ ] **0:40–0:50** Review API Contract → thêm/bớt endpoint
- [ ] **0:50–1:00** Vote ADR còn tranh cãi (Nguyên chốt) → chốt tech stack
- [ ] **1:00–1:30** Assign task Sprint 1 chính thức trên Jira
- [ ] **1:30–1:50** Mỗi người tự break sub-task ngay tại chỗ
- [ ] **1:50–2:00** Chốt DoD Sprint 1 + lịch stand-up hàng tuần

---

## Definition of Done — Sprint 0

- [ ] Output nộp đúng nơi (Discord / repo docs)
- [ ] Được review ít nhất 1 người khác
- [ ] Repo backend + frontend có health endpoint chạy được
- [ ] Không còn câu hỏi lớn bỏ ngỏ sau buổi họp Chủ nhật
