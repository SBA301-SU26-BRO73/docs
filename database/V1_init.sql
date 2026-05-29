-- Kích hoạt extension để tự động tạo UUID v4 nếu chưa có
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =========================================================================
-- 1. BẢNG USERS & SUBSCRIPTIONS (Khoa)
-- =========================================================================

CREATE TABLE users (
                       id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                       email VARCHAR(255) UNIQUE NOT NULL,
                       password_hash VARCHAR(255) NOT NULL,
                       phone VARCHAR(20),
                       role VARCHAR(50) NOT NULL, -- e.g., 'SUPER_ADMIN', 'ADMIN', 'STAFF', 'CUSTOMER'
                       status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE', -- e.g., 'ACTIVE', 'INACTIVE', 'BANNED'
                       created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                       updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                       deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE subscriptions (
                               id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                               admin_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
                               plan VARCHAR(100) NOT NULL, -- e.g., 'BASIC', 'PREMIUM', 'ENTERPRISE'
                               max_courts INT NOT NULL,
                               max_branches INT NOT NULL,
                               start_date DATE NOT NULL,
                               end_date DATE NOT NULL,
                               created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                               updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                               deleted_at TIMESTAMP WITH TIME ZONE
);

-- =========================================================================
-- 2. BẢNG BRANCHES, COURT_TYPES, COURTS & STAFF (Khoa)
-- =========================================================================

CREATE TABLE branches (
                          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                          admin_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
                          name VARCHAR(255) NOT NULL,
                          address TEXT NOT NULL,
                          city VARCHAR(100) NOT NULL,
                          phone VARCHAR(20),
                          open_time TIME NOT NULL,
                          close_time TIME NOT NULL,
                          bank_account_number VARCHAR(50),
                          bank_name VARCHAR(100),
                          status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
                          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                          updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                          deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE staff (
                       id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                       user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                       branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
                       created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                       updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                       deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE court_types (
                             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                             name VARCHAR(100) NOT NULL, -- e.g., 'Sân Cầu Lông', 'Sân Tennis', 'Sân Bóng Đá 5 Người'
                             created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                             updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE courts (
                        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                        branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE RESTRICT,
                        court_type_id UUID NOT NULL REFERENCES court_types(id) ON DELETE RESTRICT,
                        name VARCHAR(255) NOT NULL,
                        description TEXT,
                        status VARCHAR(50) NOT NULL DEFAULT 'AVAILABLE', -- e.g., 'AVAILABLE', 'MAINTENANCE', 'CLOSED'
                        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                        deleted_at TIMESTAMP WITH TIME ZONE
);

-- =========================================================================
-- 3. BẢNG TIME_SLOT_TEMPLATES, BOOKINGS & SLOT_HOLDS (Minh)
-- =========================================================================

CREATE TABLE time_slot_templates (
                                     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                                     court_id UUID NOT NULL REFERENCES courts(id) ON DELETE CASCADE,
                                     start_time TIME NOT NULL,
                                     end_time TIME NOT NULL,
                                     price DECIMAL(12, 2) NOT NULL, -- Dùng decimal để tránh sai số tiền tệ
                                     day_of_week INT NOT NULL, -- 0: Chủ nhật, 1-6: Thứ 2 đến Thứ 7
                                     is_active BOOLEAN NOT NULL DEFAULT TRUE,
                                     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                     updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                     deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE bookings (
                          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                          court_id UUID NOT NULL REFERENCES courts(id) ON DELETE RESTRICT,
                          customer_id UUID REFERENCES users(id) ON DELETE SET NULL, -- Nullable cho khách vãng lai
                          guest_phone VARCHAR(20), -- Dùng cho khách vãng lai đặt trực tiếp/qua điện thoại
                          date DATE NOT NULL,
                          status VARCHAR(50) NOT NULL DEFAULT 'PENDING', -- e.g., 'PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED'
                          total_price DECIMAL(12, 2) NOT NULL,
                          payment_method VARCHAR(50) NOT NULL, -- e.g., 'BANK_TRANSFER', 'CASH', 'VNPAY'
                          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                          updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE booking_slots (
                               id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                               booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
                               slot_start TIME NOT NULL,
                               slot_end TIME NOT NULL,
                               price_at_booking DECIMAL(12, 2) NOT NULL, -- Lưu giá tại thời điểm đặt để làm lịch sử/đối soát
                               created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                               updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE slot_holds (
                            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                            court_id UUID NOT NULL REFERENCES courts(id) ON DELETE CASCADE,
                            date DATE NOT NULL,
                            slot_start TIME NOT NULL,
                            slot_end TIME NOT NULL,
                            expired_at TIMESTAMP WITH TIME ZONE NOT NULL, -- Thời gian hết hạn giữ slot (ví dụ: +10 phút từ lúc bấm giữ)
                            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                            updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================================
-- 4. BẢNG PAYMENTS (Minh)
-- =========================================================================

CREATE TABLE payments (
                          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                          booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE RESTRICT,
                          amount DECIMAL(12, 2) NOT NULL, -- Số tiền thực tế khách trả/chuyển khoản
                          bill_image_url TEXT, -- Ảnh bill chuyển khoản do khách upload hoặc nhân viên chụp
                          status VARCHAR(50) NOT NULL DEFAULT 'PENDING', -- e.g., 'PENDING', 'SUCCESS', 'FAILED'
                          confirmed_at TIMESTAMP WITH TIME ZONE,
                          confirmed_by UUID REFERENCES users(id) ON DELETE SET NULL, -- Nhân viên duyệt bill
                          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                          updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================================
-- 5. ĐẶT INDEXES TỐI ƯU TRUY VẤN (Tăng hiệu năng hệ thống)
-- =========================================================================

-- Indexes cho Users & Staff
CREATE INDEX idx_users_email ON users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_staff_branch_user ON staff(branch_id, user_id);

-- Indexes phục vụ tìm kiếm Sân và Chi nhánh
CREATE INDEX idx_branches_city ON branches(city) WHERE deleted_at IS NULL;
CREATE INDEX idx_courts_branch_type ON courts(branch_id, court_type_id) WHERE deleted_at IS NULL;

-- Indexes "Kinh điển" phục vụ quét Slot và kiểm tra trùng lịch (Cực kỳ quan trọng khi đặt sân)
CREATE INDEX idx_bookings_court_date ON bookings(court_id, date);
CREATE INDEX idx_booking_slots_booking ON booking_slots(booking_id);
CREATE INDEX idx_slot_holds_court_date ON slot_holds(court_id, date, expired_at);
CREATE INDEX idx_time_slot_templates_court_day ON time_slot_templates(court_id, day_of_week) WHERE is_active = TRUE;

-- Index đối soát hóa đơn
CREATE INDEX idx_payments_booking ON payments(booking_id);

-- =========================================================================
-- 6. TỰ ĐỘNG CẬP NHẬT `updated_at` KHI UPDATE DÒNG
-- =========================================================================

-- Tạo trigger function dùng chung
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Áp dụng trigger tự động update cho các bảng chính
CREATE TRIGGER update_users_modtime BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_subscriptions_modtime BEFORE UPDATE ON subscriptions FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_branches_modtime BEFORE UPDATE ON branches FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_staff_modtime BEFORE UPDATE ON staff FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_courts_modtime BEFORE UPDATE ON courts FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_time_slot_templates_modtime BEFORE UPDATE ON time_slot_templates FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_bookings_modtime BEFORE UPDATE ON bookings FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_booking_slots_modtime BEFORE UPDATE ON booking_slots FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_slot_holds_modtime BEFORE UPDATE ON slot_holds FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_payments_modtime BEFORE UPDATE ON payments FOR EACH ROW EXECUTE FUNCTION update_modified_column();