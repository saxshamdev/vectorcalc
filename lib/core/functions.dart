import 'dart:math' as math;

import 'num.dart';
import 'rational.dart';

enum AngleMode { deg, rad, grad }

extension AngleModeLabel on AngleMode {
  String get label => switch (this) {
        AngleMode.deg => 'DEG',
        AngleMode.rad => 'RAD',
        AngleMode.grad => 'GRAD',
      };
}

double toRadians(double x, AngleMode m) => switch (m) {
      AngleMode.deg => x * math.pi / 180,
      AngleMode.grad => x * math.pi / 200,
      AngleMode.rad => x,
    };

double fromRadians(double x, AngleMode m) => switch (m) {
      AngleMode.deg => x * 180 / math.pi,
      AngleMode.grad => x * 200 / math.pi,
      AngleMode.rad => x,
    };

/// Physical constants and mathematical constants available by name.
const Map<String, double> physicalConstants = {
  'pi': math.pi,
  'tau': math.pi * 2,
  'e': math.e,
  'phi': 1.618033988749895,
  'c0': 299792458,
  'g0': 9.80665,
  'G_newt': 6.67430e-11,
  'hP': 6.62607015e-34,
  'hbar': 1.054571817e-34,
  'k_B': 1.380649e-23,
  'N_A': 6.02214076e23,
  'R_gas': 8.314462618,
  'eps0': 8.8541878128e-12,
  'mu0': 1.25663706212e-6,
  'm_e': 9.1093837015e-31,
  'm_p': 1.67262192369e-27,
  'm_n': 1.67492749804e-27,
  'e_charge': 1.602176634e-19,
  'F_faraday': 96485.33212,
  'sigma_SB': 5.670374419e-8,
  'atm': 101325,
  'u_amu': 1.66053906660e-27,
  'Ryd': 10973731.568160,
  'mu_B': 9.2740100783e-24,
  'mu_N': 5.0507837461e-27,
};

class ConstantInfo {
  final String name;
  final String symbol;
  final String label;
  final String unit;
  const ConstantInfo(this.name, this.symbol, this.label, this.unit);
}

const List<ConstantInfo> constantCatalog = [
  ConstantInfo('c0', 'c', 'Speed of light', 'm/s'),
  ConstantInfo('g0', 'g', 'Standard gravity', 'm/s²'),
  ConstantInfo('G_newt', 'G', 'Gravitational constant', 'm³/(kg·s²)'),
  ConstantInfo('hP', 'h', 'Planck constant', 'J·s'),
  ConstantInfo('hbar', 'ħ', 'Reduced Planck constant', 'J·s'),
  ConstantInfo('k_B', 'k', 'Boltzmann constant', 'J/K'),
  ConstantInfo('N_A', 'Nₐ', 'Avogadro constant', '1/mol'),
  ConstantInfo('R_gas', 'R', 'Molar gas constant', 'J/(mol·K)'),
  ConstantInfo('eps0', 'ε₀', 'Vacuum permittivity', 'F/m'),
  ConstantInfo('mu0', 'μ₀', 'Vacuum permeability', 'H/m'),
  ConstantInfo('m_e', 'mₑ', 'Electron mass', 'kg'),
  ConstantInfo('m_p', 'mₚ', 'Proton mass', 'kg'),
  ConstantInfo('m_n', 'mₙ', 'Neutron mass', 'kg'),
  ConstantInfo('e_charge', 'e', 'Elementary charge', 'C'),
  ConstantInfo('F_faraday', 'F', 'Faraday constant', 'C/mol'),
  ConstantInfo('sigma_SB', 'σ', 'Stefan–Boltzmann constant', 'W/(m²·K⁴)'),
  ConstantInfo('atm', 'atm', 'Standard atmosphere', 'Pa'),
  ConstantInfo('u_amu', 'u', 'Atomic mass unit', 'kg'),
  ConstantInfo('Ryd', 'R∞', 'Rydberg constant', '1/m'),
  ConstantInfo('mu_B', 'μ_B', 'Bohr magneton', 'J/T'),
  ConstantInfo('mu_N', 'μ_N', 'Nuclear magneton', 'J/T'),
  ConstantInfo('pi', 'π', 'Pi', ''),
  ConstantInfo('e', 'e', 'Euler number', ''),
  ConstantInfo('tau', 'τ', 'Tau', ''),
  ConstantInfo('phi', 'φ', 'Golden ratio', ''),
];

Num? constantValue(String name) {
  final v = physicalConstants[name];
  if (v == null) return null;
  if (name == 'pi' || name == 'tau' || name == 'e' || name == 'phi') {
    return Num.of(v);
  }
  return Num.of(v);
}

/// Storage variables and constants that may appear as a bare identifier.
const Set<String> _storageNames = {'A', 'B', 'C', 'D', 'E', 'F', 'X', 'Y', 'M'};

bool isKnownIdentifier(String name) {
  if (name.isEmpty) return false;
  if (_storageNames.contains(name)) return true;
  final lower = name.toLowerCase();
  if (lower == 'ans' || lower == 'preans') return true;
  return physicalConstants.containsKey(name) ||
      physicalConstants.containsKey(lower) ||
      physicalConstants.containsKey(name.toUpperCase());
}

