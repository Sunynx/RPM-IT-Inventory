-- =============================================
-- AssetQR — Comprehensive Mockup Data (Extended Edition)
-- Run this SQL in Supabase SQL Editor AFTER running setup.sql
-- Contains ~30 assets across all categories and rich relational data
-- =============================================

DO $$ 
DECLARE 
    -- Categories
    cat_it UUID;
    cat_printer UUID;
    cat_network UUID;
    cat_furniture UUID;
    cat_electrical UUID;
    cat_projector UUID;
    cat_ups UUID;
    cat_other UUID;
    
    -- Departments
    dept_it UUID;
    dept_admin UUID;
    dept_hr UUID;
    dept_sales UUID;
    dept_marketing UUID;
    dept_finance UUID;
    dept_ops UUID;
    dept_mgmt UUID;

    -- Asset IDs
    a1 UUID := gen_random_uuid(); a2 UUID := gen_random_uuid(); a3 UUID := gen_random_uuid();
    a4 UUID := gen_random_uuid(); a5 UUID := gen_random_uuid(); a6 UUID := gen_random_uuid();
    a7 UUID := gen_random_uuid(); a8 UUID := gen_random_uuid(); a9 UUID := gen_random_uuid();
    a10 UUID := gen_random_uuid(); a11 UUID := gen_random_uuid(); a12 UUID := gen_random_uuid();
    a13 UUID := gen_random_uuid(); a14 UUID := gen_random_uuid(); a15 UUID := gen_random_uuid();
    a16 UUID := gen_random_uuid(); a17 UUID := gen_random_uuid(); a18 UUID := gen_random_uuid();
    a19 UUID := gen_random_uuid(); a20 UUID := gen_random_uuid(); a21 UUID := gen_random_uuid();
    a22 UUID := gen_random_uuid(); a23 UUID := gen_random_uuid(); a24 UUID := gen_random_uuid();
    a25 UUID := gen_random_uuid(); a26 UUID := gen_random_uuid(); a27 UUID := gen_random_uuid();
    a28 UUID := gen_random_uuid(); a29 UUID := gen_random_uuid(); a30 UUID := gen_random_uuid();

