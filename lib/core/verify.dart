import 'dart:math' as math;

import 'engine.dart';
import 'num.dart';

/// The relational operators accepted by VERIFY.
const List<String> verifyOperators = ['=', '≠', '<', '≤', '>', '≥'];

/// A top-level relational operator found in an expression.
class RelationSplit {
  final String operator;
  final int index;
  final int length;

  const RelationSplit(this.operator, this.index, this.length);
}

/// Result of checking a relation such as `3 + 4 = 7`.
class VerifyOutcome {
  final String? operator;
  final Num? left;
  final Num? right;
  final bool? result;
  final String? error;

  const VerifyOutcome({
    this.operator,
    this.left,
    this.right,
    this.result,
    this.error,
  });

  bool get ok => result != null;
}

/// Finds the first relational operator that is not nested inside parentheses.
RelationSplit? findRelation(String input) {
  var depth = 0;
  for (var i = 0; i < input.length; i++) {
    final ch = input[i];
    if (ch == '(') {
      depth++;
      continue;
    }
    if (ch == ')') {
      if (depth > 0) depth--;
      continue;
    }
    if (depth != 0) continue;

    final next = i + 1 < input.length ? input[i + 1] : '';
    switch (ch) {
      case '<':
        if (next == '=') return RelationSplit('≤', i, 2);
        if (next == '>') return RelationSplit('≠', i, 2);
        return RelationSplit('<', i, 1);
      case '>':
        if (next == '=') return RelationSplit('≥', i, 2);
        return RelationSplit('>', i, 1);
      case '!':
        if (next == '=') return RelationSplit('≠', i, 2);
        return null;
      case '=':
        return RelationSplit('=', i, next == '=' ? 2 : 1);
      case '≠':
      case '≤':
      case '≥':
        return RelationSplit(ch, i, 1);
    }
  }
  return null;
}

/// Evaluates both sides of [input] and compares them.
///
/// Equality uses a relative tolerance so results such as `sin(30) = 0.5`
/// and `1/3 = 0.3333333333` are accepted despite binary rounding.
VerifyOutcome verifyRelation(String input, EvalContext ctx) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) {
    return const VerifyOutcome(error: 'Enter a relation');
  }
  final rel = findRelation(trimmed);
  if (rel == null) {
    return const VerifyOutcome(error: 'No relation operator');
  }
  final lhs = trimmed.substring(0, rel.index).trim();
  final rhs = trimmed.substring(rel.index + rel.length).trim();
  if (lhs.isEmpty || rhs.isEmpty) {
    return const VerifyOutcome(error: 'Incomplete relation');
  }

  final l = evaluateExpression(lhs, ctx);
  if (!l.ok) return VerifyOutcome(error: 'Left side: ${l.error}');
  final r = evaluateExpression(rhs, ctx);
  if (!r.ok) return VerifyOutcome(error: 'Right side: ${r.error}');

  final a = l.value!;
  final b = r.value!;
  final tol = 1e-9 * math.max(1.0, math.max(a.v.abs(), b.v.abs()));
  final diff = a.v - b.v;
  final equal = diff.abs() <= tol;

  final bool result = switch (rel.operator) {
    '=' => equal,
    '≠' => !equal,
    '<' => diff < -tol,
    '≤' => diff <= tol,
    '>' => diff > tol,
    '≥' => diff >= -tol,
    _ => false,
  };

  return VerifyOutcome(
    operator: rel.operator,
    left: a,
    right: b,
    result: result,
  );
}