BigInt _factorialBig(int n) {
  var r = BigInt.one;
  for (var i = 2; i <= n; i++) {
    r *= BigInt.from(i);
  }
  return r;
}

/// Shared RNG so repeated Ran# / RanInt presses keep advancing.
final math.Random _rng = math.Random();

/// Evaluates a single function call.
Num callFunction(String rawName, List<Num> args, AngleMode angle) {
  final name = rawName.toLowerCase();
  double a(int i) => args[i].v;
  void need(int n) {
    if (args.length != n) {
      throw ArgumentError('$name expects $n argument(s)');
    }
  }

  switch (name) {
    case 'sin':
      need(1);
      return Num.of(_trimTrig(math.sin(toRadians(a(0), angle))));
    case 'cos':
      need(1);
      return Num.of(_trimTrig(math.cos(toRadians(a(0), angle))));
    case 'tan':
      need(1);
      final r = toRadians(a(0), angle);
      final c = math.cos(r);
      if (c.abs() < 1e-13) return Num.of(double.nan);
      return Num.of(_trimTrig(math.sin(r) / c));
    case 'asin':
      need(1);
      return Num.of(_trimTrig(fromRadians(math.asin(a(0)), angle)));
    case 'acos':
      need(1);
      return Num.of(_trimTrig(fromRadians(math.acos(a(0)), angle)));
    case 'atan':
      need(1);
      return Num.of(_trimTrig(fromRadians(math.atan(a(0)), angle)));
    case 'sinh':
      need(1);
      return Num.of((math.exp(a(0)) - math.exp(-a(0))) / 2);
    case 'cosh':
      need(1);
      return Num.of((math.exp(a(0)) + math.exp(-a(0))) / 2);
    case 'tanh':
      need(1);
      final e2 = math.exp(2 * a(0));
      return Num.of((e2 - 1) / (e2 + 1));
    case 'asinh':
      need(1);
      final x = a(0);
      return Num.of(math.log(x + math.sqrt(x * x + 1)));
    case 'acosh':
      need(1);
      final x = a(0);
      if (x < 1) return Num.of(double.nan);
      return Num.of(math.log(x + math.sqrt(x * x - 1)));
    case 'atanh':
      need(1);
      final x = a(0);
      if (x.abs() >= 1) return Num.of(double.nan);
      return Num.of(0.5 * math.log((1 + x) / (1 - x)));
    case 'log':
      if (args.length == 1) {
        if (a(0) <= 0) return Num.of(double.nan);
        return Num.of(math.log(a(0)) / math.ln10);
      }
      need(2);
      if (a(0) <= 0 || a(0) == 1 || a(1) <= 0) return Num.of(double.nan);
      return Num.of(math.log(a(1)) / math.log(a(0)));
    case 'ln':
      need(1);
      if (a(0) <= 0) return Num.of(double.nan);
      return Num.of(math.log(a(0)));
    case 'exp':
      need(1);
      return Num.of(math.exp(a(0)));
    case 'sqrt':
      need(1);
      if (a(0) < 0) return Num.of(double.nan);
      return Num.of(math.sqrt(a(0)));
    case 'cbrt':
      need(1);
      final x = a(0);
      return Num.of(x < 0 ? -math.pow(-x, 1 / 3).toDouble() : math.pow(x, 1 / 3).toDouble());
    case 'root':
      need(2);
      final x = a(0);
      final n = a(1);
      if (n == 0) return Num.of(double.nan);
      if (x < 0 && n.abs() == n.roundToDouble() && n.toInt().isOdd) {
        return Num.of(-math.pow(-x, 1 / n).toDouble());
      }
      if (x < 0) return Num.of(double.nan);
      return Num.of(math.pow(x, 1 / n).toDouble());
    case 'nroot':
      // ˣ√: index first, then radicand (nroot(3, 27) = 3).
      need(2);
      final n = a(0);
      final x = a(1);
      if (n == 0) return Num.of(double.nan);
      if (x < 0 && n.roundToDouble() == n && n.toInt().isOdd) {
        return Num.of(-math.pow(-x, 1 / n).toDouble());
      }
      if (x < 0) return Num.of(double.nan);
      return Num.of(math.pow(x, 1 / n).toDouble());
    case 'rnd':
      // Rounds to the 10 significant digits the display shows in Norm mode.
      need(1);
      final v = a(0);
      if (v == 0 || !v.isFinite) return Num.of(v);
      final exp = (math.log(v.abs()) / math.ln10).floor();
      final scale = math.pow(10.0, 9 - exp).toDouble();
      return Num.of((v * scale).roundToDouble() / scale);
    case 'abs':
      need(1);
      return args[0].abs();
    case 'sign':
      need(1);
      return Num.i(a(0).sign.toInt());
    case 'floor':
      need(1);
      return Num.of(a(0).floorToDouble());
    case 'ceil':
      need(1);
      return Num.of(a(0).ceilToDouble());
    case 'round':
      need(1);
      return Num.of(a(0).roundToDouble());
    case 'int':
      need(1);
      return Num.of(a(0).truncateToDouble());
    case 'frac':
      if (args.length == 2) {
        // Fraction key: frac(3,4) builds the exact rational 3/4.
        final x = _rationalOf(args[0]);
        final y = _rationalOf(args[1]);
        if (y.isZero) return Num.of(double.nan);
        final r = x / y;
        return r.isSmall ? Num.r(r) : Num.of(r.clampToDouble());
      }
      need(1);
      return Num.of(a(0) - a(0).truncateToDouble());
    case 'gcd':
      need(2);
      return Num.of(_bigFromNum(args[0]).gcd(_bigFromNum(args[1])).toDouble());
    case 'lcm':
      need(2);
      final x = _bigFromNum(args[0]).abs();
      final y = _bigFromNum(args[1]).abs();
      if (x == BigInt.zero || y == BigInt.zero) return Num.zero;
      return Num.of((x ~/ x.gcd(y) * y).toDouble());
    case 'mod':
      need(2);
      final b = a(1);
      if (b == 0) return Num.of(double.nan);
      return Num.of(a(0) - b * (a(0) / b).floorToDouble());
    case 'ncr':
      need(2);
      if (!_isIntegerValue(args[0]) || !_isIntegerValue(args[1])) {
        return Num.of(double.nan);
      }
      final n = _bigFromNum(args[0]).toInt();
      final r = _bigFromNum(args[1]).toInt();
      if (r < 0 || n < 0 || r > n) return Num.of(double.nan);
      var result = BigInt.one;
      for (var i = 0; i < r; i++) {
        result = result * BigInt.from(n - i) ~/ BigInt.from(i + 1);
      }
      return Num.of(result.toDouble());
    case 'npr':
      need(2);
      if (!_isIntegerValue(args[0]) || !_isIntegerValue(args[1])) {
        return Num.of(double.nan);
      }
      final n = _bigFromNum(args[0]).toInt();
      final r = _bigFromNum(args[1]).toInt();
      if (r < 0 || n < 0 || r > n) return Num.of(double.nan);
      var result = BigInt.one;
      for (var i = 0; i < r; i++) {
        result *= BigInt.from(n - i);
      }
      return Num.of(result.toDouble());
    case 'fact':
      need(1);
      return _factorialNum(args[0]);
    case 'percent':
      need(1);
      return Num.of(a(0) / 100);
    case 'min':
      need(2);
      return args[0].v <= args[1].v ? args[0] : args[1];
    case 'max':
      need(2);
      return args[0].v >= args[1].v ? args[0] : args[1];
    case 'hypot':
      need(2);
      return Num.of(math.sqrt(a(0) * a(0) + a(1) * a(1)));
    case 'atan2':
      need(2);
      return Num.of(fromRadians(math.atan2(a(0), a(1)), angle));
    case 'deg':
      need(1);
      return Num.of(a(0) * 180 / math.pi);
    case 'rad':
      need(1);
      return Num.of(a(0) * math.pi / 180);
    case 'rand':
      need(0);
      return Num.of(_rng.nextDouble());
    case 'randint':
      need(2);
      if (!_isIntegerValue(args[0]) || !_isIntegerValue(args[1])) {
        return Num.of(double.nan);
      }
      final lo = _bigFromNum(args[0]).toInt();
      final hi = _bigFromNum(args[1]).toInt();
      if (hi < lo) return Num.of(double.nan);
      return Num.i(lo + _rng.nextInt(hi - lo + 1));
    default:
      throw ArgumentError('Unknown function $rawName');
  }
}

