import 'evaluator.dart';
import 'num.dart';
import 'parser.dart';

export 'evaluator.dart' show EvalContext;
export 'functions.dart' show AngleMode;

class EvalResult {
  final Num? value;
  final String? error;
  final bool incomplete;

  const EvalResult.ok(this.value)
      : error = null,
        incomplete = false;

  const EvalResult.err(this.error, {this.incomplete = false}) : value = null;

  bool get ok => value != null;
}

/// Parses and evaluates [input] using the supplied context.
EvalResult evaluateExpression(String input, EvalContext ctx) {
  var trimmed = input.trim();
  if (trimmed.isEmpty) return const EvalResult.err('Empty');
  // Casio closes unbalanced parentheses automatically when you press =.
  var open = 0;
  for (var i = 0; i < trimmed.length; i++) {
    final ch = trimmed[i];
    if (ch == '(') open++;
    if (ch == ')' && open > 0) open--;
  }
  if (open > 0) trimmed = trimmed + ')' * open;
  try {
    final ast = Parser(trimmed).parse();
    final value = Evaluator(ctx).eval(ast);
    if (value.v.isNaN || value.v.isInfinite) {
      return const EvalResult.err('Math ERROR');
    }
    // fx-991ES PLUS range: |x| < 1e100.
    if (value.v.abs() >= 1e100) {
      return const EvalResult.err('Math ERROR');
    }
    return EvalResult.ok(value);
  } on ParseException {
    return const EvalResult.err('Syntax ERROR', incomplete: true);
  } on ArgumentError catch (e) {
    final msg = e.message;
    if (msg is String && msg.startsWith('Undefined')) {
      return EvalResult.err(msg);
    }
    return const EvalResult.err('Math ERROR');
  } catch (_) {
    return const EvalResult.err('Math ERROR');
  }
}

/// Best-effort evaluation used for the live preview while typing.
/// Incomplete expressions simply yield null instead of an error.
Num? previewExpression(String input, EvalContext ctx) {
  var s = input.trim();
  if (s.isEmpty) return null;

  // Auto-close unbalanced parentheses.
  var open = 0;
  for (final ch in s.split('')) {
    if (ch == '(') open++;
    if (ch == ')') open--;
  }
  if (open > 0) s = s + ')' * open;

  // Drop dangling binary operators.
  s = s.replaceFirst(RegExp(r'[+\-*/^×÷]+$'), '');
  if (s.isEmpty) return null;

  final r = evaluateExpression(s, ctx);
  if (r.ok) return r.value;
  return null;
}
