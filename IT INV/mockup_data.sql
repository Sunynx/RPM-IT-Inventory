-- =============================================
-- AssetQR — Comprehensive Mock Data
-- Run in Supabase SQL Editor
-- Cleans ALL data and inserts fresh mock data
-- =============================================

-- ========== ADD NEW COLUMNS (safe idempotent) ==========
ALTER TABLE assets ADD COLUMN IF NOT EXISTS model TEXT;
ALTER TABLE assets ADD COLUMN IF NOT EXISTS cpu TEXT;
ALTER TABLE assets ADD COLUMN IF NOT EXISTS ram TEXT;
ALTER TABLE assets ADD COLUMN IF NOT EXISTS storage TEXT;
ALTER TABLE assets ADD COLUMN IF NOT EXISTS gpu TEXT;
ALTER TABLE assets ADD COLUMN IF NOT EXISTS display TEXT;
ALTER TABLE assets ADD COLUMN IF NOT EXISTS os TEXT;
ALTER TABLE assets ADD COLUMN IF NOT EXISTS os_key TEXT;
ALTER TABLE assets ADD COLUMN IF NOT EXISTS ip_address TEXT;
ALTER TABLE assets ADD COLUMN IF NOT EXISTS mac_address TEXT;
ALTER TABLE assets ADD COLUMN IF NOT EXISTS password TEXT;
ALTER TABLE assets ADD COLUMN IF NOT EXISTS po_number TEXT;
ALTER TABLE assets ADD COLUMN IF NOT EXISTS assigned_user TEXT;
ALTER TABLE assets ADD COLUMN IF NOT EXISTS user_position TEXT;
ALTER TABLE assets ADD COLUMN IF NOT EXISTS nas_user TEXT;

-- Simplify signatures (remove NOT NULL on signer_name)
ALTER TABLE signatures ALTER COLUMN signer_name DROP NOT NULL;
ALTER TABLE signatures ALTER COLUMN signer_name SET DEFAULT null;

-- ========== CLEAN ALL DATA ==========
TRUNCATE notifications CASCADE;
TRUNCATE asset_checkouts CASCADE;
TRUNCATE maintenance_schedules CASCADE;
TRUNCATE audit_log CASCADE;
TRUNCATE asset_transfers CASCADE;
TRUNCATE repair_tickets CASCADE;
TRUNCATE signatures CASCADE;
TRUNCATE asset_images CASCADE;
TRUNCATE licenses CASCADE;
TRUNCATE assets CASCADE;
TRUNCATE categories CASCADE;
TRUNCATE departments CASCADE;
-- Keep settings intact

-- ========== 1. CATEGORIES ==========
INSERT INTO categories (id, name, icon) VALUES
  ('c0000001-0000-0000-0000-000000000001', 'คอมพิวเตอร์ / IT', 'monitor'),
  ('c0000001-0000-0000-0000-000000000002', 'เครื่องพิมพ์', 'printer'),
  ('c0000001-0000-0000-0000-000000000003', 'อุปกรณ์เครือข่าย', 'wifi'),
  ('c0000001-0000-0000-0000-000000000004', 'เฟอร์นิเจอร์', 'armchair'),
  ('c0000001-0000-0000-0000-000000000005', 'เครื่องใช้ไฟฟ้า', 'zap'),
  ('c0000001-0000-0000-0000-000000000006', 'โปรเจคเตอร์', 'projector'),
  ('c0000001-0000-0000-0000-000000000007', 'UPS / ไฟสำรอง', 'battery'),
  ('c0000001-0000-0000-0000-000000000008', 'อื่นๆ', 'package');

-- ========== 2. DEPARTMENTS ==========
INSERT INTO departments (id, name) VALUES
  ('d0000001-0000-0000-0000-000000000001', 'IT'),
  ('d0000001-0000-0000-0000-000000000002', 'Admin'),
  ('d0000001-0000-0000-0000-000000000003', 'Finance'),
  ('d0000001-0000-0000-0000-000000000004', 'HR'),
  ('d0000001-0000-0000-0000-000000000005', 'Marketing'),
  ('d0000001-0000-0000-0000-000000000006', 'Operations'),
  ('d0000001-0000-0000-0000-000000000007', 'Sales'),
  ('d0000001-0000-0000-0000-000000000008', 'Management');

-- ========== 3. ASSETS (20 items — diverse statuses + specs) ==========
INSERT INTO assets (id, name, asset_code, serial_number, category_id, department_id, location, status, purchase_date, warranty_expiry, supplier, price, notes,
  model, cpu, ram, storage, gpu, display, os, os_key, ip_address, mac_address, password, po_number) VALUES