BigInt _bigFromNum(Num n) {
  if (n.q != null && n.q!.isInteger) return n.q!.n;
  return BigInt.from(n.v.round());
}

/// True when the value is a whole number within floating-point tolerance.
bool _isIntegerValue(Num n) =>
    n.v.isFinite && (n.v - n.v.roundToDouble()).abs() < 1e-9;

Rational _rationalOf(Num n) {
  final q = n.q;
  if (q != null) return q;
  if (n.v == n.v.roundToDouble() && n.v.abs() < 1e15) {
    return Rational.fromInt(n.v.toInt());
  }
  return Rational.tryParseDecimal(n.v.toString()) ??
      Rational.approx(n.v, maxDen: 1000000);
}

Num _factorialNum(Num n) {
  if (!n.v.isFinite) return Num.of(double.nan);
  final rounded = n.v.roundToDouble();
  // Casio only accepts non-negative integers (5.0 counts, 5.5 does not).
  if ((n.v - rounded).abs() > 1e-9) return Num.of(double.nan);
  final k = rounded.toInt();
  if (k < 0) return Num.of(double.nan);
  if (k > 170) return Num.of(double.infinity);
  final big = _factorialBig(k);
  if (k <= 20) {
    // Keep the exact rational form for small factorials.
    return Num(big.toDouble(), Rational.of(big));
  }
  return Num.of(big.toDouble());
}

double _trimTrig(double x) {
  if (x.abs() < 1e-15) return 0;
  final r = x.roundToDouble();
  if ((x - r).abs() < 1e-14) return r;
  return x;
}
