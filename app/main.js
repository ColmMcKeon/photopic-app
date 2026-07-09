const { app, BrowserWindow, ipcMain, dialog } = require('electron');
const path = require('path');
const fs   = require('fs');
const os   = require('os');
const crypto = require('crypto');
const { execFile } = require('child_process');
const execFileP = require('util').promisify(execFile);

// Allow slideshow background music to start without a per-play user gesture
// (Chromium/Electron otherwise blocks programmatic audio playback).
app.commandLine.appendSwitch('autoplay-policy', 'no-user-gesture-required');

// Album data lives at …/claude-workspace/photopic/data.
// In dev (`npm start`) __dirname is …/photopic/app, so the relative path
// resolves there. In a packaged .app __dirname is inside the read-only bundle,
// so fall back to the fixed workspace path — both point at the same library.
const WORKSPACE_DATA = path.join(os.homedir(), 'Library', 'CloudStorage', 'OneDrive-Adobe', 'Work', 'Development', 'claude-workspace', 'photopic', 'data');
const DATA_DIR = app.isPackaged ? WORKSPACE_DATA : path.join(__dirname, '..', 'data');
const THUMB_DIR = path.join(DATA_DIR, '.thumbs');
const THUMB_SIZE = 600; // max long-edge px for cached grid thumbnails

let mainWindow = null;
let currentFile = null; // active album file path

function createWindow() {
  mainWindow = new BrowserWindow({
    width:  900,
    height: 620,
    minWidth:  560,
    minHeight: 420,
    title: 'Photopic',
    backgroundColor: '#111111',
    titleBarStyle: 'hiddenInset',
    trafficLightPosition: { x: 14, y: 14 },
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
    },
  });
  mainWindow.loadFile('photopic.html');
  mainWindow.setMenuBarVisibility(false);
}

app.whenReady().then(() => {
  createWindow();
  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});
app.on('window-all-closed', () => app.quit());

// ── Album management ──
ipcMain.handle('list-albums', () => {
  try {
    if (!fs.existsSync(DATA_DIR)) fs.mkdirSync(DATA_DIR, { recursive: true });
    return fs.readdirSync(DATA_DIR)
      .filter(f => f.endsWith('.json'))
      .map(f => {
        const fp   = path.join(DATA_DIR, f);
        const stat = fs.statSync(fp);
        let count = 0;
        try { count = (JSON.parse(fs.readFileSync(fp, 'utf8')).photos || []).length; } catch {}
        return { name: f.replace(/\.json$/, ''), filename: f, modified: stat.mtimeMs, count };
      })
      .sort((a, b) => b.modified - a.modified);
  } catch { return []; }
});

ipcMain.handle('load-album', (e, filename) => {
  try {
    const fp = path.join(DATA_DIR, filename);
    currentFile = fp;
    if (fs.existsSync(fp)) return JSON.parse(fs.readFileSync(fp, 'utf8'));
    return null;
  } catch { return null; }
});

ipcMain.handle('create-album', (e, name) => {
  try {
    if (!fs.existsSync(DATA_DIR)) fs.mkdirSync(DATA_DIR, { recursive: true });
    const filename = `${name.replace(/[^a-z0-9 _-]/gi, '_')}.json`;
    const fp = path.join(DATA_DIR, filename);
    if (!fs.existsSync(fp)) fs.writeFileSync(fp, JSON.stringify({ albumName: name, photos: [] }, null, 2));
    currentFile = fp;
    return filename;
  } catch { return null; }
});

ipcMain.handle('save-data', (e, data) => {
  try {
    if (!currentFile) return false;
    if (!fs.existsSync(DATA_DIR)) fs.mkdirSync(DATA_DIR, { recursive: true });
    fs.writeFileSync(currentFile, JSON.stringify(data, null, 2), 'utf8');
    return true;
  } catch { return false; }
});

ipcMain.handle('delete-album', (e, filename) => {
  try {
    const fp = path.join(DATA_DIR, filename);
    if (fs.existsSync(fp)) fs.unlinkSync(fp);
    if (currentFile === fp) currentFile = null;
    return true;
  } catch { return false; }
});

