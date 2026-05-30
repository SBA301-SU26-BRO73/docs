# Database Schema — BRO73 Court Booking Platform

Data dictionary for the Sprint 0 baseline schema. Target DB: **PostgreSQL 16** (ADR-003).

- **ERD:** [`erd.dbml`](./erd.dbml)
- **Migration:** [`V1__init.sql`](./V1__init.sql) (Flyway baseline)

**Ownership (Sprint 0):** Khoa — `users`, `court_types`, `subscriptions`, `branches`, `courts`,
`time_slot_templates`, `staff`. Minh — `bookings`, `booking_slots`, `slot_holds`, `payments`.

---

## Conventions (apply to every table)

| Rule        | Choice                                                                                                         |
| ----------- | -------------------------------------------------------------------------------------------------------------- |
| Primary key | `id BIGINT GENERATED ALWAYS AS IDENTITY`                                                                       |
| Timestamps  | `created_at`, `updated_at` → `TIMESTAMPTZ NOT NULL DEFAULT now()` (all tables)                                 |
| Auto-update | `updated_at` enforced via DB trigger `update_modified_column()` on every table                                 |
| Soft delete | `deleted_at TIMESTAMPTZ NULL` — `users`, `branches`, `courts`, `time_slot_templates`, `staff`, `subscriptions` |
| Enums       | `VARCHAR` + `CHECK (col IN (...))` (portable, easy to evolve via migration)                                    |
| Money       | `NUMERIC(10,2)` · Time-of-day: `TIME` · Calendar day: `DATE`                                                   |
| FK actions  | `RESTRICT` by default; booking-owned children (`booking_slots`, `payments`) `CASCADE`                          |
| Indexes     | every FK column + frequently-queried fields; partial indexes where soft-delete or boolean flag applies         |

> Columns `id`, `created_at`, `updated_at` are present on every table and omitted from the per-table
> column lists below for brevity. `deleted_at` is listed only where it applies.

---

## Entity-relationship overview

```
users ─1:*─ branches            (admin owns branches)
users ─1:*─ subscriptions        (admin's platform plans)
users ─1:1─ staff                (one STAFF user = one staff record, one branch)
branches ─1:*─ courts
court_types ─1:*─ courts
courts ─1:*─ time_slot_templates
courts ─1:*─ bookings
courts ─1:*─ slot_holds
bookings ─1:*─ booking_slots     (CASCADE)
bookings ─1:1─ payments          (CASCADE)
users ─1:*─ payments             (confirmed_by = admin/staff)
```

Creation order (respects FK dependencies):
`court_types` → `users` → `subscriptions` → `branches` → `courts`
→ `time_slot_templates` → `staff` → `bookings` → `booking_slots` → `slot_holds` → `payments`

---

## Khoa's entities

### `court_types`

Reference catalog of sport/court types (e.g. badminton, pickleball). Super-Admin managed (modules.md 2.7).
No soft delete — it's system reference data.

| Column | Type         | Null | Notes  |
| ------ | ------------ | ---- | ------ |
| name   | VARCHAR(100) | NO   | UNIQUE |

---

### `users`

Registered accounts only — **guests are not stored here** (they book via `bookings.guest_phone`).

| Column        | Type         | Null | Notes                                                              |
| ------------- | ------------ | ---- | ------------------------------------------------------------------ |
| email         | VARCHAR(255) | NO   | UNIQUE                                                             |
| password_hash | VARCHAR(255) | NO   | bcrypt / argon2 hash                                               |
| phone         | VARCHAR(20)  | YES  |                                                                    |
| role          | VARCHAR(20)  | NO   | `CUSTOMER` \| `STAFF` \| `ADMIN` \| `SUPER_ADMIN`                  |
| status        | VARCHAR(20)  | NO   | `PENDING_APPROVAL` (default) \| `ACTIVE` \| `INACTIVE` \| `LOCKED` |
| deleted_at    | TIMESTAMPTZ  | YES  | soft delete                                                        |