BEGIN
    -- 1. Fetch Category IDs
    SELECT id INTO cat_it FROM categories WHERE name = 'คอมพิวเตอร์ / IT' LIMIT 1;
    SELECT id INTO cat_printer FROM categories WHERE name = 'เครื่องพิมพ์' LIMIT 1;
    SELECT id INTO cat_network FROM categories WHERE name = 'อุปกรณ์เครือข่าย' LIMIT 1;
    SELECT id INTO cat_furniture FROM categories WHERE name = 'เฟอร์นิเจอร์' LIMIT 1;
    SELECT id INTO cat_electrical FROM categories WHERE name = 'เครื่องใช้ไฟฟ้า' LIMIT 1;
    SELECT id INTO cat_projector FROM categories WHERE name = 'โปรเจคเตอร์' LIMIT 1;
    SELECT id INTO cat_ups FROM categories WHERE name = 'UPS / ไฟสำรอง' LIMIT 1;
    SELECT id INTO cat_other FROM categories WHERE name = 'อื่นๆ' LIMIT 1;

    -- 2. Fetch Department IDs
    SELECT id INTO dept_it FROM departments WHERE name = 'IT' LIMIT 1;
    SELECT id INTO dept_admin FROM departments WHERE name = 'Admin' LIMIT 1;
    SELECT id INTO dept_hr FROM departments WHERE name = 'HR' LIMIT 1;
    SELECT id INTO dept_sales FROM departments WHERE name = 'Sales' LIMIT 1;
    SELECT id INTO dept_marketing FROM departments WHERE name = 'Marketing' LIMIT 1;
    SELECT id INTO dept_finance FROM departments WHERE name = 'Finance' LIMIT 1;
    SELECT id INTO dept_ops FROM departments WHERE name = 'Operations' LIMIT 1;
    SELECT id INTO dept_mgmt FROM departments WHERE name = 'Management' LIMIT 1;

    -- 3. Insert Assets (30 รายการ ครอบคลุมทุกสถานะและแผนก)
    INSERT INTO assets (id, name, asset_code, serial_number, category_id, department_id, location, status, purchase_date, warranty_expiry, supplier, price, notes, thumbnail_url, assigned_user, user_position, model, cpu, ram, storage, gpu, display, os, ip_address, mac_address)
    VALUES 
    -- IT Equipment (Laptops, Desktops)
    (a1, 'MacBook Pro 16" M3 Max', 'IT-NB-2024-001', 'C02ABCDEF1', cat_it, dept_it, 'IT Room 1', 'ใช้งาน', CURRENT_DATE - INTERVAL '60 days', CURRENT_DATE + INTERVAL '1035 days', 'Apple Store TH', 129900.00, 'เครื่องสำหรับ Lead Developer', 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400&q=80', 'สมชาย ใจดี', 'Lead Developer', 'MacBook Pro 16-inch 2023', 'Apple M3 Max', '64GB', '2TB SSD', '40-core GPU', '16.2" Liquid Retina XDR', 'macOS Sonoma', '192.168.1.101', '00:1B:44:11:3A:B7'),
    (a2, 'Dell XPS 15', 'IT-NB-2024-002', 'DXPS15-9988', cat_it, dept_sales, 'Sales Floor FL.2', 'ใช้งาน', CURRENT_DATE - INTERVAL '150 days', CURRENT_DATE + INTERVAL '215 days', 'Dell Thailand', 75000.00, 'เครื่องนำเสนองาน', 'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=400&q=80', 'สมหญิง รักงาน', 'Sales Manager', 'XPS 15 9530', 'Intel Core i9-13900H', '32GB', '1TB NVMe', 'RTX 4070 8GB', '15.6" OLED 3.5K', 'Windows 11 Pro', '192.168.1.105', 'A1:B2:C3:D4:E5:F6'),
    (a3, 'Lenovo ThinkPad X1 Carbon', 'IT-NB-2023-010', 'TPX1-2023-A', cat_it, dept_mgmt, 'Executive Office', 'ใช้งาน', CURRENT_DATE - INTERVAL '300 days', CURRENT_DATE + INTERVAL '65 days', 'Lenovo TH', 65000.00, 'เครื่องผู้บริหาร', 'https://images.unsplash.com/photo-1629131726692-1accd0c53ce0?w=400&q=80', 'วิชัย บริหาร', 'CEO', 'Gen 11', 'Intel Core i7-1355U', '16GB', '512GB SSD', 'Iris Xe', '14" WUXGA', 'Windows 11 Pro', '192.168.1.20', 'C1:D2:E3:F4:00:11'),
    (a4, 'HP EliteBook 840 G9', 'IT-NB-2023-015', 'HPEB-0015', cat_it, dept_finance, 'Finance Room 4', 'ส่งซ่อม', CURRENT_DATE - INTERVAL '180 days', CURRENT_DATE + INTERVAL '185 days', 'HP Official', 42000.00, 'แบตเตอรี่บวม', 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=400&q=80', 'ปราณี เงินทอง', 'Senior Accountant', '840 G9', 'Intel Core i5-1235U', '16GB', '512GB SSD', 'Intel Iris Xe', '14" FHD', 'Windows 11 Pro', '192.168.1.130', '00:11:22:33:44:55'),
    (a5, 'Asus ROG Strix G16', 'IT-NB-2024-005', 'ROG-G16-999', cat_it, dept_marketing, 'Marketing Zone', 'ใช้งาน', CURRENT_DATE - INTERVAL '30 days', CURRENT_DATE + INTERVAL '335 days', 'JIB', 55900.00, 'ตัดต่อวิดีโอ', 'https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=400&q=80', 'เอกชัย มีศิลป์', 'Video Editor', 'G614JV', 'Intel Core i7-13650HX', '32GB', '1TB SSD', 'RTX 4060', '16" QHD+ 240Hz', 'Windows 11 Home', '192.168.1.155', 'AA:BB:CC:11:22:33'),
    (a6, 'iMac 24" M3', 'IT-DT-2024-001', 'IMAC-M3-001', cat_it, dept_admin, 'Reception', 'ใช้งาน', CURRENT_DATE - INTERVAL '10 days', CURRENT_DATE + INTERVAL '355 days', 'Apple Store TH', 52900.00, 'เครื่องต้อนรับลูกค้า', 'https://images.unsplash.com/photo-1622737133809-d95047b9e673?w=400&q=80', 'นันทิดา รับแขก', 'Receptionist', 'iMac M3 2023', 'Apple M3', '16GB', '512GB SSD', '10-core GPU', '24" 4.5K Retina', 'macOS Sonoma', '192.168.1.11', '11:22:33:AA:BB:CC'),
    (a7, 'Dell OptiPlex 7000', 'IT-DT-2022-045', 'DOPT-7000-X', cat_it, dept_ops, 'Ops Control Room', 'ใช้งาน', CURRENT_DATE - INTERVAL '600 days', CURRENT_DATE - INTERVAL '235 days', 'Dell Thailand', 28000.00, 'หมดประกันแล้ว ยังใช้งานได้ดี', 'https://images.unsplash.com/photo-1547082299-de196ea013d6?w=400&q=80', 'สมศักดิ์ คุมเครื่อง', 'Ops Staff', 'OptiPlex 7000 Micro', 'Intel Core i5-12500T', '16GB', '256GB SSD', 'Intel UHD', 'None', 'Windows 10 Pro', '192.168.1.200', 'EE:FF:00:11:22:33'),
    (a8, 'iPad Pro 11" M2', 'IT-TB-2023-001', 'IPAD-PRO-99', cat_it, dept_mgmt, 'Executive Office', 'ใช้งาน', CURRENT_DATE - INTERVAL '200 days', CURRENT_DATE + INTERVAL '165 days', 'Apple Store TH', 32900.00, 'ใช้จดรายงานและประชุม', 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400&q=80', 'วิชัย บริหาร', 'CEO', 'iPad Pro 11-inch (4th Gen)', 'Apple M2', '8GB', '256GB', '10-core GPU', '11" Liquid Retina', 'iPadOS 17', '192.168.1.21', 'A1:B2:C3:D4:E5:F6'),

    -- Printers
    (a9, 'HP LaserJet Pro M404dn', 'PR-001', 'VNB321654', cat_printer, dept_admin, 'Admin Shared Area', 'ใช้งาน', CURRENT_DATE - INTERVAL '400 days', CURRENT_DATE - INTERVAL '35 days', 'Advice', 8500.00, 'เครื่องพิมพ์ขาวดำกลาง', 'https://images.unsplash.com/photo-1612815154858-60aa4c59eaa6?w=400&q=80', NULL, NULL, 'M404dn', NULL, NULL, NULL, NULL, NULL, NULL, '192.168.1.250', '00:11:22:AA:BB:CC'),
    (a10, 'Epson L3250 EcoTank', 'PR-002', 'EP-L3250-11', cat_printer, dept_hr, 'HR Office', 'ส่งซ่อม', CURRENT_DATE - INTERVAL '150 days', CURRENT_DATE + INTERVAL '215 days', 'IT City', 4500.00, 'หมึกไม่ออก สีเพี้ยน', 'https://plus.unsplash.com/premium_photo-1683288176579-2dfca1ee8132?w=400&q=80', NULL, NULL, 'L3250', NULL, NULL, NULL, NULL, NULL, NULL, '192.168.1.251', '11:22:33:BB:CC:DD'),
    (a11, 'Brother HL-L3270CDW', 'PR-003', 'BR-HL-999', cat_printer, dept_sales, 'Sales Floor FL.2', 'ใช้งาน', CURRENT_DATE - INTERVAL '50 days', CURRENT_DATE + INTERVAL '315 days', 'JIB', 9900.00, 'เครื่องพิมพ์สีเลเซอร์', 'https://images.unsplash.com/photo-1628186173070-5bfa178eada6?w=400&q=80', NULL, NULL, 'HL-L3270CDW', NULL, NULL, NULL, NULL, NULL, NULL, '192.168.1.252', '22:33:44:CC:DD:EE'),
    (a12, 'Canon imageRUNNER 2625i', 'PR-004', 'CN-IR-2625', cat_printer, dept_ops, 'Copy Room', 'ใช้งาน', CURRENT_DATE - INTERVAL '800 days', CURRENT_DATE - INTERVAL '435 days', 'Ricoh TH', 45000.00, 'เครื่องถ่ายเอกสารส่วนกลาง สัญญาเช่ารายปี', 'https://images.unsplash.com/photo-1541560052-77ec1bbc09f7?w=400&q=80', NULL, NULL, 'iR 2625i', NULL, NULL, NULL, NULL, NULL, NULL, '192.168.1.253', '33:44:55:DD:EE:FF'),

    -- Network Equipment
    (a13, 'Cisco Catalyst 9300', 'NW-SW-001', 'C9300-1122', cat_network, dept_it, 'Server Room (Rack A)', 'ใช้งาน', CURRENT_DATE - INTERVAL '400 days', CURRENT_DATE + INTERVAL '1425 days', 'Cisco Systems', 150000.00, 'Core Switch', 'https://plus.unsplash.com/premium_photo-1678565202188-f69b2e593998?w=400&q=80', NULL, NULL, 'C9300-48P', NULL, NULL, NULL, NULL, NULL, 'Cisco IOS XE', '192.168.0.1', '11:22:33:44:55:66'),
    (a14, 'Ubiquiti UniFi UAP-AC-Pro', 'NW-AP-001', 'UBNT-AP-01', cat_network, dept_it, 'Ceiling FL.1', 'ใช้งาน', CURRENT_DATE - INTERVAL '200 days', CURRENT_DATE + INTERVAL '165 days', 'Ubiquiti TH', 5500.00, 'Access Point ชั้น 1', 'https://images.unsplash.com/photo-1558236714-d0a63aa1db15?w=400&q=80', NULL, NULL, 'UAP-AC-Pro', NULL, NULL, NULL, NULL, NULL, 'UniFi OS', '192.168.0.10', 'AA:BB:CC:11:22:33'),
    (a15, 'Ubiquiti UniFi UAP-AC-Pro', 'NW-AP-002', 'UBNT-AP-02', cat_network, dept_it, 'Ceiling FL.2', 'ใช้งาน', CURRENT_DATE - INTERVAL '200 days', CURRENT_DATE + INTERVAL '165 days', 'Ubiquiti TH', 5500.00, 'Access Point ชั้น 2', 'https://images.unsplash.com/photo-1558236714-d0a63aa1db15?w=400&q=80', NULL, NULL, 'UAP-AC-Pro', NULL, NULL, NULL, NULL, NULL, 'UniFi OS', '192.168.0.11', 'AA:BB:CC:11:22:44'),
    (a16, 'FortiGate 60F', 'NW-FW-001', 'FG60F-9999', cat_network, dept_it, 'Server Room (Rack A)', 'ใช้งาน', CURRENT_DATE - INTERVAL '100 days', CURRENT_DATE + INTERVAL '265 days', 'Fortinet Partner', 35000.00, 'Firewall หลัก', 'https://images.unsplash.com/photo-1551717757-bb6d0c64ee39?w=400&q=80', NULL, NULL, 'FG-60F', NULL, NULL, NULL, NULL, NULL, 'FortiOS 7.2', '192.168.0.254', 'FF:EE:DD:CC:BB:AA'),

    -- Furniture
    (a17, 'Herman Miller Aeron', 'FN-CH-001', 'HM-A-001', cat_furniture, dept_mgmt, 'Executive Office', 'ใช้งาน', CURRENT_DATE - INTERVAL '100 days', CURRENT_DATE + INTERVAL '4280 days', 'Herman Miller TH', 45000.00, 'เก้าอี้ผู้บริหารระดับสูง', 'https://images.unsplash.com/photo-1505843490538-5133c6c7d0e1?w=400&q=80', 'วิชัย บริหาร', 'CEO', 'Aeron Size B', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    (a18, 'IKEA MARKUS', 'FN-CH-002', 'IK-MK-001', cat_furniture, dept_it, 'IT Room 1', 'ใช้งาน', CURRENT_DATE - INTERVAL '500 days', CURRENT_DATE + INTERVAL '3600 days', 'IKEA Bangna', 5990.00, 'เก้าอี้พนักงาน IT', 'https://images.unsplash.com/photo-1505843513577-22bb7d21e455?w=400&q=80', 'สมชาย ใจดี', 'Lead Developer', 'MARKUS', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    (a19, 'Steelcase Leap V2', 'FN-CH-003', 'SC-L2-001', cat_furniture, dept_hr, 'HR Office', 'ส่งซ่อม', CURRENT_DATE - INTERVAL '200 days', CURRENT_DATE + INTERVAL '4180 days', 'Steelcase TH', 38000.00, 'ที่พักแขนหัก', 'https://images.unsplash.com/photo-1580480055273-228ff5388ef8?w=400&q=80', 'สมหมาย HR', 'HR Manager', 'Leap V2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    (a20, 'IKEA BEKANT Desk', 'FN-TB-001', 'IK-BK-111', cat_furniture, dept_it, 'IT Room 1', 'ใช้งาน', CURRENT_DATE - INTERVAL '500 days', CURRENT_DATE + INTERVAL '3600 days', 'IKEA Bangna', 7990.00, 'โต๊ะปรับระดับได้', 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=400&q=80', 'สมชาย ใจดี', 'Lead Developer', 'BEKANT 160x80', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),

    -- Electricals & Displays
    (a21, 'Samsung 65" 4K Smart TV', 'EL-TV-001', 'SS-TV-65-888', cat_electrical, dept_sales, 'Meeting Room A', 'ใช้งาน', CURRENT_DATE - INTERVAL '300 days', CURRENT_DATE + INTERVAL '65 days', 'PowerBuy', 28900.00, 'ทีวีพรีเซนต์งาน', 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=400&q=80', NULL, NULL, 'TU8000 65"', NULL, NULL, NULL, NULL, '65" 4K UHD', 'Tizen OS', '192.168.1.80', 'B1:C2:D3:E4:F5:66'),
    (a22, 'LG 55" NanoCell TV', 'EL-TV-002', 'LG-55-NANO', cat_electrical, dept_admin, 'Reception Area', 'ใช้งาน', CURRENT_DATE - INTERVAL '400 days', CURRENT_DATE - INTERVAL '35 days', 'HomePro', 19900.00, 'เปิดวิดีโอต้อนรับ', 'https://images.unsplash.com/photo-1593784991095-a205069470b6?w=400&q=80', NULL, NULL, '55NANO75', NULL, NULL, NULL, NULL, '55" 4K HDR', 'webOS', '192.168.1.81', 'C1:D2:E3:F4:G5:H6'),

    -- Projectors
    (a23, 'Epson EB-X41', 'PJ-001', 'EP-EB-X41-11', cat_projector, dept_mgmt, 'Board Room', 'ใช้งาน', CURRENT_DATE - INTERVAL '800 days', CURRENT_DATE - INTERVAL '435 days', 'Projector Pro', 14900.00, 'โปรเจคเตอร์ห้องประชุมใหญ่ หลอดภาพเริ่มซีด', 'https://images.unsplash.com/photo-1588656754026-621aa507301d?w=400&q=80', NULL, NULL, 'EB-X41', NULL, NULL, NULL, NULL, 'XGA (1024x768)', NULL, NULL, NULL),
    (a24, 'BenQ MW550', 'PJ-002', 'BQ-MW-55', cat_projector, dept_hr, 'Training Room', 'ส่งซ่อม', CURRENT_DATE - INTERVAL '300 days', CURRENT_DATE + INTERVAL '65 days', 'JIB', 12900.00, 'พัดลมเสีย เปิดสักพักเครื่องดับเอง', 'https://images.unsplash.com/photo-1535016120720-40c746a51d2f?w=400&q=80', NULL, NULL, 'MW550', NULL, NULL, NULL, NULL, 'WXGA (1280x800)', NULL, NULL, NULL),

    -- UPS
    (a25, 'APC Smart-UPS 1500VA', 'UP-001', 'APC-1500-A', cat_ups, dept_it, 'Server Room (Rack A)', 'ใช้งาน', CURRENT_DATE - INTERVAL '600 days', CURRENT_DATE - INTERVAL '235 days', 'Advice', 18500.00, 'สำรองไฟให้เซิร์ฟเวอร์หลัก แบตอาจจะต้องเปลี่ยนเร็วๆ นี้', 'https://plus.unsplash.com/premium_photo-1681400650989-18342ca0f0cc?w=400&q=80', NULL, NULL, 'SMC1500I', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    (a26, 'Syndome ECO II 800VA', 'UP-002', 'SYN-800-B', cat_ups, dept_finance, 'Finance Room 4', 'ชำรุด', CURRENT_DATE - INTERVAL '1000 days', CURRENT_DATE - INTERVAL '635 days', 'JIB', 1200.00, 'แบตเสื่อม เก็บไฟไม่อยู่ รอจำหน่ายทิ้ง', 'https://images.unsplash.com/photo-1620245084928-8d380e0eb8ec?w=400&q=80', NULL, NULL, 'ECO II 800', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),

    -- Others / Spare
    (a27, 'Logitech MX Master 3S', 'OT-MS-001', 'LOG-MX3S-1', cat_other, dept_it, 'IT Storage', 'สำรอง', CURRENT_DATE - INTERVAL '30 days', CURRENT_DATE + INTERVAL '335 days', 'JIB', 3990.00, 'เมาส์สำรองสำหรับผู้บริหาร', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400&q=80', NULL, NULL, 'MX Master 3S', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    (a28, 'Keychron K3 V2', 'OT-KB-001', 'KEY-K3-11', cat_other, dept_it, 'IT Storage', 'สำรอง', CURRENT_DATE - INTERVAL '60 days', CURRENT_DATE + INTERVAL '305 days', 'Keychron TH', 3590.00, 'คีย์บอร์ดไร้สายสำรอง', 'https://images.unsplash.com/photo-1595225476474-87563907a212?w=400&q=80', NULL, NULL, 'K3 V2 RGB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    (a29, 'iPhone 15 Pro 256GB', 'IT-MB-001', 'IP15P-256G', cat_it, dept_sales, 'Sales Floor FL.2', 'ใช้งาน', CURRENT_DATE - INTERVAL '150 days', CURRENT_DATE + INTERVAL '215 days', 'AIS', 41900.00, 'มือถือสำหรับโทรเซลล์', 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=400&q=80', 'สมหญิง รักงาน', 'Sales Manager', 'iPhone 15 Pro', 'A17 Pro', '8GB', '256GB', '6-core GPU', '6.1" OLED', 'iOS 17', NULL, NULL),
    (a30, 'Samsung Galaxy Tab S9', 'IT-TB-002', 'SSTAB-S9-A', cat_it, dept_marketing, 'Marketing Zone', 'ส่งคืน', CURRENT_DATE - INTERVAL '200 days', CURRENT_DATE + INTERVAL '165 days', 'Samsung TH', 28900.00, 'พนักงานลาออก คืนของรอเคลียร์ข้อมูล', 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400&q=80', NULL, NULL, 'Tab S9 WiFi', 'Snapdragon 8 Gen 2', '8GB', '128GB', 'Adreno 740', '11" Dynamic AMOLED', 'Android 14', NULL, NULL);

    -- 4. Insert Asset Images (Multiple images for some assets)
    INSERT INTO asset_images (asset_id, file_url, file_name) VALUES
    (a1, 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&q=80', 'macbook_front.jpg'),
    (a1, 'https://images.unsplash.com/photo-1531297484001-80022131f5a1?w=800&q=80', 'macbook_side.jpg'),
    (a2, 'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=800&q=80', 'dell_xps.jpg'),
    (a4, 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=800&q=80', 'hp_elitebook.jpg'),
    (a5, 'https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=800&q=80', 'asus_rog.jpg'),
    (a5, 'https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=800&q=80', 'asus_rog_kb.jpg'),
    (a10, 'https://plus.unsplash.com/premium_photo-1683288176579-2dfca1ee8132?w=800&q=80', 'epson_error.jpg'),
    (a13, 'https://plus.unsplash.com/premium_photo-1678565202188-f69b2e593998?w=800&q=80', 'cisco_rack.jpg'),
    (a17, 'https://images.unsplash.com/photo-1505843490538-5133c6c7d0e1?w=800&q=80', 'herman_miller.jpg'),
    (a29, 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=800&q=80', 'iphone_15.jpg');

    -- 5. Insert Signatures
    INSERT INTO signatures (asset_id, signature_url, signed_at) VALUES
    (a1, 'https://upload.wikimedia.org/wikipedia/commons/f/f8/John_Hancock_signature.svg', CURRENT_DATE - INTERVAL '50 days'),
    (a2, 'https://upload.wikimedia.org/wikipedia/commons/3/30/George_Washington_signature.svg', CURRENT_DATE - INTERVAL '140 days'),
    (a3, 'https://upload.wikimedia.org/wikipedia/commons/2/23/Signature_of_Barack_Obama.svg', CURRENT_DATE - INTERVAL '290 days'),
    (a5, 'https://upload.wikimedia.org/wikipedia/commons/9/9d/Thomas_Edison_Signature.svg', CURRENT_DATE - INTERVAL '20 days'),
    (a8, 'https://upload.wikimedia.org/wikipedia/commons/2/23/Signature_of_Barack_Obama.svg', CURRENT_DATE - INTERVAL '190 days');

    -- 6. Insert Repair Tickets
    INSERT INTO repair_tickets (asset_id, title, description, status, priority, assigned_to, cost, created_at, resolved_at) VALUES
    (a4, 'แบตเตอรี่บวม', 'แบตเตอรี่บวมดันฝาหลังโก่ง เปิดไม่ติดถ้าไม่เสียบสายชาร์จ', 'รอะไหล่', 'สูง', 'HP On-site', 3500.00, CURRENT_DATE - INTERVAL '5 days', NULL),
    (a10, 'พิมพ์สีไม่ออก', 'สั่งพิมพ์เอกสารสีแล้วสีชมพูไม่ออก ล้างหัวพิมพ์แล้วไม่หาย', 'กำลังดำเนินการ', 'ปกติ', 'IT Support (ช่างเอ็ม)', 0.00, CURRENT_DATE - INTERVAL '2 days', NULL),
    (a19, 'ที่พักแขนหัก', 'พนักวางแขนด้านซ้ายหักจากการใช้งาน', 'เปิด', 'ต่ำ', 'Steelcase Claim', 0.00, CURRENT_DATE - INTERVAL '1 days', NULL),
    (a24, 'เครื่องร้อนดับเอง', 'เปิดใช้งานประมาณ 30 นาทีพัดลมเสียงดังมากแล้วดับไปเอง', 'รอะไหล่', 'ปกติ', 'JIB Service', 1200.00, CURRENT_DATE - INTERVAL '10 days', NULL),
    (a1, 'จอเป็นเส้น', 'หน้าจอมีเส้นสีเขียวพาดตรงกลาง', 'เสร็จสิ้น', 'สูง', 'Apple Care+', 0.00, CURRENT_DATE - INTERVAL '40 days', CURRENT_DATE - INTERVAL '30 days');

    -- 7. Insert Asset Transfers
    INSERT INTO asset_transfers (asset_id, from_department, to_department, from_location, to_location, transfer_date, transferred_by, notes) VALUES
    (a2, 'Marketing', 'Sales', 'Marketing Room', 'Sales Floor FL.2', CURRENT_DATE - INTERVAL '30 days', 'Admin (พลอย)', 'เซลล์ขอยืมเครื่องสเปคแรงไปใช้นำเสนองาน'),
    (a21, 'IT', 'Sales', 'IT Storage', 'Meeting Room A', CURRENT_DATE - INTERVAL '290 days', 'IT Support', 'ติดตั้งทีวีห้องประชุมเซลล์ใหม่'),
    (a30, 'Marketing', 'IT', 'Marketing Zone', 'IT Storage', CURRENT_DATE - INTERVAL '2 days', 'HR', 'พนักงานลาออก คืนอุปกรณ์ให้ไอทีเคลียร์ข้อมูล');

    -- 8. Insert Audit Log
    INSERT INTO audit_log (asset_id, action, details, performed_by, created_at) VALUES
    (a1, 'เพิ่มอุปกรณ์ใหม่', 'เพิ่มเข้าสู่ระบบ', 'Admin', CURRENT_DATE - INTERVAL '60 days'),
    (a2, 'โอนย้ายสถานที่', 'ย้ายจาก Marketing ไป Sales', 'Admin (พลอย)', CURRENT_DATE - INTERVAL '30 days'),
    (a4, 'เปลี่ยนสถานะ', 'เปลี่ยนเป็น "ส่งซ่อม" (แบตบวม)', 'IT Support', CURRENT_DATE - INTERVAL '5 days'),
    (a10, 'แจ้งซ่อม', 'เปิด Ticket แจ้งซ่อม (พิมพ์สีไม่ออก)', 'พนักงาน HR', CURRENT_DATE - INTERVAL '2 days'),
    (a30, 'เปลี่ยนสถานะ', 'เปลี่ยนเป็น "ส่งคืน"', 'HR', CURRENT_DATE - INTERVAL '2 days'),
    (a1, 'แจ้งซ่อม', 'เปิด Ticket (จอเป็นเส้น)', 'สมชาย ใจดี', CURRENT_DATE - INTERVAL '40 days'),
    (a1, 'ปิดงานซ่อม', 'แก้ปัญหาเรียบร้อย (เคลม Apple)', 'IT Support', CURRENT_DATE - INTERVAL '30 days');

    -- 9. Insert Licenses
    INSERT INTO licenses (name, type, license_key, vendor, start_date, expiry_date, seats, assigned_to, status, asset_id) VALUES
    ('Microsoft 365 E5', 'Subscription', 'MS365-E5-001', 'Microsoft', CURRENT_DATE - INTERVAL '60 days', CURRENT_DATE + INTERVAL '305 days', 1, 'สมชาย ใจดี', 'active', a1),
    ('Adobe Creative Cloud', 'Subscription', 'ADOBE-CC-ALL', 'Adobe', CURRENT_DATE - INTERVAL '150 days', CURRENT_DATE + INTERVAL '215 days', 1, 'สมหญิง รักงาน', 'active', a2),
    ('Autodesk AutoCAD', 'Subscription', 'AUTO-CAD-2024', 'Autodesk', CURRENT_DATE - INTERVAL '30 days', CURRENT_DATE + INTERVAL '335 days', 1, 'เอกชัย มีศิลป์', 'active', a5),
    ('Cisco DNA Essentials', 'Software', 'CISCO-DNA-001', 'Cisco Systems', CURRENT_DATE - INTERVAL '400 days', CURRENT_DATE + INTERVAL '695 days', 1, 'Network Admin', 'active', a13),
    ('FortiGuard UTM', 'Subscription', 'FG-UTM-001', 'Fortinet', CURRENT_DATE - INTERVAL '100 days', CURRENT_DATE + INTERVAL '265 days', 1, 'Network Admin', 'active', a16);

    -- 10. Insert Maintenance Schedules (PM)
    INSERT INTO maintenance_schedules (asset_id, title, description, frequency, interval_days, next_due_at, assigned_to, status) VALUES
    (a13, 'Backup Switch Configuration', 'สำรองข้อมูลคอนฟิกของ Core Switch', 'monthly', 30, CURRENT_DATE + INTERVAL '10 days', 'Network Admin', 'pending'),
    (a16, 'Update Firewall Firmware', 'ตรวจสอบช่องโหว่และอัปเดต Firmware ให้เป็นเวอร์ชันล่าสุด', 'quarterly', 90, CURRENT_DATE - INTERVAL '2 days', 'Network Admin', 'overdue'),
    (a9, 'ทำความสะอาดลูกกลิ้งปริ้นเตอร์', 'ปริ้นท์เทสเพจและเช็ดลูกกลิ้งดึงกระดาษ', 'monthly', 30, CURRENT_DATE + INTERVAL '5 days', 'IT Support', 'pending'),
    (a12, 'Vendor CM/PM (Canon)', 'ช่างจาก Ricoh เข้าเช็กเครื่องถ่ายเอกสารตามรอบ', 'quarterly', 90, CURRENT_DATE + INTERVAL '15 days', 'Ricoh TH', 'pending'),
    (a25, 'ทดสอบรัน UPS (Battery Calibration)', 'ถอดปลั๊กทดสอบระยะเวลาสำรองไฟจริง', 'yearly', 365, CURRENT_DATE + INTERVAL '120 days', 'IT Support', 'pending');

    -- 11. Insert Asset Checkouts
    INSERT INTO asset_checkouts (asset_id, checked_out_to, department, checkout_date, expected_return_date, notes, status) VALUES
    (a8, 'วิชัย บริหาร', 'Management', CURRENT_DATE - INTERVAL '190 days', NULL, 'เบิกใช้ iPad ประจำตำแหน่ง', 'checked_out'),
    (a2, 'สมหญิง รักงาน', 'Sales', CURRENT_DATE - INTERVAL '140 days', NULL, 'เบิกใช้โน้ตบุ๊กทำงาน', 'checked_out'),
    (a23, 'สมหมาย HR', 'HR', CURRENT_DATE - INTERVAL '400 days', CURRENT_DATE - INTERVAL '399 days', 'ยืมโปรเจคเตอร์จัดอบรมปฐมนิเทศ (ส่งคืนแล้ว)', 'returned'),
    (a28, 'นันทิดา รับแขก', 'Admin', CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE + INTERVAL '5 days', 'ยืมคีย์บอร์ดไร้สายไปจัดกิจกรรมหน้าตึก', 'checked_out');

    -- 12. Insert Notifications
    INSERT INTO notifications (title, message, type, severity, asset_id, link_page, link_params, is_read, created_at) VALUES
    ('ใกล้หมดประกัน', 'Dell OptiPlex (IT-DT-2022-045) หมดประกันแล้ว กรุณาตรวจสอบแผนการจัดซื้อทดแทน', 'warranty', 'warning', a7, 'asset-detail', '{"id":"'||a7||'"}', FALSE, CURRENT_DATE - INTERVAL '1 hour'),
    ('เลยกำหนดแผน PM', 'อัปเดต Firewall Firmware (FortiGate 60F) เลยกำหนดมาแล้ว 2 วัน', 'maintenance', 'danger', a16, 'pm-schedules', NULL, FALSE, CURRENT_DATE - INTERVAL '3 hours'),
    ('เปิดงานซ่อมใหม่', 'แจ้งซ่อม: แบตเตอรี่บวม (HP EliteBook)', 'ticket', 'warning', a4, 'tickets', NULL, FALSE, CURRENT_DATE - INTERVAL '5 days'),
    ('อุปกรณ์ส่งคืน', 'HR แจ้งส่งคืน Samsung Galaxy Tab S9 โปรดตรวจสอบและล้างข้อมูล', 'system', 'info', a30, 'asset-detail', '{"id":"'||a30||'"}', FALSE, CURRENT_DATE - INTERVAL '2 days'),
    ('แจ้งซ่อม: ที่พักแขนหัก', 'เก้าอี้ Steelcase Leap V2 พักแขนหัก รอเคลม', 'ticket', 'info', a19, 'tickets', NULL, TRUE, CURRENT_DATE - INTERVAL '1 days');

END $$;
