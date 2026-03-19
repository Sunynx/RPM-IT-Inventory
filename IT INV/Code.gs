/**
 * AssetQR — IT Asset Inventory System
 * Main Entry Point + Settings
 */

// ============ CONFIG ============
const CONFIG = {
  SUPABASE_URL: 'https://xvcgnhcnxmiteyuibfvj.supabase.co',        // e.g. https://xxxx.supabase.co
  SUPABASE_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2Y2duaGNueG1pdGV5dWliZnZqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc0NzY0OTQsImV4cCI6MjA4MzA1MjQ5NH0.M6hvCeQGc9bFJ_pOsoVU-GulpNFicYwJBgbBH3g00o4',   // anon/public key
  APP_TITLE: 'IT Asset Inventory System'
};

// ============ WEB APP ENTRY ============
function doGet(e) {
  const page = e && e.parameter && e.parameter.page ? e.parameter.page : 'index';
  
  // If scanning QR — show asset detail page directly
  if (e && e.parameter && e.parameter.id) {
    const template = HtmlService.createTemplateFromFile('index');
    template.initialPage = 'asset-detail';
    template.initialAssetId = e.parameter.id;
    return template.evaluate()
      .setTitle(CONFIG.APP_TITLE)
      .setXFrameOptionsMode(HtmlService. XFrameOptionsMode.ALLOWALL)
      .addMetaTag('viewport', 'width=device-width, initial-scale=1, maximum-scale=1');
  }
  
  const template = HtmlService.createTemplateFromFile('index');
  template.initialPage = 'dashboard';
  template.initialAssetId = '';
  return template.evaluate()
    .setTitle(CONFIG.APP_TITLE)
    .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL)
    .addMetaTag('viewport', 'width=device-width, initial-scale=1, maximum-scale=1');
}

// ============ INCLUDE HTML FILES ============
function include(filename) {
  return HtmlService.createHtmlOutputFromFile(filename).getContent();
}

// ============ GET CONFIG (for client) ============
function getConfig() {
  return {
    supabaseUrl: CONFIG.SUPABASE_URL,
    supabaseKey: CONFIG.SUPABASE_KEY,
    appTitle: CONFIG.APP_TITLE
  };
}

// ============ GENERATE ASSET CODE ============
function generateAssetCode(categoryPrefix) {
  const prefix = categoryPrefix || 'IT';
  const year = new Date().getFullYear() + 543; // Buddhist year
  const yearShort = String(year).slice(-2);
  
  // Get count of assets this year
  const startOfYear = new Date(new Date().getFullYear(), 0, 1).toISOString();
  const result = supabaseSelect('assets', `id`, `created_at=gte.${startOfYear}`, null, true);
  const count = result && result.length ? result.length + 1 : 1;
  const seq = String(count).padStart(4, '0');
  
  return `${prefix}-${yearShort}${String(new Date().getMonth() + 1).padStart(2, '0')}-${seq}`;
}

// ============ SETTINGS SERVICE ============
function getSettings() {
  const rows = supabaseSelect('settings', '*');
  const settings = {};
  if (rows) {
    rows.forEach(function(r) {
      settings[r.key] = r.value;
    });
  }
  return settings;
}

function updateSettings(data) {
  const keys = Object.keys(data);
  keys.forEach(function(key) {
    try {
      const existing = supabaseSelect('settings', 'id', 'key=eq.' + key);
      if (existing && existing.length > 0) {
        supabaseUpdate('settings', 'key=eq.' + key, { value: data[key] });
      } else {
        supabaseInsert('settings', { key: key, value: data[key] });
      }
    } catch(e) {
      Logger.log('Settings update error for ' + key + ': ' + e.message);
    }
  });
  
  logAudit(null, 'อัปเดตการตั้งค่า', 'เปลี่ยนค่า: ' + keys.join(', '));
  return { success: true };
}

function getWebAppUrl() {
  const settings = getSettings();
  return settings.base_url || ScriptApp.getService().getUrl();
}

function testConnection() {
  try {
    const result = supabaseSelect('settings', 'id', null, null, false, 1);
    return { success: true };
  } catch(e) {
    return { success: false, error: e.message };
  }
}
