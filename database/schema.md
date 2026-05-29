# 🏟️ Sports Court Booking System — Database Schema

## 1. Database Overview

### 🛠 Database Technology

* **Database Management System:** PostgreSQL
* **Primary Key Strategy:** UUID v4
* **Timezone Standard:** `TIMESTAMP WITH TIME ZONE (timestamptz)` using UTC
* **Soft Delete Applied:**

    * `users`
    * `branches`
    * `courts`
    * `staff`
    * `subscriptions`

---

# 2. Data Dictionary

---

# 2.1 User & Authorization Entities

## 📌 Table: `users`

Stores all user accounts in the system.

| Field         | Type         | Constraints                       | Description                                 |
| ------------- | ------------ | --------------------------------- | ------------------------------------------- |
| id            | UUID         | PK, Default: `uuid_generate_v4()` | Unique user identifier                      |
| email         | VARCHAR(255) | UNIQUE, NOT NULL                  | Login email                                 |
| password_hash | VARCHAR(255) | NOT NULL                          | Hashed password                             |
| phone         | VARCHAR(20)  | Nullable                          | Contact phone                               |
| role          | VARCHAR(50)  | NOT NULL                          | `SUPER_ADMIN`, `ADMIN`, `STAFF`, `CUSTOMER` |
| status        | VARCHAR(50)  | NOT NULL, Default: `ACTIVE`       | `ACTIVE`, `INACTIVE`, `BANNED`              |
| created_at    | TIMESTAMPTZ  | Default: CURRENT_TIMESTAMP        | Created time                                |
| updated_at    | TIMESTAMPTZ  | Default: CURRENT_TIMESTAMP        | Last updated                                |
| deleted_at    | TIMESTAMPTZ  | Nullable                          | Soft delete timestamp                       |

---

## 📌 Table: `staff`

Maps staff members to branches.

| Field      | Type        | Constraints                       | Description             |
| ---------- | ----------- | --------------------------------- | ----------------------- |
| id         | UUID        | PK, Default: `uuid_generate_v4()` | Unique staff identifier |
| user_id    | UUID        | FK → `users.id`, NOT NULL         | Linked user account     |
| branch_id  | UUID        | FK → `branches.id`, NOT NULL      | Working branch          |
| created_at | TIMESTAMPTZ | Default: CURRENT_TIMESTAMP        | Assignment time         |
| updated_at | TIMESTAMPTZ | Default: CURRENT_TIMESTAMP        | Last updated            |
| deleted_at | TIMESTAMPTZ | Nullable                          | Soft delete timestamp   |

---

# 2.2 Court Operations & Subscription Entities

## 📌 Table: `subscriptions`

Subscription plans purchased by court owners.

| Field        | Type         | Constraints                | Description                      |
| ------------ | ------------ | -------------------------- | -------------------------------- |
| id           | UUID         | PK                         | Subscription identifier          |
| admin_id     | UUID         | FK → `users.id`            | Court owner                      |
| plan         | VARCHAR(100) | NOT NULL                   | `BASIC`, `PREMIUM`, `ENTERPRISE` |
| max_courts   | INT          | NOT NULL                   | Maximum courts                   |
| max_branches | INT          | NOT NULL                   | Maximum branches                 |
| start_date   | DATE         | NOT NULL                   | Activation date                  |
| end_date     | DATE         | NOT NULL                   | Expiration date                  |
| created_at   | TIMESTAMPTZ  | Default: CURRENT_TIMESTAMP | Created time                     |
| updated_at   | TIMESTAMPTZ  | Default: CURRENT_TIMESTAMP | Last updated                     |
| deleted_at   | TIMESTAMPTZ  | Nullable                   | Soft delete timestamp            |

---

## 📌 Table: `branches`

Stores sports facility branch information.

| Field               | Type         | Constraints                 | Description           |
| ------------------- | ------------ | --------------------------- | --------------------- |
| id                  | UUID         | PK                          | Branch identifier     |
| admin_id            | UUID         | FK → `users.id`             | Branch owner/admin    |
| name                | VARCHAR(255) | NOT NULL                    | Branch name           |
| address             | TEXT         | NOT NULL                    | Detailed address      |
| city                | VARCHAR(100) | NOT NULL                    | Province/City         |
| phone               | VARCHAR(20)  | Nullable                    | Hotline               |
| open_time           | TIME         | NOT NULL                    | Opening time          |
| close_time          | TIME         | NOT NULL                    | Closing time          |
| bank_account_number | VARCHAR(50)  | Nullable                    | Bank account          |
| bank_name           | VARCHAR(100) | Nullable                    | Bank name             |
| status              | VARCHAR(50)  | NOT NULL, Default: `ACTIVE` | `ACTIVE`, `INACTIVE`  |
| created_at          | TIMESTAMPTZ  | Default: CURRENT_TIMESTAMP  | Created time          |
| updated_at          | TIMESTAMPTZ  | Default: CURRENT_TIMESTAMP  | Last updated          |
| deleted_at          | TIMESTAMPTZ  | Nullable                    | Soft delete timestamp |

