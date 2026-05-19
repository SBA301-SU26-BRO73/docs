# BRO73 — Court Booking Platform · Tài liệu dự án

Dự án đặt sân thể thao trực tuyến đa cơ sở (SaaS) — môn SBA301, FPTU.

> Repo này chứa toàn bộ tài liệu phân tích và thiết kế. Code nằm ở repo riêng.

---

## Đọc theo thứ tự này

| Bước | Folder | Trạng thái |
|---|---|---|
| 1 · Phân tích nghiệp vụ | [`business/`](./business/) | ✅ Xong |
| 2 · Thiết kế hệ thống | [`design/`](./design/) | 🔲 Chưa làm |
| 3 · Thiết kế database | [`database/`](./database/) | 🔲 Chưa làm |
| 4 · Quyết định kỹ thuật | [`adr/`](./adr/) + [`tech-stack/`](./tech-stack/) | 🔲 Chưa làm |
| — · Quy ước làm việc | [`conventions/`](./conventions/) | ✅ Xong |

---

## Nội dung từng folder

**[`business/`](./business/)** — Phân tích nghiệp vụ
- [`overview.md`](./business/overview.md) — Tổng quan dự án, actors, business model, scope, glossary
- [`modules.md`](./business/modules.md) — Toàn bộ ~99 chức năng chia theo module, actor, priority

**[`design/`](./design/)** — Thiết kế hệ thống *(sẽ bổ sung)*
- Kiến trúc tổng thể, API design, sequence diagrams

**[`database/`](./database/)** — Thiết kế database *(sẽ bổ sung)*
- ERD, schema chi tiết

**[`adr/`](./adr/)** — Architecture Decision Records
- [`ADR-GUIDE.md`](./adr/ADR-GUIDE.md) — Hướng dẫn viết ADR
- [`TEMPLATE.md`](./adr/TEMPLATE.md) — Template chuẩn để tạo ADR mới

**[`tech-stack/`](./tech-stack/)** — Tổng hợp công nghệ *(sẽ bổ sung)*

**[`conventions/`](./conventions/)** — Quy ước làm việc
- [`GIT_CONVENTION.md`](./conventions/GIT_CONVENTION.md) — Branch, commit, PR, CI/CD
- [`JIRA_CONVENTION.md`](./conventions/JIRA_CONVENTION.md) — Issue types, workflow, sprint
