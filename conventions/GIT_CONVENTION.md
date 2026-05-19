# Git Convention — SBA301-BRO73

## 1. Branch Strategy

Dự án sử dụng **Gitflow** với 4 loại branch chính:

```
main          ← production-ready, chỉ merge từ hotfix hoặc release
  │
  └── dev     ← integration branch, mọi feature merge vào đây
        │
        ├── feature/xxx   ← tính năng mới
        └── hotfix/xxx    ← sửa lỗi khẩn cấp trên main
```

| Branch       | Mục đích                                  | Merge vào        | Ai được push trực tiếp |
|--------------|-------------------------------------------|------------------|------------------------|
| `main`       | Code production, luôn stable             | —                | Không ai (chỉ qua PR)  |
| `dev`        | Tích hợp code từ feature branches        | `main`           | Không ai (chỉ qua PR)  |
| `feature/*`  | Phát triển tính năng mới                 | `dev`            | Dev sở hữu branch đó   |
| `hotfix/*`   | Vá lỗi khẩn cấp trên production         | `main` và `dev`  | Senior / Lead          |

---

## 2. Branch Naming Convention

**Format:** `{type}/{jira-ticket-id}_{short-description}`

```
feature/SBA301-15_manage-product
feature/SBA301-22_user-authentication
hotfix/SBA301-31_fix-null-pointer-login
```

**Quy tắc:**
- Chỉ dùng **chữ thường**, **dấu gạch ngang** (`-`) để nối từ
- Không dùng dấu cách, dấu gạch dưới (ngoại trừ sau ticket ID), ký tự đặc biệt
- Mô tả ngắn gọn, tối đa **4-5 từ**
- Luôn có Jira ticket ID

**Ví dụ đúng / sai:**

```bash
# Đúng
feature/SBA301-10_create-product-api
hotfix/SBA301-55_fix-login-crash

# Sai
feature/CreateProductAPI      ← không có ticket ID
feature/SBA301-10             ← không có mô tả
Feature/SBA301-10_Create      ← viết hoa
feature/sba301-10 add user    ← có dấu cách
```

---

## 3. Commit Convention

Dự án theo chuẩn **Conventional Commits**.

**Format:**
```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### Commit Types

| Type       | Dùng khi                                              |
|------------|-------------------------------------------------------|
| `feat`     | Thêm tính năng mới                                   |
| `fix`      | Sửa bug                                              |
| `refactor` | Cải thiện code, không thêm tính năng / sửa bug       |
| `test`     | Thêm hoặc sửa test                                   |
| `docs`     | Cập nhật tài liệu                                    |
| `chore`    | Cấu hình, build tool, dependency (không ảnh hưởng code) |
| `style`    | Format code, whitespace (không thay đổi logic)       |
| `perf`     | Cải thiện performance                                |
| `hotfix`   | Fix lỗi khẩn cấp trên production                    |

### Scope (tuỳ chọn)

Là module bị ảnh hưởng: `auth`, `booking`, `venue`, `court`, `payment`, `staff`, `notification`, `user`

### Ví dụ thực tế

```bash
# Thêm tính năng
feat(booking): add create booking endpoint

# Sửa bug
fix(auth): resolve null pointer exception on empty email login

# Viết test
test(booking): add unit test for BookingService.createBooking

# Database migration
chore(db): add flyway migration V3 for booking table

# Cập nhật docs
docs: update API endpoint documentation for booking module

# Refactor
refactor(payment): extract deposit calculation logic to separate method
```

**Quy tắc viết commit:**
- `<subject>` viết **chữ thường**, không kết thúc bằng dấu `.`
- Tối đa **72 ký tự** cho dòng tiêu đề
- Dùng **tiếng Anh** (nhất quán toàn team)
- `<subject>` mô tả **"làm gì"**, không phải **"đã làm gì"** (dùng thì hiện tại: `add` không phải `added`)

---

## 4. Git Workflow — Luồng làm việc hàng ngày

```
1. Cập nhật dev mới nhất
   git checkout dev
   git pull origin dev

2. Tạo branch mới từ dev
   git checkout -b feature/SBA301-15_manage-product

3. Code, commit thường xuyên
   git add .
   git commit -m "feat(product): add product entity and repository"

4. Push branch lên remote
   git push origin feature/SBA301-15_manage-product

5. Tạo Pull Request vào dev trên GitHub
   - Điền PR title và description (xem mục 5)
   - Assign reviewer (tối thiểu 1 người)
   - Link Jira ticket trong PR description

6. Sau khi được approve → Merge PR
   - Dùng "Squash and merge" cho feature branch
   - Xoá branch sau khi merge
```

---

## 5. Pull Request Convention

**PR Title:** `[SBA301-XX] feat(scope): mô tả ngắn gọn`

```
[SBA301-15] feat(product): implement manage product CRUD
```

**PR Description Template:**

```markdown
## Jira Ticket
[SBA301-15](link-to-jira-ticket)

## Changes
- Mô tả ngắn những gì đã thay đổi

## Checklist
- [ ] Tự review code trước khi tạo PR
- [ ] Không có conflict với branch dev
- [ ] Đã update Jira ticket sang In Review
```

**Code Review Rules:**
- Cần ít nhất **1 approval** trước khi merge
- Author không được tự merge PR của mình (ngoại trừ hotfix khẩn)

---

## 6. CI/CD — Điều kiện để merge vào `dev`

Mỗi PR vào `dev` sẽ được GitHub Actions chạy tự động. **PR chỉ được merge khi tất cả checks xanh.**

```
Push feature branch
        │
        ▼
  GitHub Actions chạy CI
        │
        ├── Build pass?  ──► Fail → không được merge
        ├── Unit test pass? ──► Fail → không được merge
        └── 1 approval từ reviewer? ──► Chưa có → không được merge
                │
                ▼
           Merge vào dev
```

### Các bước CI chạy trên PR vào `dev`

| Bước | Mô tả | Fail thì sao |
|------|-------|--------------|
| **Build** | `mvn clean package -DskipTests` | Block merge |
| **Unit Test** | `mvn test` — chạy toàn bộ unit test | Block merge |
| **Code Review** | Tối thiểu 1 approval từ thành viên khác | Block merge |

### Quy tắc
- **Không bypass CI** — không dùng `[skip ci]` trong commit message để tránh chạy test
- Nếu CI fail, dev phải fix trước khi được merge, không nhờ người khác approve để bypass
- Branch phải được **rebase hoặc merge từ `dev` mới nhất** trước khi tạo PR (tránh conflict)

---

## 7. Tóm tắt Quick Reference

```bash
# Bắt đầu task mới
git checkout dev && git pull origin dev
git checkout -b feature/SBA301-{ticket-id}_{short-desc}

# Commit
git commit -m "feat(booking): add create booking endpoint"
git commit -m "fix(auth): resolve otp expiry not checked on guest flow"
git commit -m "test(venue): add unit test for VenueService.createBranch"
git commit -m "chore(db): add flyway migration V{n} for {table}"

# Push và tạo PR
git push origin feature/SBA301-{ticket-id}_{short-desc}
# → Tạo PR trên GitHub vào branch dev
# → CI chạy tự động — chờ build + test xanh
# → Cập nhật Jira ticket sang In Review
```
