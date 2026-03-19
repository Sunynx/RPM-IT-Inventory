/**
 * Services.gs — All Business Logic Services
 * Includes: Asset, Dashboard, Export, Notification, Signature, Ticket, Transfer, Audit
 */

// ====================================================================
//  ASSET SERVICE — CRUD, Images, Categories, Departments, Import
// ====================================================================

function getAssets(params) {
  params = params || {};
  const page = params.page || 1;
  const pageSize = params.pageSize || 20;
  const offset = (page - 1) * pageSize;
  
  let select = '*, categories(name, icon), departments(name)';
  let filters = [];
  
  if (params.search) {
    filters.push('or=(name.ilike.*' + params.search + '*,asset_code.ilike.*' + params.search + '*,serial_number.ilike.*' + params.search + '*)');
  }
  if (params.status) {
    filters.push('status=eq.' + params.status);
  }
  if (params.categoryId) {
    filters.push('category_id=eq.' + params.categoryId);
  }
  if (params.departmentId) {
    filters.push('department_id=eq.' + params.departmentId);
  }
  
  const filter = filters.join('&');
  const order = params.order || 'created_at.desc';
  
  const result = supabaseSelect('assets', select, filter, order, true, pageSize, offset);
  
  return {
    data: result.data || result,
    total: result.total || (result.data ? result.data.length : result.length),
    page: page,
    pageSize: pageSize
  };
}

function getAsset(id) {
  // Parallel fetch: asset + images + signatures + auditLog
  var baseUrl = CONFIG.SUPABASE_URL + '/rest/v1/';
  var headers = {
    'apikey': CONFIG.SUPABASE_KEY,
    'Authorization': 'Bearer ' + CONFIG.SUPABASE_KEY,
    'Content-Type': 'application/json'
  };

  var requests = [
    { url: baseUrl + 'assets?select=' + encodeURIComponent('*, categories(name, icon), departments(name)') + '&id=eq.' + id, headers: headers, muteHttpExceptions: true },
    { url: baseUrl + 'asset_images?select=*&asset_id=eq.' + id + '&order=' + encodeURIComponent('created_at.asc'), headers: headers, muteHttpExceptions: true },
    { url: baseUrl + 'signatures?select=*&asset_id=eq.' + id + '&order=' + encodeURIComponent('signed_at.desc'), headers: headers, muteHttpExceptions: true },
    { url: baseUrl + 'audit_log?select=*&asset_id=eq.' + id + '&order=' + encodeURIComponent('created_at.desc') + '&limit=20', headers: headers, muteHttpExceptions: true }
  ];

  var responses = UrlFetchApp.fetchAll(requests);

  // Check main asset response
  var code = responses[0].getResponseCode();
  if (code < 200 || code >= 300) {
    Logger.log('getAsset error: ' + responses[0].getContentText());
    throw new Error('Database error: ' + responses[0].getContentText());
  }

  var assets = JSON.parse(responses[0].getContentText());
  if (!assets || assets.length === 0) throw new Error('Asset not found: ' + id);

  var asset = assets[0];
  asset.images = (responses[1].getResponseCode() === 200) ? JSON.parse(responses[1].getContentText()) : [];
  asset.signatures = (responses[2].getResponseCode() === 200) ? JSON.parse(responses[2].getContentText()) : [];
  asset.auditLog = (responses[3].getResponseCode() === 200) ? JSON.parse(responses[3].getContentText()) : [];

  return asset;
}

function createAsset(data) {
  if (!data.asset_code) {
    data.asset_code = generateAssetCode('IT');
  }
  
  const result = supabaseInsert('assets', {
    name: data.name,
    asset_code: data.asset_code,
    serial_number: data.serial_number || null,
    category_id: data.category_id || null,
    department_id: data.department_id || null,
    location: data.location || null,
    status: data.status || 'ใช้งาน',
    purchase_date: data.purchase_date || null,
    warranty_expiry: data.warranty_expiry || null,
    supplier: data.supplier || null,
    price: data.price || null,
    notes: data.notes || null,
    thumbnail_url: data.thumbnail_url || null,
    model: data.model || null,
    cpu: data.cpu || null,
    ram: data.ram || null,
    storage: data.storage || null,
    gpu: data.gpu || null,
    display: data.display || null,
    os: data.os || null,
    os_key: data.os_key || null,
    ip_address: data.ip_address || null,
    mac_address: data.mac_address || null,
    password: data.password || null,
    nas_user: data.nas_user || null,
    po_number: data.po_number || null,
    assigned_user: data.assigned_user || null,
    user_position: data.user_position || null,
    assigned_email: data.assigned_email || null
  });
  
  logAudit(result[0].id, 'สร้างอุปกรณ์ใหม่', 'สร้าง: ' + data.name);
  return result[0];
}

function updateAsset(id, data) {
  const oldData = supabaseSelect('assets', '*', 'id=eq.' + id);
  
  const updateFields = {};
  const fields = ['name', 'asset_code', 'serial_number', 'category_id', 'department_id',
                   'location', 'status', 'purchase_date', 'warranty_expiry', 'supplier',
                   'price', 'notes', 'thumbnail_url', 'model', 'cpu', 'ram', 'storage', 
                   'gpu', 'display', 'os', 'os_key', 'ip_address', 'mac_address', 'password', 'nas_user', 'po_number',
                   'assigned_user', 'user_position', 'assigned_email'];
  
  fields.forEach(function(field) {
    if (data[field] !== undefined) {
      updateFields[field] = data[field];
    }
  });
  
  const result = supabaseUpdate('assets', 'id=eq.' + id, updateFields);
  
  if (oldData && oldData.length > 0) {
    const changes = [];
    fields.forEach(function(field) {
      if (data[field] !== undefined && String(data[field]) !== String(oldData[0][field])) {
        changes.push(field + ': ' + (oldData[0][field] || '-') + ' → ' + (data[field] || '-'));
      }
    });
    if (changes.length > 0) {
      logAudit(id, 'แก้ไขอุปกรณ์', changes.join(', '));
    }
  }
  
  return result[0];
}

