import 'dart:io';

import 'package:image/image.dart' as img;

/// Pixel glyph rows for the VECTORCALC "V" mark.
const List<String> _glyph = [
  'XX........XX',
  'XX........XX',
  'XXX......XXX',
  '.XX......XX.',
  '.XXX....XXX.',
  '..XX....XX..',
  '..XXX..XXX..',
  '...XX..XX...',
  '...XXXXXX...',
  '....XXXX....',
  '.....XX.....',
];

void main() {
  final dir = Directory('assets/icon');
  dir.createSync(recursive: true);

  final bg = img.ColorRgb8(0x12, 0x13, 0x17);
  final amber = img.ColorRgb8(0xFF, 0xB0, 0x20);

  final icon = img.Image(width: 1024, height: 1024, numChannels: 4);
  img.fill(icon, color: bg);
  _drawBorder(icon, img.ColorRgb8(0x2A, 0x2C, 0x33), 40);
  _drawGlyph(icon, amber, 0.20);
  File('assets/icon/icon.png').writeAsBytesSync(img.encodePng(icon));

  final fg = img.Image(width: 1024, height: 1024, numChannels: 4);
  img.fill(fg, color: img.ColorRgba8(0, 0, 0, 0));
  _drawGlyph(fg, amber, 0.17);
  File('assets/icon/icon_foreground.png')
      .writeAsBytesSync(img.encodePng(fg));

  stdout.writeln('wrote assets/icon/icon.png and icon_foreground.png');
}

void _drawGlyph(img.Image im, img.Color color, double marginFrac) {
  final margin = (im.width * marginFrac).round();
  final area = im.width - margin * 2;
  final rows = _glyph.length;
  final cols = _glyph.first.length;
  final cell = area / rows;
  final xOff = margin + (area - cell * cols) / 2;

  for (var y = 0; y < rows; y++) {
    for (var x = 0; x < cols; x++) {
      if (_glyph[y][x] != 'X') continue;
      final px = (xOff + x * cell).round();
      final py = (margin + y * cell).round();
      final size = cell.ceil();
      img.fillRect(
        im,
        x1: px,
        y1: py,
        x2: px + size - 1,
        y2: py + size - 1,
        color: color,
      );
    }
  }
}

void _drawBorder(img.Image im, img.Color color, int thickness) {
  img.fillRect(im,
      x1: 0, y1: 0, x2: im.width - 1, y2: thickness - 1, color: color);
  img.fillRect(im,
      x1: 0,
      y1: im.height - thickness,
      x2: im.width - 1,
      y2: im.height - 1,
      color: color);
  img.fillRect(im,
      x1: 0, y1: 0, x2: thickness - 1, y2: im.height - 1, color: color);
  img.fillRect(im,
      x1: im.width - thickness,
      y1: 0,
      x2: im.width - 1,
      y2: im.height - 1,
      color: color);
}
