'use strict';

/**
 * Copies the Flutter web release build into ./web so electron-builder can
 * package it inside the app. Run after `flutter build web --release`.
 */

const fs = require('node:fs');
const path = require('node:path');

const root = path.resolve(__dirname, '..', '..');
const source = path.join(root, 'build', 'web');
const target = path.resolve(__dirname, '..', 'web');

if (!fs.existsSync(path.join(source, 'index.html'))) {
  console.error(
    `No web build found at ${source}\n` +
      'Run "flutter build web --release" in the project root first.',
  );
  process.exit(1);
}

fs.rmSync(target, { recursive: true, force: true });
fs.mkdirSync(target, { recursive: true });
fs.cpSync(source, target, { recursive: true });

const count = fs.readdirSync(target).length;
console.log(`Synced ${count} top-level entries into ${target}`);