-- Active assets
('a0000001-0000-0000-0000-000000000001', 'MacBook Pro 16" M3 Max', 'IT-2024-001', 'C02ZR1234567',
  'c0000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000001', 'ชั้น 3 ห้อง IT', 'ใช้งาน',
  '2024-03-15', '2027-03-15', 'Apple Thailand', 129900.00, 'เครื่องหลัก Dev Team',
  'MacBook Pro 16-inch (2024)', 'Apple M3 Max 14-core', '64 GB Unified', '1 TB SSD', 'Apple M3 Max 30-core GPU', '16.2" Liquid Retina XDR (3456x2234)', 'macOS Sonoma 14', null, '192.168.1.101', 'A4:83:E7:2F:00:01', null, 'PO-2024-0015'),

('a0000001-0000-0000-0000-000000000002', 'Dell Monitor U2723QE 27"', 'IT-2024-002', 'MON-DELL-78901',
  'c0000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000001', 'ชั้น 3 ห้อง IT', 'ใช้งาน',
  '2024-04-01', '2027-04-01', 'Dell Technologies', 18900.00, '4K UHD IPS USB-C Hub',
  'U2723QE UltraSharp', null, null, null, null, '27" 4K UHD IPS (3840x2160)', null, null, null, null, null, 'PO-2024-0018'),

('a0000001-0000-0000-0000-000000000003', 'HP Laptop ProBook 450 G10', 'IT-2024-003', 'HP-PB450-23456',
  'c0000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000003', 'ชั้น 2 แผนกการเงิน', 'ใช้งาน',
  '2024-02-20', '2027-02-20', 'HP Inc.', 32500.00, 'เครื่องแผนกการเงิน',
  'ProBook 450 G10', 'Intel Core i7-1355U', '16 GB DDR4', '512 GB NVMe SSD', 'Intel Iris Xe Graphics', '15.6" FHD IPS (1920x1080)', 'Windows 11 Pro', 'XXXXX-XXXXX-XXXXX-XXXXX-HP450', '192.168.1.120', 'D4:5D:64:3A:00:03', 'Fin@2024!', 'PO-2024-0010'),

('a0000001-0000-0000-0000-000000000004', 'Canon imageCLASS MF645Cx', 'IT-2024-004', 'CAN-MF645-34567',
  'c0000001-0000-0000-0000-000000000002', 'd0000001-0000-0000-0000-000000000002', 'ชั้น 1 ห้อง Admin', 'ใช้งาน',
  '2024-01-10', '2026-01-10', 'Canon Marketing Thailand', 15900.00, 'Laser Color MFP',
  'imageCLASS MF645Cx', null, null, null, null, null, null, null, '192.168.1.200', '00:1E:8F:5C:00:04', 'admin/canon2024', 'PO-2024-0005'),

('a0000001-0000-0000-0000-000000000005', 'Cisco Switch SG350-28P', 'NET-2024-001', 'CSC-SG350-56789',
  'c0000001-0000-0000-0000-000000000003', 'd0000001-0000-0000-0000-000000000001', 'ห้อง Server Room', 'ใช้งาน',
  '2024-06-15', '2029-06-15', 'Cisco Systems', 45000.00, 'PoE+ 28 Ports Managed',
  'SG350-28P-K9', null, null, null, null, null, 'Firmware 2.5.9', null, '192.168.1.1', '00:23:EA:7B:00:05', 'admin/Cisco@Sw1tch', 'PO-2024-0030'),

('a0000001-0000-0000-0000-000000000006', 'Lenovo ThinkPad X1 Carbon Gen 11', 'IT-2024-005', 'LEN-X1C-67890',
  'c0000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000005', 'ชั้น 4 Marketing', 'ใช้งาน',
  '2024-05-01', '2027-05-01', 'Lenovo Thailand', 55900.00, 'ผู้จัดการ Marketing',
  'ThinkPad X1 Carbon Gen 11 (21HM)', 'Intel Core i7-1365U', '32 GB LPDDR5', '1 TB PCIe Gen4 SSD', 'Intel Iris Xe Graphics', '14" 2.8K OLED (2880x1800)', 'Windows 11 Pro', 'XXXXX-XXXXX-XXXXX-XXXXX-X1C11', '192.168.1.140', 'B0:68:E6:9F:00:06', null, 'PO-2024-0022'),

('a0000001-0000-0000-0000-000000000007', 'Epson EB-FH52 Projector', 'PRJ-2024-001', 'EPS-FH52-12345',
  'c0000001-0000-0000-0000-000000000006', 'd0000001-0000-0000-0000-000000000008', 'ห้องประชุมใหญ่ ชั้น 5', 'ใช้งาน',
  '2024-03-01', '2026-06-01', 'Epson Thailand', 28500.00, '4000 Lumens / Full HD',
  'EB-FH52', null, null, null, null, 'Full HD 1080p (1920x1080)', null, null, '192.168.1.210', null, null, 'PO-2024-0012'),

