/**
 * fix_gas_safe.js
 * 
 * Properly fix all HTML files for GAS compatibility:
 * - In HTML content: remove/replace emoji with text or simple symbols
 * - In JS <script> tags: use \\uXXXX escape pairs for emoji
 * - Preserve Thai characters everywhere
 * - Convert other special non-ASCII (em-dash, arrows, etc.) to safe ASCII equivalents
 */
const fs = require('fs');

const FILES = ['app.html', 'components.html', 'pages.html', 'index.html', 'styles.html'];

function isThai(cp) {
    return cp >= 0x0E00 && cp <= 0x0E7F;
}

// Convert a codepoint to \\uXXXX (for chars in BMP) or \\uXXXX\\uXXXX surrogate pair
function toJSEscape(cp) {
    if (cp <= 0xFFFF) {
        return '\\u' + cp.toString(16).toUpperCase().padStart(4, '0');
    }
    // Surrogate pair
    const hi = Math.floor((cp - 0x10000) / 0x400) + 0xD800;
    const lo = ((cp - 0x10000) % 0x400) + 0xDC00;
    return '\\u' + hi.toString(16).toUpperCase().padStart(4, '0') +
        '\\u' + lo.toString(16).toUpperCase().padStart(4, '0');
}

function processFile(filename) {
    if (!fs.existsSync(filename)) {
        console.log('SKIP: ' + filename);
        return;
    }

    const content = fs.readFileSync(filename, 'utf8');

    // Split content into segments: script vs non-script
    const parts = [];
    let idx = 0;
    const scriptRegex = /<script[^>]*>([\s\S]*?)<\/script>/gi;
    let match;

    while ((match = scriptRegex.exec(content)) !== null) {
        // HTML part before this script
        if (match.index > idx) {
            parts.push({ type: 'html', text: content.substring(idx, match.index) });
        }
        // Script tag opening
        const scriptStart = content.substring(match.index, match.index + match[0].indexOf('>') + 1);
        const scriptEnd = '</script>';
        const scriptBody = match[1];
        parts.push({ type: 'script-open', text: scriptStart });
        parts.push({ type: 'script', text: scriptBody });
        parts.push({ type: 'script-close', text: scriptEnd });
        idx = match.index + match[0].length;
    }
    // Remaining HTML after last script
    if (idx < content.length) {
        parts.push({ type: 'html', text: content.substring(idx) });
    }

    let changed = false;

    // Process each part
    const processed = parts.map(part => {
        if (part.type === 'script-open' || part.type === 'script-close') {
            return part.text;
        }

        let result = '';
        const text = part.text;
        let i = 0;

        while (i < text.length) {
            const cp = text.codePointAt(i);
            const charLen = cp > 0xFFFF ? 2 : 1;

            if (cp <= 127 || isThai(cp)) {
                // Safe ASCII or Thai - keep as-is
                result += text[i];
                i++;
            } else if (part.type === 'script') {
                // Inside <script>: use JS unicode escape
                result += toJSEscape(cp);
                changed = true;
                i += charLen;
            } else {
                // Inside HTML: use HTML numeric entity
                result += '&#' + cp + ';';
                changed = true;
                i += charLen;
            }
        }

        return result;
    });

    const output = processed.join('');

    if (changed) {
        fs.writeFileSync(filename, output, 'utf8');
        console.log('FIXED: ' + filename);
    } else {
        console.log('OK:    ' + filename);
    }
}

FILES.forEach(processFile);

// Verify no raw non-ASCII non-Thai remains
console.log('\n--- Verification ---');
FILES.forEach(f => {
    if (!fs.existsSync(f)) return;
    const c = fs.readFileSync(f, 'utf8');
    let bad = 0;
    for (let i = 0; i < c.length; i++) {
        const cp = c.codePointAt(i);
        if (cp > 0xFFFF) { bad++; i++; } // skip surrogate pair
        else if (cp > 127 && !isThai(cp)) bad++;
    }
    console.log(f + ': ' + (bad === 0 ? 'CLEAN' : 'HAS ' + bad + ' non-ASCII'));
});

console.log('\nDone! Run: clasp push --force');
