# Database Schema — BRO73 Court Booking Platform

## Conventions (apply to every table)

| Rule        | Choice                                                                                                         |
| ----------- | -------------------------------------------------------------------------------------------------------------- |
| Primary key | `id BIGINT GENERATED ALWAYS AS IDENTITY`                                                                       |
| Timestamps  | `created_at`, `updated_at` → `TIMESTAMPTZ NOT NULL DEFAULT now()` (all tables)                                 |
| Auto-update | `updated_at` maintained by the application layer                                                               |
| Soft delete | `deleted_at TIMESTAMPTZ NULL` — `users`, `branches`, `courts`, `time_slot_templates`, `staff`, `subscriptions` |
| Enums       | `VARCHAR` + `CHECK (col IN (...))` (portable, easy to evolve via migration)                                    |
| Money       | `NUMERIC(10,2)` · Time-of-day: `TIME` · Calendar day: `DATE`                                                   |
| FK actions  | `RESTRICT` by default; `booking_slots` & `slot_holds.customer_id` `CASCADE`; `bookings.payment_id` `SET NULL`  |

> Columns `id`, `created_at`, `updated_at` are present on every table and omitted from the per-table
> column lists below for brevity. `deleted_at` is listed only where it applies.

---

## Entity-relationship overview

```
users ─1:*─ branches            (admin owns branches)
users ─1:*─ subscriptions        (admin's platform plans)
subscription_plans ─1:*─ subscriptions
users ─1:1─ staff                (one STAFF user = one staff record, one branch)
branches ─1:*─ courts
court_types ─1:*─ courts
courts ─1:*─ time_slot_templates
courts ─1:*─ bookings
courts ─1:*─ slot_holds
bookings ─1:*─ booking_slots     (CASCADE)
payments ─1:*─ bookings          (one payment covers 1+ bookings, all in one branch)
branches ─1:*─ payments          (bank account that received the transfer)
users ─1:*─ payments             (confirmed_by = admin/staff)
```

Creation order (respects FK dependencies):
`court_types` → `subscription_plans` → `users` → `subscriptions` → `branches` → `courts`
→ `time_slot_templates` → `staff` → `payments` → `bookings` → `booking_slots` → `slot_holds`

---

## Khoa's entities

### `court_types`

Reference catalog of sport/court types (e.g. badminton, pickleball). Super-Admin managed (modules.md 2.7).
No soft delete — it's system reference data.

| Column | Type         | Null | Notes  |
| ------ | ------------ | ---- | ------ |
| name   | VARCHAR(100) | NO   | UNIQUE |

---

### `subscription_plans`

Catalog of platform plans an Admin can purchase. Super-Admin managed. No soft delete — set
`is_active = FALSE` to retire a plan while keeping it referenced by existing subscriptions.

| Column        | Type          | Null | Notes                              |
| ------------- | ------------- | ---- | ---------------------------------- |
| name          | VARCHAR(100)  | NO   | UNIQUE (e.g. `BASIC`, `PREMIUM`)   |
| price         | NUMERIC(10,2) | NO   | plan price                         |
| max_courts    | INT           | NO   | court cap granted by the plan      |
| max_branches  | INT           | NO   | branch cap granted by the plan     |
| duration_days | INT           | NO   | billing period length in days      |
| is_active     | BOOLEAN       | NO   | `TRUE` (default); `FALSE` = hidden |

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

**Notes:** Admin accounts start at `PENDING_APPROVAL` until Super-Admin approves (overview.md onboarding flow).

---

### `subscriptions`

An Admin's purchased plan (references `subscription_plans`).
Soft-deleted when Admin cancels mid-term (preserves history).

| Column       | Type        | Null | Notes                                   |
| ------------ | ----------- | ---- | --------------------------------------- |
| admin_id     | BIGINT      | NO   | FK → `users.id`                         |
| plan_id      | BIGINT      | NO   | FK → `subscription_plans.id`            |
| max_courts   | INT         | NO   | snapshot of plan limit at purchase time |
| max_branches | INT         | NO   | snapshot of plan limit at purchase time |
| start_date   | DATE        | NO   |                                         |
| end_date     | DATE        | NO   |                                         |
| deleted_at   | TIMESTAMPTZ | YES  | soft delete on cancellation             |

---

### `branches`

A physical location owned by an Admin. Stores the bank account customers transfer to.

| Column              | Type         | Null | Notes                                   |
| ------------------- | ------------ | ---- | --------------------------------------- |
| admin_id            | BIGINT       | NO   | FK → `users.id`                         |
| name                | VARCHAR(150) | NO   |                                         |
| address             | VARCHAR(255) | NO   |                                         |
| ward                | VARCHAR(100) | YES  | phường/xã                               |
| city                | VARCHAR(100) | NO   | used for search/filter                  |
| phone               | VARCHAR(20)  | YES  |                                         |
| open_time           | TIME         | NO   |                                         |
| close_time          | TIME         | NO   |                                         |
| bank_account_number | VARCHAR(50)  | YES  |                                         |
| bank_account_name   | VARCHAR(150) | YES  | displayed to customer on payment screen |
| bank_name           | VARCHAR(100) | YES  |                                         |
| bank_qr_image_url   | TEXT         | YES  | QR code image for bank transfer         |
| status              | VARCHAR(20)  | NO   | `ACTIVE` (default) \| `INACTIVE`        |
| deleted_at          | TIMESTAMPTZ  | YES  | soft delete                             |