('a0000001-0000-0000-0000-000000000008', 'APC Smart-UPS 1500VA', 'UPS-2024-001', 'APC-SUA1500-45678',
  'c0000001-0000-0000-0000-000000000007', 'd0000001-0000-0000-0000-000000000001', 'ห้อง Server Room', 'ใช้งาน',
  '2023-12-01', '2026-12-01', 'APC by Schneider', 19500.00, 'Line Interactive / LCD',
  'SMT1500IC', null, null, null, null, null, null, null, '192.168.1.5', null, null, 'PO-2023-0045'),

-- Warranty expiring soon (within 30 days)
('a0000001-0000-0000-0000-000000000009', 'Samsung Galaxy Tab S9', 'IT-2024-006', 'SAM-TAB-S9-11111',
  'c0000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000007', 'ชั้น 2 Sales', 'ใช้งาน',
  '2023-04-01', '2026-04-01', 'Samsung Thailand', 25900.00, 'Sales team ใช้นำเสนอ',
  'Galaxy Tab S9 (SM-X710)', 'Qualcomm Snapdragon 8 Gen 2', '8 GB', '128 GB', 'Adreno 740', '11" Dynamic AMOLED 2X (2560x1600)', 'Android 14 / One UI 6', null, null, 'DC:44:27:8A:00:09', null, 'PO-2023-0020'),

('a0000001-0000-0000-0000-000000000010', 'HP LaserJet Pro M404dn', 'IT-2024-007', 'HP-LJ404-22222',
  'c0000001-0000-0000-0000-000000000002', 'd0000001-0000-0000-0000-000000000004', 'ชั้น 2 HR', 'ใช้งาน',
  '2023-03-20', '2026-03-20', 'HP Inc.', 9900.00, 'Mono Laser Duplex',
  'LaserJet Pro M404dn (W1A53A)', null, null, null, null, null, null, null, '192.168.1.201', '3C:2A:F4:1E:00:10', 'admin/hp2023', 'PO-2023-0015'),

-- Sending for repair
('a0000001-0000-0000-0000-000000000011', 'Dell Latitude 5540', 'IT-2023-011', 'DELL-LAT5540-33333',
  'c0000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000006', 'ชั้น 1 Operations', 'ส่งซ่อม',
  '2023-07-01', '2026-07-01', 'Dell Technologies', 38900.00, 'แบตเสื่อม ส่งเคลม',
  'Latitude 5540', 'Intel Core i5-1345U', '16 GB DDR4', '256 GB SSD', 'Intel Iris Xe Graphics', '15.6" FHD (1920x1080)', 'Windows 11 Pro', 'XXXXX-XXXXX-XXXXX-XXXXX-D5540', '192.168.1.160', '54:BF:64:2C:00:11', 'Ops@Dell23', 'PO-2023-0032'),

('a0000001-0000-0000-0000-000000000012', 'Brother MFC-L2750DW', 'IT-2023-012', 'BRO-MFC-44444',
  'c0000001-0000-0000-0000-000000000002', 'd0000001-0000-0000-0000-000000000003', 'ชั้น 2 Finance', 'ส่งซ่อม',
  '2023-05-15', '2025-05-15', 'Brother Thailand', 12500.00, 'ดรัมเสีย รอเปลี่ยน',
  'MFC-L2750DW', null, null, null, null, null, null, null, '192.168.1.202', '00:80:77:3D:00:12', null, 'PO-2023-0025'),

-- Spare
('a0000001-0000-0000-0000-000000000013', 'Logitech MX Keys Mini', 'ACC-2024-001', 'LOG-MXK-55555',
  'c0000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000001', 'ห้องเก็บของ IT', 'สำรอง',
  '2024-01-15', '2026-01-15', 'Logitech', 3490.00, 'Wireless Keyboard TH/EN',
  'MX Keys Mini (920-010506)', null, null, null, null, null, null, null, null, 'E8:61:1F:AA:00:13', null, 'PO-2024-0008'),

('a0000001-0000-0000-0000-000000000014', 'Logitech MX Master 3S', 'ACC-2024-002', 'LOG-MXM3-66666',
  'c0000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000001', 'ห้องเก็บของ IT', 'สำรอง',
  '2024-01-15', '2026-01-15', 'Logitech', 3290.00, 'Ergonomic Mouse',
  'MX Master 3S (910-006561)', null, null, null, null, null, null, null, null, 'E8:61:1F:BB:00:14', null, 'PO-2024-0008'),

