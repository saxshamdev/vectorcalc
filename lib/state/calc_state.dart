import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/engine.dart';
import '../core/format.dart';
import '../core/num.dart';
import '../theme/themes.dart';

class HistoryEntry {
  final String expression;
  final String result;
  final String? alt;
  final int millis;

  const HistoryEntry({
    required this.expression,
    required this.result,
    this.alt,
    required this.millis,
  });

  DateTime get time => DateTime.fromMillisecondsSinceEpoch(millis);

  Map<String, dynamic> toJson() => {
        'e': expression,
        'r': result,
        if (alt != null) 'a': alt,
        't': millis,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> j) => HistoryEntry(
        expression: j['e'] as String? ?? '',
        result: j['r'] as String? ?? '',
        alt: j['a'] as String?,
        millis: j['t'] as int? ?? 0,
      );
}

const List<String> variableNames = ['A', 'B', 'C', 'D', 'E', 'F', 'X', 'Y'];

class CalcState extends ChangeNotifier {
  static const _kTheme = 'vc.theme';
  static const _kBrightness = 'vc.brightness';
  static const _kAngle = 'vc.angle';
  static const _kExact = 'vc.exact';
  static const _kMode = 'vc.displayMode';
  static const _kDigits = 'vc.digits';
  static const _kEng = 'vc.engineering';
  static const _kSi = 'vc.siPrefix';
  static const _kHistory = 'vc.history';
  static const _kVars = 'vc.vars';
  static const _kAns = 'vc.ans';
  static const _kPreAns = 'vc.preans';

  SharedPreferences? _prefs;

  String _expression = '';
  int _cursor = 0;
  bool _justEvaluated = false;

  String _themeId = 'amber';
  BrightnessMode _brightness = BrightnessMode.night;
  AngleMode _angle = AngleMode.deg;
  bool _exactPreferred = true;
  FormatSettings _format = const FormatSettings();

  bool _shift = false;
  bool _alpha = false;
  bool _powered = true;
  bool _overwrite = false;
  String? _notice;
  Timer? _noticeTimer;

  int? _historyCursor;
  String _historyDraft = '';

  Num _ans = Num.i(0);
  Num _preAns = Num.i(0);
  final Map<String, Num> _variables = {
    'A': Num.i(0),
    'B': Num.i(0),
    'C': Num.i(0),
    'D': Num.i(0),
    'E': Num.i(0),
    'F': Num.i(0),
    'X': Num.i(0),
    'Y': Num.i(0),
    'M': Num.i(0),
  };

  final List<HistoryEntry> _history = [];

  Num? _lastResult;
  String? _error;

  Num? _previewCache;
  bool _previewValid = false;

  // ---------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------

  String get expression => _expression;
  int get cursor => _cursor;
  bool get justEvaluated => _justEvaluated;
  bool get shiftOn => _shift;
  bool get alphaOn => _alpha;
  bool get powered => _powered;
  bool get overwrite => _overwrite;
  String? get notice => _notice;
  String get themeId => _themeId;
  BrightnessMode get brightness => _brightness;
  AngleMode get angle => _angle;
  bool get exactPreferred => _exactPreferred;
  FormatSettings get format => _format;
  Num get ans => _ans;
  Num get preAns => _preAns;
  List<HistoryEntry> get history => List.unmodifiable(_history);
  Map<String, Num> get variables => Map.unmodifiable(_variables);
  Num get memory => _variables['M'] ?? Num.i(0);
  Num? get lastResult => _lastResult;
  String? get error => _error;

  AppTheme get theme => themeById(_themeId);
  Palette get palette => theme.palette(_brightness);

  EvalContext get evalContext => EvalContext(
        variables: Map<String, Num>.from(_variables),
        ans: _ans,
        preAns: _preAns,
        angle: _angle,
      );

  Num? get preview {
    if (!_previewValid) {
      _previewCache = previewExpression(_expression, evalContext);
      _previewValid = true;
    }
    return _previewCache;
  }

  /// The value the big result line should show.
  Num? get displayValue {
    if (_error != null) return null;
    if (_justEvaluated) return _lastResult;
    return preview;
  }

  String get displayText {
    final v = displayValue;
    if (v == null) return '';
    return formatValue(v, _format, preferExact: _exactPreferred);
  }

  String? get displayAlt {
    final v = displayValue;
    if (v == null) return null;
    return altFormatValue(v, _format, preferExact: _exactPreferred);
  }

  String get expressionText => _expression.isEmpty ? '0' : _expression;

  /// Expression with a caret marker at the cursor, for the display.
  String get expressionWithCaret {
    if (_justEvaluated) return _expression.isEmpty ? '0' : _expression;
    final e = _expression;
    if (e.isEmpty) return '▏';
    final c = _cursor.clamp(0, e.length);
    return '${e.substring(0, c)}▏${e.substring(c)}';
  }

