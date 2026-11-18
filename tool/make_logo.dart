// Turns the supplied DI.jpeg (actually a PNG) into a transparent logo mark.
//
// The artwork is a green symbol printed on a solid cream plate. Only the
// cream connected to the image border is removed, so any cream used *inside*
// the mark is preserved. Edge pixels get a feathered alpha so the mark sits
// cleanly on dark and light themes.
//
// Run from the project root:
//   dart run tool/make_logo.dart
import 'dart:io';

import 'package:image/image.dart' as img;

const int _creamR = 0xFF;
const int _creamG = 0xE8;
const int _creamB = 0xC2;

int _dist2(img.Pixel p) {
  final dr = p.r.toInt() - _creamR;
  final dg = p.g.toInt() - _creamG;
  final db = p.b.toInt() - _creamB;
  return dr * dr + dg * dg + db * db;
}

/// True for the cream plate and for the light strip along the source edge.
/// Only pixels connected to the image border are removed, so cream/white
/// used inside the mark survives.
bool _isPlate(img.Pixel p) {
  if (_dist2(p) <= 22 * 22) return true;
  return p.r.toInt() > 224 && p.g.toInt() > 224 && p.b.toInt() > 218;
}

void main() {
  final source = File('DI.jpeg');
  if (!source.existsSync()) {
    stderr.writeln('DI.jpeg not found in ${Directory.current.path}');
    exit(1);
  }

  final decoded = img.decodeImage(source.readAsBytesSync());
  if (decoded == null) {
    stderr.writeln('Could not decode DI.jpeg');
    exit(1);
  }
  final src = decoded.convert(numChannels: 4);
  final w = src.width;
  final h = src.height;

  const creamTol = 22 * 22;
  final outside = List.generate(h, (_) => List<bool>.filled(w, false));
  final stack = <int>[];

  void push(int x, int y) {
    if (x < 0 || y < 0 || x >= w || y >= h) return;
    final i = y * w + x;
    if (outside[y][x]) return;
    if (!_isPlate(src.getPixel(x, y))) return;
    outside[y][x] = true;
    stack.add(i);
  }

  for (var x = 0; x < w; x++) {
    push(x, 0);
    push(x, h - 1);
  }
  for (var y = 0; y < h; y++) {
    push(0, y);
    push(w - 1, y);
  }
  while (stack.isNotEmpty) {
    final i = stack.removeLast();
    final x = i % w;
    final y = i ~/ w;
    push(x + 1, y);
    push(x - 1, y);
    push(x, y + 1);
    push(x, y - 1);
  }

  bool touchesOutside(int x, int y) {
    for (var dy = -1; dy <= 1; dy++) {
      for (var dx = -1; dx <= 1; dx++) {
        final nx = x + dx;
        final ny = y + dy;
        if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
        if (outside[ny][nx]) return true;
      }
    }
    return false;
  }

  final out = img.Image(width: w, height: h, numChannels: 4);
  var kept = 0;
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      if (outside[y][x]) {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
        continue;
      }
      final p = src.getPixel(x, y);
      var alpha = p.a.toInt();
      if (alpha > 0 && touchesOutside(x, y)) {
        // Feather the anti-aliased rim: the closer to cream, the more
        // transparent the pixel becomes.
        final d = _dist2(p);
        final f = (d / creamTol).clamp(0.0, 1.0);
        alpha = (alpha * (0.25 + 0.75 * f)).round();
      }
      if (alpha > 0) kept++;
      out.setPixelRgba(x, y, p.r.toInt(), p.g.toInt(), p.b.toInt(), alpha);
    }
  }

  final trimmed = img.trim(out, mode: img.TrimMode.transparent);
  final dir = Directory('assets/logo');
  dir.createSync(recursive: true);
  final file = File('${dir.path}/mark.png');
  file.writeAsBytesSync(img.encodePng(trimmed));

  // A soft halo variant used for the animated glow. Same silhouette, tinted
  // with the mark's own green so it reads as light, not a drop shadow.
  final glow = img.Image(width: trimmed.width, height: trimmed.height,
      numChannels: 4);
  for (var y = 0; y < trimmed.height; y++) {
    for (var x = 0; x < trimmed.width; x++) {
      final p = trimmed.getPixel(x, y);
      if (p.a.toInt() < 24) {
        glow.setPixelRgba(x, y, 0, 0, 0, 0);
        continue;
      }
      final l = (p.r.toInt() + p.g.toInt() + p.b.toInt()) / 3;
      // Keep green pixels green, wash bright pixels toward the accent.
      final r = l > 200 ? 0x6B : 0x2F;
      final g = l > 200 ? 0xE0 : 0xA3;
      final b = l > 200 ? 0xB4 : 0x6B;
      glow.setPixelRgba(x, y, r, g, b, p.a.toInt());
    }
  }
  final glowFile = File('${dir.path}/mark_glow.png');
  glowFile.writeAsBytesSync(img.encodePng(glow));

  stdout.writeln(
      'logo: ${trimmed.width}x${trimmed.height}  kept=$kept  -> ${file.path}');
  stdout.writeln('glow: -> ${glowFile.path}');
}
