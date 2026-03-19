const fs = require('fs');
const path = require('path');

const artifactDir = 'C:\\Users\\ChatcharitP\\.gemini\\antigravity\\brain\\b7cae7b2-754d-48c9-b5fe-9b034e4675a7';
const componentsHtmlPath = path.join(__dirname, 'components.html');

try {
    // Find the most recently modified image file
    const files = fs.readdirSync(artifactDir)
        .filter(f => f.match(/\.(png|jpe?g)$/i))
        .map(f => ({
            name: f,
            time: fs.statSync(path.join(artifactDir, f)).mtime.getTime()
        }))
        .sort((a, b) => b.time - a.time);

    if (files.length === 0) {
        console.error('No image files found in artifact directory.');
        process.exit(1);
    }

    const latestImage = files[0].name;
    const imagePath = path.join(artifactDir, latestImage);
    console.log(`Using latest image: ${latestImage}`);

    const ext = latestImage.toLowerCase().endsWith('jpg') || latestImage.toLowerCase().endsWith('jpeg') ? 'jpeg' : 'png';

    const imageBuffer = fs.readFileSync(imagePath);
    const base64Image = imageBuffer.toString('base64');
    const dataUrl = `data:image/${ext};base64,${base64Image}`;

    let htmlContent = fs.readFileSync(componentsHtmlPath, 'utf8');

    // Replace the existing src inside the sidebar-logo div
    const regex = /(<div class="sidebar-logo"[^>]*>\s*<img src=")[^"]+(")/i;

    if (regex.test(htmlContent)) {
        htmlContent = htmlContent.replace(regex, `$1${dataUrl}$2`);
        fs.writeFileSync(componentsHtmlPath, htmlContent, 'utf8');
        console.log('Successfully updated logo in components.html');
    } else {
        console.error('Could not find the img tag to replace in components.html');
    }
} catch (err) {
    console.error('Error:', err);
}
