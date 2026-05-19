# Hướng dẫn viết ADR hiệu quả

> Dịch và cô đọng từ: *"Master architecture decision records (ADRs): Best practices for effective decision-making"* — AWS Architecture Blog (Christoph Kappey, Dominik Goby, Darius Kunce · 20/03/2025)

---

## ADR là gì và tại sao cần?

ADR giúp **ghi lại và truyền đạt** các quyết định kiến trúc quan trọng trong dự án. Thay vì mỗi người nhớ một kiểu hoặc không ai nhớ tại sao lại chọn công nghệ X, ADR lưu lại:
- **Bối cảnh** lúc ra quyết định
- **Các lựa chọn đã xem xét**
- **Lý do chọn** phương án này thay vì phương án kia

**5 vấn đề ADR giải quyết:**

| Vấn đề | Mô tả |
|---|---|
| Team alignment | Dev mất 20–30% thời gian phối hợp, gây chậm trễ và refactor lặp lại |
| Design flexibility | Khó cân bằng giữa thiết kế upfront và kiến trúc tiến hoá theo Agile |
| Nonfunctional requirements | Trade-off giữa security, maintainability, scalability |
| Changing requirements | Yêu cầu thay đổi nhưng không biết quyết định cũ dựa trên giả định gì |
| Knowledge transfer | Người mới vào không hiểu "tại sao code lại như vậy" |

---

## 10 nguyên tắc viết ADR tốt

### 1. Họp ngắn và có trọng tâm
- Mỗi buổi review ADR **tối đa 30–45 phút**
- Đừng để buổi họp kéo dài thành thảo luận vô tận

> **Ví dụ thực hành:** Đặt timer 40 phút. Nếu chưa xong → ghi lại điểm còn tranh luận, lên lịch buổi 2.

---

### 2. Đọc trước, comment bằng văn bản
- Dành 10–15 phút đầu buổi để **mọi người đọc ADR** (không đọc trước ở nhà)
- Góp ý bằng comment viết ra — không nói miệng ngay

> **Ví dụ thực hành:** Mở Google Doc hoặc GitHub PR, ai cũng comment vào đúng dòng cần góp ý trước khi bắt đầu thảo luận.

---

### 3. Đủ thành phần, không đông người
- Mời đại diện từ **các team bị ảnh hưởng**
- Tổng số người **dưới 10**

> **Ví dụ thực hành:** Quyết định chọn database → mời 1 BE dev + 1 DevOps + 1 lead. Không cần FE, không cần cả team.

---

### 4. Mỗi ADR = 1 quyết định duy nhất
- Đừng gộp "chọn database + chọn ORM + chọn migration tool" vào 1 ADR
- Nếu thấy scope phình to → tách ra

> **Ví dụ thực hành:**
> - ❌ `ADR-001-backend-technology-decisions.md`
> - ✅ `ADR-001-database-postgresql-vs-mysql.md`
> - ✅ `ADR-002-orm-hibernate-vs-jooq.md`

---

### 5. Tách design document khỏi ADR
- ADR = ghi lại **quyết định đã chọn**
- Design doc = nơi **khám phá, so sánh chi tiết** các lựa chọn
- ADR chỉ cần link tới design doc, không cần copy toàn bộ

> **Ví dụ thực hành:** Viết một file `design/payment-options-analysis.md` so sánh chi tiết PayOS vs VNPay vs MoMo. ADR chỉ ghi "Chosen: PayOS, xem thêm [payment-options-analysis.md](../design/payment-options-analysis.md)".

---

### 6. Giải quyết hết mọi comment trước khi close
- Không được "im lặng = đồng ý"
- Mỗi comment phải được **incorporate hoặc thảo luận đến khi đạt consensus**

> **Ví dụ thực hành:** Dùng GitHub PR cho ADR. Chỉ merge khi tất cả review comments đã được resolved.

---

### 7. Ra quyết định nhanh — không thảo luận mãi
- **1–3 buổi readout là đủ**. Nếu vẫn chưa xong → vấn đề là scope quá rộng hoặc có quá nhiều người
- Hầu hết quyết định là **two-way door** (có thể thay đổi sau) — đừng coi như một chiều

> **Ví dụ thực hành:** Sau buổi review thứ 2 vẫn chưa chọn được → thu hẹp scope ADR hoặc giảm số người tham gia.

---

### 8. ADR là của cả team, không phải của tác giả
- Người viết ADR phải **chủ động lấy feedback** từ tất cả các bên liên quan
- Sau khi accepted → tất cả cùng chịu trách nhiệm

> **Ví dụ thực hành:** Assign ADR như assign task trên Jira. Người viết = owner, nhưng cả team review và approve.

---

### 9. Cập nhật khi quyết định thay đổi
- Nếu ADR cũ bị thay thế → **không xóa**, chỉ update `status: superseded by ADR-XXX`
- Link ADR mới vào ADR cũ

> **Ví dụ thực hành:**
> ```yaml
> # ADR-001
> status: "superseded by ADR-007"
> ```
> ```yaml
> # ADR-007
> # More Information:
> # Thay thế ADR-001 vì lý do X, xem: [ADR-001](./ADR-001-...)
> ```

---

### 10. Lưu tập trung, ai cũng truy cập được
- ADR phải nằm ở **1 nơi duy nhất**, không scatter qua Slack, email, Notion riêng lẻ
- Toàn bộ team đều thấy được — kể cả người mới join sau

> **Ví dụ thực hành:** Toàn bộ ADR trong `docs/adr/` của repo này. Link từ root README. Không lưu trong Notion cá nhân.

---

## Quy trình thực hành cho BRO73

```
1. Phát hiện cần ra quyết định kỹ thuật quan trọng
         ↓
2. Copy TEMPLATE.md → ADR-XXX-ten-quyet-dinh.md
   Set status: proposed
         ↓
3. Điền Context, Decision Drivers, Considered Options
   Viết design doc riêng nếu cần so sánh chi tiết
         ↓
4. Tạo PR → tag người liên quan review
   Buổi readout 30–45 phút (đọc 10 phút + thảo luận)
         ↓
5. Resolve tất cả comments
         ↓
6. Đổi status: accepted → merge PR
   Cập nhật bảng index trong docs/adr/README.md
         ↓
7. Nếu sau này thay đổi → tạo ADR mới, supersede cái cũ
```

---

## Những ADR nên viết cho dự án này

| # | Quyết định | Độ ưu tiên |
|---|---|---|
| ADR-001 | Chọn tech stack tổng thể (React + Spring Boot + PostgreSQL) | Cao |
| ADR-002 | Chiến lược authentication (JWT vs Session vs OAuth2) | Cao |
| ADR-003 | Tích hợp payment gateway (PayOS) | Cao |
| ADR-004 | SMS OTP provider (Twilio vs VIETTEL vs FPT) | Trung bình |
| ADR-005 | Chiến lược CI/CD (GitHub Actions + AWS) | Trung bình |
| ADR-006 | Real-time strategy (WebSocket vs SSE vs Polling) | Thấp — làm sau |

---

> **Nguồn:** [AWS Architecture Blog — Master ADRs: Best practices for effective decision-making](https://aws.amazon.com/blogs/architecture/master-architecture-decision-records-adrs-best-practices-for-effective-decision-making/)
