import 'dart:math' as math;

import 'ast.dart';
import 'functions.dart';
import 'num.dart';

class EvalContext {
  final Map<String, Num> variables;
  final Num ans;
  final Num preAns;
  final AngleMode angle;

  /// Values written as a side effect of Pol()/Rec() (X and Y).
  final Map<String, Num> outputs;

  EvalContext({
    Map<String, Num>? variables,
    Num? ans,
    Num? preAns,
    this.angle = AngleMode.deg,
    Map<String, Num>? outputs,
  })  : variables = variables ?? <String, Num>{},
        ans = ans ?? Num.i(0),
        preAns = preAns ?? Num.i(0),
        outputs = outputs ?? <String, Num>{};
}

class Evaluator {
  final EvalContext ctx;
  Evaluator(this.ctx);

  Num eval(Node n) {
    if (n is NumberNode) {
      final q = n.exact;
      if (q != null && q.isSmall) return Num(n.value, q);
      return Num.of(n.value);
    }
    if (n is VariableNode) return _variable(n.name);
    if (n is UnaryNode) {
      final v = eval(n.child);
      switch (n.op) {
        case '-':
          return -v;
        case 'sqrt':
          return callFunction('sqrt', [v], ctx.angle);
        case 'cbrt':
          return callFunction('cbrt', [v], ctx.angle);
      }
      throw StateError('Unknown unary operator ${n.op}');
    }
    if (n is BinaryNode) {
      final l = eval(n.left);
      // Casio treats a percentage after + or - as relative to the left side:
      // 200+10% = 220, 200-10% = 180. For * and / the plain /100 rule applies.
      if ((n.op == '+' || n.op == '-') &&
          n.right is PostfixNode &&
          (n.right as PostfixNode).op == '%') {
        final base = eval((n.right as PostfixNode).child);
        final delta = l * base / Num.i(100);
        return n.op == '+' ? l + delta : l - delta;
      }
      final r = eval(n.right);
      switch (n.op) {
        case '+':
          return l + r;
        case '-':
          return l - r;
        case '*':
          return l * r;
        case '/':
          return l / r;
        case '^':
          return l.pow(r);
      }
      throw StateError('Unknown operator ${n.op}');
    }
    if (n is PostfixNode) {
      final v = eval(n.child);
      switch (n.op) {
        case '!':
          return callFunction('fact', [v], ctx.angle);
        case '%':
          return Num.of(v.v / 100);
        case '°':
          return Num.of(fromRadians(toRadians(v.v, AngleMode.deg), ctx.angle));
        case '′':
          return Num.of(fromRadians(toRadians(v.v / 60, AngleMode.deg), ctx.angle));
        case '″':
          return Num.of(fromRadians(toRadians(v.v / 3600, AngleMode.deg), ctx.angle));
      }
      throw StateError('Unknown postfix operator ${n.op}');
    }
    if (n is CallNode) {
      // These need to control when (and how often) their arguments run.
      switch (n.name.toLowerCase()) {
        case 'sumto':
          return _sumProduct(n.args, product: false);
        case 'prodto':
          return _sumProduct(n.args, product: true);
        case 'integ':
          return _integral(n.args);
        case 'diff':
          return _derivative(n.args);
        case 'pol':
          return _pol(n.args);
        case 'rec':
          return _rec(n.args);
      }
      final args = n.args.map(eval).toList();
      return callFunction(n.name, args, ctx.angle);
    }
    throw StateError('Unknown node');
  }

  // -------------------------------------------------------------------
  // ES PLUS calculus / coordinate functions (X is the implied variable)
  // -------------------------------------------------------------------

  static const int _maxIterations = 100000;

  void _need(List<Node> args, int count, String name) {
    if (args.length != count) {
      throw ArgumentError('$name expects $count argument(s)');
    }
  }

  Num _sumProduct(List<Node> args, {required bool product}) {
    _need(args, 3, product ? 'prodto' : 'sumto');
    final lower = eval(args[1]).v;
    final upper = eval(args[2]).v;
    if (!lower.isFinite || !upper.isFinite) {
      throw ArgumentError('Math ERROR');
    }
    final a = lower.round();
    final b = upper.round();
    final saved = ctx.variables['X'];
    try {
      var acc = product ? Num.one : Num.zero;
      if (b < a) return acc;
      if (b - a > _maxIterations) throw ArgumentError('Math ERROR');
      for (var i = a; i <= b; i++) {
        ctx.variables['X'] = Num.i(i);
        final v = eval(args[0]);
        acc = product ? acc * v : acc + v;
      }
      return acc;
    } finally {
      _restore('X', saved);
    }
  }

