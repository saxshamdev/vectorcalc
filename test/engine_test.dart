import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:vectorcalc/core/engine.dart';
import 'package:vectorcalc/core/format.dart';
import 'package:vectorcalc/core/num.dart';
import 'package:vectorcalc/core/rational.dart';
import 'package:vectorcalc/state/calc_state.dart';

Num ev(String s, {AngleMode angle = AngleMode.deg, Map<String, Num>? vars}) {
  final r = evaluateExpression(
    s,
    EvalContext(angle: angle, variables: vars),
  );
  expect(r.ok, isTrue, reason: 'failed: "$s" -> ${r.error}');
  return r.value!;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('arithmetic', () {
    test('precedence', () {
      expect(ev('2+3*4').v, 14);
      expect(ev('(2+3)*4').v, 20);
      expect(ev('10-2-3').v, 5);
    });

    test('power is right associative', () {
      expect(ev('2^3^2').v, 512);
    });

    test('unary minus binds looser than power', () {
      expect(ev('-2^2').v, -4);
      expect(ev('(-2)^2').v, 4);
    });

    test('implicit multiplication', () {
      expect(ev('2(3+4)').v, 14);
      expect(ev('3π').v, closeTo(9.4247779607, 1e-9));
      expect(ev('2√9').v, 6);
    });

    test('exact fractions are preserved', () {
      final n = ev('1/3+1/6');
      expect(n.v, 0.5);
      expect(n.q, Rational.fromInt(2) / Rational.fromInt(4));
    });

    test('decimal literals stay decimal', () {
      final n = ev('0.5');
      expect(n.v, 0.5);
      expect(formatValue(n, const FormatSettings()), '0.5');
      expect(ev('0.1+0.2').v, closeTo(0.3, 1e-12));
    });

    test('division by zero is a math error', () {
      final r = evaluateExpression('1/0', EvalContext());
      expect(r.ok, isFalse);
      expect(r.error, 'Math ERROR');
    });
  });

  group('functions', () {
    test('trigonometry in degrees', () {
      expect(ev('sin(30)').v, closeTo(0.5, 1e-12));
      expect(ev('cos(60)').v, closeTo(0.5, 1e-12));
      expect(ev('tan(45)').v, closeTo(1, 1e-12));
    });

    test('trigonometry in radians', () {
      expect(ev('sin(pi/2)', angle: AngleMode.rad).v, closeTo(1, 1e-12));
      expect(ev('cos(pi)', angle: AngleMode.rad).v, closeTo(-1, 1e-12));
    });

    test('inverse trigonometry returns degrees', () {
      expect(ev('asin(0.5)').v, closeTo(30, 1e-9));
    });

    test('roots and logs', () {
      expect(ev('√(81)').v, 9);
      expect(ev('∛(27)').v, closeTo(3, 1e-9));
      expect(ev('root(16,4)').v, closeTo(2, 1e-9));
      expect(ev('log(1000)').v, closeTo(3, 1e-12));
      expect(ev('ln(e)').v, closeTo(1, 1e-12));
      expect(ev('log(2,8)').v, closeTo(3, 1e-12));
    });

    test('combinatorics', () {
      expect(ev('5!').v, 120);
      expect(ev('ncr(5,2)').v, 10);
      expect(ev('npr(5,2)').v, 20);
    });

    test('number theory', () {
      expect(ev('gcd(12,18)').v, 6);
      expect(ev('lcm(4,6)').v, 12);
      expect(ev('mod(10,3)').v, 1);
    });

    test('percent and dms', () {
      expect(ev('50%').v, 0.5);
      expect(ev('30°').v, closeTo(30, 1e-12));
      expect(ev('30°', angle: AngleMode.rad).v, closeTo(0.5235987756, 1e-9));
    });
  });

  group('state bindings', () {
    test('Ans and variables', () {
      final r = evaluateExpression(
        'Ans+A',
        EvalContext(ans: Num.i(5), variables: {'A': Num.i(7)}),
      );
      expect(r.ok, isTrue);
      expect(r.value!.v, 12);
    });

    test('constants resolve', () {
      expect(ev('c0').v, 299792458);
      expect(ev('g0').v, closeTo(9.80665, 1e-9));
    });

    test('undefined variable reports an error', () {
      final r = evaluateExpression('Q', EvalContext());
      expect(r.ok, isFalse);
      expect(r.error, contains('Undefined'));
    });
  });

  group('formatting', () {
    test('exact fraction', () {
      final n = Num.r(Rational(BigInt.one, BigInt.from(3)));
      expect(formatValue(n, const FormatSettings()), '1/3');
      expect(decimalString(n, const FormatSettings()), '0.3333333333');
    });

    test('engineering notation', () {
      expect(engineeringString(1234), '1.234×10³');
      expect(engineeringString(0.00042), '420×10⁻⁶');
    });

    test('scientific mode', () {
      final s = decimalString(
        Num.of(1234),
        const FormatSettings(mode: DisplayMode.sci, digits: 3),
      );
      expect(s, '1.234×10³');
    });

    test('fix mode', () {
      final s = decimalString(
        Num.of(1.23456),
        const FormatSettings(mode: DisplayMode.fix, digits: 2),
      );
      expect(s, '1.23');
    });
  });

  group('ES PLUS calculus', () {
    test('sigma binds X over the range', () {
      expect(ev('Σ(X,1,10)').v, 55);
      expect(ev('Σ(X²,1,4)').v, 30);
    });

    test('product binds X over the range', () {
      expect(ev('Π(X,1,5)').v, 120);
    });

    test('sigma restores a stored X', () {
      final vars = {'X': Num.i(99)};
      expect(ev('Σ(X,1,3)', vars: vars).v, 6);
      expect(vars['X']!.v, 99);
    });

    test('integral of x over [0,2]', () {
      expect(ev('∫(X,0,2)').v, closeTo(2, 1e-6));
    });

    test('integral of x² over [0,3]', () {
      expect(ev('∫(X²,0,3)').v, closeTo(9, 1e-6));
    });

    test('integral reverses sign when bounds flip', () {
      expect(ev('∫(X,2,0)').v, closeTo(-2, 1e-6));
    });

    test('derivative of x² at 3', () {
      expect(ev('d/dx(X²,3)').v, closeTo(6, 1e-4));
    });

    test('derivative of sin at 0 in degrees', () {
      expect(ev('d/dx(sin(X),0)').v, closeTo(math.pi / 180, 1e-6));
    });

    test('nth root', () {
      expect(ev('ⁿ√(3,27)').v, closeTo(3, 1e-9));
      expect(ev('ⁿ√(3,-8)').v, closeTo(-2, 1e-9));
    });

    test('Rnd rounds to ten significant digits', () {
      expect(ev('rnd(1/3)').v, closeTo(0.3333333333, 1e-12));
    });

    test('fraction key builds an exact rational', () {
      final n = ev('frac(3,4)');
      expect(n.v, 0.75);
      expect(n.isExact, isTrue);
      expect(formatValue(n, const FormatSettings()), '3/4');
    });

    test('frac with one argument is the fractional part', () {
      expect(ev('frac(3.25)').v, closeTo(0.25, 1e-12));
    });
  });

  group('ES PLUS coordinates', () {    test('Pol writes r to X and theta to Y', () {
      final ctx = EvalContext();
      final r = evaluateExpression('pol(3,4)', ctx);
      expect(r.ok, isTrue);
      expect(r.value!.v, closeTo(5, 1e-12));
      expect(ctx.outputs['X']!.v, closeTo(5, 1e-12));
      expect(ctx.outputs['Y']!.v, closeTo(53.13010235, 1e-6));
    });

    test('Rec writes x to X and y to Y', () {
      final ctx = EvalContext();
      final r = evaluateExpression('rec(10,30)', ctx);
      expect(r.ok, isTrue);
      expect(ctx.outputs['X']!.v, closeTo(8.6602540378, 1e-9));
      expect(ctx.outputs['Y']!.v, closeTo(5, 1e-9));
    });
  });

  group('parity regressions', () {
    test('large factorials do not overflow 64-bit ints', () {
      // 25! is far past the int64 limit; the old code wrapped around.
      expect(ev('25!').v, closeTo(1.5511210043330986e25, 1e10));
      expect(ev('69!').v, closeTo(1.711224524281413e98, 1e83));
    });

    test('non-integer factorial is a math error', () {
      final r = evaluateExpression('2.5!', EvalContext());
      expect(r.ok, isFalse);
      expect(r.error, 'Math ERROR');
    });

    test('percent after plus or minus is relative', () {
      expect(ev('200+10%').v, closeTo(220, 1e-9));
      expect(ev('200-10%').v, closeTo(180, 1e-9));
      expect(ev('200*10%').v, closeTo(20, 1e-9));
    });

    test('inverse trig trims floating-point noise', () {
      expect(ev('asin(1)').v, 90);
      expect(ev('acos(0)').v, 90);
      expect(ev('atan(1)').v, 45);
    });

    test('unbalanced parentheses auto-close', () {
      expect(ev('sin(30').v, closeTo(0.5, 1e-12));
      expect(ev('2*(3+4').v, 14);
    });

    test('combinatorics reject non-integers', () {
      final r = evaluateExpression('ncr(5.5,2)', EvalContext());
      expect(r.ok, isFalse);
      expect(r.error, 'Math ERROR');
    });

    test('overflow beyond the Casio range is an error', () {
      final r = evaluateExpression('70!', EvalContext());
      expect(r.ok, isFalse);
      expect(r.error, 'Math ERROR');
      expect(evaluateExpression('10^99', EvalContext()).ok, isTrue);
    });

    test('identifier followed by a digit is implicit multiplication', () {
      expect(ev('π2').v, closeTo(2 * math.pi, 1e-12));
      expect(ev('A2', vars: {'A': Num.i(3)}).v, 6);
      expect(ev('Ans2', vars: {}).v, 0); // Ans defaults to 0
      expect(ev('sin2').v, closeTo(math.sin(2 * math.pi / 180), 1e-12));
    });

    test('a variable followed by parentheses is multiplication', () {
      expect(ev('A(2)', vars: {'A': Num.i(5)}).v, 10);
      expect(ev('X(2)', vars: {'X': Num.i(4)}).v, 8);
    });

    test('constant names with digits are not split', () {
      expect(ev('c0').v, 299792458);
      expect(ev('mu0').v, closeTo(1.25663706212e-6, 1e-20));
    });
  });

  group('state behaviour', () {
    test('evaluating an empty expression is a no-op', () {
      final s = CalcState();
      s.evaluate();
      expect(s.error, isNull);
      expect(s.history, isEmpty);
    });

    test('only one decimal point per number literal', () {
      final s = CalcState();
      s.insert('1');
      s.insert('.');
      s.insert('5');
      s.insert('.');
      expect(s.expression, '1.5');
    });

    test('a decimal after an operator is allowed', () {
      final s = CalcState();
      s.insert('1');
      s.insert('.');
      s.insert('5');
      s.insert('+');
      s.insert('.');
      expect(s.expression, '1.5+.');
    });
  });
}
