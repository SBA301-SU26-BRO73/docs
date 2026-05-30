-- =====================================================================
-- BRO73 Court Booking Platform — Initial Schema (Flyway baseline)
-- File: V1__init.sql  (target: backend/src/main/resources/db/migration/)
-- Database: PostgreSQL 16  (ADR-003)
--
-- Conventions:
--   * PK            : BIGINT GENERATED ALWAYS AS IDENTITY
--   * Timestamps    : created_at / updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
--   * Soft delete   : deleted_at TIMESTAMPTZ NULL on users, branches, courts,
--                     courts, time_slot_templates, staff, subscriptions
--   * Enums         : VARCHAR + CHECK (portable, Flyway-friendly)
--   * Money         : NUMERIC(10,2)   Time-of-day: TIME   Calendar day: DATE
--   * FK actions    : RESTRICT by default; booking-owned children CASCADE
--   * updated_at    : enforced by DB trigger on every table
--
-- Ownership (Sprint 0):
--   Khoa = users, court_types, subscriptions, branches, courts,
--           time_slot_templates, staff
--   Minh = bookings, booking_slots, slot_holds, payments
-- =====================================================================

-- -----------------------------------------------------------------------
-- Shared trigger function — auto-updates updated_at on every row UPDATE
-- -----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================
-- KHOA'S ENTITIES
-- =====================================================================