function markAssetAudited(id) {
  var asset = supabaseSelect('assets', 'name', 'id=eq.' + id);
  if (asset && asset.length > 0) {
    logAudit(id, 'ตรวจนับอุปกรณ์', 'สแกนตรวจพบผ่าน Smart Scanner (Mobile)');
    return asset[0];
  }
  return null;
}

function deleteAsset(id) {
  const asset = supabaseSelect('assets', 'name', 'id=eq.' + id);
  
  const images = supabaseSelect('asset_images', '*', 'asset_id=eq.' + id);
  if (images) {
    images.forEach(function(img) {
      try {
        const path = img.file_url.split('/asset-images/')[1];
        if (path) supabaseDeleteFile('asset-images', path);
      } catch(e) { /* ignore */ }
    });
  }
  
  const result = supabaseDelete('assets', 'id=eq.' + id);
  
  if (asset && asset.length > 0) {
    logAudit(null, 'ลบอุปกรณ์', 'ลบ: ' + asset[0].name + ' (ID: ' + id + ')');
  }
  
  return { success: true };
}

function deleteAssets(ids) {
  ids.forEach(function(id) {
    deleteAsset(id);
  });
  return { success: true, count: ids.length };
}

function uploadAssetImage(assetId, base64Data, fileName, contentType) {
  const timestamp = new Date().getTime();
  const path = assetId + '/' + timestamp + '_' + fileName;
  
  const fileUrl = supabaseUpload('asset-images', path, base64Data, contentType);
  
  const result = supabaseInsert('asset_images', {
    asset_id: assetId,
    file_url: fileUrl,
    file_name: fileName
  });
  
  const images = supabaseSelect('asset_images', 'id', 'asset_id=eq.' + assetId);
  if (images && images.length === 1) {
    supabaseUpdate('assets', 'id=eq.' + assetId, { thumbnail_url: fileUrl });
  }
  
  logAudit(assetId, 'เพิ่มรูปภาพ', fileName);
  return result[0];
}

function deleteAssetImage(imageId) {
  const img = supabaseSelect('asset_images', '*', 'id=eq.' + imageId);
  if (img && img.length > 0) {
    try {
      const path = img[0].file_url.split('/asset-images/')[1];
      if (path) supabaseDeleteFile('asset-images', path);
    } catch(e) { /* ignore */ }
    
    supabaseDelete('asset_images', 'id=eq.' + imageId);
    logAudit(img[0].asset_id, 'ลบรูปภาพ', img[0].file_name);
  }
  return { success: true };
}

function getCategories() {
  return supabaseSelect('categories', '*', null, 'name.asc');
}

function getDepartments() {
  return supabaseSelect('departments', '*', null, 'name.asc');
}

// Combined init data fetch (parallel)
function getInitData() {
  var baseUrl = CONFIG.SUPABASE_URL + '/rest/v1/';
  var headers = {
    'apikey': CONFIG.SUPABASE_KEY,
    'Authorization': 'Bearer ' + CONFIG.SUPABASE_KEY,
    'Content-Type': 'application/json'
  };
  var requests = [
    { url: baseUrl + 'categories?select=*&order=' + encodeURIComponent('name.asc'), headers: headers, muteHttpExceptions: true },
    { url: baseUrl + 'departments?select=*&order=' + encodeURIComponent('name.asc'), headers: headers, muteHttpExceptions: true }
  ];
  var responses = UrlFetchApp.fetchAll(requests);
  return {
    categories: JSON.parse(responses[0].getContentText()),
    departments: JSON.parse(responses[1].getContentText())
  };
}

function createCategory(name, icon) {
  return supabaseInsert('categories', { name: name, icon: icon || 'box' });
}

function createDepartment(name) {
  return supabaseInsert('departments', { name: name });
}

function deleteCategory(id) {
  supabaseDelete('categories', 'id=eq.' + id);
  return { success: true };
}

function deleteDepartment(id) {
  supabaseDelete('departments', 'id=eq.' + id);
  return { success: true };
}

function importAssets(csvData) {
  let imported = 0;
  let errors = [];
  
  csvData.forEach(function(row, index) {
    try {
      createAsset({
        name: row.name || row['ชื่ออุปกรณ์'],
        asset_code: row.asset_code || row['รหัสทรัพย์สิน'],
        serial_number: row.serial_number || row['Serial Number'],
        location: row.location || row['สถานที่'],
        status: row.status || row['สถานะ'] || 'ใช้งาน',
        purchase_date: row.purchase_date || row['วันที่ซื้อ'],
        warranty_expiry: row.warranty_expiry || row['หมดประกัน'],
        supplier: row.supplier || row['ผู้จำหน่าย'],
        price: row.price || row['ราคา'],
        notes: row.notes || row['หมายเหตุ']
      });
      imported++;
    } catch(e) {
      errors.push('Row ' + (index + 1) + ': ' + e.message);
    }
  });
  
  return { imported: imported, errors: errors };
}


// ====================================================================
//  DASHBOARD SERVICE
// ====================================================================