-- Returned / Damaged / Disposed
('a0000001-0000-0000-0000-000000000015', 'ASUS ROG Strix G15', 'IT-2022-015', 'ASUS-ROG-77777',
  'c0000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000005', 'คืนคลัง IT', 'ส่งคืน',
  '2022-01-01', '2025-01-01', 'ASUS Thailand', 42900.00, 'พนักงานลาออก ส่งคืน',
  'ROG Strix G15 G513RC', 'AMD Ryzen 7 6800H', '16 GB DDR5', '512 GB NVMe SSD', 'NVIDIA RTX 3050 4GB', '15.6" FHD 144Hz IPS', 'Windows 11 Home', 'XXXXX-XXXXX-XXXXX-XXXXX-ROG15', null, 'FC:34:97:5E:00:15', null, 'PO-2022-0003'),

('a0000001-0000-0000-0000-000000000016', 'HP EliteBook 840 G7', 'IT-2021-016', 'HP-EB840-88888',
  'c0000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000002', 'ชั้น 1 Admin', 'ชำรุด',
  '2021-06-01', '2024-06-01', 'HP Inc.', 35000.00, 'จอแตก ซ่อมไม่คุ้ม',
  'EliteBook 840 G7 (1J6A5EA)', 'Intel Core i5-10210U', '8 GB DDR4', '256 GB SSD', 'Intel UHD 620', '14" FHD (1920x1080)', 'Windows 10 Pro', null, null, '80:CE:62:4F:00:16', null, 'PO-2021-0022'),

('a0000001-0000-0000-0000-000000000017', 'Epson L3210 Printer', 'IT-2020-017', 'EPS-L3210-99999',
  'c0000001-0000-0000-0000-000000000002', 'd0000001-0000-0000-0000-000000000006', '-', 'จำหน่าย',
  '2020-03-01', '2022-03-01', 'Epson Thailand', 4990.00, 'หมดอายุใช้งาน จำหน่ายแล้ว',
  'L3210 EcoTank', null, null, null, null, null, null, null, null, null, null, 'PO-2020-0010'),

-- More active
('a0000001-0000-0000-0000-000000000018', 'Ubiquiti UniFi AP U6-Pro', 'NET-2024-002', 'UBI-U6P-11111',
  'c0000001-0000-0000-0000-000000000003', 'd0000001-0000-0000-0000-000000000001', 'ชั้น 3 Lobby', 'ใช้งาน',
  '2024-07-01', '2027-07-01', 'Ubiquiti Thailand', 8500.00, 'WiFi 6E Access Point',
  'U6-Pro (U6-Pro-US)', null, null, null, null, null, 'Firmware 6.6.55', null, '192.168.1.10', '24:5A:4C:1D:00:18', 'admin/ubnt2024', 'PO-2024-0035'),

('a0000001-0000-0000-0000-000000000019', 'โต๊ะทำงานปรับระดับ FlexiSpot E7', 'FUR-2024-001', 'FLEX-E7-22222',
  'c0000001-0000-0000-0000-000000000004', 'd0000001-0000-0000-0000-000000000001', 'ชั้น 3 ห้อง IT', 'ใช้งาน',
  '2024-08-01', '2029-08-01', 'FlexiSpot', 16900.00, 'Standing Desk 140x70cm',
  'E7 (Black Frame)', null, null, null, null, null, null, null, null, null, null, 'PO-2024-0040'),

('a0000001-0000-0000-0000-000000000020', 'Daikin FTKM12SV2S แอร์', 'ELC-2024-001', 'DAI-FTKM12-33333',
  'c0000001-0000-0000-0000-000000000005', 'd0000001-0000-0000-0000-000000000008', 'ห้องประชุมใหญ่ ชั้น 5', 'ใช้งาน',
  '2024-02-01', '2029-02-01', 'Daikin Thailand', 32000.00, 'Inverter 12000 BTU',
  'FTKM12SV2S / RKM12SV2S', null, null, null, null, null, null, null, null, null, null, 'PO-2024-0009');

