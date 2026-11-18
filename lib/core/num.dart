import 'dart:math' as math;

import 'rational.dart';

/// A calculator number: a [double] value plus an optional exact rational form.
class Num {
  final double v;
  final Rational? q;

  const Num(this.v, [this.q]);

  factory Num.of(double v) => Num(v);

  factory Num.r(Rational r) => Num(r.clampToDouble(), r);

  factory Num.i(int v) => Num(v.toDouble(), Rational.fromInt(v));

  static final Num zero = Num(0, Rational.zero);
  static final Num one = Num(1, Rational.one);

  bool get isExact => q != null && q!.isSmall;
  bool get isFinite => v.isFinite;
  bool get isInteger => v == v.roundToDouble() && v.abs() < 1e15;

  Rational? get exact => isExact ? q : null;

  /// Drops exactness (e.g. after an irrational operation).
  Num get inexact => Num(v);

  Num operator +(Num o) {
    final a = q, b = o.q;
    if (a != null && b != null) {
      final r = a + b;
      if (r.isSmall) return Num(r.clampToDouble(), r);
    }
    return Num(v + o.v);
  }

  Num operator -(Num o) {
    final a = q, b = o.q;
    if (a != null && b != null) {
      final r = a - b;
      if (r.isSmall) return Num(r.clampToDouble(), r);
    }
    return Num(v - o.v);
  }

  Num operator *(Num o) {
    final a = q, b = o.q;
    if (a != null && b != null) {
      final r = a * b;
      if (r.isSmall) return Num(r.clampToDouble(), r);
    }
    return Num(v * o.v);
  }

  Num operator /(Num o) {
    if (o.v == 0 && (o.q == null || o.q!.isZero)) {
      return const Num(double.nan);
    }
    final a = q, b = o.q;
    if (a != null && b != null && !b.isZero) {
      final r = a / b;
      if (r.isSmall) return Num(r.clampToDouble(), r);
    }
    return Num(v / o.v);
  }

  Num operator -() => Num(-v, q == null ? null : -q!);

  Num abs() => Num(v.abs(), q?.abs());

  bool get isZero => v == 0;

  Num pow(Num e) {
    // Exact integer powers of exact values.
    if (isExact && e.isExact && e.q!.isInteger && e.v.abs() <= 4096) {
      final exp = e.q!.n.toInt();
      try {
        final r = q!.pow(exp);
        if (r.isSmall) return Num(r.clampToDouble(), r);
      } catch (_) {
        // fall through to floating point
      }
    }
    final base = v;
    final exp = e.v;
    if (base < 0 && exp != exp.roundToDouble()) {
      // negative base with fractional exponent -> not real
      return const Num(double.nan);
    }
    return Num(math.pow(base, exp).toDouble());
  }

  @override
  String toString() => v.toString();

  @override
  bool operator ==(Object other) => other is Num && other.v == v;

  @override
  int get hashCode => v.hashCode;
}
