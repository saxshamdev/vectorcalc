import 'package:flutter/material.dart';

import '../core/stats.dart';
import 'mode_scaffold.dart';
import 'widgets.dart';

/// STAT: one-variable statistics and two-variable regression.
class StatPage extends StatefulWidget {
  const StatPage({super.key});

  @override
  State<StatPage> createState() => _StatPageState();
}

class _StatPageState extends State<StatPage> {
  bool _twoVar = false;
  final _data = TextEditingController();
  List<(String, String)> _results = const [];
  String? _error;

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  void _setTwoVar(bool v) {
    setState(() {
      _twoVar = v;
      _results = const [];
      _error = null;
    });
  }

  List<double> _parseColumn(String text) {
    final out = <double>[];
    for (final line in text.split(RegExp(r'[\n;]'))) {
      final t = line.trim();
      if (t.isEmpty) continue;
      final v = double.tryParse(t.replaceAll(',', '.'));
      if (v == null) return const [];
      out.add(v);
    }
    return out;
  }

  void _calculate() {
    setState(() {
      _error = null;
      _results = const [];
      final raw = _data.text;
      if (_twoVar) {
        final xs = <double>[];
        final ys = <double>[];
        for (final line in raw.split(RegExp(r'[\n;]'))) {
          final t = line.trim();
          if (t.isEmpty) continue;
          final parts = t.split(RegExp(r'[,\s]+'));
          if (parts.length < 2) {
            _error = 'Each line needs an x and a y: x,y';
            return;
          }
          final x = double.tryParse(parts[0].replaceAll(',', '.'));
          final y = double.tryParse(parts[1].replaceAll(',', '.'));
          if (x == null || y == null) {
            _error = 'Could not read "$line"';
            return;
          }
          xs.add(x);
          ys.add(y);
        }
        if (xs.length < 2) {
          _error = 'Enter at least two data pairs';
          return;
        }
        final s = Stats2(xs, ys);
        final (a, b) = s.regressionYX;
        final (c, d) = s.regressionXY;
        _results = [
          ('n', '${s.count}'),
          ('x̄', fmtNum(s.meanX)),
          ('ȳ', fmtNum(s.meanY)),
          ('Σx', fmtNum(s.sumX)),
          ('Σy', fmtNum(s.sumY)),
          ('Σxy', fmtNum(s.sumXY)),
          ('σx', fmtNum(s.sigmaX)),
          ('σy', fmtNum(s.sigmaY)),
          ('sx', fmtNum(s.sampleSigmaX)),
          ('sy', fmtNum(s.sampleSigmaY)),
          ('r', fmtNum(s.correlation)),
          ('y = a + bx', 'a=${fmtNum(a)}  b=${fmtNum(b)}'),
          ('x = c + dy', 'c=${fmtNum(c)}  d=${fmtNum(d)}'),
        ];
      } else {
        final values = _parseColumn(raw);
        if (values.isEmpty) {
          _error = 'Enter at least one number';
          return;
        }
        final s = Stats1(values);
        final (q1, q3) = s.quartiles;
        _results = [
          ('n', '${s.count}'),
          ('Σx', fmtNum(s.sum)),
          ('x̄', fmtNum(s.mean)),
          ('σx', fmtNum(s.sigma)),
          ('sx', fmtNum(s.sampleSigma)),
          ('min', fmtNum(s.min)),
          ('q1', fmtNum(q1)),
          ('median', fmtNum(s.median)),
          ('q3', fmtNum(q3)),
          ('max', fmtNum(s.max)),
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ModeScaffold(
      title: 'Statistics',
      code: _twoVar ? 'TWO-VARIABLE · REGRESSION' : 'ONE-VARIABLE',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          PixelSegmented<bool>(
            value: _twoVar,
            options: const [
              SegmentedOption(false, '1-VAR'),
              SegmentedOption(true, '2-VAR'),
            ],
            onChanged: _setTwoVar,
          ),
          const SizedBox(height: 14),
          PixelField(
            controller: _data,
            label: _twoVar ? 'Data (x,y per line)' : 'Data (one value per line)',
            hint: _twoVar ? '1,2\n2,4\n3,6' : '2\n4\n4\n5\n7',
            multiline: true,
          ),
          const SizedBox(height: 16),
          ModeButton('CALCULATE', filled: true, onTap: _calculate),
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
          if (_results.isNotEmpty) ...[
            const SizedBox(height: 16),
            const SectionLabel('Results'),
            const SizedBox(height: 8),
            for (final r in _results)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 96,
                      child: Text(
                        r.$1,
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 7,
                          height: 2.2,
                          letterSpacing: 0.5,
                          color: p.keySub,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: p.well,
                          border: Border.all(color: p.border),
                        ),
                        child: Text(
                          r.$2,
                          style: TextStyle(
                            fontFamily: 'VT323',
                            fontSize: 18,
                            color: p.wellText,
                          ),
                        ),
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
}
