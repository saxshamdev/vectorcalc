/// Integer base conversion and bitwise helpers for BASE-N mode.

int? digitValue(String ch) {
  if (ch.isEmpty) return null;
  final c = ch.codeUnitAt(0);
  if (c >= 0x30 && c <= 0x39) return c - 0x30; // 0-9
  if (c >= 0x41 && c <= 0x46) return c - 0x41 + 10; // A-F
  if (c >= 0x61 && c <= 0x66) return c - 0x61 + 10; // a-f
  return null;
}

String digitChar(int d) =>
    d < 10 ? '$d' : String.fromCharCode(0x41 + d - 10);

/// Parses an integer in [radix] (2, 8, 10 or 16). Returns null on invalid input.
BigInt? parseBase(String text, int radix) {
  var s = text.trim().replaceAll('_', '').replaceAll(' ', '');
  if (s.isEmpty) return null;
  var negative = false;
  if (s.startsWith('-')) {
    negative = true;
    s = s.substring(1);
  } else if (s.startsWith('+')) {
    s = s.substring(1);
  }
  if (s.isEmpty) return null;
  final r = BigInt.from(radix);
  var acc = BigInt.zero;
  for (final ch in s.split('')) {
    final d = digitValue(ch);
    if (d == null || d >= radix) return null;
    acc = acc * r + BigInt.from(d);
  }
  return negative ? -acc : acc;
}

/// Formats [value] in [radix] (2, 8, 10 or 16).
String formatBase(BigInt value, int radix) {
  if (value == BigInt.zero) return '0';
  var v = value;
  final negative = v.isNegative;
  if (negative) v = -v;
  final r = BigInt.from(radix);
  final digits = <String>[];
  while (v > BigInt.zero) {
    digits.add(digitChar((v % r).toInt()));
    v = v ~/ r;
  }
  final out = digits.reversed.join();
  return negative ? '-$out' : out;
}

/// Bitwise NOT within [bits] two's-complement width.
BigInt bitNot(BigInt value, int bits) {
  final mask = (BigInt.one << bits) - BigInt.one;
  return (~value) & mask;
}

BigInt bitAnd(BigInt a, BigInt b, int bits) =>
    (a & b) & ((BigInt.one << bits) - BigInt.one);

BigInt bitOr(BigInt a, BigInt b, int bits) =>
    (a | b) & ((BigInt.one << bits) - BigInt.one);

BigInt bitXor(BigInt a, BigInt b, int bits) =>
    (a ^ b) & ((BigInt.one << bits) - BigInt.one);

/// Signed interpretation of a two's-complement value of [bits] width.
BigInt signedValue(BigInt value, int bits) {
  final mask = (BigInt.one << bits) - BigInt.one;
  final v = value & mask;
  final signBit = BigInt.one << (bits - 1);
  return (v & signBit) != BigInt.zero ? v - (BigInt.one << bits) : v;
}