ipcMain.handle('rename-album', (e, oldFilename, newName) => {
  try {
    const oldPath = path.join(DATA_DIR, oldFilename);
    const newFilename = `${newName.replace(/[^a-z0-9 _-]/gi, '_')}.json`;
    const newPath = path.join(DATA_DIR, newFilename);
    if (!fs.existsSync(oldPath)) return null;
    if (newPath !== oldPath && fs.existsSync(newPath)) return null; // name taken
    // Update the display name stored inside the file, then rename the file.
    try {
      const data = JSON.parse(fs.readFileSync(oldPath, 'utf8'));
      data.albumName = newName;
      fs.writeFileSync(oldPath, JSON.stringify(data, null, 2), 'utf8');
    } catch { /* leave contents as-is if unreadable */ }
    if (newPath !== oldPath) fs.renameSync(oldPath, newPath);
    if (currentFile === oldPath) currentFile = newPath;
    return newFilename;
  } catch { return null; }
});

// ── File helpers ──
ipcMain.handle('file-exists', (e, filePath) => {
  try { return fs.existsSync(filePath); } catch { return false; }
});

// Return a cached, downscaled thumbnail for the grid (generating it once with
// `sips`). The key includes the source mtime so edited files regenerate.
// Full-resolution originals are still used for the expanded view + slideshow.
ipcMain.handle('get-thumb', async (e, src) => {
  try {
    if (!fs.existsSync(src)) return null;
    const st = fs.statSync(src);
    const key = crypto.createHash('md5').update(`${src}:${st.mtimeMs}:${THUMB_SIZE}`).digest('hex');
    const ext = (src.split('.').pop() || 'jpg').toLowerCase();
    const outExt = ['jpg', 'jpeg', 'png'].includes(ext) ? ext : 'jpg';
    const out = path.join(THUMB_DIR, `${key}.${outExt}`);
    if (fs.existsSync(out)) return out;
    if (!fs.existsSync(THUMB_DIR)) fs.mkdirSync(THUMB_DIR, { recursive: true });
    await execFileP('sips', ['-Z', String(THUMB_SIZE), src, '--out', out]);
    return fs.existsSync(out) ? out : null;
  } catch { return null; }
});

const IMAGE_EXT = new Set(['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'avif']);

function scanDir(dir, results = [], visited = new Set()) {
  try {
    const real = fs.realpathSync(dir);
    if (visited.has(real)) return results;
    visited.add(real);
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      if (entry.isSymbolicLink()) continue; // skip aliases/symlinks
      if (entry.name.startsWith('.')) continue; // skip hidden files
      const full = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        scanDir(full, results, visited);
      } else if (entry.isFile()) {
        const ext = entry.name.split('.').pop().toLowerCase();
        if (IMAGE_EXT.has(ext)) results.push(full);
      }
    }
  } catch { /* skip unreadable dirs */ }
  return results;
}

// Returns image files from folder paths (recursive) or confirms file paths
ipcMain.handle('scan-paths', (e, paths) => {
  const results = [];
  for (const p of paths) {
    try {
      const stat = fs.statSync(p);
      if (stat.isDirectory()) {
        scanDir(p, results);
      } else {
        const ext = p.split('.').pop().toLowerCase();
        if (IMAGE_EXT.has(ext)) results.push(p);
      }
    } catch { /* skip */ }
  }
  // Natural sort so WorkImages2 comes before WorkImages10
  results.sort((a, b) => a.localeCompare(b, undefined, { numeric: true, sensitivity: 'base' }));
  return results;
});

ipcMain.handle('open-folder-dialog', async () => {
  const result = await dialog.showOpenDialog(mainWindow, {
    properties: ['openDirectory', 'multiSelections'],
  });
  return result.canceled ? [] : result.filePaths;
});

ipcMain.handle('open-music-dialog', async () => {
  const result = await dialog.showOpenDialog(mainWindow, {
    properties: ['openFile', 'multiSelections'],
    filters: [{ name: 'Audio', extensions: ['mp3', 'm4a', 'wav', 'ogg', 'aac', 'flac', 'aiff', 'aif'] }],
  });
  return result.canceled ? [] : result.filePaths;
});

ipcMain.handle('open-photos-dialog', async () => {
  const result = await dialog.showOpenDialog(mainWindow, {
    properties: ['openFile', 'multiSelections'],
    filters: [{ name: 'Images', extensions: [...IMAGE_EXT] }],
  });
  return result.canceled ? [] : result.filePaths;
});

// ── Window ──
ipcMain.handle('toggle-fullscreen', () => {
  if (!mainWindow) return false;
  const next = !mainWindow.isFullScreen();
  mainWindow.setFullScreen(next);
  return next;
});

ipcMain.handle('set-fullscreen', (e, val) => {
  if (!mainWindow) return false;
  const prev = mainWindow.isFullScreen();
  mainWindow.setFullScreen(!!val);
  return prev; // caller can restore the previous state later
});