-- ========== 3B. UPDATE assigned_user / user_position / nas_user ==========
UPDATE assets SET assigned_user = 'คุณปัญญา ศรีโสภา',  user_position = 'Senior Developer',          nas_user = 'panya.s'    WHERE id = 'a0000001-0000-0000-0000-000000000001';
UPDATE assets SET assigned_user = 'คุณปัญญา ศรีโสภา',  user_position = 'Senior Developer',          nas_user = 'panya.s'    WHERE id = 'a0000001-0000-0000-0000-000000000002';
UPDATE assets SET assigned_user = 'คุณแก้ว สุคนธ์',     user_position = 'เจ้าหน้าที่การเงิน',        nas_user = 'kaew.s'     WHERE id = 'a0000001-0000-0000-0000-000000000003';
UPDATE assets SET assigned_user = null,                  user_position = null,                         nas_user = null          WHERE id = 'a0000001-0000-0000-0000-000000000004';
UPDATE assets SET assigned_user = null,                  user_position = null,                         nas_user = null          WHERE id = 'a0000001-0000-0000-0000-000000000005';
UPDATE assets SET assigned_user = 'คุณอรุณ รุ่งเรือง',  user_position = 'ผู้จัดการฝ่าย Marketing',    nas_user = 'arun.r'     WHERE id = 'a0000001-0000-0000-0000-000000000006';
UPDATE assets SET assigned_user = null,                  user_position = null,                         nas_user = null          WHERE id = 'a0000001-0000-0000-0000-000000000007';
UPDATE assets SET assigned_user = null,                  user_position = null,                         nas_user = null          WHERE id = 'a0000001-0000-0000-0000-000000000008';
UPDATE assets SET assigned_user = 'คุณสมชาย วิทยา',     user_position = 'เจ้าหน้าที่ขาย',            nas_user = 'somchai.w'  WHERE id = 'a0000001-0000-0000-0000-000000000009';
UPDATE assets SET assigned_user = null,                  user_position = null,                         nas_user = null          WHERE id = 'a0000001-0000-0000-0000-000000000010';
UPDATE assets SET assigned_user = 'คุณวีระ มานะ',       user_position = 'หัวหน้าฝ่าย Operations',    nas_user = 'weera.m'    WHERE id = 'a0000001-0000-0000-0000-000000000011';
UPDATE assets SET assigned_user = null,                  user_position = null,                         nas_user = null          WHERE id = 'a0000001-0000-0000-0000-000000000012';
UPDATE assets SET assigned_user = null,                  user_position = null,                         nas_user = null          WHERE id = 'a0000001-0000-0000-0000-000000000013';
UPDATE assets SET assigned_user = null,                  user_position = null,                         nas_user = null          WHERE id = 'a0000001-0000-0000-0000-000000000014';
UPDATE assets SET assigned_user = 'คุณธนกร ประเสริฐ',   user_position = 'Graphic Designer',           nas_user = 'thanakorn.p' WHERE id = 'a0000001-0000-0000-0000-000000000015';
UPDATE assets SET assigned_user = 'คุณนิชา เจริญสุข',   user_position = 'เจ้าหน้าที่ธุรการ',          nas_user = 'nicha.j'    WHERE id = 'a0000001-0000-0000-0000-000000000016';
UPDATE assets SET assigned_user = null,                  user_position = null,                         nas_user = null          WHERE id = 'a0000001-0000-0000-0000-000000000017';
UPDATE assets SET assigned_user = null,                  user_position = null,                         nas_user = null          WHERE id = 'a0000001-0000-0000-0000-000000000018';
UPDATE assets SET assigned_user = 'คุณพิชิต สมบูรณ์',   user_position = 'System Admin',               nas_user = 'pichit.s'   WHERE id = 'a0000001-0000-0000-0000-000000000019';
UPDATE assets SET assigned_user = null,                  user_position = null,                         nas_user = null          WHERE id = 'a0000001-0000-0000-0000-000000000020';

-- ========== 4. REPAIR TICKETS (5 — mixed status) ==========
INSERT INTO repair_tickets (asset_id, title, description, status, priority, assigned_to, cost) VALUES
  ('a0000001-0000-0000-0000-000000000011', 'แบตเตอรี่เสื่อม ส่งเคลม Dell', 'แบตชาร์จไม่เข้า อายุเครื่อง 1 ปี ยังอยู่ในประกัน', 'กำลังดำเนินการ', 'สูง', 'ช่าง Dell', 0.00),
  ('a0000001-0000-0000-0000-000000000012', 'ดรัมเครื่อง Brother เสีย', 'พิมพ์ออกมามีเส้นดำ ต้องเปลี่ยนดรัม', 'รอะไหล่', 'ปกติ', 'ช่างภายนอก', 3200.00),
  ('a0000001-0000-0000-0000-000000000016', 'จอ HP EliteBook แตก', 'จอแตกจากการตกพื้น ราคาซ่อมสูงกว่าค่าเครื่อง', 'เสร็จสิ้น', 'ต่ำ', 'Admin', 0.00),
  ('a0000001-0000-0000-0000-000000000007', 'โปรเจคเตอร์ภาพมัว', 'ภาพเริ่มมัวเวลาฉาย ลองทำความสะอาดเลนส์แล้วไม่ดีขึ้น', 'เปิด', 'ปกติ', 'ทีม IT', null),
  ('a0000001-0000-0000-0000-000000000008', 'UPS แจ้งเตือน Battery Low', 'UPS ส่งเสียงเตือน battery low ทุก 10 นาที', 'เปิด', 'เร่งด่วน', 'ทีม IT', null);