---

### `courts`

A single court inside a branch.

| Column        | Type         | Null | Notes                                             |
| ------------- | ------------ | ---- | ------------------------------------------------- |
| branch_id     | BIGINT       | NO   | FK → `branches.id`                                |
| name          | VARCHAR(150) | NO   |                                                   |
| court_type_id | BIGINT       | NO   | FK → `court_types.id`                             |
| description   | TEXT         | YES  |                                                   |
| image_url     | TEXT         | YES  | court photo URL                                   |
| status        | VARCHAR(20)  | NO   | `ACTIVE` (default) \| `INACTIVE` \| `MAINTENANCE` |
| deleted_at    | TIMESTAMPTZ  | YES  | soft delete                                       |

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

---

### `staff`

Links a `STAFF` user to the branch they work at. One user = one staff record (enforced by UNIQUE).

| Column     | Type        | Null | Notes                                       |
| ---------- | ----------- | ---- | ------------------------------------------- |
| user_id    | BIGINT      | NO   | FK → `users.id`, **UNIQUE**                 |
| branch_id  | BIGINT      | NO   | FK → `branches.id`                          |
| deleted_at | TIMESTAMPTZ | YES  | soft delete when admin removes staff access |

---

## Minh's entities

### `bookings`

One order = 1+ consecutive slots on one court. Made by a registered customer **or** a guest.

| Column      | Type          | Null | Notes                               |
| ----------- | ------------- | ---- | ----------------------------------- |
| court_id    | BIGINT        | NO   | FK → `courts.id`                    |
| customer_id | BIGINT        | YES  | FK → `users.id`; null for guest     |
| payment_id  | BIGINT        | YES  | FK → `payments.id`; null until paid |
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

---

### `booking_slots`

The individual 30-min slots that make up a booking.

`court_id` and `booking_date` are denormalized from the parent booking so one row carries
`(court, date, slot)` — required to enforce no double-booking.

`price_at_booking` snapshots the price at order time — preserved when admin later changes template prices.

| Column           | Type          | Null | Notes                                                   |
| ---------------- | ------------- | ---- | ------------------------------------------------------- |
| booking_id       | BIGINT        | NO   | FK → `bookings.id`, **ON DELETE CASCADE**               |
| court_id         | BIGINT        | NO   | FK → `courts.id` (denormalized from parent booking)     |
| booking_date     | DATE          | NO   | denormalized from parent booking                        |
| slot_start       | TIME          | NO   |                                                         |
| slot_end         | TIME          | NO   |                                                         |
| price_at_booking | NUMERIC(10,2) | NO   | snapshot of `time_slot_templates.price` at booking time |

**Constraints:** `UNIQUE (court_id, booking_date, slot_start)` — hard guard against double-booking.

> Cancelling a booking must **delete** its `booking_slots` rows to free the slot; the `bookings`
> row keeps the order/audit history via its `status`. (Two active bookings can never hold the
> same court + date + slot.)

---

### `slot_holds`

Temporary 5-minute lock while a customer transfers payment (overview.md line 42).
`customer_id` / `guest_phone` identifies the holder (same rule as `bookings`).
Rows are cleaned up by a scheduled job querying `expired_at < now()`.

| Column      | Type        | Null | Notes                               |
| ----------- | ----------- | ---- | ----------------------------------- |
| court_id    | BIGINT      | NO   | FK → `courts.id`                    |
| customer_id | BIGINT      | YES  | FK → `users.id`; null for guest     |
| guest_phone | VARCHAR(20) | YES  | required when `customer_id` is null |
| date        | DATE        | NO   |                                     |
| slot_start  | TIME        | NO   |                                     |
| slot_end    | TIME        | NO   |                                     |
| expired_at  | TIMESTAMPTZ | NO   |                                     |

**Constraints:** `CHECK (customer_id IS NOT NULL OR guest_phone IS NOT NULL)`;
`UNIQUE (court_id, date, slot_start)` — at most one live hold per slot.

> The cleanup job deletes expired holds; the app should also delete an expired hold for a slot
> before re-holding it, otherwise the `UNIQUE` constraint rejects the new hold.

---

### `payments`

One bank-transfer bill covering one or more bookings, confirmed by an admin or staff.
The link lives on the child side: `bookings.payment_id → payments.id` (1 payment : N bookings).

`branch_id` ties the payment to the branch whose bank account received the transfer. A single
transfer goes to one account, so **every booking sharing a payment must belong to a court in that
same branch** — enforced at the application layer (a payment spans only one branch).

`amount` stores what the customer actually transferred — may differ from the total of its bookings
(wrong transfer amount, partial payment). Used for reconciliation.

| Column         | Type          | Null | Notes                                            |
| -------------- | ------------- | ---- | ------------------------------------------------ |
| branch_id      | BIGINT        | NO   | FK → `branches.id` (bank account that was paid)  |
| amount         | NUMERIC(10,2) | NO   | actual transferred amount                        |
| bill_image_url | TEXT          | YES  | S3/Cloudinary URL of uploaded receipt            |
| status         | VARCHAR(20)   | NO   | `PENDING` (default) \| `CONFIRMED` \| `REJECTED` |
| confirmed_at   | TIMESTAMPTZ   | YES  | set on confirm or reject                         |
| confirmed_by   | BIGINT        | YES  | FK → `users.id` (admin/staff who acted)          |
