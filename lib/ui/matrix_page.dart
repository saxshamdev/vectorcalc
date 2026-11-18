import 'package:flutter/material.dart';

import '../core/matrix.dart';
import 'mode_scaffold.dart';
import 'widgets.dart';

/// MATRIX: add, subtract, multiply, invert and transpose 2×2 / 3×3 matrices.
class MatrixPage extends StatefulWidget {
  const MatrixPage({super.key});

  @override
  State<MatrixPage> createState() => _MatrixPageState();
}

class _MatrixPageState extends State<MatrixPage> {
  int _n = 2;
  final Map<String, TextEditingController> _c = {};
  Matrix? _result;
  String? _error;
  String _resultLabel = 'Result';

  TextEditingController _ctrl(String m, int i) => _c.putIfAbsent(
        '$m$i',
        () => TextEditingController(),
      );

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  double _val(String m, int i) =>
      double.tryParse(_ctrl(m, i).text.trim()) ?? 0;

  Matrix _read(String m) => Matrix(
        _n,
        _n,
        [
          for (var r = 0; r < _n; r++)
            [for (var c = 0; c < _n; c++) _val(m, r * _n + c)],
        ],
      );

  void _apply(String label, Matrix? Function(Matrix a, Matrix b) op) {
    setState(() {
      _error = null;
      _result = null;
      try {
        final r = op(_read('A'), _read('B'));
        if (r == null) {
          _error = 'Operation is undefined for these matrices';
          return;
        }
        _result = r;
        _resultLabel = label;
      } on ArgumentError catch (e) {
        _error = e.message.toString();
      }
    });
  }

  void _setSize(int n) {
    setState(() {
      _n = n;
      _result = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ModeScaffold(
      title: 'Matrix',
      code: 'DETERMINANT · INVERSE · PRODUCT',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          const SectionLabel('Size'),
          const SizedBox(height: 8),
          PixelSegmented<int>(
            value: _n,
            options: const [
              SegmentedOption(2, '2 × 2'),
              SegmentedOption(3, '3 × 3'),
            ],
            onChanged: _setSize,
          ),
          const SizedBox(height: 16),
          const SectionLabel('Matrix A'),
          const SizedBox(height: 8),
          _grid('A'),
          const SizedBox(height: 16),
          const SectionLabel('Matrix B'),
          const SizedBox(height: 8),
          _grid('B'),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ModeButton('A + B', onTap: () => _apply('A + B', (a, b) => a + b)),
              ModeButton('A − B', onTap: () => _apply('A − B', (a, b) => a - b)),
              ModeButton('A × B', onTap: () => _apply('A × B', (a, b) => a * b)),
              ModeButton('det A', onTap: () => _apply('det A', (a, b) => Matrix(1, 1, [
                    [a.determinant()],
                  ]))),
              ModeButton('inv A', onTap: () => _apply('inv A', (a, b) => a.inverse())),
              ModeButton('transpose A',
                  onTap: () => _apply('transpose A', (a, b) => a.transpose())),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(
              _error!,
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 17,
                color: p.accent,
              ),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 16),
            SectionLabel(_resultLabel),
            const SizedBox(height: 8),
            _resultView(_result!),
          ],
        ],
      ),
    );
  }

  Widget _grid(String m) => Column(
        children: [
          for (var r = 0; r < _n; r++) ...[
            if (r > 0) const SizedBox(height: 6),
            Row(
              children: [
                for (var c = 0; c < _n; c++) ...[
                  if (c > 0) const SizedBox(width: 6),
                  Expanded(
                    child: PixelCell(
                      controller: _ctrl(m, r * _n + c),
                      prefix: '$m${r + 1}${c + 1}',
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      );

  Widget _resultView(Matrix m) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.well,
        border: Border.all(color: p.accent),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var r = 0; r < m.rows; r++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  for (var c = 0; c < m.cols; c++)
                    Expanded(
                      child: Text(
                        fmtNum(m.at(r, c)),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'VT323',
                          fontSize: 18,
                          color: p.wellText,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