-- ========== 5. ASSET TRANSFERS (3) ==========
INSERT INTO asset_transfers (asset_id, from_department, to_department, from_location, to_location, transferred_by, notes, transfer_date) VALUES
  ('a0000001-0000-0000-0000-000000000006', 'IT', 'Marketing', 'ชั้น 3 ห้อง IT', 'ชั้น 4 Marketing', 'Admin', 'โอนย้ายให้ทีม Marketing ใช้งาน', NOW() - INTERVAL '30 days'),
  ('a0000001-0000-0000-0000-000000000003', 'HR', 'Finance', 'ชั้น 2 HR', 'ชั้น 2 แผนกการเงิน', 'Admin', 'ย้ายเครื่องตามพนักงานย้ายแผนก', NOW() - INTERVAL '15 days'),
  ('a0000001-0000-0000-0000-000000000015', 'Marketing', 'IT', 'ชั้น 4 Marketing', 'คืนคลัง IT', 'Admin', 'พนักงานลาออก คืนเครื่อง', NOW() - INTERVAL '7 days');

-- ========== 6. LICENSES (6) ==========
INSERT INTO licenses (name, type, license_key, vendor, start_date, expiry_date, seats, assigned_to, status, notes, asset_id) VALUES
  ('Microsoft 365 Business Premium', 'Cloud', 'M365-BP-XXXX-YYYY-ZZZZ', 'Microsoft', '2024-01-01', '2025-12-31', 50, 'ทุกแผนก', 'active', 'Annual Subscription', null),
  ('Adobe Creative Cloud', 'Cloud', 'ADCC-XXXX-YYYY-ZZZZ', 'Adobe', '2024-06-01', '2025-06-01', 5, 'Marketing', 'active', 'All Apps Plan', null),
  ('AutoCAD 2024', 'Software', 'ACAD-2024-XXXX-YYYY', 'Autodesk', '2024-01-01', '2025-01-01', 2, 'Operations', 'active', 'LT Version', null),
  ('Kaspersky Endpoint Security', 'Software', 'KES-XXXX-YYYY-ZZZZ', 'Kaspersky', '2024-03-01', '2026-03-15', 30, 'IT', 'active', 'Endpoint Protection', null),
  ('Zoom Business', 'Cloud', 'ZOOM-BIZ-XXXX', 'Zoom', '2024-01-01', '2025-01-01', 20, 'ทุกแผนก', 'active', 'Max 300 participants', null),
  ('Windows Server 2022 Standard', 'Software', 'WS2022-STD-XXXX-YYYY', 'Microsoft', '2023-06-01', null, 1, 'IT', 'active', 'Perpetual License', null);

-- ========== 7. AUDIT LOG (recent activity) ==========
INSERT INTO audit_log (asset_id, action, details, performed_by, created_at) VALUES
  ('a0000001-0000-0000-0000-000000000001', 'เพิ่มอุปกรณ์', 'MacBook Pro 16" M3 Max', 'Admin', NOW() - INTERVAL '60 days'),
  ('a0000001-0000-0000-0000-000000000002', 'เพิ่มอุปกรณ์', 'Dell Monitor U2723QE', 'Admin', NOW() - INTERVAL '55 days'),
  ('a0000001-0000-0000-0000-000000000006', 'โอนย้ายอุปกรณ์', 'จาก IT ไป Marketing', 'Admin', NOW() - INTERVAL '30 days'),
  ('a0000001-0000-0000-0000-000000000011', 'สร้างงานซ่อม', 'แบตเตอรี่เสื่อม ส่งเคลม Dell', 'Admin', NOW() - INTERVAL '14 days'),
  ('a0000001-0000-0000-0000-000000000012', 'สร้างงานซ่อม', 'ดรัมเครื่อง Brother เสีย', 'Admin', NOW() - INTERVAL '10 days'),
  ('a0000001-0000-0000-0000-000000000003', 'โอนย้ายอุปกรณ์', 'จาก HR ไป Finance', 'Admin', NOW() - INTERVAL '15 days'),
  ('a0000001-0000-0000-0000-000000000015', 'โอนย้ายอุปกรณ์', 'จาก Marketing ไป IT (คืน)', 'Admin', NOW() - INTERVAL '7 days'),
  ('a0000001-0000-0000-0000-000000000018', 'เพิ่มอุปกรณ์', 'Ubiquiti UniFi AP U6-Pro', 'Admin', NOW() - INTERVAL '5 days'),
  ('a0000001-0000-0000-0000-000000000019', 'เพิ่มอุปกรณ์', 'โต๊ะ FlexiSpot E7', 'Admin', NOW() - INTERVAL '3 days'),
  ('a0000001-0000-0000-0000-000000000020', 'เพิ่มอุปกรณ์', 'แอร์ Daikin Inverter', 'Admin', NOW() - INTERVAL '1 day');