**Indexes:** `email` partial (`WHERE deleted_at IS NULL`), `phone`, `role`.

**Notes:** Admin accounts start at `PENDING_APPROVAL` until Super-Admin approves (overview.md onboarding flow).

---

### `subscriptions`

An Admin's platform plan (month/year), priced by court/branch limits.
Soft-deleted when Admin cancels mid-term (preserves history).

| Column       | Type        | Null | Notes                                    |
| ------------ | ----------- | ---- | ---------------------------------------- |
| admin_id     | BIGINT      | NO   | FK → `users.id`                          |
| plan         | VARCHAR(50) | NO   | plan/tier name (e.g. `BASIC`, `PREMIUM`) |
| max_courts   | INT         | NO   | court cap enforced at app layer          |
| max_branches | INT         | NO   | branch cap enforced at app layer         |
| start_date   | DATE        | NO   |                                          |
| end_date     | DATE        | NO   |                                          |
| deleted_at   | TIMESTAMPTZ | YES  | soft delete on cancellation              |

**Indexes:** `admin_id`.

---

### `branches`

A physical location owned by an Admin. Stores the bank account customers transfer to.

| Column              | Type         | Null | Notes                                   |
| ------------------- | ------------ | ---- | --------------------------------------- |
| admin_id            | BIGINT       | NO   | FK → `users.id`                         |
| name                | VARCHAR(150) | NO   |                                         |
| address             | VARCHAR(255) | NO   |                                         |
| city                | VARCHAR(100) | NO   | used for search/filter                  |
| phone               | VARCHAR(20)  | YES  |                                         |
| open_time           | TIME         | NO   |                                         |
| close_time          | TIME         | NO   |                                         |
| bank_account_number | VARCHAR(50)  | YES  |                                         |
| bank_account_name   | VARCHAR(150) | YES  | displayed to customer on payment screen |
| bank_name           | VARCHAR(100) | YES  |                                         |
| status              | VARCHAR(20)  | NO   | `ACTIVE` (default) \| `INACTIVE`        |
| deleted_at          | TIMESTAMPTZ  | YES  | soft delete                             |

**Indexes:** `admin_id`, `city` partial (`WHERE deleted_at IS NULL`).

---

### `courts`

A single court inside a branch.

| Column        | Type         | Null | Notes                                             |
| ------------- | ------------ | ---- | ------------------------------------------------- |
| branch_id     | BIGINT       | NO   | FK → `branches.id`                                |
| name          | VARCHAR(150) | NO   |                                                   |
| court_type_id | BIGINT       | NO   | FK → `court_types.id`                             |
| description   | TEXT         | YES  |                                                   |
| status        | VARCHAR(20)  | NO   | `ACTIVE` (default) \| `INACTIVE` \| `MAINTENANCE` |
| deleted_at    | TIMESTAMPTZ  | YES  | soft delete                                       |

**Indexes:** `branch_id` partial (`WHERE deleted_at IS NULL`), `court_type_id`.

---

### `time_slot_templates`

Recurring 30-min priced slots per court and weekday (basis for generating bookable slots).

`is_active = FALSE` → temporarily locked (maintenance, holiday). `deleted_at` → permanently removed.

| Column      | Type          | Null | Notes                                                  |
| ----------- | ------------- | ---- | ------------------------------------------------------ |
| court_id    | BIGINT        | NO   | FK → `courts.id`                                       |
| start_time  | TIME          | NO   |                                                        |
| end_time    | TIME          | NO   |                                                        |
| price       | NUMERIC(10,2) | NO   | supports peak/off-peak via multiple rows per court/day |
| day_of_week | SMALLINT      | NO   | CHECK 0–6 (0 = Sunday)                                 |
| is_active   | BOOLEAN       | NO   | `TRUE` (default); `FALSE` = temporarily disabled       |
| deleted_at  | TIMESTAMPTZ   | YES  | soft delete                                            |

**Indexes:** `(court_id, day_of_week)` partial (`WHERE is_active = TRUE AND deleted_at IS NULL`).

---

