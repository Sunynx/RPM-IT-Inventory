-- =============================================
-- AssetQR — Complete Database Setup (Unified)
-- Run this SQL in Supabase SQL Editor
-- Last updated: 2026-03-04
-- =============================================

-- ========================================
-- 1. Categories (ประเภทอุปกรณ์)
-- ========================================
CREATE TABLE IF NOT EXISTS categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT DEFAULT 'box',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO categories (name, icon) VALUES
  ('คอมพิวเตอร์ / IT', 'monitor'),
  ('เครื่องพิมพ์', 'printer'),
  ('อุปกรณ์เครือข่าย', 'wifi'),
  ('เฟอร์นิเจอร์', 'armchair'),
  ('เครื่องใช้ไฟฟ้า', 'zap'),
  ('โปรเจคเตอร์', 'projector'),
  ('UPS / ไฟสำรอง', 'battery'),
  ('อื่นๆ', 'package')
ON CONFLICT DO NOTHING;

-- ========================================
-- 2. Departments (แผนก)
-- ========================================
CREATE TABLE IF NOT EXISTS departments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO departments (name) VALUES
  ('IT'), ('Admin'), ('Finance'), ('HR'),
  ('Marketing'), ('Operations'), ('Sales'), ('Management')
ON CONFLICT DO NOTHING;