  String formatNum(Num n) => formatValue(n, _format, preferExact: _exactPreferred);

  // ---------------------------------------------------------------------
  // Loading / persistence
  // ---------------------------------------------------------------------

  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      return;
    }
    final p = _prefs!;
    _themeId = p.getString(_kTheme) ?? _themeId;
    final b = p.getString(_kBrightness);
    _brightness = b == 'bright' ? BrightnessMode.bright : BrightnessMode.night;
    final a = p.getString(_kAngle);
    _angle = switch (a) {
      'rad' => AngleMode.rad,
      'grad' => AngleMode.grad,
      _ => AngleMode.deg,
    };
    _exactPreferred = p.getBool(_kExact) ?? true;
    final m = p.getString(_kMode);
    final mode = switch (m) {
      'fix' => DisplayMode.fix,
      'sci' => DisplayMode.sci,
      _ => DisplayMode.norm,
    };
    _format = FormatSettings(
      mode: mode,
      digits: p.getInt(_kDigits) ?? 4,
      engineering: p.getBool(_kEng) ?? false,
      siPrefix: p.getBool(_kSi) ?? false,
    );

    final h = p.getString(_kHistory);
    if (h != null && h.isNotEmpty) {
      try {
        final list = jsonDecode(h) as List<dynamic>;
        _history
          ..clear()
          ..addAll(list
              .whereType<Map<String, dynamic>>()
              .map(HistoryEntry.fromJson));
      } catch (_) {}
    }

    final v = p.getString(_kVars);
    if (v != null && v.isNotEmpty) {
      try {
        final map = jsonDecode(v) as Map<String, dynamic>;
        for (final e in map.entries) {
          final d = e.value;
          if (d is num) _variables[e.key] = Num.of(d.toDouble());
        }
      } catch (_) {}
    }

    final ansRaw = p.getDouble(_kAns);
    if (ansRaw != null) _ans = Num.of(ansRaw);
    final preRaw = p.getDouble(_kPreAns);
    if (preRaw != null) _preAns = Num.of(preRaw);

    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final p = _prefs;
    if (p == null) return;
    await p.setString(_kTheme, _themeId);
    await p.setString(_kBrightness, _brightness.name);
    await p.setString(_kAngle, _angle.name);
    await p.setBool(_kExact, _exactPreferred);
    await p.setString(_kMode, _format.mode.name);
    await p.setInt(_kDigits, _format.digits);
    await p.setBool(_kEng, _format.engineering);
    await p.setBool(_kSi, _format.siPrefix);
  }

  Future<void> _saveHistory() async {
    final p = _prefs;
    if (p == null) return;
    await p.setString(
        _kHistory, jsonEncode(_history.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveVars() async {
    final p = _prefs;
    if (p == null) return;
    await p.setString(
      _kVars,
      jsonEncode(_variables.map((k, v) => MapEntry(k, v.v))),
    );
    await p.setDouble(_kAns, _ans.v);
    await p.setDouble(_kPreAns, _preAns.v);
  }

  // ---------------------------------------------------------------------
  // Editing
  // ---------------------------------------------------------------------

  void _tick() {}

  void toggleShift() {
    if (!_powered) return;
    _shift = !_shift;
    _alpha = false;
    notifyListeners();
  }

  void toggleAlpha() {
    if (!_powered) return;
    _alpha = !_alpha;
    _shift = false;
    notifyListeners();
  }

  void clearModifiers() {
    if (!_shift && !_alpha) return;
    _shift = false;
    _alpha = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Power / status
  // ---------------------------------------------------------------------

  void powerOff() {
    if (!_powered) return;
    _powered = false;
    _shift = false;
    _alpha = false;
    _notice = null;
    _noticeTimer?.cancel();
    notifyListeners();
  }

  void powerOn() {
    if (_powered) return;
    _powered = true;
    notifyListeners();
  }

  /// Shows a short status message in the display (mode changes, stage notes).
  void setNotice(String message) {
    _notice = message;
    _noticeTimer?.cancel();
    _noticeTimer = Timer(const Duration(seconds: 3), () {
      _notice = null;
      notifyListeners();
    });
    notifyListeners();
  }

  void clearNotice() {
    if (_notice == null) return;
    _notice = null;
    _noticeTimer?.cancel();
    notifyListeners();
  }

  void toggleInsertMode() {
    if (!_powered) return;
    _overwrite = !_overwrite;
    _tick();
    notifyListeners();
  }

  @override
  void notifyListeners() {
    // Any state change can affect the live preview; recompute it lazily once
    // per change instead of on every widget rebuild.
    _previewValid = false;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _noticeTimer?.cancel();
    super.dispose();
  }

  void insert(String text) {
    if (text.isEmpty || !_powered) return;
    _tick();
    _error = null;
    _notice = null;
    _noticeTimer?.cancel();
    _historyCursor = null;

    if (_justEvaluated) {
      const continues = {'+', '−', '×', '÷', '^'};
      if (continues.contains(text)) {
        _expression = 'Ans$text';
        _cursor = _expression.length;
      } else {
        _expression = '';
        _cursor = 0;
      }
      _justEvaluated = false;
    }

    if (_expression == '0' && RegExp(r'^[0-9.]$').hasMatch(text)) {
      _expression = '';
      _cursor = 0;
    }

    // Avoid duplicate decimal points inside the current number literal only.
    if (text == '.') {
      var i = _cursor - 1;
      while (i >= 0 && RegExp(r'[0-9.]').hasMatch(_expression[i])) {
        if (_expression[i] == '.') return;
        i--;
      }
    }

    final c = _cursor.clamp(0, _expression.length);
    if (_overwrite && c < _expression.length) {
      final span = _expression.startsWith('⁻¹', c) ? 2 : 1;
      _expression = _expression.replaceRange(c, c + span, text);
    } else {
      _expression = _expression.replaceRange(c, c, text);
    }
    _cursor = c + text.length;
    _shift = false;
    _alpha = false;
    notifyListeners();
  }

  void backspace() {
    if (!_powered) return;
    _tick();
    _error = null;
    _notice = null;
    _historyCursor = null;
    if (_justEvaluated) {
      _expression = '';
      _cursor = 0;
      _justEvaluated = false;
      _lastResult = null;
      notifyListeners();
      return;
    }
    if (_cursor <= 0) return;
    if (_expression.endsWith('⁻¹') && _cursor >= 2) {
      _expression =
          _expression.replaceRange(_cursor - 2, _cursor, '');
      _cursor -= 2;
    } else {
      _expression = _expression.replaceRange(_cursor - 1, _cursor, '');
      _cursor -= 1;
    }
    notifyListeners();
  }

  void clearAll() {
    if (!_powered) return;
    _tick();
    _expression = '';
    _cursor = 0;
    _justEvaluated = false;
    _lastResult = null;
    _error = null;
    _shift = false;
    _alpha = false;
    _notice = null;
    _historyCursor = null;
    notifyListeners();
  }

  void clearEntry() {
    if (!_powered) return;
    _tick();
    _expression = '';
    _cursor = 0;
    _justEvaluated = false;
    _lastResult = null;
    _error = null;
    _notice = null;
    _historyCursor = null;
    notifyListeners();
  }

  void moveCursor(int delta) {
    if (!_powered || _justEvaluated) return;
    _cursor = (_cursor + delta).clamp(0, _expression.length);
    notifyListeners();
  }

  void setExpression(String value) {
    _expression = value;
    _cursor = value.length;
    _justEvaluated = false;
    _lastResult = null;
    _error = null;
    _notice = null;
    _historyCursor = null;
    notifyListeners();
  }

  /// REPLAY up: step back through the history tape.
  void historyUp() {
    if (!_powered || _history.isEmpty) return;
    final current = _historyCursor;
    if (current == null) {
      _historyDraft = _expression;
      _historyCursor = 0;
    } else if (current < _history.length - 1) {
      _historyCursor = current + 1;
    } else {
      return;
    }
    _expression = _history[_historyCursor!].expression;
    _cursor = _expression.length;
    _justEvaluated = false;
    _error = null;
    _notice = null;
    notifyListeners();
  }

  /// REPLAY down: step forward, then back to the draft expression.
  void historyDown() {
    if (!_powered) return;
    final current = _historyCursor;
    if (current == null) return;
    if (current == 0) {
      _historyCursor = null;
      _expression = _historyDraft;
      _cursor = _expression.length;
    } else {
      _historyCursor = current - 1;
      _expression = _history[_historyCursor!].expression;
      _cursor = _expression.length;
    }
    _justEvaluated = false;
    _error = null;
    _notice = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Evaluation
  // ---------------------------------------------------------------------

  void evaluate() {
    if (!_powered) return;
    if (_expression.trim().isEmpty) return;
    _tick();
    _notice = null;
    _historyCursor = null;
    final ctx = evalContext;
    final r = evaluateExpression(_expression, ctx);
    if (!r.ok) {
      _error = r.error;
      _justEvaluated = false;
      notifyListeners();
      return;
    }
    final value = r.value!;
    if (ctx.outputs.isNotEmpty) {
      _variables.addAll(ctx.outputs);
    }
    _preAns = _ans;
    _ans = value;
    _lastResult = value;
    _error = null;
    _justEvaluated = true;
    _cursor = _expression.length;

    final entry = HistoryEntry(
      expression: _expression,
      result: formatValue(value, _format, preferExact: _exactPreferred),
      alt: altFormatValue(value, _format, preferExact: _exactPreferred),
      millis: DateTime.now().millisecondsSinceEpoch,
    );
    _history.insert(0, entry);
    if (_history.length > 100) {
      _history.removeRange(100, _history.length);
    }
    _saveHistory();
    _saveVars();
    notifyListeners();
  }

  /// SHIFT+CALC: numerically solve the current expression for X (Newton).
  void solve() {
    if (!_powered) return;
    final expr = _expression.trim();
    if (expr.isEmpty) {
      setNotice('Nothing to solve');
      return;
    }
    _tick();
    final ctx = evalContext;

    double f(double x) {
      ctx.variables['X'] = Num.of(x);
      final r = evaluateExpression(expr, ctx);
      return r.ok ? r.value!.v : double.nan;
    }

    var x = ctx.variables['X']?.v ?? 0;
    if (!x.isFinite) x = 0;
    var found = false;

    for (var i = 0; i < 120; i++) {
      final fx = f(x);
      if (!fx.isFinite) break;
      if (fx.abs() < 1e-11) {
        found = true;
        break;
      }
      final h = 1e-6 * math.max(1.0, x.abs());
      final df = (f(x + h) - f(x - h)) / (2 * h);
      if (!df.isFinite || df.abs() < 1e-14) break;
      final next = x - fx / df;
      if (!next.isFinite) break;
      if ((next - x).abs() <= 1e-12 * math.max(1.0, next.abs())) {
        x = next;
        found = true;
        break;
      }
      x = next;
    }

    if (!found) {
      setNotice('No solution found');
      return;
    }

    _variables['X'] = Num.of(x);
    _saveVars();
    _expression = 'X';
    _cursor = 1;
    _lastResult = Num.of(x);
    _justEvaluated = true;
    _error = null;
    _notice = null;

    final entry = HistoryEntry(
      expression: 'SOLVE: $expr',
      result: formatValue(Num.of(x), _format, preferExact: _exactPreferred),
      alt: altFormatValue(Num.of(x), _format, preferExact: _exactPreferred),
      millis: DateTime.now().millisecondsSinceEpoch,
    );
    _history.insert(0, entry);
    if (_history.length > 100) {
      _history.removeRange(100, _history.length);
    }
    _saveHistory();
    notifyListeners();
  }

  void toggleExact() {
    _exactPreferred = !_exactPreferred;
    _saveSettings();
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------

  void setTheme(String id) {
    _themeId = id;
    _saveSettings();
    notifyListeners();
  }

  void setBrightness(BrightnessMode mode) {
    _brightness = mode;
    _saveSettings();
    notifyListeners();
  }

  void toggleBrightness() {
    setBrightness(_brightness == BrightnessMode.night
        ? BrightnessMode.bright
        : BrightnessMode.night);
  }

  void setAngle(AngleMode mode) {
    _angle = mode;
    _saveSettings();
    notifyListeners();
  }

  void cycleAngle() {
    setAngle(switch (_angle) {
      AngleMode.deg => AngleMode.rad,
      AngleMode.rad => AngleMode.grad,
      AngleMode.grad => AngleMode.deg,
    });
  }

  void setFormat(FormatSettings f) {
    _format = f;
    _saveSettings();
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Variables / memory
  // ---------------------------------------------------------------------

  void storeVariable(String name, Num value) {
    _variables[name] = value;
    _saveVars();
    notifyListeners();
  }

  void storeCurrentTo(String name) {
    final v = displayValue;
    if (v == null) return;
    storeVariable(name, v);
  }

  void clearVariable(String name) {
    _variables[name] = Num.i(0);
    _saveVars();
    notifyListeners();
  }

  void resetVariables() {
    for (final name in _variables.keys.toList()) {
      _variables[name] = Num.i(0);
    }
    _ans = Num.i(0);
    _preAns = Num.i(0);
    _saveVars();
    notifyListeners();
  }

  void memoryAdd() {
    final v = displayValue;
    if (v == null) return;
    _variables['M'] = memory + v;
    _saveVars();
    notifyListeners();
  }

  void memorySubtract() {
    final v = displayValue;
    if (v == null) return;
    _variables['M'] = memory - v;
    _saveVars();
    notifyListeners();
  }

  void memoryClear() {
    _variables['M'] = Num.i(0);
    _saveVars();
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // History
  // ---------------------------------------------------------------------

  void recallHistory(HistoryEntry entry) {
    setExpression(entry.expression);
  }

  void clearHistory() {
    _history.clear();
    _saveHistory();
    notifyListeners();
  }

  void removeHistoryAt(int index) {
    if (index < 0 || index >= _history.length) return;
    _history.removeAt(index);
    _saveHistory();
    notifyListeners();
  }
}
