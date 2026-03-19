/**
 * Database.gs — Supabase REST API Helper
 * All database operations via UrlFetchApp
 */

/**
 * Generic Supabase SELECT
 * @param {string} table - Table name
 * @param {string} select - Columns to select (e.g. "*", "id,name")
 * @param {string} filter - PostgREST filter (e.g. "status=eq.ใช้งาน")
 * @param {string} order - Order (e.g. "created_at.desc")
 * @param {boolean} returnCount - Whether to just return data (false) or include count header
 * @param {number} limit - Limit number of rows
 * @param {number} offset - Offset for pagination
 * @returns {Array|Object}
 */
function supabaseSelect(table, select, filter, order, returnAll, limit, offset) {
  let url = `${CONFIG.SUPABASE_URL}/rest/v1/${table}?select=${encodeURIComponent(select || '*')}`;
  
  if (filter) {
    // filter can be multiple conditions joined by &
    url += '&' + filter;
  }
  if (order) {
    url += '&order=' + encodeURIComponent(order);
  }
  if (limit) {
    url += '&limit=' + limit;
  }
  if (offset) {
    url += '&offset=' + offset;
  }
  
  const options = {
    method: 'GET',
    headers: {
      'apikey': CONFIG.SUPABASE_KEY,
      'Authorization': 'Bearer ' + CONFIG.SUPABASE_KEY,
      'Content-Type': 'application/json',
      'Prefer': returnAll ? 'count=exact' : ''
    },
    muteHttpExceptions: true
  };
  
  const response = UrlFetchApp.fetch(url, options);
  const code = response.getResponseCode();
  
  if (code >= 200 && code < 300) {
    const data = JSON.parse(response.getContentText());
    if (returnAll) {
      const headers = response.getHeaders();
      const contentRange = headers['Content-Range'] || headers['content-range'] || headers['CONTENT-RANGE'] || '';
      const total = contentRange.split('/')[1] || data.length;
      return { data: data, total: parseInt(total) };
    }
    return data;
  } else {
    Logger.log('Supabase SELECT error: ' + response.getContentText());
    throw new Error('Database error: ' + response.getContentText());
  }
}

/**
 * Generic Supabase INSERT
 * @param {string} table
 * @param {Object|Array} data
 * @returns {Array} inserted rows
 */
function supabaseInsert(table, data) {
  const url = `${CONFIG.SUPABASE_URL}/rest/v1/${table}`;
  
  const options = {
    method: 'POST',
    headers: {
      'apikey': CONFIG.SUPABASE_KEY,
      'Authorization': 'Bearer ' + CONFIG.SUPABASE_KEY,
      'Content-Type': 'application/json',
      'Prefer': 'return=representation'
    },
    payload: JSON.stringify(data),
    muteHttpExceptions: true
  };
  
  const response = UrlFetchApp.fetch(url, options);
  const code = response.getResponseCode();
  
  if (code >= 200 && code < 300) {
    return JSON.parse(response.getContentText());
  } else {
    Logger.log('Supabase INSERT error: ' + response.getContentText());
    throw new Error('Database error: ' + response.getContentText());
  }
}

/**
 * Generic Supabase UPDATE
 * @param {string} table
 * @param {string} filter - e.g. "id=eq.xxxx"
 * @param {Object} data
 * @returns {Array} updated rows
 */
function supabaseUpdate(table, filter, data) {
  const url = `${CONFIG.SUPABASE_URL}/rest/v1/${table}?${filter}`;
  
  const options = {
    method: 'PATCH',
    headers: {
      'apikey': CONFIG.SUPABASE_KEY,
      'Authorization': 'Bearer ' + CONFIG.SUPABASE_KEY,
      'Content-Type': 'application/json',
      'Prefer': 'return=representation'
    },
    payload: JSON.stringify(data),
    muteHttpExceptions: true
  };
  
  const response = UrlFetchApp.fetch(url, options);
  const code = response.getResponseCode();
  
  if (code >= 200 && code < 300) {
    return JSON.parse(response.getContentText());
  } else {
    Logger.log('Supabase UPDATE error: ' + response.getContentText());
    throw new Error('Database error: ' + response.getContentText());
  }
}