-- ---------------------------------------------------------------------
-- court_types  — reference catalog managed by Super Admin, no soft delete
-- ---------------------------------------------------------------------
CREATE TABLE court_types (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_court_types_updated_at
    BEFORE UPDATE ON court_types
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ---------------------------------------------------------------------
-- users  — registered accounts only (guests book via bookings.guest_phone)
-- ---------------------------------------------------------------------
CREATE TABLE users (
    id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email          VARCHAR(255) NOT NULL UNIQUE,
    password_hash  VARCHAR(255) NOT NULL,
    phone          VARCHAR(20),
    role           VARCHAR(20)  NOT NULL
                   CHECK (role IN ('CUSTOMER', 'STAFF', 'ADMIN', 'SUPER_ADMIN')),
    status         VARCHAR(20)  NOT NULL DEFAULT 'PENDING_APPROVAL'
                   CHECK (status IN ('PENDING_APPROVAL', 'ACTIVE', 'INACTIVE', 'LOCKED')),
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
    deleted_at     TIMESTAMPTZ
);

-- Partial index covers the hot path (login, lookup) — skips deleted rows
CREATE INDEX idx_users_email_active ON users (email)  WHERE deleted_at IS NULL;
CREATE INDEX idx_users_phone        ON users (phone);
CREATE INDEX idx_users_role         ON users (role);

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ---------------------------------------------------------------------
-- subscriptions  — Admin's platform plan; soft-deleted on cancellation
-- ---------------------------------------------------------------------
CREATE TABLE subscriptions (
    id            BIGINT      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    admin_id      BIGINT      NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    plan          VARCHAR(50) NOT NULL,
    max_courts    INT         NOT NULL,
    max_branches  INT         NOT NULL,
    start_date    DATE        NOT NULL,
    end_date      DATE        NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at    TIMESTAMPTZ
);

CREATE INDEX idx_subscriptions_admin_id ON subscriptions (admin_id);

CREATE TRIGGER trg_subscriptions_updated_at
    BEFORE UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ---------------------------------------------------------------------
-- branches  — physical location owned by an Admin; holds bank account
-- ---------------------------------------------------------------------
CREATE TABLE branches (
    id                   BIGINT       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    admin_id             BIGINT       NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    name                 VARCHAR(150) NOT NULL,
    address              VARCHAR(255) NOT NULL,
    city                 VARCHAR(100) NOT NULL,
    phone                VARCHAR(20),
    open_time            TIME         NOT NULL,
    close_time           TIME         NOT NULL,
    bank_account_number  VARCHAR(50),
    bank_account_name    VARCHAR(150),
    bank_name            VARCHAR(100),
    status               VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE'
                         CHECK (status IN ('ACTIVE', 'INACTIVE')),
    created_at           TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at           TIMESTAMPTZ  NOT NULL DEFAULT now(),
    deleted_at           TIMESTAMPTZ
);

CREATE INDEX idx_branches_admin_id    ON branches (admin_id);
CREATE INDEX idx_branches_city_active ON branches (city) WHERE deleted_at IS NULL;

CREATE TRIGGER trg_branches_updated_at
    BEFORE UPDATE ON branches
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ---------------------------------------------------------------------
-- courts  — a single court inside a branch
-- ---------------------------------------------------------------------
CREATE TABLE courts (
    id             BIGINT       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    branch_id      BIGINT       NOT NULL REFERENCES branches    (id) ON DELETE RESTRICT,
    name           VARCHAR(150) NOT NULL,
    court_type_id  BIGINT       NOT NULL REFERENCES court_types (id) ON DELETE RESTRICT,
    description    TEXT,
    status         VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE'
                   CHECK (status IN ('ACTIVE', 'INACTIVE', 'MAINTENANCE')),
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
    deleted_at     TIMESTAMPTZ
);

CREATE INDEX idx_courts_branch_active ON courts (branch_id)     WHERE deleted_at IS NULL;
CREATE INDEX idx_courts_court_type    ON courts (court_type_id);

CREATE TRIGGER trg_courts_updated_at
    BEFORE UPDATE ON courts
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ---------------------------------------------------------------------
-- time_slot_templates  — recurring 30-min priced slots per court & weekday
-- is_active : temporarily disable a slot (maintenance, holiday)
-- deleted_at: permanently remove the template
-- ---------------------------------------------------------------------
CREATE TABLE time_slot_templates (
    id           BIGINT        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    court_id     BIGINT        NOT NULL REFERENCES courts (id) ON DELETE RESTRICT,
    start_time   TIME          NOT NULL,
    end_time     TIME          NOT NULL,
    price        NUMERIC(10,2) NOT NULL,
    day_of_week  SMALLINT      NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    is_active    BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ   NOT NULL DEFAULT now(),
    deleted_at   TIMESTAMPTZ
);

-- Hot path: generate available slots for a given court + day
CREATE INDEX idx_time_slot_templates_court_dow
    ON time_slot_templates (court_id, day_of_week)
    WHERE is_active = TRUE AND deleted_at IS NULL;

CREATE TRIGGER trg_time_slot_templates_updated_at
    BEFORE UPDATE ON time_slot_templates
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ---------------------------------------------------------------------
-- staff  — links a STAFF user to the branch they work at
-- ---------------------------------------------------------------------
CREATE TABLE staff (
    id          BIGINT      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id     BIGINT      NOT NULL UNIQUE REFERENCES users    (id) ON DELETE RESTRICT,
    branch_id   BIGINT      NOT NULL        REFERENCES branches (id) ON DELETE RESTRICT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at  TIMESTAMPTZ
);

CREATE INDEX idx_staff_branch_id ON staff (branch_id);

CREATE TRIGGER trg_staff_updated_at
    BEFORE UPDATE ON staff
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- =====================================================================
-- MINH'S ENTITIES
-- =====================================================================

-- ---------------------------------------------------------------------
-- bookings  — one order = 1+ consecutive slots on one court
-- customer_id OR guest_phone must be set (never both null)
-- ---------------------------------------------------------------------
CREATE TABLE bookings (
    id           BIGINT        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    court_id     BIGINT        NOT NULL REFERENCES courts (id) ON DELETE RESTRICT,
    customer_id  BIGINT        REFERENCES users (id) ON DELETE RESTRICT,
    guest_phone  VARCHAR(20),
    date         DATE          NOT NULL,
    status       VARCHAR(25)   NOT NULL DEFAULT 'PENDING_PAYMENT'
                 CHECK (status IN ('PENDING_PAYMENT', 'AWAITING_CONFIRMATION',
                                   'CONFIRMED', 'CHECKED_IN', 'COMPLETED', 'CANCELLED')),
    total_price  NUMERIC(10,2) NOT NULL,
    created_at   TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ   NOT NULL DEFAULT now(),
    CONSTRAINT chk_bookings_customer_or_guest
        CHECK (customer_id IS NOT NULL OR guest_phone IS NOT NULL)
);

CREATE INDEX idx_bookings_court_id    ON bookings (court_id);
CREATE INDEX idx_bookings_customer_id ON bookings (customer_id);
CREATE INDEX idx_bookings_court_date  ON bookings (court_id, date);

CREATE TRIGGER trg_bookings_updated_at
    BEFORE UPDATE ON bookings
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ---------------------------------------------------------------------
-- booking_slots  — individual 30-min slots in a booking
-- price_at_booking: snapshot of price when booked — preserves history
--   when admin later changes template prices
-- ---------------------------------------------------------------------
CREATE TABLE booking_slots (
    id               BIGINT        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    booking_id       BIGINT        NOT NULL REFERENCES bookings (id) ON DELETE CASCADE,
    slot_start       TIME          NOT NULL,
    slot_end         TIME          NOT NULL,
    price_at_booking NUMERIC(10,2) NOT NULL,
    created_at       TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE INDEX idx_booking_slots_booking_id ON booking_slots (booking_id);

CREATE TRIGGER trg_booking_slots_updated_at
    BEFORE UPDATE ON booking_slots
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ---------------------------------------------------------------------
-- slot_holds  — temporary 5-min lock while customer transfers payment
-- ---------------------------------------------------------------------
CREATE TABLE slot_holds (
    id          BIGINT      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    court_id    BIGINT      NOT NULL REFERENCES courts (id) ON DELETE RESTRICT,
    date        DATE        NOT NULL,
    slot_start  TIME        NOT NULL,
    slot_end    TIME        NOT NULL,
    expired_at  TIMESTAMPTZ NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Composite covers "find active holds for court on date" + expired_at for cleanup job
CREATE INDEX idx_slot_holds_court_date_exp ON slot_holds (court_id, date, expired_at);

CREATE TRIGGER trg_slot_holds_updated_at
    BEFORE UPDATE ON slot_holds
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ---------------------------------------------------------------------
-- payments  — one bank-transfer record per booking, confirmed by admin/staff
-- amount    : actual amount transferred (may differ from booking.total_price
--             e.g. customer transferred wrong amount — useful for reconciliation)
-- ---------------------------------------------------------------------
CREATE TABLE payments (
    id             BIGINT        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    booking_id     BIGINT        NOT NULL UNIQUE REFERENCES bookings (id) ON DELETE CASCADE,
    amount         NUMERIC(10,2) NOT NULL,
    bill_image_url TEXT,
    status         VARCHAR(20)   NOT NULL DEFAULT 'PENDING'
                   CHECK (status IN ('PENDING', 'CONFIRMED', 'REJECTED')),
    confirmed_at   TIMESTAMPTZ,
    confirmed_by   BIGINT        REFERENCES users (id) ON DELETE RESTRICT,
    created_at     TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ   NOT NULL DEFAULT now()
);

-- booking_id UNIQUE constraint already creates an index; only need confirmed_by
CREATE INDEX idx_payments_confirmed_by ON payments (confirmed_by);

CREATE TRIGGER trg_payments_updated_at
    BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();
