import 'package:flutter/material.dart';

import '../core/engine.dart';
import '../core/format.dart';
import '../core/num.dart';
import '../state/calc_state.dart';
import 'mode_scaffold.dart';
import 'widgets.dart';

/// TABLE: evaluate f(x) over a start/end/step range.
class TablePage extends StatefulWidget {
  final CalcState state;
  const TablePage({super.key, required this.state});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  final _expr = TextEditingController(text: 'X²');
  final _start = TextEditingController(text: '0');
  final _end = TextEditingController(text: '10');
  final _step = TextEditingController(text: '1');

  List<(double, String)> _rows = const [];
  String? _error;

  @override
  void dispose() {
    _expr.dispose();
    _start.dispose();
    _end.dispose();
    _step.dispose();
    super.dispose();
  }

  void _generate() {
    final expr = _expr.text.trim();
    final start = double.tryParse(_start.text.trim());
    final end = double.tryParse(_end.text.trim());
    final step = double.tryParse(_step.text.trim());
    setState(() {
      _error = null;
      _rows = const [];
      if (expr.isEmpty) {
        _error = 'Enter a function of X';
        return;
      }
      if (start == null || end == null || step == null) {
        _error = 'Start, end and step must be numbers';
        return;
      }
      if (step == 0) {
        _error = 'Step cannot be zero';
        return;
      }
      if ((end - start) / step < 0) {
        _error = 'Step points away from the end value';
        return;
      }
      final count = ((end - start) / step).abs().floor() + 1;
      if (count > 200) {
        _error = 'Too many rows ($count); use a larger step';
        return;
      }
      final rows = <(double, String)>[];
      for (var i = 0; i < count; i++) {
        final x = start + step * i;
        final ctx = widget.state.evalContext;
        ctx.variables['X'] = Num.of(x);
        final r = evaluateExpression(expr, ctx);
        rows.add((
          x,
          r.ok
              ? formatValue(r.value!, widget.state.format,
                  preferExact: widget.state.exactPreferred)
              : (r.error ?? 'ERROR'),
        ));
      }
      _rows = rows;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ModeScaffold(
      title: 'Table',
      code: 'f(x) OVER A RANGE',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          PixelField(
            controller: _expr,
            label: 'Function f(x)',
            hint: 'X²',
            fontSize: 20,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PixelField(
                  controller: _start,
                  label: 'Start',
                  keyboardType:
                      const TextInputType.numberWithOptions(signed: true, decimal: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PixelField(
                  controller: _end,
                  label: 'End',
                  keyboardType:
                      const TextInputType.numberWithOptions(signed: true, decimal: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PixelField(
                  controller: _step,
                  label: 'Step',
                  keyboardType:
                      const TextInputType.numberWithOptions(signed: true, decimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ModeButton('GENERATE', filled: true, onTap: _generate),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 17,
                color: p.accent,
              ),
            ),
          ],
          if (_rows.isNotEmpty) ...[
            const SizedBox(height: 16),
            const SectionLabel('Table'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: p.well,
                border: Border.all(color: p.border),
              ),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: p.border)),
                    ),
                    child: Row(
                      children: [
                        _head('X', p.wellDim),
                        _head('F(X)', p.wellDim, right: true),
                      ],
                    ),
                  ),
                  for (final row in _rows)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: p.border.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              fmtNum(row.$1),
                              style: TextStyle(
                                fontFamily: 'VT323',
                                fontSize: 17,
                                color: p.wellText,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              row.$2,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontFamily: 'VT323',
                                fontSize: 17,
                                color: p.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _head(String text, Color color, {bool right = false}) => Expanded(
        child: Text(
          text,
          textAlign: right ? TextAlign.right : TextAlign.left,
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 7,
            letterSpacing: 0.8,
            color: color,
          ),
        ),
      );
}
