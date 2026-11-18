import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/calc_state.dart';
import 'display_panel.dart';
import 'keypad.dart';
import 'widgets.dart';

class CalculatorScreen extends StatefulWidget {
  final CalcState state;
  final VoidCallback? onOpenHistory;

  const CalculatorScreen({super.key, required this.state, this.onOpenHistory});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _focus = FocusNode(debugLabel: 'calculator');

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    return KeyboardListener(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _onKey,
      child: LayoutBuilder(
        builder: (context, c) {
          final compact = c.maxHeight < 660;
          final landscape = c.maxWidth > 660 && c.maxWidth > c.maxHeight;
          final wide = c.maxWidth >= 1000;

          final calc = Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: EdgeInsets.all(compact ? 10 : 14),
                child: Column(
                  children: [
                    DisplayPanel(state: s, compact: compact),
                    const SizedBox(height: 10),
                    if (!compact) ...[
                      _FunctionStrip(state: s),
                      const SizedBox(height: 10),
                    ],
                    Expanded(child: Keypad(state: s, compact: compact)),
                  ],
                ),
              ),
            ),
          );

          if (wide) {
            final p = context.palette;
            return Row(
              children: [
                Expanded(child: calc),
                Container(width: 1, color: p.border),
                SizedBox(
                  width: 330,
                  child: _HistoryTape(state: s),
                ),
              ],
            );
          }

          if (landscape) {
            return Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
                    child: Column(
                      children: [
                        DisplayPanel(state: s, compact: true),
                        const SizedBox(height: 10),
                        _FunctionStrip(state: s),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 12, 12, 12),
                    child: Keypad(state: s, compact: true),
                  ),
                ),
              ],
            );
          }

          return calc;
        },
      ),
    );
  }

  bool _onKey(KeyEvent e) {
    if (e is! KeyDownEvent) return false;
    final s = widget.state;
    if (!s.powered) {
      s.powerOn();
      return true;
    }
    final k = e.logicalKey;

    bool handled(VoidCallback action) {
      action();
      return true;
    }

    if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter) {
      return handled(s.evaluate);
    }
    if (k == LogicalKeyboardKey.escape) {
      return handled(s.clearAll);
    }
    if (k == LogicalKeyboardKey.backspace) {
      return handled(s.backspace);
    }
    if (k == LogicalKeyboardKey.delete) {
      return handled(s.clearEntry);
    }
    if (k == LogicalKeyboardKey.arrowLeft) {
      return handled(() => s.moveCursor(-1));
    }
    if (k == LogicalKeyboardKey.arrowRight) {
      return handled(() => s.moveCursor(1));
    }
    if (k == LogicalKeyboardKey.arrowUp) {
      return handled(s.historyUp);
    }
    if (k == LogicalKeyboardKey.arrowDown) {
      return handled(s.historyDown);
    }
    final ch = e.character;
    if (ch == null || ch.isEmpty) return false;
    const map = {
      '*': '×',
      '/': '÷',
      '-': '−',
    };
    if (RegExp(r'^[0-9.+\-*/^()!%,]$').hasMatch(ch)) {
      return handled(() => s.insert(map[ch] ?? ch));
    }
    if (RegExp(r'^[a-zA-Z]$').hasMatch(ch)) {
      return handled(() => s.insert(ch.toUpperCase()));
    }
    return false;
  }
}

class _StripItem {
  final String label;
  final String insert;
  const _StripItem(this.label, this.insert);
}

const List<_StripItem> _stripItems = [
  _StripItem('Σ', 'Σ('),
  _StripItem('Π', 'Π('),
  _StripItem('∫', '∫('),
  _StripItem('d/dx', 'd/dx('),
  _StripItem('Pol', 'pol('),
  _StripItem('Rec', 'rec('),
  _StripItem('ˣ√', 'ⁿ√('),
  _StripItem('Rnd', 'rnd('),
  _StripItem('a/b', 'frac('),
  _StripItem('x!', '!'),
  _StripItem('%', '%'),
  _StripItem('|x|', 'abs('),
  _StripItem('gcd', 'gcd('),
  _StripItem('lcm', 'lcm('),
  _StripItem('mod', 'mod('),
  _StripItem('floor', 'floor('),
  _StripItem('ceil', 'ceil('),
  _StripItem('round', 'round('),
  _StripItem('sinh', 'sinh('),
  _StripItem('cosh', 'cosh('),
  _StripItem('tanh', 'tanh('),
  _StripItem('asinh', 'asinh('),
  _StripItem('acosh', 'acosh('),
  _StripItem('atanh', 'atanh('),
  _StripItem('°′″', '°'),
  _StripItem('hypot', 'hypot('),
  _StripItem('min', 'min('),
  _StripItem('max', 'max('),
  _StripItem('rand', 'rand('),
  _StripItem('randInt', 'randint('),
  _StripItem('root', 'root('),
  _StripItem('logb', 'log('),
];

class _FunctionStrip extends StatelessWidget {
  final CalcState state;
  const _FunctionStrip({required this.state});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _stripItems.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final item = _stripItems[i];
          return GestureDetector(
            onTap: () => state.insert(item.insert),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: p.panel,
                border: Border.all(color: p.border.withValues(alpha: 0.8)),
              ),
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: p.keyText.withValues(alpha: 0.85),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HistoryTape extends StatelessWidget {
  final CalcState state;
  const _HistoryTape({required this.state});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final entries = state.history;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const SectionLabel('History'),
              const Spacer(),
              if (entries.isNotEmpty)
                GestureDetector(
                  onTap: state.clearHistory,
                  child: Text(
                    'CLEAR',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 7,
                      color: p.keySub,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: entries.isEmpty
              ? Center(
                  child: Text(
                    'No calculations yet',
                    style: TextStyle(fontSize: 12, color: p.keySub),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: p.border.withValues(alpha: 0.6)),
                  itemBuilder: (context, i) {
                    final e = entries[i];
                    return InkWell(
                      onTap: () => state.recallHistory(e),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              e.expression,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'VT323',
                                fontSize: 15,
                                color: p.keySub,
                              ),
                            ),
                            const SizedBox(height: 2),
                            SuperscriptText(
                              '= ${e.result}',
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'VT323',
                                fontSize: 21,
                                color: p.keyText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
