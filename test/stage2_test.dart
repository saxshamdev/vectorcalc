import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:vectorcalc/core/basen.dart';
import 'package:vectorcalc/core/complex.dart';
import 'package:vectorcalc/core/eqn.dart';
import 'package:vectorcalc/core/matrix.dart';
import 'package:vectorcalc/core/stats.dart';
import 'package:vectorcalc/core/vector.dart';

void main() {
  group('complex arithmetic', () {
    test('multiply and divide', () {
      final p = const Complex(1, 2) * const Complex(3, -4);
      expect(p.re, closeTo(11, 1e-12));
      expect(p.im, closeTo(2, 1e-12));

      final q = const Complex(1, 1) / const Complex(1, -1);
      expect(q.re, closeTo(0, 1e-12));
      expect(q.im, closeTo(1, 1e-12));
    });

    test('magnitude, argument and conjugate', () {
      const c = Complex(3, 4);
      expect(c.magnitude, 5);
      expect(c.conjugate.im, -4);
      expect(c.argument, closeTo(math.atan2(4, 3), 1e-12));
    });

    test('sqrt of a negative real', () {
      final r = const Complex(-4).sqrt();
      expect(r.re, closeTo(0, 1e-12));
      expect(r.im, closeTo(2, 1e-12));
    });
  });

  group('equations', () {
    test('quadratic with real roots', () {
      final r = solveQuadratic(1, -5, 6);
      expect(r.ok, isTrue);
      expect(r.roots.map((e) => e.re).toList(), [2, 3]);
    });

    test('quadratic with complex roots', () {
      final r = solveQuadratic(1, 0, 1);
      expect(r.roots.length, 2);
      expect(r.roots[0].re, closeTo(0, 1e-12));
      expect(r.roots[0].im.abs(), closeTo(1, 1e-12));
    });

    test('cubic with three real roots', () {
      final r = solveCubic(1, -6, 11, -6);
      expect(r.ok, isTrue);
      final reals = r.roots.map((e) => e.re).toList()..sort();
      expect(reals[0], closeTo(1, 1e-9));
      expect(reals[1], closeTo(2, 1e-9));
      expect(reals[2], closeTo(3, 1e-9));
    });

    test('cubic with one real root', () {
      final r = solveCubic(1, 0, 0, -8);
      expect(r.roots.any((e) => e.im == 0 && (e.re - 2).abs() < 1e-9), isTrue);
      expect(r.roots.where((e) => e.im.abs() > 1e-9).length, 2);
    });

    test('linear system', () {
      final x = solveLinearSystem([
        [2, 3],
        [1, -1],
      ], [8, -1]);
      expect(x, isNotNull);
      expect(x![0], closeTo(1, 1e-12));
      expect(x[1], closeTo(2, 1e-12));
    });

    test('singular system returns null', () {
      final x = solveLinearSystem([
        [1, 2],
        [2, 4],
      ], [3, 6]);
      expect(x, isNull);
    });
  });

  group('statistics', () {
    test('one-variable stats', () {
      const s = Stats1([2, 4, 4, 4, 5, 5, 7, 9]);
      expect(s.mean, 5);
      expect(s.sigma, 2);
      expect(s.sampleSigma, closeTo(2.138089935, 1e-9));
      expect(s.median, 4.5);
      expect(s.min, 2);
      expect(s.max, 9);
    });

    test('two-variable regression', () {
      final s = Stats2([1, 2, 3], [2, 4, 6]);
      expect(s.correlation, closeTo(1, 1e-12));
      final (a, b) = s.regressionYX;
      expect(a, closeTo(0, 1e-12));
      expect(b, closeTo(2, 1e-12));
    });
  });

  group('matrices', () {
    test('determinant and inverse', () {
      final m = Matrix(2, 2, [
        [1, 2],
        [3, 4],
      ]);
      expect(m.determinant(), closeTo(-2, 1e-12));
      final inv = m.inverse()!;
      expect(inv.at(0, 0), closeTo(-2, 1e-12));
      expect(inv.at(0, 1), closeTo(1, 1e-12));
      expect(inv.at(1, 0), closeTo(1.5, 1e-12));
      expect(inv.at(1, 1), closeTo(-0.5, 1e-12));
    });

    test('multiplication and transpose', () {
      final a = Matrix(2, 2, [
        [1, 2],
        [3, 4],
      ]);
      final id = Matrix.identity(2);
      final p = a * id;
      expect(p.at(0, 1), 2);
      final t = a.transpose();
      expect(t.at(0, 1), 3);
    });
  });

  group('vectors', () {
    test('dot, cross and angle', () {
      const a = Vec3(1, 0, 0);
      const b = Vec3(0, 1, 0);
      expect(a.dot(b), 0);
      final c = a.cross(b);
      expect(c.x, 0);
      expect(c.y, 0);
      expect(c.z, 1);
      expect(a.angleDeg(b), closeTo(90, 1e-12));
      expect(const Vec3(3, 4).magnitude, 5);
    });
  });

  group('base conversion', () {
    test('parse and format', () {
      expect(parseBase('FF', 16), BigInt.from(255));
      expect(parseBase('11111111', 2), BigInt.from(255));
      expect(formatBase(BigInt.from(255), 2), '11111111');
      expect(formatBase(BigInt.from(255), 16), 'FF');
      expect(parseBase('102', 2), isNull);
    });

    test('bitwise within a word size', () {
      expect(bitNot(BigInt.zero, 8), BigInt.from(255));
      expect(signedValue(BigInt.from(255), 8), BigInt.from(-1));
      expect(bitAnd(BigInt.from(0xF0), BigInt.from(0x3C), 8), BigInt.from(0x30));
    });
  });
}