-- ========== 8. MAINTENANCE SCHEDULES (8 — mixed states) ==========
INSERT INTO maintenance_schedules (asset_id, title, description, frequency, interval_days, last_performed_at, next_due_at, assigned_to, status) VALUES

-- Overdue PM
('a0000001-0000-0000-0000-000000000005', 'ตรวจสอบ Switch Port & LED', 'ตรวจสอบสถานะ LED ทุก port และทดสอบ throughput', 'monthly', 30, NOW() - INTERVAL '45 days', NOW() - INTERVAL '15 days', 'ทีม IT', 'pending'),
('a0000001-0000-0000-0000-000000000020', 'ล้างแอร์ประจำไตรมาส', 'ล้างฟิลเตอร์ เช็คน้ำยา ทดสอบอุณหภูมิ', 'quarterly', 90, NOW() - INTERVAL '100 days', NOW() - INTERVAL '10 days', 'ช่างแอร์ภายนอก', 'pending'),

-- Due within 7 days
('a0000001-0000-0000-0000-000000000008', 'เช็คสถานะแบตเตอรี่ UPS', 'ตรวจสอบ battery health, runtime test, ทำความสะอาด', 'monthly', 30, NOW() - INTERVAL '27 days', NOW() + INTERVAL '3 days', 'ทีม IT', 'pending'),

-- Normal pending (future)
('a0000001-0000-0000-0000-000000000001', 'ทำความสะอาดเครื่อง MacBook', 'เป่าฝุ่น ทำความสะอาดหน้าจอ คีย์บอร์ด พัดลม', 'quarterly', 90, NOW() - INTERVAL '30 days', NOW() + INTERVAL '60 days', 'ทีม IT', 'pending'),
('a0000001-0000-0000-0000-000000000004', 'เปลี่ยนหมึก Canon MF645', 'เช็คระดับหมึก CMYK เปลี่ยนตลับที่หมด', 'monthly', 30, NOW() - INTERVAL '10 days', NOW() + INTERVAL '20 days', 'Admin', 'pending'),
('a0000001-0000-0000-0000-000000000018', 'อัปเดต Firmware UniFi AP', 'อัปเดต firmware ล่าสุด ตรวจสอบ coverage range', 'quarterly', 90, NOW() - INTERVAL '5 days', NOW() + INTERVAL '85 days', 'ทีม IT', 'pending'),
('a0000001-0000-0000-0000-000000000007', 'เปลี่ยนหลอดโปรเจคเตอร์', 'ตรวจสอบชั่วโมงใช้งานหลอด เปลี่ยนเมื่อเกิน 3000 hrs', 'yearly', 365, NOW() - INTERVAL '200 days', NOW() + INTERVAL '165 days', 'ช่างภายนอก', 'pending'),
('a0000001-0000-0000-0000-000000000019', 'ตรวจสอบมอเตอร์โต๊ะปรับระดับ', 'ทดสอบมอเตอร์ ปรับระดับขึ้นลง หล่อลื่น', 'yearly', 365, null, NOW() + INTERVAL '300 days', 'ทีม IT', 'pending');

-- ========== 9. ASSET CHECKOUTS (8 — mixed states) ==========
INSERT INTO asset_checkouts (asset_id, checked_out_to, department, checkout_date, expected_return_date, actual_return_date, notes, status) VALUES

-- Currently checked out (normal)
('a0000001-0000-0000-0000-000000000009', 'คุณสมชาย วิทยา', 'Sales', NOW() - INTERVAL '3 days', (NOW() + INTERVAL '11 days')::date, null, 'ยืมไปนำเสนอลูกค้า', 'checked_out'),
('a0000001-0000-0000-0000-000000000013', 'คุณนิชา เจริญสุข', 'Marketing', NOW() - INTERVAL '2 days', (NOW() + INTERVAL '5 days')::date, null, 'ใช้แทนคีย์บอร์ดเสีย', 'checked_out'),
('a0000001-0000-0000-0000-000000000014', 'คุณพิชิต สมบูรณ์', 'IT', NOW() - INTERVAL '1 day', (NOW() + INTERVAL '6 days')::date, null, 'ยืม mouse ไป WFH', 'checked_out'),

-- Overdue
('a0000001-0000-0000-0000-000000000007', 'คุณวิภา แก้วมณี', 'Management', NOW() - INTERVAL '20 days', (NOW() - INTERVAL '6 days')::date, null, 'ยืมโปรเจคเตอร์ไปงาน Seminar', 'checked_out'),
('a0000001-0000-0000-0000-000000000002', 'คุณธนกร ประเสริฐ', 'Finance', NOW() - INTERVAL '15 days', (NOW() - INTERVAL '1 day')::date, null, 'ยืมจอ Dell ไปใช้ชั่วคราว', 'checked_out'),