---

## 📌 Table: `court_types`

Defines sports categories.

| Field      | Type         | Constraints                | Description                |
| ---------- | ------------ | -------------------------- | -------------------------- |
| id         | UUID         | PK                         | Court type identifier      |
| name       | VARCHAR(100) | NOT NULL                   | Example: Badminton, Tennis |
| created_at | TIMESTAMPTZ  | Default: CURRENT_TIMESTAMP | Created time               |
| updated_at | TIMESTAMPTZ  | Default: CURRENT_TIMESTAMP | Last updated               |

---

## 📌 Table: `courts`

Stores individual court information.

| Field         | Type         | Constraints                    | Description                          |
| ------------- | ------------ | ------------------------------ | ------------------------------------ |
| id            | UUID         | PK                             | Court identifier                     |
| branch_id     | UUID         | FK → `branches.id`             | Parent branch                        |
| court_type_id | UUID         | FK → `court_types.id`          | Court category                       |
| name          | VARCHAR(255) | NOT NULL                       | Court name/number                    |
| description   | TEXT         | Nullable                       | Additional details                   |
| status        | VARCHAR(50)  | NOT NULL, Default: `AVAILABLE` | `AVAILABLE`, `MAINTENANCE`, `CLOSED` |
| created_at    | TIMESTAMPTZ  | Default: CURRENT_TIMESTAMP     | Created time                         |
| updated_at    | TIMESTAMPTZ  | Default: CURRENT_TIMESTAMP     | Last updated                         |
| deleted_at    | TIMESTAMPTZ  | Nullable                       | Soft delete timestamp                |

---

## 📌 Table: `time_slot_templates`

Default pricing & schedule configuration.

| Field       | Type          | Constraints                | Description                  |
| ----------- | ------------- | -------------------------- | ---------------------------- |
| id          | UUID          | PK                         | Template identifier          |
| court_id    | UUID          | FK → `courts.id`           | Applied court                |
| start_time  | TIME          | NOT NULL                   | Slot start                   |
| end_time    | TIME          | NOT NULL                   | Slot end                     |
| price       | DECIMAL(12,2) | NOT NULL                   | Slot price                   |
| day_of_week | INT           | NOT NULL                   | `0 → Sunday`, `6 → Saturday` |
| is_active   | BOOLEAN       | Default: TRUE              | Active status                |
| created_at  | TIMESTAMPTZ   | Default: CURRENT_TIMESTAMP | Created time                 |
| updated_at  | TIMESTAMPTZ   | Default: CURRENT_TIMESTAMP | Last updated                 |
| deleted_at  | TIMESTAMPTZ   | Nullable                   | Soft delete timestamp        |

---

# 2.3 Booking & Holding Entities

## 📌 Table: `bookings`

Main booking orders.

| Field          | Type          | Constraints                  | Description                                      |
| -------------- | ------------- | ---------------------------- | ------------------------------------------------ |
| id             | UUID          | PK                           | Booking identifier                               |
| court_id       | UUID          | FK → `courts.id`             | Reserved court                                   |
| customer_id    | UUID          | FK → `users.id`              | Registered customer                              |
| guest_phone    | VARCHAR(20)   | Nullable                     | Guest customer phone                             |
| date           | DATE          | NOT NULL                     | Playing date                                     |
| status         | VARCHAR(50)   | NOT NULL, Default: `PENDING` | `PENDING`, `CONFIRMED`, `CANCELLED`, `COMPLETED` |
| total_price    | DECIMAL(12,2) | NOT NULL                     | Total booking amount                             |
| payment_method | VARCHAR(50)   | NOT NULL                     | `BANK_TRANSFER`, `CASH`, `VNPAY`                 |
| created_at     | TIMESTAMPTZ   | Default: CURRENT_TIMESTAMP   | Created time                                     |
| updated_at     | TIMESTAMPTZ   | Default: CURRENT_TIMESTAMP   | Last updated                                     |

