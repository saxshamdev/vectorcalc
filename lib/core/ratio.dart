/// Ratio solving for RATIO mode.
///
/// Solves `A : B = C : D` for the unknown position:
/// 0 = A, 1 = B, 2 = C, 3 = D.

/// Returns the missing value, or null when a required divisor is zero or an
/// input is missing.
double? solveRatio({
  required double? a,
  required double? b,
  required double? c,
  required double? d,
  required int unknown,
}) {
  if (unknown < 0 || unknown > 3) return null;
  final values = [a, b, c, d];
  for (var i = 0; i < 4; i++) {
    if (i != unknown && values[i] == null) return null;
  }

  double v(int i) => values[i]!;
  switch (unknown) {
    case 0: // A = B · C / D
      if (v(3) == 0) return null;
      return v(1) * v(2) / v(3);
    case 1: // B = A · D / C
      if (v(2) == 0) return null;
      return v(0) * v(3) / v(2);
    case 2: // C = A · D / B
      if (v(1) == 0) return null;
      return v(0) * v(3) / v(1);
    default: // D = B · C / A
      if (v(0) == 0) return null;
      return v(1) * v(2) / v(0);
  }
}

/// Reduces an integer ratio to lowest terms, e.g. `4:6` becomes `2:3`.
String? reduceRatio(double a, double b) {
  if (a != a.roundToDouble() || b != b.roundToDouble()) return null;
  if (a.abs() > 1e15 || b.abs() > 1e15) return null;
  var x = a.toInt().abs();
  var y = b.toInt().abs();
  if (x == 0 || y == 0) return null;
  final g = _gcd(x, y);
  x ~/= g;
  y ~/= g;
  final sign = (a < 0) ^ (b < 0) ? '-' : '';
  return '$sign$x:$y';
}

int _gcd(int a, int b) {
  while (b != 0) {
    final t = a % b;
    a = b;
    b = t;
  }
  return a;
}
