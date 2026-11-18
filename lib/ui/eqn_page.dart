import 'package:flutter/material.dart';

import '../core/complex.dart';
import '../core/eqn.dart';
import 'mode_scaffold.dart';
import 'widgets.dart';

enum _EqnType { linear2, linear3, quadratic, cubic }

/// EQN: linear systems, quadratics and cubics with real or complex roots.
class EqnPage extends StatefulWidget {
  const EqnPage({super.key});

  @override
  State<EqnPage> createState() => _EqnPageState();
}

class _EqnPageState extends State<EqnPage> {
  _EqnType _type = _EqnType.quadratic;
  final Map<int, TextEditingController> _c = {};
  List<String> _results = const [];
  String? _error;

  TextEditingController _ctrl(int i) =>
      _c.putIfAbsent(i, () => TextEditingController());

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  double _val(int i) => double.tryParse(_ctrl(i).text.trim()) ?? 0;

  void _setType(_EqnType t) {
    setState(() {
      _type = t;
      _results = const [];
      _error = null;
    });
  }

  void _solve() {
    setState(() {
      _error = null;
      _results = const [];
      switch (_type) {
        case _EqnType.quadratic:
          final r = solveQuadratic(_val(0), _val(1), _val(2));
          if (!r.ok) {
            _error = r.error;
          } else {
            _results = r.roots.map(_rootText).toList();
          }
          break;
        case _EqnType.cubic:
          final r = solveCubic(_val(0), _val(1), _val(2), _val(3));
          if (!r.ok) {
            _error = r.error;
          } else {
            _results = r.roots.map(_rootText).toList();
          }
          break;
        case _EqnType.linear2:
          final x = solveLinearSystem([
            [_val(0), _val(1)],
            [_val(3), _val(4)],
          ], [_val(2), _val(5)]);
          _linearResult(x, ['x', 'y']);
          break;
        case _EqnType.linear3:
          final x = solveLinearSystem([
            [_val(0), _val(1), _val(2)],
            [_val(4), _val(5), _val(6)],
            [_val(8), _val(9), _val(10)],
          ], [_val(3), _val(7), _val(11)]);
          _linearResult(x, ['x', 'y', 'z']);
          break;
      }
    });
  }

  void _linearResult(List<double>? x, List<String> names) {
    if (x == null) {
      _error = 'No unique solution (singular system)';
      return;
    }
    _results = [
      for (var i = 0; i < x.length; i++) '${names[i]} = ${fmtNum(x[i])}',
    ];
  }

  String _rootText(Complex r) {
    if (r.im.abs() < 1e-9) return 'x = ${fmtNum(r.re)}';
    final sign = r.im < 0 ? '−' : '+';
    return 'x = ${fmtNum(r.re)} $sign ${fmtNum(r.im.abs())}i';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ModeScaffold(
      title: 'Equation',
      code: 'LINEAR · QUADRATIC · CUBIC',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          const SectionLabel('Type'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in const [
                (_EqnType.linear2, '2 UNKNOWN'),
                (_EqnType.linear3, '3 UNKNOWN'),
                (_EqnType.quadratic, 'QUADRATIC'),
                (_EqnType.cubic, 'CUBIC'),
              ])
                GestureDetector(
                  onTap: () => _setType(e.$1),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                    decoration: BoxDecoration(
                      color: _type == e.$1 ? p.accent : Colors.transparent,
                      border: Border.all(
                        color: _type == e.$1 ? p.accent : p.border,
                      ),
                    ),
                    child: Text(
                      e.$2,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        color: _type == e.$1 ? p.onAccent : p.keyText,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          const SectionLabel('Coefficients'),
          const SizedBox(height: 8),
          ..._fields(),
          const SizedBox(height: 16),
          ModeButton('SOLVE', filled: true, onTap: _solve),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: p.well,
                border: Border.all(color: p.accent),
              ),
              child: Text(
                _error!,
                style: TextStyle(
                  fontFamily: 'VT323',
                  fontSize: 17,
                  color: p.accent,
                ),
              ),
            ),
          ],
          if (_results.isNotEmpty) ...[
            const SizedBox(height: 14),
            const SectionLabel('Roots'),
            const SizedBox(height: 8),
            for (var i = 0; i < _results.length; i++)
              ResultWell(label: 'ROOT ${i + 1}', value: _results[i]),
          ],
        ],
      ),
    );
  }

  List<Widget> _fields() {
    switch (_type) {
      case _EqnType.quadratic:
        return [
          _row([(0, 'a'), (1, 'b'), (2, 'c')]),
          const SizedBox(height: 8),
          Text('a x² + b x + c = 0',
              style: TextStyle(fontSize: 11, color: _hintColor(context))),
        ];
      case _EqnType.cubic:
        return [
          _row([(0, 'a'), (1, 'b'), (2, 'c')]),
          const SizedBox(height: 8),
          _row([(3, 'd')]),
          const SizedBox(height: 8),
          Text('a x³ + b x² + c x + d = 0',
              style: TextStyle(fontSize: 11, color: _hintColor(context))),
        ];
      case _EqnType.linear2:
        return [
          _row([(0, 'a₁'), (1, 'b₁'), (2, 'c₁')]),
          const SizedBox(height: 8),
          _row([(3, 'a₂'), (4, 'b₂'), (5, 'c₂')]),
          const SizedBox(height: 8),
          Text('a x + b y = c',
              style: TextStyle(fontSize: 11, color: _hintColor(context))),
        ];
      case _EqnType.linear3:
        return [
          _row([(0, 'a₁'), (1, 'b₁'), (2, 'c₁'), (3, 'd₁')]),
          const SizedBox(height: 8),
          _row([(4, 'a₂'), (5, 'b₂'), (6, 'c₂'), (7, 'd₂')]),
          const SizedBox(height: 8),
          _row([(8, 'a₃'), (9, 'b₃'), (10, 'c₃'), (11, 'd₃')]),
          const SizedBox(height: 8),
          Text('a x + b y + c z = d',
              style: TextStyle(fontSize: 11, color: _hintColor(context))),
        ];
    }
  }

  Color _hintColor(BuildContext context) => context.palette.keySub;

  Widget _row(List<(int, String)> cells) => Row(
        children: [
          for (var i = 0; i < cells.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: PixelCell(
                controller: _ctrl(cells[i].$1),
                prefix: cells[i].$2,
              ),
            ),
          ],
        ],
      );
}
