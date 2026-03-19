/**
 * fix_all_emoji.js
 * Replaces ALL raw non-ASCII characters (emoji, special symbols)
 * in HTML files with HTML numeric character references (&#CODEPOINT;)
 * so that GAS's document.write() can handle them safely.
 *
 * Thai characters (U+0E00–U+0E7F) are preserved as-is.
 */
const fs = require('fs');

const FILES = ['app.html', 'components.html', 'pages.html', 'index.html', 'styles.html'];

// Characters we want to KEEP as-is (Thai range)
function isThai(cp) {
    return cp >= 0x0E00 && cp <= 0x0E7F;
}

// Common safe ASCII-range chars we keep as-is
function isSafeASCII(cp) {
    return cp <= 127;
}

function encodeToHTMLEntity(str) {
    let result = '';
    let i = 0;
    while (i < str.length) {
        const cp = str.codePointAt(i);
        const charLen = cp > 0xFFFF ? 2 : 1; // surrogate pair takes 2 JS chars

        if (isSafeASCII(cp) || isThai(cp)) {
            result += str[i];
            i++;
        } else {
            // Encode as HTML numeric character reference
            result += '&#' + cp + ';';
            i += charLen;
        }
    }
    return result;
}

let totalFixed = 0;

FILES.forEach(filename => {
    if (!fs.existsSync(filename)) {
        console.log('SKIP (not found): ' + filename);
        return;
    }

    const original = fs.readFileSync(filename, 'utf8');
    const fixed = encodeToHTMLEntity(original);

    const changed = (original !== fixed);
    if (changed) {
        fs.writeFileSync(filename, fixed, 'utf8');
        // Count chars changed
        let count = 0;
        for (let i = 0; i < original.length; i++) {
            if (original.codePointAt(i) > 127 && !isThai(original.codePointAt(i))) count++;
        }
        totalFixed += count;
        console.log('FIXED: ' + filename + ' (' + count + ' non-ASCII chars encoded)');
    } else {
        console.log('OK:    ' + filename + ' (no changes needed)');
    }
});

console.log('\nTotal chars encoded: ' + totalFixed);
console.log('Done! Run: clasp push --force');