### `staff`

Links a `STAFF` user to the branch they work at. One user = one staff record (enforced by UNIQUE).

| Column     | Type        | Null | Notes                                       |
| ---------- | ----------- | ---- | ------------------------------------------- |
| user_id    | BIGINT      | NO   | FK → `users.id`, **UNIQUE**                 |
| branch_id  | BIGINT      | NO   | FK → `branches.id`                          |
| deleted_at | TIMESTAMPTZ | YES  | soft delete when admin removes staff access |

**Indexes:** `user_id` (unique), `branch_id`.

---

## Minh's entities

### `bookings`

One order = 1+ consecutive slots on one court. Made by a registered customer **or** a guest.

| Column      | Type          | Null | Notes                               |
| ----------- | ------------- | ---- | ----------------------------------- |
| court_id    | BIGINT        | NO   | FK → `courts.id`                    |
| customer_id | BIGINT        | YES  | FK → `users.id`; null for guest     |
| guest_phone | VARCHAR(20)   | YES  | required when `customer_id` is null |
| date        | DATE          | NO   |                                     |
| status      | VARCHAR(25)   | NO   | see status flow below               |
| total_price | NUMERIC(10,2) | NO   | expected total = sum of slot prices |

**Status flow:**

```
PENDING_PAYMENT → AWAITING_CONFIRMATION → CONFIRMED → CHECKED_IN → COMPLETED
                                        ↘ CANCELLED (any stage before check-in)
```

**Constraints:** `CHECK (customer_id IS NOT NULL OR guest_phone IS NOT NULL)`.

**Indexes:** `court_id`, `customer_id`, `(court_id, date)`.

---

### `booking_slots`

The individual 30-min slots that make up a booking.

`price_at_booking` snapshots the price at order time — preserved when admin later changes template prices.

| Column           | Type          | Null | Notes                                                   |
| ---------------- | ------------- | ---- | ------------------------------------------------------- |
| booking_id       | BIGINT        | NO   | FK → `bookings.id`, **ON DELETE CASCADE**               |
| slot_start       | TIME          | NO   |                                                         |
| slot_end         | TIME          | NO   |                                                         |
| price_at_booking | NUMERIC(10,2) | NO   | snapshot of `time_slot_templates.price` at booking time |

**Indexes:** `booking_id`.

---

### `slot_holds`

Temporary 5-minute lock while a customer transfers payment (overview.md line 42).
Rows are cleaned up by a scheduled job querying `expired_at < now()`.

| Column     | Type        | Null | Notes            |
| ---------- | ----------- | ---- | ---------------- |
| court_id   | BIGINT      | NO   | FK → `courts.id` |
| date       | DATE        | NO   |                  |
| slot_start | TIME        | NO   |                  |
| slot_end   | TIME        | NO   |                  |
| expired_at | TIMESTAMPTZ | NO   |                  |

**Indexes:** `(court_id, date, expired_at)` composite.

---

### `payments`

One bank-transfer bill per booking, confirmed by an admin or staff.

`amount` stores what the customer actually transferred — may differ from `bookings.total_price`
(wrong transfer amount, partial payment). Used for reconciliation.

| Column         | Type          | Null | Notes                                                 |
| -------------- | ------------- | ---- | ----------------------------------------------------- |
| booking_id     | BIGINT        | NO   | FK → `bookings.id`, **UNIQUE**, **ON DELETE CASCADE** |
| amount         | NUMERIC(10,2) | NO   | actual transferred amount                             |
| bill_image_url | TEXT          | YES  | S3/Cloudinary URL of uploaded receipt                 |
| status         | VARCHAR(20)   | NO   | `PENDING` (default) \| `CONFIRMED` \| `REJECTED`      |
| confirmed_at   | TIMESTAMPTZ   | YES  | set on confirm or reject                              |
| confirmed_by   | BIGINT        | YES  | FK → `users.id` (admin/staff who acted)               |

**Indexes:** `confirmed_by`. (`booking_id` UNIQUE constraint creates its own index.)