-- ========================================
-- 3. Assets (อุปกรณ์)
-- ========================================
CREATE TABLE IF NOT EXISTS assets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  asset_code TEXT UNIQUE,
  serial_number TEXT,
  category_id UUID REFERENCES categories(id),
  department_id UUID REFERENCES departments(id),
  location TEXT,
  status TEXT DEFAULT 'ใช้งาน' CHECK (status IN ('ใช้งาน', 'ส่งซ่อม', 'ส่งคืน', 'สำรอง', 'ชำรุด', 'จำหน่าย')),
  purchase_date DATE,
  warranty_expiry DATE,
  supplier TEXT,
  price DECIMAL(12,2),
  notes TEXT,
  thumbnail_url TEXT,

  -- ผู้ใช้และตำแหน่ง
  assigned_user TEXT,
  user_position TEXT,
  signer_name TEXT,
  signer_position TEXT,

  -- ข้อมูลเทคนิคเพิ่มเติม
  model TEXT,
  cpu TEXT,
  ram TEXT,
  storage TEXT,
  gpu TEXT,
  display TEXT,
  os TEXT,
  os_key TEXT,
  ip_address TEXT,
  mac_address TEXT,
  password TEXT,
  po_number TEXT,
  nas_user TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER assets_updated_at
  BEFORE UPDATE ON assets
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ========================================
-- 4. Asset Images (รูปภาพอุปกรณ์)
-- ========================================
CREATE TABLE IF NOT EXISTS asset_images (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
  file_url TEXT NOT NULL,
  file_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- 5. Signatures (ลายเซ็นรับอุปกรณ์)
-- ========================================
CREATE TABLE IF NOT EXISTS signatures (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
  signature_url TEXT NOT NULL,
  signed_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- 6. Repair Tickets (งานซ่อม)
-- ========================================
CREATE TABLE IF NOT EXISTS repair_tickets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  asset_id UUID REFERENCES assets(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'เปิด' CHECK (status IN ('เปิด', 'กำลังดำเนินการ', 'รอะไหล่', 'เสร็จสิ้น', 'ยกเลิก')),
  priority TEXT DEFAULT 'ปกติ' CHECK (priority IN ('ต่ำ', 'ปกติ', 'สูง', 'เร่งด่วน')),
  assigned_to TEXT,
  cost DECIMAL(12,2),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  resolved_at TIMESTAMPTZ
);

-- ========================================
-- 7. Asset Transfers (โอนย้ายทรัพย์สิน)
-- ========================================
CREATE TABLE IF NOT EXISTS asset_transfers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  asset_id UUID REFERENCES assets(id) ON DELETE SET NULL,
  from_department TEXT,
  to_department TEXT,
  from_location TEXT,
  to_location TEXT,
  transfer_date TIMESTAMPTZ DEFAULT NOW(),
  transferred_by TEXT,
  notes TEXT,
  signature_url TEXT
);

-- ========================================
-- 8. Audit Log (ประวัติการแก้ไข)
-- ========================================
CREATE TABLE IF NOT EXISTS audit_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  asset_id UUID REFERENCES assets(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  details TEXT,
  performed_by TEXT DEFAULT 'Admin',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- 9. Settings (ตั้งค่าระบบ)
-- ========================================
CREATE TABLE IF NOT EXISTS settings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  key TEXT UNIQUE NOT NULL,
  value TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO settings (key, value) VALUES
  ('org_name', 'Royal Phuket Marina'),
  ('base_url', ''),
  ('line_token', ''),
  ('smtp_host', ''),
  ('smtp_port', '587'),
  ('smtp_user', ''),
  ('smtp_pass', ''),
  ('notify_email', '')
ON CONFLICT (key) DO NOTHING;

-- ========================================
-- 10. Licenses (จัดการ License)
-- ========================================
CREATE TABLE IF NOT EXISTS licenses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT DEFAULT 'Software' CHECK (type IN ('Software', 'Cloud', 'Hardware', 'Subscription', 'Other')),
  license_key TEXT,
  vendor TEXT,
  start_date DATE,
  expiry_date DATE,
  seats INTEGER,
  assigned_to TEXT,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'expired', 'cancelled')),
  notes TEXT,
  asset_id UUID REFERENCES assets(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TRIGGER licenses_updated_at
  BEFORE UPDATE ON licenses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ========================================
-- 11. Maintenance Schedules (ตาราง PM)
-- ========================================
CREATE TABLE IF NOT EXISTS maintenance_schedules (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  frequency TEXT DEFAULT 'monthly' CHECK (frequency IN ('daily', 'weekly', 'monthly', 'quarterly', 'yearly', 'custom')),
  interval_days INTEGER DEFAULT 30,
  last_performed_at TIMESTAMPTZ,
  next_due_at TIMESTAMPTZ NOT NULL,
  assigned_to TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'overdue', 'cancelled')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TRIGGER maintenance_updated_at
  BEFORE UPDATE ON maintenance_schedules
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ========================================
-- 12. Asset Checkouts (ยืม-คืนอุปกรณ์)
-- ========================================
CREATE TABLE IF NOT EXISTS asset_checkouts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
  checked_out_to TEXT NOT NULL,
  department TEXT,
  checkout_date TIMESTAMPTZ DEFAULT NOW(),
  expected_return_date DATE,
  actual_return_date TIMESTAMPTZ,
  notes TEXT,
  status TEXT DEFAULT 'checked_out' CHECK (status IN ('checked_out', 'returned', 'overdue')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- 13. Notifications (ศูนย์แจ้งเตือน)
-- ========================================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  message TEXT,
  type TEXT DEFAULT 'system' CHECK (type IN ('warranty', 'maintenance', 'checkout', 'ticket', 'system')),
  severity TEXT DEFAULT 'info' CHECK (severity IN ('info', 'warning', 'danger')),
  asset_id UUID REFERENCES assets(id) ON DELETE SET NULL,
  link_page TEXT,
  link_params TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- 14. Indexes
-- ========================================
CREATE INDEX IF NOT EXISTS idx_assets_status ON assets(status);
CREATE INDEX IF NOT EXISTS idx_assets_category ON assets(category_id);
CREATE INDEX IF NOT EXISTS idx_assets_department ON assets(department_id);
CREATE INDEX IF NOT EXISTS idx_assets_code ON assets(asset_code);
CREATE INDEX IF NOT EXISTS idx_asset_images_asset ON asset_images(asset_id);
CREATE INDEX IF NOT EXISTS idx_signatures_asset ON signatures(asset_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_asset ON audit_log(asset_id);
CREATE INDEX IF NOT EXISTS idx_repair_tickets_asset ON repair_tickets(asset_id);
CREATE INDEX IF NOT EXISTS idx_repair_tickets_status ON repair_tickets(status);
CREATE INDEX IF NOT EXISTS idx_licenses_status ON licenses(status);
CREATE INDEX IF NOT EXISTS idx_licenses_expiry ON licenses(expiry_date);
CREATE INDEX IF NOT EXISTS idx_licenses_asset ON licenses(asset_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_asset ON maintenance_schedules(asset_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_status ON maintenance_schedules(status);
CREATE INDEX IF NOT EXISTS idx_maintenance_next_due ON maintenance_schedules(next_due_at);
CREATE INDEX IF NOT EXISTS idx_checkouts_asset ON asset_checkouts(asset_id);
CREATE INDEX IF NOT EXISTS idx_checkouts_status ON asset_checkouts(status);
CREATE INDEX IF NOT EXISTS idx_checkouts_return ON asset_checkouts(expected_return_date);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);
CREATE INDEX IF NOT EXISTS idx_notifications_created ON notifications(created_at DESC);

-- ========================================
-- 15. Storage Buckets
-- (Create manually in Supabase Dashboard > Storage)
-- Bucket: asset-images (public)
-- Bucket: signatures  (public)
-- ========================================

-- ========================================
-- 16. Row Level Security (RLS)
-- ========================================
ALTER TABLE assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE asset_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE signatures ENABLE ROW LEVEL SECURITY;
ALTER TABLE repair_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE asset_transfers ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE licenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE maintenance_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE asset_checkouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Allow all access (internal system, no public users)
CREATE POLICY "Allow all" ON assets FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON categories FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON departments FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON asset_images FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON signatures FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON repair_tickets FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON asset_transfers FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON audit_log FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON settings FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON licenses FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON maintenance_schedules FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON asset_checkouts FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON notifications FOR ALL USING (true) WITH CHECK (true);