/**
 * Generic Supabase DELETE
 * @param {string} table
 * @param {string} filter - e.g. "id=eq.xxxx"
 * @returns {Array} deleted rows
 */
function supabaseDelete(table, filter) {
  const url = `${CONFIG.SUPABASE_URL}/rest/v1/${table}?${filter}`;
  
  const options = {
    method: 'DELETE',
    headers: {
      'apikey': CONFIG.SUPABASE_KEY,
      'Authorization': 'Bearer ' + CONFIG.SUPABASE_KEY,
      'Content-Type': 'application/json',
      'Prefer': 'return=representation'
    },
    muteHttpExceptions: true
  };
  
  const response = UrlFetchApp.fetch(url, options);
  const code = response.getResponseCode();
  
  if (code >= 200 && code < 300) {
    return JSON.parse(response.getContentText());
  } else {
    Logger.log('Supabase DELETE error: ' + response.getContentText());
    throw new Error('Database error: ' + response.getContentText());
  }
}

/**
 * Upload file to Supabase Storage
 * @param {string} bucket - Bucket name
 * @param {string} path - File path in bucket
 * @param {string} base64Data - Base64 encoded file data
 * @param {string} contentType - MIME type
 * @returns {string} Public URL
 */
function supabaseUpload(bucket, path, base64Data, contentType) {
  const url = `${CONFIG.SUPABASE_URL}/storage/v1/object/${bucket}/${path}`;
  
  const blob = Utilities.newBlob(Utilities.base64Decode(base64Data), contentType, path);
  
  const options = {
    method: 'POST',
    headers: {
      'apikey': CONFIG.SUPABASE_KEY,
      'Authorization': 'Bearer ' + CONFIG.SUPABASE_KEY,
      'Content-Type': contentType,
      'x-upsert': 'true'
    },
    payload: blob.getBytes(),
    muteHttpExceptions: true
  };
  
  const response = UrlFetchApp.fetch(url, options);
  const code = response.getResponseCode();
  
  if (code >= 200 && code < 300) {
    // Return public URL
    return `${CONFIG.SUPABASE_URL}/storage/v1/object/public/${bucket}/${path}`;
  } else {
    Logger.log('Supabase Upload error: ' + response.getContentText());
    throw new Error('Upload error: ' + response.getContentText());
  }
}

/**
 * Delete file from Supabase Storage
 */
function supabaseDeleteFile(bucket, path) {
  const url = `${CONFIG.SUPABASE_URL}/storage/v1/object/${bucket}/${path}`;
  
  const options = {
    method: 'DELETE',
    headers: {
      'apikey': CONFIG.SUPABASE_KEY,
      'Authorization': 'Bearer ' + CONFIG.SUPABASE_KEY
    },
    muteHttpExceptions: true
  };
  
  return UrlFetchApp.fetch(url, options);
}

/**
 * Supabase RPC (call stored function)
 */
function supabaseRpc(functionName, params) {
  const url = `${CONFIG.SUPABASE_URL}/rest/v1/rpc/${functionName}`;
  
  const options = {
    method: 'POST',
    headers: {
      'apikey': CONFIG.SUPABASE_KEY,
      'Authorization': 'Bearer ' + CONFIG.SUPABASE_KEY,
      'Content-Type': 'application/json'
    },
    payload: JSON.stringify(params || {}),
    muteHttpExceptions: true
  };
  
  const response = UrlFetchApp.fetch(url, options);
  const code = response.getResponseCode();
  
  if (code >= 200 && code < 300) {
    return JSON.parse(response.getContentText());
  } else {
    Logger.log('Supabase RPC error: ' + response.getContentText());
    throw new Error('RPC error: ' + response.getContentText());
  }
}
