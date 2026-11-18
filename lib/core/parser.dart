import 'ast.dart';
import 'functions.dart';
import 'lexer.dart';
import 'rational.dart';

class ParseException implements Exception {
  final String message;
  ParseException(this.message);
  @override
  String toString() => message;
}

const Set<String> knownFunctions = {
  'sin', 'cos', 'tan',
  'asin', 'acos', 'atan',
  'sinh', 'cosh', 'tanh',
  'asinh', 'acosh', 'atanh',
  'log', 'ln', 'exp', 'sqrt', 'cbrt', 'root',
  'abs', 'sign', 'floor', 'ceil', 'round', 'int', 'frac',
  'gcd', 'lcm', 'mod', 'ncr', 'npr',
  'min', 'max', 'rand', 'randint', 'hypot', 'atan2',
  'deg', 'rad', 'fact', 'percent',
  // ES PLUS additions
  'sumto', 'prodto', 'integ', 'diff', 'nroot', 'rnd', 'pol', 'rec', 'angle',
};

/// Pratt parser producing an [Node] tree from a calculator expression.
class Parser {
  final List<Token> _t;
  int _i = 0;

  Parser(String input) : _t = Lexer(input).tokenize();

  Token get _peek => _t[_i];

  Token _next() => _t[_i++];

  Node parse() {
    if (_peek.type == TokType.eof) throw ParseException('Empty expression');
    final n = _expr(0);
    if (_peek.type != TokType.eof) {
      throw ParseException('Unexpected "${_peek.text}"');
    }
    return n;
  }

  static bool _isPostfix(String s) =>
      s == '!' || s == '%' || s == '°' || s == '′' || s == '″';

  static (int, int)? _binaryBp(String op) {
    switch (op) {
      case '+':
      case '-':
        return (10, 11);
      case '*':
      case '/':
        return (20, 21);
      case '^':
        return (40, 40);
    }
    return null;
  }

  bool _startsPrimary(Token t) {
    switch (t.type) {
      case TokType.number:
      case TokType.ident:
      case TokType.lparen:
        return true;
      case TokType.op:
        return t.text == '√' || t.text == '∛';
      default:
        return false;
    }
  }

  Node _expr(int minBp) {
    var left = _prefix();
    while (true) {
      final t = _peek;
      if (t.type == TokType.op && _isPostfix(t.text)) {
        _next();
        left = PostfixNode(t.text, left);
        continue;
      }
      if (t.type == TokType.op) {
        final bp = _binaryBp(t.text);
        if (bp != null && bp.$1 >= minBp) {
          _next();
          final right = _expr(bp.$2);
          left = BinaryNode(t.text, left, right);
          continue;
        }
        // `2√9` — a prefix operator directly after a value multiplies.
        if (bp == null && _startsPrimary(t)) {
          const lbp = 20;
          if (lbp < minBp) break;
          final right = _expr(21);
          left = BinaryNode('*', left, right);
          continue;
        }
        break;
      }
      if (_startsPrimary(t)) {
        const lbp = 20;
        if (lbp < minBp) break;
        final right = _expr(21);
        left = BinaryNode('*', left, right);
        continue;
      }
      break;
    }
    return left;
  }

  Node _prefix() {
    final t = _next();
    switch (t.type) {
      case TokType.number:
        // Only whole-number literals carry an exact form. A literal typed with
        // a decimal point stays a decimal (0.5 shows as 0.5, not 1/2), which
        // matches the way a Casio treats decimal entry.
        final text = t.text;
        final exact = RegExp(r'^\d+$').hasMatch(text)
            ? Rational.tryParseDecimal(text)
            : null;
        return NumberNode(t.value ?? 0, exact);
      case TokType.lparen:
        final inner = _expr(0);
        if (_peek.type != TokType.rparen) {
          throw ParseException('Missing ")"');
        }
        _next();
        return inner;
      case TokType.op:
        if (t.text == '-') return UnaryNode('-', _expr(30));
        if (t.text == '+') return _expr(30);
        if (t.text == '√') return UnaryNode('sqrt', _expr(45));
        if (t.text == '∛') return UnaryNode('cbrt', _expr(45));
        throw ParseException('Unexpected "${t.text}"');
      case TokType.ident:
        final name = t.text;
        final lowerName = name.toLowerCase();
        // Only real functions consume parentheses. `A(2)` is A×2, not a call.
        if (_peek.type == TokType.lparen &&
            knownFunctions.contains(lowerName)) {
          _next();
          final args = <Node>[];
          if (_peek.type != TokType.rparen) {
            args.add(_expr(0));
            while (_peek.type == TokType.comma) {
              _next();
              args.add(_expr(0));
            }
          }
          if (_peek.type != TokType.rparen) {
            throw ParseException('Missing ")"');
          }
          _next();
          return CallNode(name, args);
        }
        if (knownFunctions.contains(lowerName)) {
          return CallNode(name, [_expr(45)]);
        }
        // The lexer keeps letters and digits together (`π2` -> `pi2`,
        // `Ans2` -> `Ans2`). Split a trailing number back off so implicit
        // multiplication and `sin2` style entry keep working.
        if (!isKnownIdentifier(name)) {
          final split = _splitNameAndDigits(name);
          if (split != null) {
            final base = split.$1;
            final digits = split.$2;
            final number = NumberNode(
              double.parse(digits),
              Rational.tryParseDecimal(digits),
            );
            if (knownFunctions.contains(base.toLowerCase())) {
              return CallNode(base, [number]);
            }
            return BinaryNode('*', VariableNode(base), number);
          }
        }
        return VariableNode(name);
      default:
        throw ParseException('Unexpected "${t.text}"');
    }
  }

  /// Splits `pi2` into (`pi`, `2`) and `Ans12` into (`Ans`, `12`).
  static (String, String)? _splitNameAndDigits(String name) {
    final m = RegExp(r'^([A-Za-z_]+)(\d+)$').firstMatch(name);
    if (m == null) return null;
    return (m.group(1)!, m.group(2)!);
  }
}
