# Sprint 2 — Payment & Operations

> **Thời gian:** 2 tuần (~10 ngày làm việc)
> **Mục tiêu:** Full booking flow end-to-end. Staff check-in + checkout thật. Notifications hoạt động.

> **Convention:** 1 feature = [BE] task + [FE] task = 2 PRs. Mỗi task tạo 2 sub-task bắt buộc: **[Study]** trước khi code, **[Review]** khi tạo PR.

---

## Nguyên · Auth nâng cao + Notifications + Dashboard (~10 ngày)

| Task | ~Ngày |
|---|---|
| [BE] Auth — Reset mật khẩu qua email, đổi mật khẩu khi đã đăng nhập | 1 |
| [FE] Auth — Màn quên mật khẩu & đổi mật khẩu | 1 |
| [BE] Notification — Email: confirm booking, cancel, admin approve, notify admin booking mới | 2 |
| [BE] Dashboard — Revenue chart API theo thời gian, occupancy rate API | 1.5 |
| [FE] Dashboard — Biểu đồ doanh thu theo thời gian & occupancy rate | 1.5 |
| [BE] Subscription — Admin chọn gói, xem gói hiện tại; Super Admin manage plans | 1 |
| [FE] Subscription — Màn chọn gói khi đăng ký & xem gói hiện tại | 1 |

---

## Tuấn · Admin nâng cao (~9 ngày)

| Task | ~Ngày |
|---|---|
| [BE] Branch — Upload & lưu ảnh branch / court lên storage | 1 |
| [FE] Branch/Court — Hiển thị ảnh trên trang detail | 1 |
| [BE] Slot — Lock / block slot API (bảo trì, nghỉ lễ) | 1.5 |
| [FE] Slot — Calendar view theo ngày / tuần & lock slot UI | 2.5 |
| [BE] Slot — Bulk apply template cho nhiều court cùng lúc | 1.5 |
| [FE] Slot — Bulk apply UI (chọn nhiều court, preview, confirm) | 1.5 |

---

## Đăng · Booking nâng cao (~9 ngày)

| Task | ~Ngày |
|---|---|
| [BE] Booking — Booking history & detail API | 1 |
| [FE] Booking — Lịch sử booking, chi tiết booking, hiển thị QR | 1 |
| [BE] Booking — Cancel booking API (validate theo policy) | 1.5 |
| [FE] Booking — Màn huỷ booking, confirm dialog, hiển thị policy | 1.5 |
| [BE] Branch — Advanced filter API (giờ trống hôm nay, khoảng giá, khu vực) | 1 |
| [FE] Branch — Advanced filter UI | 1 |
| [BE] Booking — Admin xem toàn bộ booking của branch, filter nâng cao | 1 |
| [FE] Booking — Admin branch booking list & filter UI | 1 |

---

## Minh · QR + Payment hoàn chỉnh (~9 ngày)

| Task | ~Ngày |
|---|---|
| [FE] Payment — QR đầy đủ trong booking detail, nhập mã thủ công fallback | 1 |
| [BE] Payment — Customer transaction history API | 1 |
| [FE] Payment — Danh sách giao dịch của customer | 1 |
| [BE] Payment — Branch transaction history API | 1 |
| [FE] Payment — Admin xem toàn bộ giao dịch của branch | 1 |
| [BE] Payment — Polling endpoint trạng thái payment | 1.5 |
| [FE] Payment — Payment status realtime UX (polling + feedback rõ ràng) | 1.5 |

---

## Khoa · Staff hoàn chỉnh (~8 ngày)

| Task | ~Ngày |
|---|---|
| [BE] Staff — Walk-in hoàn chỉnh: full validation, chọn slot từ lịch hôm nay | 1.5 |
| [FE] Staff — Walk-in form hoàn chỉnh với calendar hôm nay | 1.5 |
| [BE] Staff — Schedule API: filter theo ngày, xem tuần, trạng thái real-time | 1.5 |
| [FE] Staff — Lịch sân nâng cao: filter ngày, xem tuần | 1.5 |
| [BE] Staff — Manual check-in bằng mã booking | 1 |
| [FE] Staff — Nhập mã check-in thủ công khi không scan được QR | 1 |

---

## Definition of Done — Sprint 2

- [ ] Demo full flow: **Tìm sân → Chọn slot → Upload bill → Admin confirm → Nhận QR → Staff scan QR → Check-in → Checkout**
- [ ] Email notifications gửi được
- [ ] Mỗi task có PR merged vào `dev`, CI pass, ≥1 approval
