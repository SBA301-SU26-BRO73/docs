# Jira Convention — SBA301-BRO73

## 1. Cấu trúc Issue Types

```
Epic
 └── Task / Bug
      └── Sub-task
```

| Type     | Mô tả                                                    | Người tạo         |
|----------|----------------------------------------------------------|-------------------|
| Epic     | Tính năng lớn, trải dài nhiều sprint                    | Scrum Master/Lead |
| Task     | Công việc kỹ thuật cụ thể, thuộc 1 Epic                 | Scrum Master/Lead |
| Bug      | Lỗi phát hiện trong quá trình dev hoặc review           | Bất kỳ ai         |
| Sub-task | Việc nhỏ do dev tự tách ra từ Task, tự tạo và tự assign | Dev được assign   |

---

## 2. Quy trình tạo Sub-task

Khi được assign 1 **Task** lớn (ví dụ: `Manage Court`), dev tự tách thành các sub-task CRUD:

```
Task: [SBA301-15] Manage Court
  ├── Sub-task: [SBA301-15-1] Create Court
  ├── Sub-task: [SBA301-15-2] Read/List Court
  ├── Sub-task: [SBA301-15-3] Update Court
  └── Sub-task: [SBA301-15-4] Delete Court
```

**Quy tắc sub-task:**
- Đặt tên theo format: `[Hành động] [Đối tượng]` — VD: `Create Court`, `Cancel Booking`
- Mỗi sub-task nên hoàn thành trong **1 ngày làm việc** hoặc ít hơn
- Sub-task phải link đến parent Task
- Dev tự estimate time và assign cho chính mình

---

## 3. Ticket Naming Convention

| Type     | Format                                  | Ví dụ                                     |
|----------|-----------------------------------------|-------------------------------------------|
| Epic     | `[Module] tên tính năng`               | `[Booking] Court Booking System`         |
| Task     | `[Module] Verb + Object`               | `[Booking] Implement create booking API` |
| Bug      | `[BUG] Mô tả ngắn + điều kiện tái hiện` | `[BUG] Double booking allowed on same slot` |
| Sub-task | `Verb + Object`                        | `Create Court`, `Cancel Booking`              |

---

## 4. Workflow Trạng thái

```
To Do  ──►  In Progress  ──►  In Review  ──►  Done
             │                    │
             │                    └──► To Do  (reviewer reject)
             │
             └──► To Do  (bị block, cần clarify)
```

| Trạng thái  | Ý nghĩa                                                  | Người thực hiện          |
|-------------|----------------------------------------------------------|--------------------------|
| To Do       | Ticket đã được tạo, chưa bắt đầu làm                    | —                        |
| In Progress | Đang phát triển, đã tạo branch tương ứng                | Dev được assign          |
| In Review   | Đã tạo PR, đang chờ code review                         | Dev → chuyển khi tạo PR  |
| Done        | PR được merge, ticket hoàn thành                        | Reviewer merge PR        |

**Quy tắc:**
- Chuyển ticket sang **In Progress** ngay khi bắt đầu code, không để **To Do** khi đã làm
- Chuyển sang **In Review** cùng lúc tạo PR trên GitHub
- Ticket chỉ được **Done** sau khi PR được merge vào `dev`

---

## 5. Điền thông tin Ticket

Mỗi ticket khi tạo cần có đủ các trường sau:

```
Title    : [Module] Mô tả ngắn gọn rõ ràng
Assignee : Dev phụ trách
Priority : Low / Medium / High / Critical
Sprint   : Sprint hiện tại
Parent   : Link đến Task cha (nếu là sub-task)
```

---

## 6. Quy trình Log Bug

Khi phát hiện bug, tạo ticket loại **Bug** với mô tả ngắn gọn:

```
Title    : [BUG] Mô tả ngắn + điều kiện tái hiện
Mô tả    : Làm gì thì bị lỗi, kết quả mong đợi là gì, thực tế nhận được gì
Đính kèm : Screenshot hoặc log nếu có
```

**Phân loại Priority bug:**

| Priority | Mô tả                                                   |
|----------|---------------------------------------------------------|
| Critical | App crash, không login được, mất dữ liệu               |
| High     | Tính năng chính bị lỗi, ảnh hưởng nhiều user          |
| Medium   | Tính năng phụ lỗi, có cách workaround                  |
| Low      | UI sai nhỏ, typo, không ảnh hưởng nghiệp vụ           |

---

## 7. Sprint Management

### Sprint Planning
- Diễn ra đầu mỗi sprint (mỗi sprint = 1-2 tuần)
- Lead chuyển ticket từ Backlog vào Sprint
- Dev estimate effort (giờ hoặc story points) cho ticket của mình

### Sprint Review
- Demo tính năng đã hoàn thành trong sprint
- Ticket chưa Done → chuyển sang sprint tiếp theo, ghi rõ lý do

### Definition of Done (DoD)
Một ticket được coi là **Done** khi:
- [ ] Code đã được review và approve
- [ ] PR đã merge vào `dev`
- [ ] Không có unit test bị fail
- [ ] Ticket status trên Jira đã chuyển sang Done