function getDashboardStats() {
  // Parallel fetch: allAssets, recentAssets, recentActivity, openTickets
  var baseUrl = CONFIG.SUPABASE_URL + '/rest/v1/';
  var headers = {
    'apikey': CONFIG.SUPABASE_KEY,
    'Authorization': 'Bearer ' + CONFIG.SUPABASE_KEY,
    'Content-Type': 'application/json'
  };

  var nowISO = new Date().toISOString();
  var requests = [
    { url: baseUrl + 'assets?select=' + encodeURIComponent('id,status,warranty_expiry,created_at,price,categories(name),departments(name)'), headers: headers, muteHttpExceptions: true },
    { url: baseUrl + 'assets?select=' + encodeURIComponent('*, categories(name, icon), departments(name)') + '&order=' + encodeURIComponent('created_at.desc') + '&limit=8', headers: headers, muteHttpExceptions: true },
    { url: baseUrl + 'audit_log?select=*&order=' + encodeURIComponent('created_at.desc') + '&limit=10', headers: headers, muteHttpExceptions: true },
    { url: baseUrl + 'repair_tickets?select=id&' + encodeURIComponent('status=neq.เสร็จสิ้น') + '&' + encodeURIComponent('status=neq.ยกเลิก'), headers: headers, muteHttpExceptions: true },
    { url: baseUrl + 'maintenance_schedules?select=id&status=eq.pending&next_due_at=lte.' + encodeURIComponent(nowISO), headers: headers, muteHttpExceptions: true },
    { url: baseUrl + 'asset_checkouts?select=id&status=eq.checked_out&expected_return_date=lt.' + encodeURIComponent(nowISO.slice(0,10)), headers: headers, muteHttpExceptions: true }
  ];

  var responses = UrlFetchApp.fetchAll(requests);
  var allAssets = JSON.parse(responses[0].getContentText());
  var recentAssets = JSON.parse(responses[1].getContentText());
  var recentActivity = JSON.parse(responses[2].getContentText());
  var openTickets = JSON.parse(responses[3].getContentText());
  var maintenanceDueArr = JSON.parse(responses[4].getContentText());
  var overdueCheckoutsArr = JSON.parse(responses[5].getContentText());

  const total = allAssets.length;
  let active = 0, repair = 0, returned = 0, spare = 0, damaged = 0, disposed = 0;
  let warrantyExpiring = 0;
  let totalValue = 0;
  
  const now = new Date();
  const thirtyDaysLater = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);
  
  const categoryStats = {};
  const departmentStats = {};
  
  allAssets.forEach(function(a) {
    switch(a.status) {
      case 'ใช้งาน': active++; break;
      case 'ส่งซ่อม': repair++; break;
      case 'ส่งคืน': returned++; break;
      case 'สำรอง': spare++; break;
      case 'ชำรุด': damaged++; break;
      case 'จำหน่าย': disposed++; break;
    }
    
    if (a.price) totalValue += parseFloat(a.price) || 0;
    
    if (a.warranty_expiry) {
      const expiry = new Date(a.warranty_expiry);
      if (expiry > now && expiry <= thirtyDaysLater) {
        warrantyExpiring++;
      }
    }

    // Category Aggregation
    const catName = (a.categories && a.categories.name) ? a.categories.name : 'ไม่ระบุ';
    if (!categoryStats[catName]) categoryStats[catName] = 0;
    categoryStats[catName]++;

    // Department Aggregation
    const deptName = (a.departments && a.departments.name) ? a.departments.name : 'ไม่ระบุ';
    if (!departmentStats[deptName]) departmentStats[deptName] = 0;
    departmentStats[deptName]++;
  });
  
  // Format Category Stats
  const categoryChart = {
    labels: Object.keys(categoryStats),
    data: Object.values(categoryStats)
  };

  // Format Department Stats
  const departmentChart = {
    labels: Object.keys(departmentStats),
    data: Object.values(departmentStats)
  };

  // Monthly stats (last 12 months)
  const monthlyStats = [];
  for (let i = 11; i >= 0; i--) {
    const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
    const monthStr = (d.getMonth() + 1).toString().padStart(2, '0');
    const monthStart = d.getFullYear() + '-' + monthStr;
    const count = allAssets.filter(function(a) {
      return a.created_at && a.created_at.slice(0, 7) === monthStart;
    }).length;
    monthlyStats.push({
      month: monthStart,
      label: getThaiMonth(d.getMonth()) + ' ' + ((d.getFullYear() + 543).toString().substring(2)),
      count: count
    });
  }
  
  return {
    total: total,
    active: active,
    repair: repair,
    returned: returned,
    spare: spare,
    damaged: damaged,
    disposed: disposed,
    warrantyExpiring: warrantyExpiring,
    statusChart: {
      labels: ['ใช้งาน', 'ส่งซ่อม', 'สำรอง', 'อื่น'],
      data: [active, repair, spare, returned + damaged + disposed]
    },
    categoryChart: categoryChart,
    departmentChart: departmentChart,
    monthlyStats: monthlyStats,
    recentAssets: recentAssets,
    recentActivity: recentActivity,
    openTickets: openTickets ? openTickets.length : 0,
    maintenanceDue: maintenanceDueArr ? maintenanceDueArr.length : 0,
    overdueCheckouts: overdueCheckoutsArr ? overdueCheckoutsArr.length : 0,
    totalValue: totalValue
  };
}

function getThaiMonth(monthIndex) {
  const months = ['ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
                   'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'];
  return months[monthIndex];
}

function getWarrantyAlerts() {
  const now = new Date().toISOString().slice(0, 10);
  const thirtyDays = new Date(new Date().getTime() + 30 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10);
  
  return supabaseSelect('assets', '*, departments(name)', 
    'warranty_expiry=gte.' + now + '&warranty_expiry=lte.' + thirtyDays,
    'warranty_expiry.asc');
}


// ====================================================================
//  EXPORT SERVICE — Excel & PDF
// ====================================================================

function exportExcel(assetIds, fields) {
  const assets = getAssetsForExport(assetIds);
  const fieldDefs = getFieldDefinitions(fields);
  
  const spreadsheet = SpreadsheetApp.create('AssetQR_Export_' + Utilities.formatDate(new Date(), 'Asia/Bangkok', 'yyyyMMdd_HHmmss'));
  const sheet = spreadsheet.getActiveSheet();
  sheet.setName('อุปกรณ์');
  
  const headers = fieldDefs.map(function(f) { return f.label; });
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);
  sheet.getRange(1, 1, 1, headers.length).setFontWeight('bold');
  sheet.getRange(1, 1, 1, headers.length).setBackground('#0DCAF0');
  sheet.getRange(1, 1, 1, headers.length).setFontColor('#FFFFFF');
  
  const rows = assets.map(function(asset) {
    return fieldDefs.map(function(f) {
      return getFieldValue(asset, f.key);
    });
  });
  
  if (rows.length > 0) {
    sheet.getRange(2, 1, rows.length, headers.length).setValues(rows);
  }
  
  for (let i = 1; i <= headers.length; i++) {
    sheet.autoResizeColumn(i);
  }
  
  SpreadsheetApp.flush();
  
  const file = DriveApp.getFileById(spreadsheet.getId());
  const blob = file.getAs('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  const base64 = Utilities.base64Encode(blob.getBytes());
  
  DriveApp.getFileById(spreadsheet.getId()).setTrashed(true);
  
  return {
    base64: base64,
    filename: 'AssetQR_Export_' + Utilities.formatDate(new Date(), 'Asia/Bangkok', 'yyyyMMdd') + '.xlsx',
    mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  };
}

