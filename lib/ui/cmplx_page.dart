import 'package:flutter/material.dart';

import '../core/complex.dart';
import 'mode_scaffold.dart';
import 'widgets.dart';

/// CMPLX: rectangular/polar complex arithmetic.
class CmplxPage extends StatefulWidget {
  const CmplxPage({super.key});

  @override
  State<CmplxPage> createState() => _CmplxPageState();
}

class _CmplxPageState extends State<CmplxPage> {
  final Map<String, TextEditingController> _c = {};
  String _label = 'Result';
  String _rect = '—';
  String _polar = '';

  TextEditingController _ctrl(String key) =>
      _c.putIfAbsent(key, () => TextEditingController());

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  double _val(String key) => double.tryParse(_ctrl(key).text.trim()) ?? 0;
  Complex _read(String z) => Complex(_val('${z}re'), _val('${z}im'));

  void _show(String label, Complex c) => setState(() {
        _label = label;
        _rect = _fmtC(c);
        _polar = '${fmtNum(c.magnitude)} ∠ ${fmtNum(c.argument * 180 / 3.141592653589793)}°';
      });

  String _fmtC(Complex c) {
    if (c.im.abs() < 1e-12) return fmtNum(c.re);
    final sign = c.im < 0 ? '−' : '+';
    return '${fmtNum(c.re)} $sign ${fmtNum(c.im.abs())}i';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ModeScaffold(
      title: 'Complex',
      code: 'RECTANGULAR · POLAR',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          const SectionLabel('z₁ = a + bi'),
          const SizedBox(height: 8),
          _pair('z1'),
          const SizedBox(height: 14),
          const SectionLabel('z₂ = c + di'),
          const SizedBox(height: 8),
          _pair('z2'),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ModeButton('z₁ + z₂',
                  onTap: () => _show('z₁ + z₂', _read('z1') + _read('z2'))),
              ModeButton('z₁ − z₂',
                  onTap: () => _show('z₁ − z₂', _read('z1') - _read('z2'))),
              ModeButton('z₁ × z₂',
                  onTap: () => _show('z₁ × z₂', _read('z1') * _read('z2'))),
              ModeButton('z₁ ÷ z₂',
                  onTap: () => _show('z₁ ÷ z₂', _read('z1') / _read('z2'))),
              ModeButton('|z₁|',
                  onTap: () => _show('|z₁|', Complex(_read('z1').magnitude))),
              ModeButton('arg z₁',
                  onTap: () => _show(
                      'arg z₁',
                      Complex(_read('z1').argument * 180 /
                          3.141592653589793))),
              ModeButton('conj z₁',
                  onTap: () => _show('conj z₁', _read('z1').conjugate)),
              ModeButton('√z₁', onTap: () => _show('√z₁', _read('z1').sqrt())),
            ],
          ),
          const SizedBox(height: 16),
          ResultWell(label: _label.toUpperCase(), value: _rect, accent: p.accent),
          if (_polar.isNotEmpty) ...[
            const SizedBox(height: 8),
            ResultWell(label: 'POLAR', value: _polar),
          ],
          const SizedBox(height: 10),
          Text(
            'Division by zero gives NaN.',
            style: TextStyle(fontSize: 11, color: p.keySub),
          ),
        ],
      ),
    );
  }

  Widget _pair(String z) => Row(
        children: [
          Expanded(
            child: PixelCell(controller: _ctrl('${z}re'), prefix: 're'),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: PixelCell(controller: _ctrl('${z}im'), prefix: 'im'),
          ),
        ],
      );
}
