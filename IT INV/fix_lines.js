const fs = require('fs');
const file = 'c:\\Users\\ChatcharitP\\Desktop\\IT INV\\pages.html';
let lines = fs.readFileSync(file, 'utf8').split('\n');

// Fix lines 1058 and 1059 (0-indexed: 1057, 1058)
// Replace both broken lines with single clean line
for (let i = 0; i < lines.length; i++) {
  if (lines[i].includes('asset.user_position') && lines[i].includes("'';")) {
    lines[i] = "          var sPos = asset.user_position || '';";
    // Remove the next line (duplicate sPos with signer_position)
    if (i + 1 < lines.length && lines[i+1].includes('signer_position')) {
      lines.splice(i + 1, 1);
    }
    break;
  }
}

fs.writeFileSync(file, lines.join('\n'), 'utf8');
console.log('Fixed!');