-- Already returned
('a0000001-0000-0000-0000-000000000006', 'คุณอรุณ รุ่งเรือง', 'Marketing', NOW() - INTERVAL '30 days', (NOW() - INTERVAL '16 days')::date, NOW() - INTERVAL '17 days', 'ยืม laptop ไปถ่ายภาพงาน Event', 'returned'),
('a0000001-0000-0000-0000-000000000001', 'คุณปัญญา ศรีโสภา', 'IT', NOW() - INTERVAL '14 days', (NOW() - INTERVAL '7 days')::date, NOW() - INTERVAL '8 days', 'ยืม MacBook ไป Setup ระบบ', 'returned'),
('a0000001-0000-0000-0000-000000000003', 'คุณแก้ว สุคนธ์', 'HR', NOW() - INTERVAL '25 days', (NOW() - INTERVAL '20 days')::date, NOW() - INTERVAL '21 days', 'ยืม laptop ทำรายงานประจำปี', 'returned');

-- ========== 10. NOTIFICATIONS (12 — mixed types) ==========
INSERT INTO notifications (title, message, type, severity, asset_id, link_page, is_read, created_at) VALUES

-- Unread notifications
('PM ถึงกำหนด: ตรวจสอบ Switch Port', 'Cisco Switch SG350-28P เลยกำหนด PM 15 วัน', 'maintenance', 'danger', 'a0000001-0000-0000-0000-000000000005', 'maintenance', false, NOW() - INTERVAL '2 hours'),
('อุปกรณ์ค้างคืน: โปรเจคเตอร์', 'คุณวิภา แก้วมณี ยืมเกินกำหนด 6 วัน', 'checkout', 'danger', 'a0000001-0000-0000-0000-000000000007', 'checkouts', false, NOW() - INTERVAL '4 hours'),
('PM ถึงกำหนด: ล้างแอร์', 'แอร์ Daikin ห้องประชุมเลยกำหนดล้าง 10 วัน', 'maintenance', 'warning', 'a0000001-0000-0000-0000-000000000020', 'maintenance', false, NOW() - INTERVAL '6 hours'),
('ยืมอุปกรณ์: Samsung Tab S9', 'คุณสมชาย วิทยา ยืม Tab ไปนำเสนอ', 'checkout', 'info', 'a0000001-0000-0000-0000-000000000009', 'checkouts', false, NOW() - INTERVAL '3 days'),
('ประกันใกล้หมด: Canon MF645', 'เหลือ 30 วัน', 'warranty', 'warning', 'a0000001-0000-0000-0000-000000000004', 'warranty', false, NOW() - INTERVAL '5 days'),
('Ticket ใหม่: UPS Battery Low', 'UPS ห้อง Server แจ้งเตือน battery low', 'ticket', 'danger', 'a0000001-0000-0000-0000-000000000008', 'tickets', false, NOW() - INTERVAL '1 day'),

-- Read notifications
('PM ใหม่: ทำความสะอาด MacBook', 'กำหนดถัดไป 60 วัน', 'maintenance', 'info', 'a0000001-0000-0000-0000-000000000001', 'maintenance', true, NOW() - INTERVAL '10 days'),
('คืนอุปกรณ์: Lenovo ThinkPad', 'คุณอรุณ คืน laptop เรียบร้อย', 'checkout', 'info', 'a0000001-0000-0000-0000-000000000006', 'checkouts', true, NOW() - INTERVAL '17 days'),
('คืนอุปกรณ์: MacBook Pro', 'คุณปัญญา คืน MacBook เรียบร้อย', 'checkout', 'info', 'a0000001-0000-0000-0000-000000000001', 'checkouts', true, NOW() - INTERVAL '8 days'),
('Ticket เสร็จ: จอ HP EliteBook', 'ปิดงานซ่อม จอแตก ซ่อมไม่คุ้ม', 'ticket', 'info', 'a0000001-0000-0000-0000-000000000016', 'tickets', true, NOW() - INTERVAL '20 days'),
('โอนย้าย: ThinkPad ไป Marketing', 'โอน Lenovo ThinkPad X1 จาก IT ไป Marketing', 'system', 'info', 'a0000001-0000-0000-0000-000000000006', 'assets', true, NOW() - INTERVAL '30 days'),
('ระบบ: นำเข้า 5 รายการ', 'นำเข้าอุปกรณ์สำเร็จจาก CSV', 'system', 'info', null, 'assets', true, NOW() - INTERVAL '45 days');
