'use strict';

const { app, BrowserWindow, Menu, shell } = require('electron');
const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');

const WEB_DIR = path.join(__dirname, 'web');
const INDEX = path.join(WEB_DIR, 'index.html');

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.wasm': 'application/wasm',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.map': 'application/json; charset=utf-8',
  '.txt': 'text/plain; charset=utf-8',
};

let server = null;

function serveFile(res, filePath) {
  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
      res.end('Not found');
      return;
    }
    res.writeHead(200, {
      'Content-Type': MIME[path.extname(filePath).toLowerCase()] ||
        'application/octet-stream',
      'Cache-Control': 'no-cache',
    });
    res.end(data);
  });
}

function startServer() {
  return new Promise((resolve, reject) => {
    server = http.createServer((req, res) => {
      let rel;
      try {
        rel = decodeURIComponent((req.url || '/').split('?')[0]);
      } catch {
        res.writeHead(400).end();
        return;
      }
      const resolved = path.resolve(WEB_DIR, '.' + rel);
      // Never serve anything outside the bundled web directory. Compare with a
      // trailing separator so a sibling like "web-old" cannot match the prefix.
      if (resolved !== WEB_DIR && !resolved.startsWith(WEB_DIR + path.sep)) {
        res.writeHead(403, { 'Content-Type': 'text/plain' });
        res.end('Forbidden');
        return;
      }
      fs.stat(resolved, (err, stat) => {
        if (!err && stat.isFile()) {
          serveFile(res, resolved);
        } else {
          serveFile(res, INDEX);
        }
      });
    });
    server.on('error', reject);
    server.listen(0, '127.0.0.1', () => resolve(server.address().port));
  });
}

function createWindow(port) {
  const win = new BrowserWindow({
    width: 470,
    height: 830,
    minWidth: 380,
    minHeight: 620,
    backgroundColor: '#121317',
    title: 'VECTORCALC',
    show: false,
    autoHideMenuBar: true,
    icon: path.join(__dirname, 'build-resources', 'icon.png'),
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true,
      spellcheck: false,
      devTools: !app.isPackaged,
    },
  });

  win.setMenuBarVisibility(false);
  win.once('ready-to-show', () => win.show());

  // Keep the app self-contained: no external navigation, no popups.
  win.webContents.setWindowOpenHandler(({ url }) => {
    if (url.startsWith('http://127.0.0.1:') || url.startsWith('file://')) {
      return { action: 'allow' };
    }
    shell.openExternal(url);
    return { action: 'deny' };
  });

  win.webContents.on('will-navigate', (event, url) => {
    const local = `http://127.0.0.1:${port}`;
    if (!url.startsWith(local)) {
      event.preventDefault();
    }
  });

  win.loadURL(`http://127.0.0.1:${port}/`);
  return win;
}

if (!app.requestSingleInstanceLock()) {
  app.quit();
} else {
  app.on('second-instance', () => {
    const [win] = BrowserWindow.getAllWindows();
    if (win) {
      if (win.isMinimized()) win.restore();
      win.focus();
    }
  });

  app.whenReady().then(async () => {
    if (!fs.existsSync(INDEX)) {
      const { dialog } = require('electron');
      dialog.showErrorBox(
        'VECTORCALC',
        'The web build is missing.\n\nRun "flutter build web --release" in the ' +
          'project root, then "npm run sync" inside the desktop folder.',
      );
      app.quit();
      return;
    }
    Menu.setApplicationMenu(null);
    const port = await startServer();
    createWindow(port);

    app.on('activate', () => {
      if (BrowserWindow.getAllWindows().length === 0) createWindow(port);
    });
  });

  app.on('window-all-closed', () => {
    if (server) server.close();
    if (process.platform !== 'darwin') app.quit();
  });

  app.on('before-quit', () => {
    if (server) server.close();
  });
}
