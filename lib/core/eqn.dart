import 'dart:math' as math;

import 'complex.dart';

/// One root of a polynomial equation. Real roots have `im == 0`.
typedef Root = Complex;

class EqnResult {
  final List<Root> roots;
  final String? error;
  const EqnResult.roots(this.roots) : error = null;
  const EqnResult.err(this.error) : roots = const [];
  bool get ok => error == null;
}

/// Solves `a x + b = 0`.
EqnResult solveLinear1(double a, double b) {
  if (a == 0) {
    return b == 0
        ? const EqnResult.err('Infinite solutions')
        : const EqnResult.err('No solution');
  }
  return EqnResult.roots([Complex(-b / a)]);
}

/// Solves `a x² + b x + c = 0`.
EqnResult solveQuadratic(double a, double b, double c) {
  if (a == 0) return solveLinear1(b, c);
  final disc = b * b - 4 * a * c;
  if (disc > 0) {
    final s = math.sqrt(disc);
    return EqnResult.roots(_cleanRoots([
      Complex((-b + s) / (2 * a)),
      Complex((-b - s) / (2 * a)),
    ]));
  }
  if (disc == 0) {
    return EqnResult.roots(_cleanRoots([Complex(-b / (2 * a))]));
  }
  final s = math.sqrt(-disc);
  return EqnResult.roots(_cleanRoots([
    Complex(-b / (2 * a), s / (2 * a)),
    Complex(-b / (2 * a), -s / (2 * a)),
  ]));
}

/// Solves `a x³ + b x² + c x + d = 0` using Cardano's method.
EqnResult solveCubic(double a, double b, double c, double d) {
  if (a == 0) return solveQuadratic(b, c, d);

  // Depress: x = t - b/(3a)  =>  t³ + p t + q = 0.
  final p = (3 * a * c - b * b) / (3 * a * a);
  final q = (2 * b * b * b - 9 * a * b * c + 27 * a * a * d) / (27 * a * a * a);
  final shift = -b / (3 * a);

  final disc = (q / 2) * (q / 2) + (p / 3) * (p / 3) * (p / 3);
  final roots = <Root>[];

  if (disc > 1e-14) {
    final sqrtDisc = math.sqrt(disc);
    final u = _cbrt(-q / 2 + sqrtDisc);
    final v = _cbrt(-q / 2 - sqrtDisc);
    roots.add(Complex(u + v + shift));
    final realPart = -(u + v) / 2 + shift;
    final imagPart = (u - v) * math.sqrt(3) / 2;
    roots.add(Complex(realPart, imagPart));
    roots.add(Complex(realPart, -imagPart));
  } else if (disc.abs() <= 1e-14) {
    final u = _cbrt(-q / 2);
    roots.add(Complex(2 * u + shift));
    roots.add(Complex(-u + shift));
    roots.add(Complex(-u + shift));
  } else {
    // Three real roots (casus irreducibilis): trigonometric form.
    final r = math.sqrt(-(p * p * p) / 27);
    final phi = math.acos((-q / 2) / r);
    final m = 2 * math.sqrt(-p / 3);
    roots.add(Complex(m * math.cos(phi / 3) + shift));
    roots.add(Complex(m * math.cos((phi + 2 * math.pi) / 3) + shift));
    roots.add(Complex(m * math.cos((phi + 4 * math.pi) / 3) + shift));
  }

  return EqnResult.roots(_cleanRoots(roots));
}

double _cbrt(double x) => x < 0 ? -math.pow(-x, 1 / 3).toDouble() : math.pow(x, 1 / 3).toDouble();

/// Removes tiny floating-point residues and sorts roots for stable display.
List<Root> _cleanRoots(List<Root> roots) {
  final cleaned = roots
      .map((r) => Complex(_clean(r.re), _clean(r.im)))
      .toList();
  cleaned.sort((a, b) {
    final c = a.re.compareTo(b.re);
    return c != 0 ? c : a.im.compareTo(b.im);
  });
  return cleaned;
}

double _clean(double v) {
  if (!v.isFinite) return v;
  final rounded = v.roundToDouble();
  if ((v - rounded).abs() < 1e-9) return rounded;
  return v;
}

/// Solves a linear system `a x = b` with Gaussian elimination and partial
/// pivoting. Returns null when the system is singular.
List<double>? solveLinearSystem(List<List<double>> a, List<double> b) {
  final n = b.length;
  if (a.length != n) return null;
  final m = [
    for (var i = 0; i < n; i++) [...a[i], b[i]],
  ];

  for (var col = 0; col < n; col++) {
    var pivot = col;
    var best = m[col][col].abs();
    for (var r = col + 1; r < n; r++) {
      final v = m[r][col].abs();
      if (v > best) {
        best = v;
        pivot = r;
      }
    }
    if (best < 1e-12) return null;
    if (pivot != col) {
      final tmp = m[pivot];
      m[pivot] = m[col];
      m[col] = tmp;
    }
    final pv = m[col][col];
    for (var c = col; c <= n; c++) {
      m[col][c] /= pv;
    }
    for (var r = 0; r < n; r++) {
      if (r == col) continue;
      final f = m[r][col];
      if (f == 0) continue;
      for (var c = col; c <= n; c++) {
        m[r][c] -= f * m[col][c];
      }
    }
  }

  return [for (var i = 0; i < n; i++) _clean(m[i][n])];
}