  Num _integral(List<Node> args) {
    _need(args, 3, 'integ');
    final lo = eval(args[1]).v;
    final hi = eval(args[2]).v;
    if (!lo.isFinite || !hi.isFinite) {
      throw ArgumentError('Math ERROR');
    }
    final saved = ctx.variables['X'];
    try {
      var evaluations = 0;
      double f(double x) {
        // A pathological integrand must never lock up the UI thread.
        if (++evaluations > 120000) throw ArgumentError('Math ERROR');
        ctx.variables['X'] = Num.of(x);
        final v = eval(args[0]).v;
        if (!v.isFinite) throw ArgumentError('Math ERROR');
        return v;
      }

      if (lo == hi) return Num.zero;
      final sign = hi < lo ? -1.0 : 1.0;
      final a = math.min(lo, hi);
      final b = math.max(lo, hi);
      final value = _adaptiveSimpson(f, a, b, 1e-10, 22);
      return Num.of(sign * value);
    } finally {
      _restore('X', saved);
    }
  }

  Num _derivative(List<Node> args) {
    _need(args, 2, 'diff');
    final x0 = eval(args[1]).v;
    if (!x0.isFinite) throw ArgumentError('Math ERROR');
    final saved = ctx.variables['X'];
    try {
      double f(double x) {
        ctx.variables['X'] = Num.of(x);
        final v = eval(args[0]).v;
        if (!v.isFinite) throw ArgumentError('Math ERROR');
        return v;
      }

      final h = 1e-4 * math.max(1.0, x0.abs());
      final d1 = (f(x0 + h) - f(x0 - h)) / (2 * h);
      final d2 = (f(x0 + h / 2) - f(x0 - h / 2)) / h;
      // Richardson extrapolation cancels the leading truncation error.
      return Num.of(d2 + (d2 - d1) / 3);
    } finally {
      _restore('X', saved);
    }
  }

  Num _pol(List<Node> args) {
    _need(args, 2, 'pol');
    final x = eval(args[0]).v;
    final y = eval(args[1]).v;
    if (!x.isFinite || !y.isFinite) throw ArgumentError('Math ERROR');
    final r = math.sqrt(x * x + y * y);
    final theta = fromRadians(math.atan2(y, x), ctx.angle);
    ctx.outputs['X'] = Num.of(r);
    ctx.outputs['Y'] = Num.of(theta);
    return Num.of(r);
  }

  Num _rec(List<Node> args) {
    _need(args, 2, 'rec');
    final r = eval(args[0]).v;
    final theta = eval(args[1]).v;
    if (!r.isFinite || !theta.isFinite) throw ArgumentError('Math ERROR');
    final rad = toRadians(theta, ctx.angle);
    final x = r * math.cos(rad);
    final y = r * math.sin(rad);
    ctx.outputs['X'] = Num.of(x);
    ctx.outputs['Y'] = Num.of(y);
    return Num.of(x);
  }

  void _restore(String name, Num? saved) {
    if (saved == null) {
      ctx.variables.remove(name);
    } else {
      ctx.variables[name] = saved;
    }
  }

  static double _adaptiveSimpson(
    double Function(double) f,
    double a,
    double b,
    double eps,
    int depth,
  ) {
    final fa = f(a);
    final fb = f(b);
    final m = (a + b) / 2;
    final fm = f(m);
    final whole = (b - a) / 6 * (fa + 4 * fm + fb);

    double recurse(
      double a,
      double b,
      double fa,
      double fm,
      double fb,
      double whole,
      double eps,
      int depth,
    ) {
      final m = (a + b) / 2;
      final lm = (a + m) / 2;
      final rm = (m + b) / 2;
      final flm = f(lm);
      final frm = f(rm);
      final left = (m - a) / 6 * (fa + 4 * flm + fm);
      final right = (b - m) / 6 * (fm + 4 * frm + fb);
      final delta = left + right - whole;
      if (depth <= 0 || delta.abs() <= 15 * eps) {
        return left + right + delta / 15;
      }
      return recurse(a, m, fa, flm, fm, left, eps / 2, depth - 1) +
          recurse(m, b, fm, frm, fb, right, eps / 2, depth - 1);
    }

    return recurse(a, b, fa, fm, fb, whole, eps, depth);
  }

  // -------------------------------------------------------------------
  // Variables and constants
  // -------------------------------------------------------------------

  static const Set<String> _storageVariables = {
    'A', 'B', 'C', 'D', 'E', 'F', 'X', 'Y', 'M',
  };

  Num _variable(String raw) {
    final lower = raw.toLowerCase();
    if (lower == 'ans') return ctx.ans;
    if (lower == 'preans') return ctx.preAns;
    if (_storageVariables.contains(raw)) {
      return ctx.variables[raw] ?? Num.i(0);
    }
    final direct = constantValue(raw);
    if (direct != null) return direct;
    final upper = raw.toUpperCase();
    if (upper != raw) {
      final c2 = constantValue(upper);
      if (c2 != null) return c2;
    }
    if (lower != raw) {
      final c3 = constantValue(lower);
      if (c3 != null) return c3;
    }
    throw ArgumentError('Undefined variable "$raw"');
  }
}
