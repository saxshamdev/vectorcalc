enum TokType { number, ident, op, lparen, rparen, comma, eof }

class Token {
  final TokType type;
  final String text;
  final double? value;
  final int start;
  final int end;

  const Token(this.type, this.text, this.start, this.end, [this.value]);

  @override
  String toString() => '${type.name}($text)';
}

/// Normalises calculator glyphs into plain ASCII-ish tokens.
String normalizeInput(String input) {
  var s = input;
  const replacements = <String, String>{
    '×': '*',
    '·': '*',
    '⋅': '*',
    '÷': '/',
    '∕': '/',
    '−': '-',
    '–': '-',
    '—': '-',
    '²': '^2',
    '³': '^3',
    '⁻¹': '^(-1)',
    'π': 'pi',
    'τ': 'tau',
    'θ': 'theta',
    '√': '√',
    '∛': '∛',
    // ES PLUS style entry glyphs. The display keeps the glyph; the parser sees
    // a plain function name.
    'Σ': 'sumto',
    '∑': 'sumto',
    'Π': 'prodto',
    '∏': 'prodto',
    '∫': 'integ',
    'd/dx': 'diff',
    'ⁿ√': 'nroot',
    '∠': 'angle',
    '\u00A0': ' ',
  };
  for (final e in replacements.entries) {
    s = s.replaceAll(e.key, e.value);
  }
  return s;
}

class Lexer {
  final String src;
  int _pos = 0;

  Lexer(String input) : src = normalizeInput(input);

  List<Token> tokenize() {
    final out = <Token>[];
    while (true) {
      _skipSpace();
      if (_pos >= src.length) {
        out.add(Token(TokType.eof, '', _pos, _pos));
        return out;
      }
      final c = src[_pos];
      if (_isDigit(c) || (c == '.' && _pos + 1 < src.length && _isDigit(src[_pos + 1]))) {
        out.add(_number());
      } else if (c == '√' || c == '∛') {
        out.add(Token(TokType.op, c, _pos, ++_pos));
      } else if (_isLetter(c)) {
        out.add(_ident());
      } else if (c == '(') {
        out.add(Token(TokType.lparen, c, _pos, ++_pos));
      } else if (c == ')') {
        out.add(Token(TokType.rparen, c, _pos, ++_pos));
      } else if (c == ',') {
        out.add(Token(TokType.comma, c, _pos, ++_pos));
      } else {
        out.add(Token(TokType.op, c, _pos, ++_pos));
      }
    }
  }

  void _skipSpace() {
    while (_pos < src.length && (src[_pos] == ' ' || src[_pos] == '\t' || src[_pos] == '\n')) {
      _pos++;
    }
  }

  static bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;

  static bool _isLetter(String c) {
    final u = c.codeUnitAt(0);
    return (u >= 65 && u <= 90) || (u >= 97 && u <= 122) || u == 0x3C0;
  }

  Token _number() {
    final start = _pos;
    var seenDot = false;
    while (_pos < src.length) {
      final c = src[_pos];
      if (_isDigit(c)) {
        _pos++;
      } else if (c == '.' && !seenDot) {
        seenDot = true;
        _pos++;
      } else {
        break;
      }
    }
    // Scientific notation written as 1.2E3 or 1.2e3.
    if (_pos < src.length && (src[_pos] == 'E' || src[_pos] == 'e')) {
      var look = _pos + 1;
      if (look < src.length && (src[look] == '+' || src[look] == '-')) look++;
      if (look < src.length && _isDigit(src[look])) {
        _pos++; // consume E
        if (src[_pos] == '+' || src[_pos] == '-') _pos++;
        while (_pos < src.length && _isDigit(src[_pos])) {
          _pos++;
        }
      }
    }
    final text = src.substring(start, _pos);
    return Token(TokType.number, text, start, _pos, double.tryParse(text));
  }

  Token _ident() {
    final start = _pos;
    while (_pos < src.length) {
      final c = src[_pos];
      if (_isLetter(c) || _isDigit(c) || c == '_') {
        _pos++;
      } else {
        break;
      }
    }
    final text = src.substring(start, _pos);
    return Token(TokType.ident, text, start, _pos);
  }
}
