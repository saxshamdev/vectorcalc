import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/functions.dart';
import '../state/calc_state.dart';
import 'basen_page.dart';
import 'cmplx_page.dart';
import 'eqn_page.dart';
import 'matrix_page.dart';
import 'stat_page.dart';
import 'table_page.dart';
import 'vector_page.dart';
import 'widgets.dart';

enum KeyKind { num, fn, op, accent, danger, mod }

class KeySpec {
  final String label;
  final String? sup;
  final String? shift;
  final String? alpha;
  final KeyKind kind;
  final VoidCallback action;
  final VoidCallback? shiftAction;
  final VoidCallback? alphaAction;
  final bool active;

  KeySpec(
    this.label,
    this.kind,
    this.action, {
    this.sup,
    this.shift,
    this.alpha,
    this.shiftAction,
    this.alphaAction,
    this.active = false,
  });
}

/// Casio fx-991ES PLUS key matrix:
///
/// * rows 1–2 hold the SHIFT/ALPHA/MODE/ON block around the REPLAY rocker;
/// * rows 3–5 are the six-column scientific block;
/// * rows 6–9 are the five-column numeric block.
class Keypad extends StatelessWidget {
  final CalcState state;
  final bool compact;

  const Keypad({super.key, required this.state, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final rows = <List<KeySpec>>[
      _scientificRow1(context),
      _scientificRow2(context),
      _scientificRow3(context),
      _numericRow1(context),
      _numericRow2(context),
      _numericRow3(context),
      _numericRow4(context),
    ];

    return Column(
      children: [
        Expanded(flex: 2, child: _topBlock(context)),
        for (final row in rows) ...[
          const SizedBox(height: 5),
          Expanded(flex: 1, child: _row(context, row)),
        ],
      ],
    );
  }

  // -------------------------------------------------------------------
  // Layout
  // -------------------------------------------------------------------

  Widget _topBlock(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _stack(context, [
            KeySpec('SHIFT', KeyKind.mod, state.toggleShift,
                active: state.shiftOn),
            KeySpec('CALC', KeyKind.fn, state.evaluate,
                shift: 'SOLVE',
                shiftAction: state.solve,
                alpha: '=',
                alphaAction: () => _notice('= is used in equation mode')),
          ]),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: _stack(context, [
            KeySpec('ALPHA', KeyKind.mod, state.toggleAlpha,
                active: state.alphaOn),
            KeySpec('∫dx', KeyKind.fn, () => _ins('∫('),
                shift: 'd/dx',
                shiftAction: () => _ins('d/dx('),
                alpha: ':',
                alphaAction: () => _notice('":" is used in equation mode')),
          ]),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: ReplayPad(
            compact: compact,
            onUp: state.historyUp,
            onDown: state.historyDown,
            onLeft: () => state.moveCursor(-1),
            onRight: () => state.moveCursor(1),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: _stack(context, [
            KeySpec('MODE', KeyKind.fn, () => _openModeMenu(context),
                shift: 'SETUP',
                shiftAction: () => _openSetupMenu(context)),
            KeySpec('x⁻¹', KeyKind.fn, () => _ins('⁻¹'),
                shift: 'x!', shiftAction: () => _ins('!')),
          ]),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: _stack(context, [
            KeySpec('ON', KeyKind.mod, state.powerOn),
            KeySpec('logₐb', KeyKind.fn, () => _ins('log('),
                shift: 'Σ', shiftAction: () => _ins('Σ(')),
          ]),
        ),
      ],
    );
  }

  Widget _stack(BuildContext context, List<KeySpec> keys) => Column(
        children: [
          Expanded(child: _buildKey(context, keys[0])),
          const SizedBox(height: 5),
          Expanded(child: _buildKey(context, keys[1])),
        ],
      );

  Widget _row(BuildContext context, List<KeySpec> keys) {
    return Row(
      children: [
        for (var i = 0; i < keys.length; i++) ...[
          if (i > 0) const SizedBox(width: 5),
          Expanded(child: _buildKey(context, keys[i])),
        ],
      ],
    );
  }

  Widget _buildKey(BuildContext context, KeySpec k) {
    final p = context.palette;
    final Color face;
    final Color text;
    final double size;
    final bool big;

    switch (k.kind) {
      case KeyKind.num:
        face = p.keyNum;
        text = p.keyText;
        size = compact ? 19 : 22;
        big = true;
        break;
      case KeyKind.fn:
        face = p.keyFn;
        text = p.keyText;
        size = compact ? 9.5 : 11;
        big = false;
        break;
      case KeyKind.op:
        face = p.keyOp;
        text = p.accent;
        size = compact ? 18 : 21;
        big = true;
        break;
      case KeyKind.accent:
        face = p.accent;
        text = p.onAccent;
        size = compact ? 19 : 22;
        big = true;
        break;
      case KeyKind.danger:
        face = p.keyOp;
        text = p.accent;
        size = compact ? 9.5 : 11;
        big = false;
        break;
      case KeyKind.mod:
        face = p.keyFn;
        text = p.keyText;
        size = compact ? 7.5 : 9;
        big = false;
        break;
    }

    return KeyCap(
      label: k.label,
      sup: k.sup,
      shiftLabel: k.shift,
      alphaLabel: k.alpha,
      face: face,
      textColor: text,
      subColor: p.keySub,
      accentColor: p.accent,
      shiftColor: p.shiftLegend,
      alphaColor: p.alphaLegend,
      active: k.active,
      accentFill: k.kind == KeyKind.accent,
      labelSize: size,
      legendSize: compact ? 6.5 : 7.5,
      bigFont: big,
      onTap: () => _fire(k),
    );
  }

  void _fire(KeySpec k) {
    if (!state.powered) {
      if (k.label == 'ON') {
        k.action();
      }
      return;
    }
    if (k.kind == KeyKind.mod) {
      k.action();
      return;
    }
    if (state.shiftOn) {
      state.clearModifiers();
      k.shiftAction?.call();
      return;
    }
    if (state.alphaOn) {
      state.clearModifiers();
      k.alphaAction?.call();
      return;
    }
    k.action();
  }

  // -------------------------------------------------------------------
  // Rows
  // -------------------------------------------------------------------

  List<KeySpec> _scientificRow1(BuildContext context) => [
        KeySpec('a/b', KeyKind.fn, () => _ins('frac('),
            shift: 'mixed', shiftAction: _toggleMixed),
        KeySpec('√', KeyKind.op, () => _ins('√('),
            shift: '∛', shiftAction: () => _ins('∛(')),
        KeySpec('x', KeyKind.op, () => _ins('²'),
            sup: '2',
            shift: 'x³',
            shiftAction: () => _ins('³'),
            alpha: 'DEC',
            alphaAction: () => _notice('BASE-N arrives in stage 2')),
        KeySpec('x', KeyKind.op, () => _ins('^'),
            sup: '□',
            shift: 'ˣ√',
            shiftAction: () => _ins('ⁿ√('),
            alpha: 'HEX',
            alphaAction: () => _notice('BASE-N arrives in stage 2')),
        KeySpec('log', KeyKind.fn, () => _ins('log('),
            shift: '10ˣ',
            shiftAction: () => _ins('10^'),
            alpha: 'BIN',
            alphaAction: () => _notice('BASE-N arrives in stage 2')),
        KeySpec('ln', KeyKind.fn, () => _ins('ln('),
            shift: 'eˣ',
            shiftAction: () => _ins('e^'),
            alpha: 'OCT',
            alphaAction: () => _notice('BASE-N arrives in stage 2')),
      ];

  List<KeySpec> _scientificRow2(BuildContext context) => [
        KeySpec('(-)', KeyKind.fn, () => _ins('-'),
            shift: '∠',
            shiftAction: () => _notice('∠ arrives with complex numbers'),
            alpha: 'A',
            alphaAction: () => _ins('A')),
        KeySpec("°'\"", KeyKind.fn, () => _ins('°'),
            shift: '←',
            shiftAction: () => state.moveCursor(-1),
            alpha: 'B',
            alphaAction: () => _ins('B')),
        KeySpec('hyp', KeyKind.fn, () => _openHypMenu(context),
            shift: 'Abs',
            shiftAction: () => _ins('abs('),
            alpha: 'C',
            alphaAction: () => _ins('C')),
        KeySpec('sin', KeyKind.fn, () => _ins('sin('),
            shift: 'sin⁻¹',
            shiftAction: () => _ins('asin('),
            alpha: 'D',
            alphaAction: () => _ins('D')),
        KeySpec('cos', KeyKind.fn, () => _ins('cos('),
            shift: 'cos⁻¹',
            shiftAction: () => _ins('acos('),
            alpha: 'E',
            alphaAction: () => _ins('E')),
        KeySpec('tan', KeyKind.fn, () => _ins('tan('),
            shift: 'tan⁻¹',
            shiftAction: () => _ins('atan('),
            alpha: 'F',
            alphaAction: () => _ins('F')),
      ];

  List<KeySpec> _scientificRow3(BuildContext context) => [
        KeySpec('RCL', KeyKind.fn,
            () => _openVariableSheet(context, store: false),
            shift: 'STO',
            shiftAction: () => _openVariableSheet(context, store: true)),
        KeySpec('ENG', KeyKind.fn, _toggleEng,
            shift: '←',
            shiftAction: () => state.moveCursor(-1),
            alpha: 'i',
            alphaAction: () => _notice('i arrives with complex numbers')),
        KeySpec('(', KeyKind.fn, () => _ins('('),
            shift: '%', shiftAction: () => _ins('%')),
        KeySpec(')', KeyKind.fn, () => _ins(')'),
            shift: ',',
            shiftAction: () => _ins(','),
            alpha: 'X',
            alphaAction: () => _ins('X')),
        KeySpec('S⇔D', KeyKind.fn, state.toggleExact,
            shift: 'ab/c⇔d/c',
            shiftAction: _toggleMixed,
            alpha: 'Y',
            alphaAction: () => _ins('Y')),
        KeySpec('M+', KeyKind.fn, state.memoryAdd,
            shift: 'M−',
            shiftAction: state.memorySubtract,
            alpha: 'M',
            alphaAction: () => _ins('M')),
      ];

  List<KeySpec> _numericRow1(BuildContext context) => [
        KeySpec('7', KeyKind.num, () => _ins('7'),
            shift: 'CONST', shiftAction: () => _openConstantsSheet(context)),
        KeySpec('8', KeyKind.num, () => _ins('8'),
            shift: 'CONV',
            shiftAction: () => _notice('Unit conversion arrives in stage 3')),
        KeySpec('9', KeyKind.num, () => _ins('9'),
            shift: 'CLR', shiftAction: () => _openClearMenu(context)),
        KeySpec('DEL', KeyKind.danger, state.backspace,
            shift: 'INS', shiftAction: state.toggleInsertMode),
        KeySpec('AC', KeyKind.danger, state.clearAll,
            shift: 'OFF', shiftAction: state.powerOff),
      ];

  List<KeySpec> _numericRow2(BuildContext context) => [
        KeySpec('4', KeyKind.num, () => _ins('4'),
            shift: 'MATRIX',
            shiftAction: () => _notice('MATRIX arrives in stage 2')),
        KeySpec('5', KeyKind.num, () => _ins('5'),
            shift: 'VECTOR',
            shiftAction: () => _notice('VECTOR arrives in stage 2')),
        KeySpec('6', KeyKind.num, () => _ins('6')),
        KeySpec('×', KeyKind.op, () => _ins('×'),
            shift: 'nPr', shiftAction: () => _ins('npr(')),
        KeySpec('÷', KeyKind.op, () => _ins('÷'),
            shift: 'nCr', shiftAction: () => _ins('ncr(')),
      ];

  List<KeySpec> _numericRow3(BuildContext context) => [
        KeySpec('1', KeyKind.num, () => _ins('1'),
            shift: 'STAT',
            shiftAction: () => _notice('STAT arrives in stage 2')),
        KeySpec('2', KeyKind.num, () => _ins('2'),
            shift: 'CMPLX',
            shiftAction: () => _notice('CMPLX arrives in stage 2')),
        KeySpec('3', KeyKind.num, () => _ins('3'),
            shift: 'BASE',
            shiftAction: () => _notice('BASE-N arrives in stage 2')),
        KeySpec('+', KeyKind.op, () => _ins('+'),
            shift: 'Pol', shiftAction: () => _ins('pol(')),
        KeySpec('−', KeyKind.op, () => _ins('−'),
            shift: 'Rec', shiftAction: () => _ins('rec(')),
      ];

  List<KeySpec> _numericRow4(BuildContext context) => [
        KeySpec('0', KeyKind.num, () => _ins('0'),
            shift: 'Rnd', shiftAction: () => _ins('rnd(')),
        KeySpec('.', KeyKind.num, () => _ins('.'),
            shift: 'Ran#',
            shiftAction: () => _ins('rand('),
            alpha: 'RanInt',
            alphaAction: () => _ins('randint(')),
        KeySpec('×10', KeyKind.fn, () => _ins('×10^'),
            sup: 'x',
            shift: 'π',
            shiftAction: () => _ins('π'),
            alpha: 'e',
            alphaAction: () => _ins('e')),
        KeySpec('Ans', KeyKind.fn, () => _ins('Ans'),
            shift: 'DRG►', shiftAction: state.cycleAngle),
        KeySpec('=', KeyKind.accent, state.evaluate),
      ];

  // -------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------

  void _ins(String text) => state.insert(text);

  void _notice(String message) => state.setNotice(message);

  void _toggleMixed() {
    final f = state.format;
    state.setFormat(f.copyWith(mixedFraction: !f.mixedFraction));
  }

  void _toggleEng() {
    final f = state.format;
    state.setFormat(f.copyWith(engineering: !f.engineering));
  }

  // -------------------------------------------------------------------
  // Sheets
  // -------------------------------------------------------------------

  Future<void> _sheet(BuildContext context, String title, Widget child) {
    final p = context.palette;
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: p.panel,
          border: Border.all(color: p.border),
          boxShadow: [
            BoxShadow(
              color: p.shadow.withValues(alpha: 0.5),
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.82,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 10, 8),
                  child: Row(
                    children: [
                      SectionLabel(title),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.close, size: 16, color: p.keySub),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1, color: p.border),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openModeMenu(BuildContext context) {
    void open(Widget page) {
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => page),
      );
    }

    _sheet(
      context,
      'MODE',
      Column(
        children: [
          _sheetItem(context, '1', 'COMP', 'General calculation', () {
            Navigator.of(context).pop();
          }),
          _sheetItem(
            context,
            '2',
            'CMPLX',
            'Complex number calculation',
            () => open(const CmplxPage()),
          ),
          _sheetItem(
            context,
            '3',
            'STAT',
            'Statistics and regression',
            () => open(const StatPage()),
          ),
          _sheetItem(
            context,
            '4',
            'BASE-N',
            'Binary, octal, decimal, hex',
            () => open(const BaseNPage()),
          ),
          _sheetItem(
            context,
            '5',
            'EQN',
            'Linear, quadratic and cubic equations',
            () => open(const EqnPage()),
          ),
          _sheetItem(
            context,
            '6',
            'MATRIX',
            'Matrix calculation',
            () => open(const MatrixPage()),
          ),
          _sheetItem(
            context,
            '7',
            'TABLE',
            'Function tables',
            () => open(TablePage(state: state)),
          ),
          _sheetItem(
            context,
            '8',
            'VECTOR',
            'Vector calculation',
            () => open(const VectorPage()),
          ),
        ],
      ),
    );
  }

  void _openSetupMenu(BuildContext context) {
    _sheet(
      context,
      'SETUP',
      AnimatedBuilder(
        animation: state,
        builder: (ctx, _) {
          final p = ctx.palette;
          final f = state.format;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sheetLabel(ctx, 'Angle unit'),
              PixelSegmented<AngleMode>(
                value: state.angle,
                onChanged: state.setAngle,
                options: const [
                  SegmentedOption(AngleMode.deg, 'DEG'),
                  SegmentedOption(AngleMode.rad, 'RAD'),
                  SegmentedOption(AngleMode.grad, 'GRAD'),
                ],
              ),
              const SizedBox(height: 16),
              _sheetLabel(ctx, 'Display'),
              PixelSegmented<DisplayMode>(
                value: f.mode,
                onChanged: (m) => state.setFormat(f.copyWith(mode: m)),
                options: const [
                  SegmentedOption(DisplayMode.norm, 'NORM'),
                  SegmentedOption(DisplayMode.fix, 'FIX'),
                  SegmentedOption(DisplayMode.sci, 'SCI'),
                ],
              ),
              if (f.mode != DisplayMode.norm) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      f.mode == DisplayMode.fix ? 'Decimal places' : 'Digits',
                      style: TextStyle(fontSize: 12, color: p.keyText),
                    ),
                    const Spacer(),
                    _MiniStepper(
                      value: f.digits,
                      onChanged: (v) =>
                          state.setFormat(f.copyWith(digits: v)),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              _sheetLabel(ctx, 'Result'),
              _setupSwitch(ctx, 'Exact fractions (S⇔D)',
                  state.exactPreferred, (_) => state.toggleExact()),
              _setupSwitch(
                ctx,
                'Mixed fractions',
                f.mixedFraction,
                (v) => state.setFormat(f.copyWith(mixedFraction: v)),
              ),
              _setupSwitch(
                ctx,
                'Engineering notation',
                f.engineering,
                (v) => state.setFormat(f.copyWith(engineering: v)),
              ),
              _setupSwitch(
                ctx,
                'SI prefixes',
                f.siPrefix,
                (v) => state.setFormat(f.copyWith(siPrefix: v)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openHypMenu(BuildContext context) {
    final fns = <String, String>{
      'sinh': 'Hyperbolic sine',
      'cosh': 'Hyperbolic cosine',
      'tanh': 'Hyperbolic tangent',
      'asinh': 'Inverse hyperbolic sine',
      'acosh': 'Inverse hyperbolic cosine',
      'atanh': 'Inverse hyperbolic tangent',
    };
    _sheet(
      context,
      'HYPERBOLIC',
      Column(
        children: [
          for (final e in fns.entries)
            _sheetItem(context, e.key.substring(0, 1).toUpperCase(), e.key,
                e.value, () {
              Navigator.of(context).pop();
              _ins('${e.key}(');
            }),
        ],
      ),
    );
  }

  void _openConstantsSheet(BuildContext context) {
    _sheet(
      context,
      'CONSTANTS',
      Column(
        children: [
          for (final c in constantCatalog)
            _sheetItem(
              context,
              c.symbol,
              c.label,
              c.unit.isEmpty ? c.name : '${c.name}  ·  ${c.unit}',
              () {
                Navigator.of(context).pop();
                _ins(c.name);
              },
            ),
        ],
      ),
    );
  }

  void _openVariableSheet(BuildContext context, {required bool store}) {
    final names = <String>[...variableNames, 'M'];
    _sheet(
      context,
      store ? 'STO' : 'RCL',
      Column(
        children: [
          for (final name in names)
            _sheetItem(
              context,
              name,
              name,
              state.formatNum(state.variables[name]!),
              () {
                Navigator.of(context).pop();
                if (store) {
                  state.storeCurrentTo(name);
                  _notice('$name stored');
                } else {
                  _ins(name);
                }
              },
            ),
        ],
      ),
    );
  }

  void _openClearMenu(BuildContext context) {
    _sheet(
      context,
      'CLEAR',
      Column(
        children: [
          _sheetItem(context, '1', 'Clear expression', 'Remove the current entry',
              () {
            Navigator.of(context).pop();
            state.clearEntry();
          }),
          _sheetItem(context, '2', 'Clear history',
              'Delete all stored calculations', () {
            Navigator.of(context).pop();
            state.clearHistory();
            _notice('History cleared');
          }),
          _sheetItem(context, '3', 'Reset variables',
              'Set A–F, X, Y, M and Ans to zero', () {
            Navigator.of(context).pop();
            state.resetVariables();
            _notice('Variables reset');
          }),
        ],
      ),
    );
  }

  Widget _sheetLabel(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SectionLabel(text),
      );

  Widget _setupSwitch(
    BuildContext context,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 12, color: p.keyText),
            ),
          ),
          PixelSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _sheetItem(
    BuildContext context,
    String key,
    String title,
    String? subtitle,
    VoidCallback onTap, {
    bool enabled = true,
  }) {
    final p = context.palette;
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: p.border.withValues(alpha: 0.5)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: enabled
                      ? p.border
                      : p.border.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                key,
                style: TextStyle(
                  fontFamily: 'VT323',
                  fontSize: 16,
                  color: enabled ? p.keyText : p.keySub,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: enabled ? p.keyText : p.keySub,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 10, color: p.keySub),
                    ),
                ],
              ),
            ),
            if (!enabled)
              PixelPill('STAGE 2', textColor: p.keySub, fontSize: 6),
          ],
        ),
      ),
    );
  }
}

class _MiniStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _MiniStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget button(String glyph, int next) => GestureDetector(
          onTap: () => onChanged(next.clamp(0, 9)),
          child: Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(border: Border.all(color: p.border)),
            child: Text(
              glyph,
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 18,
                color: p.keyText,
              ),
            ),
          ),
        );
    return Row(
      children: [
        button('−', value - 1),
        SizedBox(
          width: 32,
          child: Center(
            child: Text(
              '$value',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 18,
                color: p.keyText,
              ),
            ),
          ),
        ),
        button('+', value + 1),
      ],
    );
  }
}