function exportPDF(assetIds, fields) {
  const assets = getAssetsForExport(assetIds);
  const fieldDefs = getFieldDefinitions(fields);
  
  let html = '<html><head><style>';
  html += 'body { font-family: "Sarabun", sans-serif; font-size: 12px; }';
  html += 'h1 { color: #0DCAF0; font-size: 18px; }';
  html += 'table { width: 100%; border-collapse: collapse; margin-top: 10px; }';
  html += 'th { background: #0DCAF0; color: white; padding: 8px; text-align: left; font-size: 11px; }';
  html += 'td { padding: 6px 8px; border-bottom: 1px solid #eee; font-size: 11px; }';
  html += 'tr:nth-child(even) { background: #f8f9fa; }';
  html += '.footer { margin-top: 20px; text-align: center; color: #666; font-size: 10px; }';
  html += '</style></head><body>';
  html += '<h1>รายงานอุปกรณ์ — AssetQR</h1>';
  html += '<p>วันที่ออกรายงาน: ' + Utilities.formatDate(new Date(), 'Asia/Bangkok', 'dd/MM/yyyy HH:mm') + '</p>';
  html += '<p>จำนวน: ' + assets.length + ' รายการ</p>';
  html += '<table><thead><tr>';
  
  fieldDefs.forEach(function(f) {
    html += '<th>' + f.label + '</th>';
  });
  html += '</tr></thead><tbody>';
  
  assets.forEach(function(asset) {
    html += '<tr>';
    fieldDefs.forEach(function(f) {
      html += '<td>' + (getFieldValue(asset, f.key) || '-') + '</td>';
    });
    html += '</tr>';
  });
  
  html += '</tbody></table>';
  html += '<div class="footer">สร้างโดย AssetQR — ระบบจัดการอุปกรณ์</div>';
  html += '</body></html>';
  
  const blob = HtmlService.createHtmlOutput(html).getBlob().getAs('application/pdf');
  const base64 = Utilities.base64Encode(blob.getBytes());
  
  return {
    base64: base64,
    filename: 'AssetQR_Report_' + Utilities.formatDate(new Date(), 'Asia/Bangkok', 'yyyyMMdd') + '.pdf',
    mimeType: 'application/pdf'
  };
}

function getAssetsForExport(assetIds) {
  if (assetIds && assetIds.length > 0) {
    const filter = 'id=in.(' + assetIds.join(',') + ')';
    return supabaseSelect('assets', '*, categories(name), departments(name)', filter, 'created_at.desc');
  }
  return supabaseSelect('assets', '*, categories(name), departments(name)', null, 'created_at.desc');
}

function getFieldDefinitions(selectedFields) {
  const allFields = [
    { key: 'asset_code', label: 'รหัสทรัพย์สิน' },
    { key: 'name', label: 'ชื่ออุปกรณ์' },
    { key: 'serial_number', label: 'Serial Number' },
    { key: 'category_name', label: 'ประเภท' },
    { key: 'department_name', label: 'แผนก' },
    { key: 'location', label: 'สถานที่' },
    { key: 'status', label: 'สถานะ' },
    { key: 'purchase_date', label: 'วันที่ซื้อ' },
    { key: 'warranty_expiry', label: 'หมดประกัน' },
    { key: 'supplier', label: 'ผู้จำหน่าย' },
    { key: 'price', label: 'ราคา' },
    { key: 'notes', label: 'หมายเหตุ' },
    { key: 'created_at', label: 'วันที่บันทึก' }
  ];
  
  if (!selectedFields || selectedFields.length === 0) return allFields;
  
  return allFields.filter(function(f) {
    return selectedFields.indexOf(f.key) !== -1;
  });
}

function getFieldValue(asset, key) {
  switch(key) {
    case 'category_name':
      return asset.categories ? asset.categories.name : '';
    case 'department_name':
      return asset.departments ? asset.departments.name : '';
    case 'purchase_date':
    case 'warranty_expiry':
      return asset[key] ? formatThaiDate(asset[key]) : '';
    case 'created_at':
      return asset[key] ? formatThaiDate(asset[key]) : '';
    case 'price':
      return asset[key] ? Number(asset[key]).toLocaleString('th-TH') : '';
    default:
      return asset[key] || '';
  }
}

function formatThaiDate(dateStr) {
  if (!dateStr) return '';
  const d = new Date(dateStr);
  const day = d.getDate();
  const month = getThaiMonth(d.getMonth());
  const year = d.getFullYear() + 543;
  return day + ' ' + month + ' ' + year;
}


// ====================================================================
//  NOTIFICATION SERVICE — Email & LINE
// ====================================================================

function sendEmailNotification(to, subject, body) {
  try {
    const settings = getSettings();
    
    if (!to && settings.notify_email) {
      to = settings.notify_email;
    }
    
    if (!to) {
      Logger.log('No email recipient configured');
      return { success: false, error: 'ไม่ได้ตั้งค่าอีเมลผู้รับ' };
    }
    
    const htmlBody = `
      <div style="font-family: 'Sarabun', Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background: linear-gradient(135deg, #0DCAF0, #0AA8CC); padding: 20px; border-radius: 10px 10px 0 0;">
          <h2 style="color: white; margin: 0;">🏷️ AssetQR — แจ้งเตือน</h2>
        </div>
        <div style="padding: 20px; background: #f8f9fa; border-radius: 0 0 10px 10px;">
          <h3 style="color: #333;">${subject}</h3>
          <div style="color: #555; line-height: 1.6;">${body}</div>
          <hr style="border: 1px solid #eee; margin: 20px 0;">
          <p style="color: #999; font-size: 12px;">ส่งจากระบบ AssetQR — ระบบจัดการอุปกรณ์</p>
        </div>
      </div>
    `;
    
    MailApp.sendEmail({
      to: to,
      subject: '[AssetQR] ' + subject,
      htmlBody: htmlBody
    });
    
    return { success: true };
  } catch(e) {
    Logger.log('Email error: ' + e.message);
    return { success: false, error: e.message };
  }
}

