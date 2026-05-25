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

**Format:** `{type}/{short-description}`

```
feature/manage-branch
feature/user-authentication
hotfix/fix-null-pointer-login
```

**Quy tắc:**
- Chỉ dùng **chữ thường**, **dấu gạch ngang** (`-`) để nối từ
- Không dùng dấu cách, ký tự đặc biệt, viết hoa
- Mô tả ngắn gọn, đủ hiểu là làm gì

**Ví dụ đúng / sai:**

```bash
# Đúng
feature/manage-branch
feature/user-authentication
hotfix/fix-login-crash

# Sai
feature/ManageBranch      ← viết hoa
feature/manage branch     ← có dấu cách
feature/x                 ← quá ngắn, không rõ nghĩa
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

Là module bị ảnh hưởng: `auth`, `booking`, `branch`, `court`, `slot`, `payment`, `staff`, `dashboard`, `notification`, `user`

### Ví dụ thực tế

```bash
# Thêm tính năng
feat(booking): add slot hold endpoint with 5-minute expiry
feat(branch): add bank account config for branch
feat(payment): add bill upload and admin confirm flow
feat(auth): add jwt middleware and role guard

# Sửa bug
fix(booking): prevent double booking on same slot
fix(auth): resolve null pointer on empty email login

# Viết test
test(booking): add unit test for SlotHoldService
test(payment): add unit test for bill upload validation

# Database migration
chore(db): add flyway migration V2 for slot_holds table

# Cập nhật docs
docs: update readme with local setup guide

# Refactor
refactor(slot): extract slot generation logic to SlotTemplateService
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
   git checkout -b feature/manage-branch

3. Code, commit thường xuyên
   git add .
   git commit -m "feat(branch): add branch entity and repository"

4. Push branch lên remote
   git push origin feature/manage-branch

5. Tạo Pull Request vào dev trên GitHub
   - Điền PR title và description (xem mục 5)
   - Assign reviewer (tối thiểu 1 người)

6. Sau khi được approve → Merge PR
   - Dùng "Squash and merge" cho feature branch
   - Xoá branch sau khi merge
```

---

## 5. Pull Request Convention

**PR Title:** `feat(scope): mô tả ngắn gọn`

```
feat(branch): implement branch CRUD API
```

**PR Description Template:**

```markdown
## Changes
- Mô tả ngắn những gì đã thay đổi

## Checklist
- [ ] Tự review code trước khi tạo PR
- [ ] Không có conflict với branch dev
- [ ] Unit test pass
- [ ] Build pass (CI xanh)
- [ ] Đã update Jira ticket sang In Review
- [ ] Đã tạo ticket Request Review Coding assign Nguyên
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
        ├── Build pass?        ──► Fail → không được merge
        ├── Unit test pass?    ──► Fail → không được merge
        └── 1 approval từ reviewer? ──► Chưa có → không được merge
                │
                ▼
           Merge vào dev
```

### Backend (Spring Boot)

| Bước | Command | Fail thì sao |
|------|---------|--------------|
| **Build** | `mvn clean package -DskipTests` | Block merge |
| **Unit Test** | `mvn test` | Block merge |

### Frontend (React)

| Bước | Command | Fail thì sao |
|------|---------|--------------|
| **Build** | `npm run build` | Block merge |
| **Lint** | `npm run lint` | Block merge |

### Quy tắc
- **Không bypass CI** — không dùng `[skip ci]` trong commit message
- Nếu CI fail, dev phải fix trước khi được merge
- Branch phải được **rebase hoặc merge từ `dev` mới nhất** trước khi tạo PR

---

## 7. Tóm tắt Quick Reference

```bash
# Bắt đầu task mới
git checkout dev && git pull origin dev
git checkout -b feature/{short-desc}

# Commit
git commit -m "feat(booking): add slot hold with 5-minute session expiry"
git commit -m "fix(payment): fix bill upload not accepting png format"
git commit -m "test(booking): add unit test for SlotHoldService"
git commit -m "chore(db): add flyway migration V{n} for {table}"

# Push và tạo PR
git push origin feature/{short-desc}
# → Tạo PR trên GitHub vào branch dev
# → CI chạy tự động — chờ build + test xanh
# → Tạo ticket Request Review Coding assign Nguyên
# → Cập nhật Jira ticket sang In Review
```