---

## 📌 Table: `booking_slots`

Stores detailed booked time slots.

| Field            | Type          | Constraints                | Description             |
| ---------------- | ------------- | -------------------------- | ----------------------- |
| id               | UUID          | PK                         | Booking slot identifier |
| booking_id       | UUID          | FK → `bookings.id`         | Parent booking          |
| slot_start       | TIME          | NOT NULL                   | Slot start              |
| slot_end         | TIME          | NOT NULL                   | Slot end                |
| price_at_booking | DECIMAL(12,2) | NOT NULL                   | Snapshot price          |
| created_at       | TIMESTAMPTZ   | Default: CURRENT_TIMESTAMP | Created time            |
| updated_at       | TIMESTAMPTZ   | Default: CURRENT_TIMESTAMP | Last updated            |

---

## 📌 Table: `slot_holds`

Temporary reservation lock system.

| Field      | Type        | Constraints                | Description             |
| ---------- | ----------- | -------------------------- | ----------------------- |
| id         | UUID        | PK                         | Hold session identifier |
| court_id   | UUID        | FK → `courts.id`           | Reserved court          |
| date       | DATE        | NOT NULL                   | Booking date            |
| slot_start | TIME        | NOT NULL                   | Hold start              |
| slot_end   | TIME        | NOT NULL                   | Hold end                |
| expired_at | TIMESTAMPTZ | NOT NULL                   | Hold expiration         |
| created_at | TIMESTAMPTZ | Default: CURRENT_TIMESTAMP | Created time            |
| updated_at | TIMESTAMPTZ | Default: CURRENT_TIMESTAMP | Last updated            |

---

# 2.4 Transactions & Payments

## 📌 Table: `payments`

Stores payment transaction records.

| Field          | Type          | Constraints                  | Description                    |
| -------------- | ------------- | ---------------------------- | ------------------------------ |
| id             | UUID          | PK                           | Payment identifier             |
| booking_id     | UUID          | FK → `bookings.id`           | Related booking                |
| amount         | DECIMAL(12,2) | NOT NULL                     | Paid amount                    |
| bill_image_url | TEXT          | Nullable                     | Uploaded bill image            |
| status         | VARCHAR(50)   | NOT NULL, Default: `PENDING` | `PENDING`, `SUCCESS`, `FAILED` |
| confirmed_at   | TIMESTAMPTZ   | Nullable                     | Confirmation timestamp         |
| confirmed_by   | UUID          | FK → `users.id`              | Staff/Admin confirmer          |
| created_at     | TIMESTAMPTZ   | Default: CURRENT_TIMESTAMP   | Created time                   |
| updated_at     | TIMESTAMPTZ   | Default: CURRENT_TIMESTAMP   | Last updated                   |

---

# 3. Database Indexing Strategy

Optimized indexes for high-performance booking operations.

---

## ⚡ `idx_users_email`

**Table:** `users`

```sql
(email)
WHERE deleted_at IS NULL
```

Purpose:

* Faster login
* Prevent duplicate active emails

---

## ⚡ `idx_staff_branch_user`

**Table:** `staff`

```sql
(branch_id, user_id)
```

Purpose:

* Fast permission checking within branches

---

## ⚡ `idx_branches_city`

**Table:** `branches`

```sql
(city)
WHERE deleted_at IS NULL
```

Purpose:

* Faster city-based branch filtering

---

## ⚡ `idx_courts_branch_type`

**Table:** `courts`

```sql
(branch_id, court_type_id)
```

Purpose:

* Efficient filtering by branch and court type

---

## ⚡ `idx_bookings_court_date`

**Table:** `bookings`

```sql
(court_id, date)
```

Purpose:

* Critical for booking timeline rendering
* Fast court schedule lookup

---

## ⚡ `idx_time_slot_templates_court_day`

**Table:** `time_slot_templates`

```sql
(court_id, day_of_week)
WHERE is_active = TRUE
```

Purpose:

* Quickly load active pricing templates

---

## ⚡ `idx_slot_holds_court_date`

**Table:** `slot_holds`

```sql
(court_id, date, expired_at)
```

Purpose:

* Prevent overbooking
* Fast active hold-session scanning

---

# ✅ Final Notes

This schema is fully aligned with:

* Multi-branch architecture
* Role-based access control
* Real-time slot locking
* Payment verification workflow
* Scalable SaaS subscription model

Recommended file name:

```bash
README.md
```

or

```bash
schema.md
```