function sendLineNotification(message) {
  try {
    const settings = getSettings();
    const token = settings.line_token;
    
    if (!token) {
      Logger.log('LINE Token not configured');
      return { success: false, error: 'ไม่ได้ตั้งค่า LINE Token' };
    }
    
    const url = 'https://notify-api.line.me/api/notify';
    const options = {
      method: 'POST',
      headers: {
        'Authorization': 'Bearer ' + token,
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      payload: 'message=' + encodeURIComponent('\n' + message),
      muteHttpExceptions: true
    };
    
    const response = UrlFetchApp.fetch(url, options);
    const code = response.getResponseCode();
    
    if (code === 200) {
      return { success: true };
    } else {
      return { success: false, error: 'LINE API error: ' + response.getContentText() };
    }
  } catch(e) {
    Logger.log('LINE error: ' + e.message);
    return { success: false, error: e.message };
  }
}

function sendNotification(subject, message, emailTo) {
  const results = {
    email: sendEmailNotification(emailTo, subject, message),
    line: sendLineNotification('📋 ' + subject + '\n' + message.replace(/<[^>]*>/g, ''))
  };
  return results;
}

function checkWarrantyAndNotify() {
  const alerts = getWarrantyAlerts();
  
  if (alerts && alerts.length > 0) {
    let message = '⚠️ อุปกรณ์ใกล้หมดประกัน ' + alerts.length + ' รายการ:\n\n';
    
    alerts.forEach(function(a) {
      message += '• ' + a.name + ' (' + a.asset_code + ') — หมด ' + formatThaiDate(a.warranty_expiry) + '\n';
    });
    
    sendNotification('แจ้งเตือนประกันภัยใกล้หมด', message);
  }
  
  return { checked: true, alertCount: alerts ? alerts.length : 0 };
}

function setupDailyWarrantyCheck() {
  const triggers = ScriptApp.getProjectTriggers();
  triggers.forEach(function(trigger) {
    if (trigger.getHandlerFunction() === 'checkWarrantyAndNotify') {
      ScriptApp.deleteTrigger(trigger);
    }
  });
  
  ScriptApp.newTrigger('checkWarrantyAndNotify')
    .timeBased()
    .atHour(8)
    .everyDays(1)
    .inTimezone('Asia/Bangkok')
    .create();
    
  return { success: true };
}


// ====================================================================
//  SIGNATURE SERVICE — Equipment Receipt
// ====================================================================

function saveSignature(assetId, base64Signature) {
  const timestamp = new Date().getTime();
  const path = assetId + '/sig_' + timestamp + '.png';
  
  const signatureUrl = supabaseUpload('signatures', path, base64Signature, 'image/png');
  
  const result = supabaseInsert('signatures', {
    asset_id: assetId,
    signature_url: signatureUrl
  });
  
  logAudit(assetId, '\u0e40\u0e0b\u0e47\u0e19\u0e23\u0e31\u0e1a\u0e2d\u0e38\u0e1b\u0e01\u0e23\u0e13\u0e4c', '\u0e1a\u0e31\u0e19\u0e17\u0e36\u0e01\u0e25\u0e32\u0e22\u0e40\u0e0b\u0e47\u0e19');
  return result[0];
}

function getAssetSignatures(assetId) {
  return supabaseSelect('signatures', '*', 'asset_id=eq.' + assetId, 'signed_at.desc');
}

function deleteSignature(signatureId) {
  const sig = supabaseSelect('signatures', '*', 'id=eq.' + signatureId);
  if (sig && sig.length > 0) {
    try {
      const path = sig[0].signature_url.split('/signatures/')[1];
      if (path) supabaseDeleteFile('signatures', path);
    } catch(e) { /* ignore */ }
    
    supabaseDelete('signatures', 'id=eq.' + signatureId);
    logAudit(sig[0].asset_id, 'ลบลายเซ็น', 'ลบลายเซ็นออก');
  }
  return { success: true };
}

function generateReceipt(assetId, signatureId) {
  const asset = getAsset(assetId);
  const sig = supabaseSelect('signatures', '*', 'id=eq.' + signatureId);
  
  if (!sig || sig.length === 0) throw new Error('Signature not found');
  const signature = sig[0];
  
  const settings = getSettings();
  
  const html = `
    <div style="font-family: 'Sarabun', sans-serif; max-width: 700px; margin: 0 auto; padding: 30px;">
      <div style="text-align: center; margin-bottom: 30px;">
        <h2 style="margin: 0;">ใบรับอุปกรณ์ / Equipment Receipt</h2>
        <p style="color: #666;">${settings.org_name || 'องค์กร'}</p>
      </div>
      
      <table style="width: 100%; border-collapse: collapse; margin-bottom: 20px;">
        <tr><td style="padding: 8px; border: 1px solid #ddd; width: 30%; background: #f5f5f5; font-weight: bold;">ชื่ออุปกรณ์</td><td style="padding: 8px; border: 1px solid #ddd;">${asset.name}</td></tr>
        <tr><td style="padding: 8px; border: 1px solid #ddd; background: #f5f5f5; font-weight: bold;">รหัสทรัพย์สิน</td><td style="padding: 8px; border: 1px solid #ddd;">${asset.asset_code || '-'}</td></tr>
        <tr><td style="padding: 8px; border: 1px solid #ddd; background: #f5f5f5; font-weight: bold;">Serial Number</td><td style="padding: 8px; border: 1px solid #ddd;">${asset.serial_number || '-'}</td></tr>
        <tr><td style="padding: 8px; border: 1px solid #ddd; background: #f5f5f5; font-weight: bold;">แผนก</td><td style="padding: 8px; border: 1px solid #ddd;">${asset.departments ? asset.departments.name : '-'}</td></tr>
        <tr><td style="padding: 8px; border: 1px solid #ddd; background: #f5f5f5; font-weight: bold;">สถานที่</td><td style="padding: 8px; border: 1px solid #ddd;">${asset.location || '-'}</td></tr>
        <tr><td style="padding: 8px; border: 1px solid #ddd; background: #f5f5f5; font-weight: bold;">วันที่รับ</td><td style="padding: 8px; border: 1px solid #ddd;">${formatThaiDate(signature.signed_at)}</td></tr>
        <tr><td style="padding: 8px; border: 1px solid #ddd; background: #f5f5f5; font-weight: bold;">ผู้ใช้</td><td style="padding: 8px; border: 1px solid #ddd;">${asset.assigned_user || '-'}</td></tr>
        <tr><td style="padding: 8px; border: 1px solid #ddd; background: #f5f5f5; font-weight: bold;">ตำแหน่ง</td><td style="padding: 8px; border: 1px solid #ddd;">${asset.user_position || '-'}</td></tr>
      </table>
      
      <div style="display: flex; justify-content: space-between; margin-top: 40px;">
        <div style="text-align: center; width: 45%;">
          <p style="font-weight: bold;">ผู้ส่งมอบ</p>
          <div style="height: 80px; border-bottom: 1px solid #333; margin-bottom: 5px;"></div>
          <p>( .......................... )</p>
          <p>IT Admin</p>
        </div>
        <div style="text-align: center; width: 45%;">
          <p style="font-weight: bold;">ผู้รับอุปกรณ์</p>
          <img src="${signature.signature_url}" style="height: 80px; border-bottom: 1px solid #333;">
          <p>( ${asset.assigned_user || '...........................'} )</p>
          <p>${asset.user_position || ''}</p>
        </div>
      </div>
    </div>
  `;
  
  return html;
}


// ====================================================================
//  TICKET SERVICE — Repair Tickets
// ====================================================================

function getTickets(params) {
  params = params || {};
  const page = params.page || 1;
  const pageSize = params.pageSize || 20;
  const offset = (page - 1) * pageSize;
  
  let filters = [];
  if (params.status) filters.push('status=eq.' + params.status);
  if (params.priority) filters.push('priority=eq.' + params.priority);
  if (params.search) filters.push('or=(title.ilike.*' + params.search + '*)');
  
  const filter = filters.join('&');
  const result = supabaseSelect('repair_tickets', '*, assets(name, asset_code)', filter, 'created_at.desc', true, pageSize, offset);
  
  return {
    data: result.data || result,
    total: result.total || 0,
    page: page,
    pageSize: pageSize
  };
}

function getTicket(id) {
  const data = supabaseSelect('repair_tickets', '*, assets(name, asset_code)', 'id=eq.' + id);
  if (!data || data.length === 0) throw new Error('Ticket not found');
  return data[0];
}

function createTicket(data) {
  const result = supabaseInsert('repair_tickets', {
    asset_id: data.asset_id || null,
    title: data.title,
    description: data.description || '',
    status: 'เปิด',
    priority: data.priority || 'ปกติ',
    assigned_to: data.assigned_to || '',
    cost: data.cost || null
  });
  
  if (data.asset_id) {
    supabaseUpdate('assets', 'id=eq.' + data.asset_id, { status: 'ส่งซ่อม' });
    logAudit(data.asset_id, 'สร้างงานซ่อม', data.title);
  }
  
  sendNotification('งานซ่อมใหม่: ' + data.title, 
    'อุปกรณ์: ' + (data.asset_name || '-') + '\nรายละเอียด: ' + (data.description || '-'));
  
  return result[0];
}

function updateTicket(id, data) {
  const result = supabaseUpdate('repair_tickets', 'id=eq.' + id, data);
  
  if (data.status === 'เสร็จสิ้น' && result[0].asset_id) {
    supabaseUpdate('assets', 'id=eq.' + result[0].asset_id, { status: 'ใช้งาน' });
    logAudit(result[0].asset_id, 'ซ่อมเสร็จ', data.title || '');
  }
  
  return result[0];
}

function deleteTicket(id) {
  supabaseDelete('repair_tickets', 'id=eq.' + id);
  return { success: true };
}


// ====================================================================
//  TRANSFER SERVICE
// ====================================================================

function getTransfers(params) {
  params = params || {};
  const page = params.page || 1;
  const pageSize = params.pageSize || 20;
  const offset = (page - 1) * pageSize;
  
  const result = supabaseSelect('asset_transfers', '*, assets(name, asset_code)', 
    null, 'transfer_date.desc', true, pageSize, offset);
  
  return {
    data: result.data || result,
    total: result.total || 0,
    page: page,
    pageSize: pageSize
  };
}

function createTransfer(data) {
  const result = supabaseInsert('asset_transfers', {
    asset_id: data.asset_id,
    from_department: data.from_department || '',
    to_department: data.to_department || '',
    from_location: data.from_location || '',
    to_location: data.to_location || '',
    transferred_by: data.transferred_by || 'Admin',
    notes: data.notes || '',
    signature_url: data.signature_url || null
  });
  
  if (data.to_department_id) {
    supabaseUpdate('assets', 'id=eq.' + data.asset_id, { 
      department_id: data.to_department_id,
      location: data.to_location || undefined
    });
  }
  
  logAudit(data.asset_id, 'โอนย้ายอุปกรณ์', 
    'จาก ' + (data.from_department || '-') + ' → ' + (data.to_department || '-'));
  
  return result[0];
}


// ====================================================================
//  AUDIT LOG SERVICE
// ====================================================================

function logAudit(assetId, action, details) {
  try {
    supabaseInsert('audit_log', {
      asset_id: assetId,
      action: action,
      details: details || '',
      performed_by: 'Admin'
    });
  } catch(e) {
    Logger.log('Audit log error: ' + e.message);
  }
}

function getAuditLog(params) {
  params = params || {};
  const page = params.page || 1;
  const pageSize = params.pageSize || 50;
  const offset = (page - 1) * pageSize;
  
  let filters = [];
  if (params.assetId) filters.push('asset_id=eq.' + params.assetId);
  if (params.action) filters.push('action=ilike.*' + params.action + '*');
  if (params.dateFrom) filters.push('created_at=gte.' + params.dateFrom);
  if (params.dateTo) filters.push('created_at=lte.' + params.dateTo);
  
  const filter = filters.join('&');
  const result = supabaseSelect('audit_log', '*', filter, 'created_at.desc', true, pageSize, offset);
  
  return {
    data: result.data || result,
    total: result.total || 0,
    page: page,
    pageSize: pageSize
  };
}


// ====================================================================
//  LICENSE SERVICE — Software License Management
// ====================================================================

function getLicenses() {
  return supabaseSelect('licenses', '*', null, 'created_at.desc');
}

function createLicense(data) {
  const result = supabaseInsert('licenses', {
    name: data.name,
    type: data.type || 'Software',
    license_key: data.license_key || null,
    vendor: data.vendor || null,
    start_date: data.start_date || null,
    expiry_date: data.expiry_date || null,
    seats: data.seats || null,
    assigned_to: data.assigned_to || null,
    status: data.status || 'active',
    notes: data.notes || null,
    asset_id: data.asset_id || null
  });
  
  logAudit(data.asset_id, 'เพิ่ม License', data.name);
  return result[0];
}

function updateLicense(id, data) {
  const result = supabaseUpdate('licenses', 'id=eq.' + id, data);
  logAudit(data.asset_id, 'แก้ไข License', data.name || '');
  return result[0];
}

function deleteLicense(id) {
  const license = supabaseSelect('licenses', 'name', 'id=eq.' + id);
  supabaseDelete('licenses', 'id=eq.' + id);
  
  if (license && license.length > 0) {
    logAudit(null, 'ลบ License', license[0].name);
  }
  return { success: true };
}


// ====================================================================
//  MAINTENANCE SERVICE — Preventive Maintenance Schedule
// ====================================================================

function getMaintenanceSchedules(params) {
  params = params || {};
  var filters = [];
  if (params.status) filters.push('status=eq.' + params.status);
  if (params.assetId) filters.push('asset_id=eq.' + params.assetId);
  var filter = filters.join('&');
  return supabaseSelect('maintenance_schedules', '*, assets(name, asset_code)', filter, 'next_due_at.asc');
}

function createMaintenance(data) {
  var intervalDays = calculateIntervalDays(data.frequency, data.interval_days);
  var nextDue = data.next_due_at || new Date(Date.now() + intervalDays * 86400000).toISOString();

  var result = supabaseInsert('maintenance_schedules', {
    asset_id: data.asset_id,
    title: data.title,
    description: data.description || null,
    frequency: data.frequency || 'monthly',
    interval_days: intervalDays,
    next_due_at: nextDue,
    assigned_to: data.assigned_to || null,
    status: 'pending'
  });

  logAudit(data.asset_id, 'สร้างตาราง PM', data.title);
  createAppNotification({
    title: 'PM ใหม่: ' + data.title,
    message: 'กำหนดถัดไป: ' + nextDue.slice(0, 10),
    type: 'maintenance', severity: 'info',
    asset_id: data.asset_id, link_page: 'maintenance'
  });
  return result[0];
}

function updateMaintenance(id, data) {
  if (data.frequency) {
    data.interval_days = calculateIntervalDays(data.frequency, data.interval_days);
  }
  var result = supabaseUpdate('maintenance_schedules', 'id=eq.' + id, data);
  return result[0];
}

function completeMaintenance(id) {
  var rows = supabaseSelect('maintenance_schedules', '*', 'id=eq.' + id);
  if (!rows || rows.length === 0) throw new Error('PM not found');
  var pm = rows[0];

  var now = new Date();
  var nextDue = new Date(now.getTime() + pm.interval_days * 86400000).toISOString();

  supabaseUpdate('maintenance_schedules', 'id=eq.' + id, {
    last_performed_at: now.toISOString(),
    next_due_at: nextDue,
    status: 'pending'
  });

  logAudit(pm.asset_id, 'ดำเนินการ PM เสร็จ', pm.title + ' | ครั้งถัดไป: ' + nextDue.slice(0, 10));
  return { success: true, next_due_at: nextDue };
}

function deleteMaintenance(id) {
  var rows = supabaseSelect('maintenance_schedules', 'asset_id,title', 'id=eq.' + id);
  supabaseDelete('maintenance_schedules', 'id=eq.' + id);
  if (rows && rows.length > 0) logAudit(rows[0].asset_id, 'ลบตาราง PM', rows[0].title);
  return { success: true };
}

function calculateIntervalDays(frequency, customDays) {
  switch (frequency) {
    case 'daily': return 1;
    case 'weekly': return 7;
    case 'monthly': return 30;
    case 'quarterly': return 90;
    case 'yearly': return 365;
    case 'custom': return customDays || 30;
    default: return 30;
  }
}


// ====================================================================
//  CHECKOUT SERVICE — Asset Check-in / Check-out
// ====================================================================

function getCheckouts(params) {
  params = params || {};
  var filters = [];
  if (params.status) filters.push('status=eq.' + params.status);
  if (params.assetId) filters.push('asset_id=eq.' + params.assetId);
  var filter = filters.join('&');
  return supabaseSelect('asset_checkouts', '*, assets(name, asset_code)', filter, 'created_at.desc');
}

function checkoutAsset(data) {
  // check if already checked out
  var existing = supabaseSelect('asset_checkouts', 'id', 'asset_id=eq.' + data.asset_id + '&status=eq.checked_out');
  if (existing && existing.length > 0) {
    throw new Error('อุปกรณ์นี้ถูกยืมออกไปแล้ว');
  }

  var result = supabaseInsert('asset_checkouts', {
    asset_id: data.asset_id,
    checked_out_to: data.checked_out_to,
    department: data.department || null,
    expected_return_date: data.expected_return_date || null,
    notes: data.notes || null,
    status: 'checked_out'
  });

  logAudit(data.asset_id, 'ยืมอุปกรณ์', 'ผู้ยืม: ' + data.checked_out_to);
  createAppNotification({
    title: 'ยืมอุปกรณ์',
    message: data.checked_out_to + ' ยืม ' + (data.asset_name || ''),
    type: 'checkout', severity: 'info',
    asset_id: data.asset_id, link_page: 'checkouts'
  });
  return result[0];
}

function checkinAsset(id) {
  var rows = supabaseSelect('asset_checkouts', '*, assets(name)', 'id=eq.' + id);
  if (!rows || rows.length === 0) throw new Error('Checkout not found');
  var co = rows[0];

  supabaseUpdate('asset_checkouts', 'id=eq.' + id, {
    actual_return_date: new Date().toISOString(),
    status: 'returned'
  });

  logAudit(co.asset_id, 'คืนอุปกรณ์', 'ผู้ยืม: ' + co.checked_out_to);
  return { success: true };
}

function getAssetCheckoutHistory(assetId) {
  return supabaseSelect('asset_checkouts', '*', 'asset_id=eq.' + assetId, 'created_at.desc');
}


// ====================================================================
//  IN-APP NOTIFICATION SERVICE
// ====================================================================

function getNotifications(limit) {
  return supabaseSelect('notifications', '*', null, 'created_at.desc', false, limit || 20);
}

function getUnreadNotificationCount() {
  var rows = supabaseSelect('notifications', 'id', 'is_read=eq.false');
  return { count: rows ? rows.length : 0 };
}

function markNotificationRead(id) {
  supabaseUpdate('notifications', 'id=eq.' + id, { is_read: true });
  return { success: true };
}

function markAllNotificationsRead() {
  supabaseUpdate('notifications', 'is_read=eq.false', { is_read: true });
  return { success: true };
}

function createAppNotification(data) {
  try {
    supabaseInsert('notifications', {
      title: data.title,
      message: data.message || '',
      type: data.type || 'system',
      severity: data.severity || 'info',
      asset_id: data.asset_id || null,
      link_page: data.link_page || null,
      link_params: data.link_params || null,
      is_read: false
    });
  } catch(e) {
    Logger.log('Notification insert error: ' + e.message);
  }
}


// ====================================================================
//  SYSTEM INFO & DATA MANAGEMENT
// ====================================================================

function getSystemInfo() {
  var baseUrl = CONFIG.SUPABASE_URL + '/rest/v1/';
  var headers = {
    'apikey': CONFIG.SUPABASE_KEY,
    'Authorization': 'Bearer ' + CONFIG.SUPABASE_KEY,
    'Content-Type': 'application/json',
    'Prefer': 'count=exact'
  };
  var requests = [
    { url: baseUrl + 'assets?select=id&limit=0', headers: headers, muteHttpExceptions: true },
    { url: baseUrl + 'repair_tickets?select=id&limit=0', headers: headers, muteHttpExceptions: true },
    { url: baseUrl + 'licenses?select=id&limit=0', headers: headers, muteHttpExceptions: true },
    { url: baseUrl + 'audit_log?select=id&limit=0', headers: headers, muteHttpExceptions: true },
    { url: baseUrl + 'maintenance_schedules?select=id&limit=0', headers: headers, muteHttpExceptions: true },
    { url: baseUrl + 'asset_checkouts?select=id&limit=0', headers: headers, muteHttpExceptions: true }
  ];
  var responses = UrlFetchApp.fetchAll(requests);

  function getCount(resp) {
    var range = resp.getHeaders()['content-range'] || '';
    var m = range.match(/\/(\d+)/);
    return m ? parseInt(m[1]) : JSON.parse(resp.getContentText()).length;
  }

  // Check trigger status
  var triggers = ScriptApp.getProjectTriggers();
  var warrantyTrigger = null;
  triggers.forEach(function (t) {
    if (t.getHandlerFunction() === 'checkWarrantyAndNotify') {
      warrantyTrigger = { id: t.getUniqueId(), type: t.getEventType().toString() };
    }
  });

  return {
    assetCount: getCount(responses[0]),
    ticketCount: getCount(responses[1]),
    licenseCount: getCount(responses[2]),
    auditLogCount: getCount(responses[3]),
    maintenanceCount: getCount(responses[4]),
    checkoutCount: getCount(responses[5]),
    webAppUrl: ScriptApp.getService().getUrl(),
    warrantyTrigger: warrantyTrigger,
    version: '2.5.0'
  };
}

function purgeOldAuditLogs(monthsOld) {
  monthsOld = monthsOld || 6;
  var cutoff = new Date();
  cutoff.setMonth(cutoff.getMonth() - monthsOld);
  var cutoffStr = cutoff.toISOString();

  var old = supabaseSelect('audit_log', 'id', 'created_at=lt.' + cutoffStr);
  var count = old ? old.length : 0;

  if (count > 0) {
    supabaseDelete('audit_log', 'created_at=lt.' + cutoffStr);
    logAudit(null, '\u0e25\u0e49\u0e32\u0e07 Audit Log', '\u0e25\u0e1a ' + count + ' \u0e23\u0e32\u0e22\u0e01\u0e32\u0e23\u0e17\u0e35\u0e48\u0e40\u0e01\u0e48\u0e32\u0e01\u0e27\u0e48\u0e32 ' + monthsOld + ' \u0e40\u0e14\u0e37\u0e2d\u0e19');
  }
  return { success: true, deleted: count };
}

function removeDailyWarrantyCheck() {
  var triggers = ScriptApp.getProjectTriggers();
  var removed = 0;
  triggers.forEach(function (trigger) {
    if (trigger.getHandlerFunction() === 'checkWarrantyAndNotify') {
      ScriptApp.deleteTrigger(trigger);
      removed++;
    }
  });
  return { success: true, removed: removed };
}

function renameCategory(id, newName) {
  supabaseUpdate('categories', 'id=eq.' + id, { name: newName });
  return { success: true };
}

function renameDepartment(id, newName) {
  supabaseUpdate('departments', 'id=eq.' + id, { name: newName });
  return { success: true };
}
