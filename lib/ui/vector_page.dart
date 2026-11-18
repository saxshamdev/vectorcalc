import 'package:flutter/material.dart';

import '../core/vector.dart';
import 'mode_scaffold.dart';
import 'widgets.dart';

/// VECTOR: 2D/3D vector arithmetic, dot/cross products and angles.
class VectorPage extends StatefulWidget {
  const VectorPage({super.key});

  @override
  State<VectorPage> createState() => _VectorPageState();
}

class _VectorPageState extends State<VectorPage> {
  bool _threeD = false;
  final Map<String, TextEditingController> _c = {};
  String _label = 'Result';
  String _value = '—';

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

  Vec3 _read(String v) => Vec3(
        _val('${v}x'),
        _val('${v}y'),
        _threeD ? _val('${v}z') : 0,
      );

  void _show(String label, String value) => setState(() {
        _label = label;
        _value = value;
      });

  String _vec(Vec3 v) => _threeD
      ? '(${fmtNum(v.x)}, ${fmtNum(v.y)}, ${fmtNum(v.z)})'
      : '(${fmtNum(v.x)}, ${fmtNum(v.y)})';

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ModeScaffold(
      title: 'Vector',
      code: _threeD ? '3D · DOT · CROSS' : '2D · DOT · ANGLE',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          const SectionLabel('Dimension'),
          const SizedBox(height: 8),
          PixelSegmented<bool>(
            value: _threeD,
            options: const [
              SegmentedOption(false, '2D'),
              SegmentedOption(true, '3D'),
            ],
            onChanged: (v) => setState(() {
              _threeD = v;
              _value = '—';
            }),
          ),
          const SizedBox(height: 16),
          const SectionLabel('Vector A'),
          const SizedBox(height: 8),
          _vectorFields('A'),
          const SizedBox(height: 14),
          const SectionLabel('Vector B'),
          const SizedBox(height: 8),
          _vectorFields('B'),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ModeButton('A + B',
                  onTap: () => _show('A + B', _vec(_read('A') + _read('B')))),
              ModeButton('A − B',
                  onTap: () => _show('A − B', _vec(_read('A') - _read('B')))),
              ModeButton('A · B',
                  onTap: () => _show('A · B', fmtNum(_read('A').dot(_read('B'))))),
              ModeButton('|A|',
                  onTap: () => _show('|A|', fmtNum(_read('A').magnitude))),
              ModeButton('|B|',
                  onTap: () => _show('|B|', fmtNum(_read('B').magnitude))),
              ModeButton('angle',
                  onTap: () => _show('Angle A→B', '${fmtNum(_read('A').angleDeg(_read('B')))}°')),
              ModeButton('A × B',
                  onTap: _threeD
                      ? () => _show('A × B', _vec(_read('A').cross(_read('B'))))
                      : null),
              ModeButton('unit A',
                  onTap: () => _show('Unit A', _vec(_read('A').unit))),
            ],
          ),
          const SizedBox(height: 16),
          ResultWell(label: _label.toUpperCase(), value: _value),
          const SizedBox(height: 10),
          Text(
            _threeD ? 'Cross product uses the right-hand rule.' : 'Switch to 3D for the cross product.',
            style: TextStyle(fontSize: 11, color: p.keySub),
          ),
        ],
      ),
    );
  }

  Widget _vectorFields(String v) => Row(
        children: [
          Expanded(
            child: PixelCell(
              controller: _ctrl('${v}x'),
              prefix: '${v}x',
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: PixelCell(
              controller: _ctrl('${v}y'),
              prefix: '${v}y',
            ),
          ),
          if (_threeD) ...[
            const SizedBox(width: 6),
            Expanded(
              child: PixelCell(
                controller: _ctrl('${v}z'),
                prefix: '${v}z',
              ),
            ),
          ],
        ],
      );
}
