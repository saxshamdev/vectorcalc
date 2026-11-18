import 'dart:math' as math;

import 'num.dart';
import 'rational.dart';

enum DisplayMode { norm, fix, sci }

/// How the result area renders numbers.
class FormatSettings {
  final DisplayMode mode;
  final int digits;
  final bool engineering;
  final bool siPrefix;
  final bool mixedFraction;

  const FormatSettings({
    this.mode = DisplayMode.norm,
    this.digits = 4,
    this.engineering = false,
    this.siPrefix = false,
    this.mixedFraction = false,
  });

  FormatSettings copyWith({
    DisplayMode? mode,
    int? digits,
    bool? engineering,
    bool? siPrefix,
    bool? mixedFraction,
  }) =>
      FormatSettings(
        mode: mode ?? this.mode,
        digits: digits ?? this.digits,
        engineering: engineering ?? this.engineering,
        siPrefix: siPrefix ?? this.siPrefix,
        mixedFraction: mixedFraction ?? this.mixedFraction,
      );
}

const Map<String, String> _supDigits = {
  '0': '⁰',
  '1': '¹',
  '2': '²',
  '3': '³',
  '4': '⁴',
  '5': '⁵',
  '6': '⁶',
  '7': '⁷',
  '8': '⁸',
  '9': '⁹',
};

String superscript(int e) =>
    (e < 0 ? '⁻' : '') +
    e.abs().toString().split('').map((c) => _supDigits[c]!).join();

const List<(int, String, String)> _siPrefixes = [
  (-24, 'y', 'yocto'),
  (-21, 'z', 'zepto'),
  (-18, 'a', 'atto'),
  (-15, 'f', 'femto'),
  (-12, 'p', 'pico'),
  (-9, 'n', 'nano'),
  (-6, 'µ', 'micro'),
  (-3, 'm', 'milli'),
  (0, '', ''),
  (3, 'k', 'kilo'),
  (6, 'M', 'mega'),
  (9, 'G', 'giga'),
  (12, 'T', 'tera'),
  (15, 'P', 'peta'),
  (18, 'E', 'exa'),
  (21, 'Z', 'zetta'),
  (24, 'Y', 'yotta'),
];

String? siPrefixSymbol(int exponent) {
  for (final p in _siPrefixes) {
    if (p.$1 == exponent) return p.$2;
  }
  return null;
}

String? siPrefixName(int exponent) {
  for (final p in _siPrefixes) {
    if (p.$1 == exponent) return p.$3;
  }
  return null;
}

String _stripZeros(String s) {
  if (!s.contains('.')) return s;
  var out = s.replaceFirst(RegExp(r'0+$'), '');
  if (out.endsWith('.')) out = out.substring(0, out.length - 1);
  return out;
}

String _sciFmt(double v, int sig) {
  if (v == 0) return '0';
  final s = v.abs().toStringAsExponential(math.max(0, sig - 1));
  final parts = s.split('e');
  final mant = parts[0];
  final exp = int.parse(parts[1]);
  final sign = v.isNegative ? '-' : '';
  return '$sign$mant×10${superscript(exp)}';
}

String _normFmt(double v, int sig) {
  if (v == 0) return '0';
  final a = v.abs();
  final exp = (math.log(a) / math.ln10).floor();
  if (exp < -9 || exp >= sig) return _sciFmt(v, sig);
  final s = v.toStringAsPrecision(sig);
  if (s.contains('e') || s.contains('E')) return _sciFmt(v, sig);
  return _stripZeros(s);
}

String _fixFmt(double v, int digits) {
  if (v != 0 && (v.abs() >= 1e10 || v.abs() < 1e-9)) {
    return _sciFmt(v, digits + 1);
  }
  return v.toStringAsFixed(digits);
}

String engineeringString(double v, {int sig = 10, bool si = false}) {
  if (v == 0) return '0';
  if (!v.isFinite) return v.isNegative ? '-∞' : '∞';
  final exp = (math.log(v.abs()) / math.ln10).floor();
  var e3 = (exp / 3).floor() * 3;
  var mant = v / math.pow(10, e3);
  if (mant.abs() >= 1000) {
    mant /= 1000;
    e3 += 3;
  }
  if (mant.abs() < 1 && mant != 0) {
    mant *= 1000;
    e3 -= 3;
  }
  var ms = mant.toStringAsPrecision(sig);
  if (ms.contains('e') || ms.contains('E')) {
    ms = mant.toStringAsFixed(math.max(0, sig - 1));
  }
  ms = _stripZeros(ms);
  if (si) {
    final sym = siPrefixSymbol(e3);
    if (sym != null) return '$ms$sym';
  }
  if (e3 == 0) return ms;
  return '$ms×10${superscript(e3)}';
}

/// Exact fraction form of [n], or null when no exact form is available.
String? exactString(Num n, {bool mixed = false}) {
  if (!n.isExact) return null;
  final q = n.q!;
  if (q.isInteger) {
    if (q.n.abs() > BigInt.from(10).pow(15)) return null;
    return q.n.toString();
  }
  return mixed ? q.toMixedString() : q.toString();
}

String decimalString(Num n, FormatSettings f) {
  if (n.v.isNaN) return 'NaN';
  if (n.v.isInfinite) return n.v.isNegative ? '-∞' : '∞';
  if (f.engineering) {
    return engineeringString(n.v, sig: math.max(3, 10), si: f.siPrefix);
  }
  switch (f.mode) {
    case DisplayMode.fix:
      return _fixFmt(n.v, f.digits.clamp(0, 9));
    case DisplayMode.sci:
      return _sciFmt(n.v, (f.digits + 1).clamp(1, 10));
    case DisplayMode.norm:
      return _normFmt(n.v, 10);
  }
}

/// Main display string. Prefers the exact form when [preferExact] is set.
String formatValue(Num n, FormatSettings f, {bool preferExact = true}) {
  if (preferExact) {
    final ex = exactString(n, mixed: f.mixedFraction);
    if (ex != null) return ex;
  }
  return decimalString(n, f);
}

/// Secondary display string (the "other" form), or null if identical.
String? altFormatValue(Num n, FormatSettings f, {bool preferExact = true}) {
  final ex = exactString(n, mixed: f.mixedFraction);
  final dec = decimalString(n, f);
  if (ex != null && ex != dec) {
    return preferExact ? dec : ex;
  }
  return null;
}

String formatRational(Rational r, {bool mixed = false}) =>
    mixed ? r.toMixedString() : r.toString();
