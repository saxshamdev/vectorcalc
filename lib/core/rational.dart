import 'dart:math' as math;

/// An exact rational number backed by [BigInt].
///
/// Used so the calculator can show exact results (fractions, `S<=>D`) instead
/// of only decimal approximations.
class Rational {
  final BigInt n;
  final BigInt d;

  const Rational._(this.n, this.d);

  factory Rational(BigInt n, [BigInt? d]) {
    var num = n;
    var den = d ?? BigInt.one;
    if (den == BigInt.zero) throw ArgumentError('zero denominator');
    if (den.isNegative) {
      num = -num;
      den = -den;
    }
    final g = num.gcd(den);
    if (g > BigInt.one) {
      num = num ~/ g;
      den = den ~/ g;
    }
    return Rational._(num, den);
  }

  factory Rational.fromInt(int v) => Rational._(BigInt.from(v), BigInt.one);

  factory Rational.of(BigInt v) => Rational._(v, BigInt.one);

  static final Rational zero = Rational._(BigInt.zero, BigInt.one);
  static final Rational one = Rational._(BigInt.one, BigInt.one);

  bool get isInteger => d == BigInt.one;
  bool get isZero => n == BigInt.zero;
  int get sign => n.sign;

  double toDouble() => n.toDouble() / d.toDouble();

  Rational operator +(Rational o) => Rational(n * o.d + o.n * d, d * o.d);

  Rational operator -(Rational o) => Rational(n * o.d - o.n * d, d * o.d);

  Rational operator *(Rational o) => Rational(n * o.n, d * o.d);

  Rational operator /(Rational o) {
    if (o.n == BigInt.zero) throw ArgumentError('division by zero');
    return Rational(n * o.d, d * o.n);
  }

  Rational operator -() => Rational._(-n, d);

  Rational abs() => Rational._(n.abs(), d);

  Rational pow(int e) {
    if (e == 0) return one;
    if (e < 0) {
      if (n == BigInt.zero) throw ArgumentError('division by zero');
      return Rational(d.pow(-e), n.pow(-e));
    }
    return Rational(n.pow(e), d.pow(e));
  }

  bool get isSmall =>
      n.bitLength <= 96 && d.bitLength <= 96;

  /// Parses a decimal literal exactly, e.g. `12`, `0.125`, `1.2E3`.
  ///
  /// Returns null when the text is not a plain decimal number or when the
  /// implied denominator would be unreasonably large.
  static Rational? tryParseDecimal(String text) {
    final m = RegExp(r'^([+-]?)(\d*)(?:\.(\d*))?(?:[eE]([+-]?\d+))?$')
        .firstMatch(text);
    if (m == null) return null;
    final negative = m.group(1) == '-';
    final whole = m.group(2) ?? '';
    final frac = m.group(3) ?? '';
    if (whole.isEmpty && frac.isEmpty) return null;
    final exp = int.tryParse(m.group(4) ?? '0') ?? 0;
    final digits = whole + frac;
    final scale = frac.length - exp;
    if (scale.abs() > 300) return null;
    var n = BigInt.parse(digits);
    if (negative) n = -n;
    if (scale <= 0) {
      return Rational(n * BigInt.from(10).pow(-scale), BigInt.one);
    }
    return Rational(n, BigInt.from(10).pow(scale));
  }

  /// Best rational approximation of [x] with denominator <= [maxDen].
  static Rational approx(double x, {int maxDen = 1000000}) {
    if (!x.isFinite) throw ArgumentError('not finite');
    if (x == 0) return zero;
    if (x == x.roundToDouble() && x.abs() < 1e15) {
      return Rational.of(BigInt.from(x));
    }
    final neg = x < 0;
    var value = x.abs();
    var h0 = BigInt.zero, h1 = BigInt.one;
    var k0 = BigInt.one, k1 = BigInt.zero;
    var best = zero;
    for (var i = 0; i < 64; i++) {
      final a = value.floor();
      final h2 = BigInt.from(a) * h1 + h0;
      final k2 = BigInt.from(a) * k1 + k0;
      if (k2 > BigInt.from(maxDen)) break;
      h0 = h1;
      h1 = h2;
      k0 = k1;
      k1 = k2;
      best = Rational(h1, k1);
      final frac = value - a;
      if (frac < 1e-12) break;
      value = 1 / frac;
      if (!value.isFinite || value > 1e18) break;
    }
    return neg ? -best : best;
  }

  /// Converts to a mixed fraction like `2 1/3`.
  String toMixedString() {
    if (isInteger) return n.toString();
    final neg = n.isNegative;
    final a = n.abs();
    final whole = a ~/ d;
    final rem = a % d;
    if (whole == BigInt.zero) return '${neg ? '-' : ''}$rem/$d';
    return '${neg ? '-' : ''}$whole $rem/$d';
  }

  @override
  String toString() => isInteger ? n.toString() : '$n/$d';

  @override
  bool operator ==(Object other) =>
      other is Rational && other.n == n && other.d == d;

  @override
  int get hashCode => Object.hash(n, d);

  /// Greatest common divisor helper for two BigInts.
  static BigInt gcd(BigInt a, BigInt b) => a.gcd(b);

  /// Clamp to a safe magnitude before converting to double.
  double clampToDouble() {
    if (n.bitLength > 1000 || d.bitLength > 1000) {
      final s = n.sign;
      final scale = math.max(n.bitLength, d.bitLength) - 900;
      final nn = n >> scale;
      final dd = d >> scale;
      if (dd == BigInt.zero) return s * double.infinity;
      return nn.toDouble() / dd.toDouble();
    }
    return toDouble();
  }
}
