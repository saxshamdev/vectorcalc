import 'package:flutter/material.dart';

import '../core/basen.dart';
import 'mode_scaffold.dart';
import 'widgets.dart';

/// BASE-N: convert and bit-manipulate integers in base 2/8/10/16.
class BaseNPage extends StatefulWidget {
  const BaseNPage({super.key});

  @override
  State<BaseNPage> createState() => _BaseNPageState();
}

class _BaseNPageState extends State<BaseNPage> {
  int _radix = 10;
  int _bits = 32;
  final _input = TextEditingController(text: '0');
  final _operand = TextEditingController(text: '0');
  BigInt? _value = BigInt.zero;

  @override
  void initState() {
    super.initState();
    _input.addListener(_reparse);
  }

  @override
  void dispose() {
    _input.dispose();
    _operand.dispose();
    super.dispose();
  }

  void _reparse() {
    final v = parseBase(_input.text, _radix);
    setState(() => _value = v);
  }

  void _changeRadix(int r) {
    final v = _value;
    setState(() {
      _radix = r;
      if (v != null) _input.text = formatBase(v, r);
    });
  }

  void _setValue(BigInt v) {
    setState(() => _input.text = formatBase(v, _radix));
  }

  void _apply(BigInt Function(BigInt a, BigInt b) op) {
    final a = _value;
    final b = parseBase(_operand.text, _radix);
    if (a == null || b == null) return;
    _setValue(op(a, b));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final v = _value;
    final valid = v != null;
    return ModeScaffold(
      title: 'Base-N',
      code: 'INTEGER · BINARY · OCTAL · HEX',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          const SectionLabel('Active base'),
          const SizedBox(height: 8),
          PixelSegmented<int>(
            value: _radix,
            options: const [
              SegmentedOption(10, 'DEC'),
              SegmentedOption(16, 'HEX'),
              SegmentedOption(8, 'OCT'),
              SegmentedOption(2, 'BIN'),
            ],
            onChanged: _changeRadix,
          ),
          const SizedBox(height: 16),
          PixelField(
            controller: _input,
            label: 'Value',
            hint: _radix == 16 ? 'FF' : '0',
            keyboardType: TextInputType.text,
            fontSize: 22,
          ),
          if (!valid) ...[
            const SizedBox(height: 6),
            Text(
              'Invalid digit for base $_radix',
              style: TextStyle(fontSize: 11, color: p.accent),
            ),
          ],
          const SizedBox(height: 16),
          const SectionLabel('Conversions'),
          const SizedBox(height: 8),
          for (final row in const [
            (10, 'DEC'),
            (16, 'HEX'),
            (8, 'OCT'),
            (2, 'BIN'),
          ])
            _ConversionRow(
              label: row.$2,
              value: valid ? formatBase(v, row.$1) : '—',
              highlight: row.$1 == _radix,
              wrap: row.$1 == 2,
            ),
          const SizedBox(height: 18),
          const SectionLabel('Word size (bitwise)'),
          const SizedBox(height: 8),
          PixelSegmented<int>(
            value: _bits,
            options: const [
              SegmentedOption(8, '8'),
              SegmentedOption(16, '16'),
              SegmentedOption(32, '32'),
              SegmentedOption(64, '64'),
            ],
            onChanged: (b) => setState(() => _bits = b),
          ),
          const SizedBox(height: 18),
          const SectionLabel('Bitwise / shift'),
          const SizedBox(height: 8),
          PixelField(
            controller: _operand,
            label: 'Operand (base $_radix)',
            hint: '0',
            fontSize: 18,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ModeButton('AND', onTap: () => _apply((a, b) => bitAnd(a, b, _bits))),
              ModeButton('OR', onTap: () => _apply((a, b) => bitOr(a, b, _bits))),
              ModeButton('XOR', onTap: () => _apply((a, b) => bitXor(a, b, _bits))),
              ModeButton('NOT', onTap: () {
                final a = _value;
                if (a != null) _setValue(bitNot(a, _bits));
              }),
              ModeButton('<<', onTap: () {
                final a = _value;
                final n = parseBase(_operand.text, _radix);
                if (a != null && n != null && !n.isNegative) {
                  _setValue(a << n.toInt());
                }
              }),
              ModeButton('>>', onTap: () {
                final a = _value;
                final n = parseBase(_operand.text, _radix);
                if (a != null && n != null && !n.isNegative) {
                  _setValue(a >> n.toInt());
                }
              }),
            ],
          ),
          const SizedBox(height: 18),
          const SectionLabel('Signed reading'),
          const SizedBox(height: 8),
          ResultWell(
            label: 'TWO\'S COMPLEMENT · $_bits-BIT',
            value: valid ? formatBase(signedValue(v, _bits), 10) : '—',
          ),
          const SizedBox(height: 10),
          ModeButton(
            'CLEAR',
            onTap: () {
              _operand.text = '0';
              _setValue(BigInt.zero);
            },
          ),
        ],
      ),
    );
  }
}

class _ConversionRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final bool wrap;

  const _ConversionRow({
    required this.label,
    required this.value,
    required this.highlight,
    required this.wrap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Text(
      value,
      maxLines: wrap ? 4 : 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: 'VT323',
        fontSize: 18,
        height: 1.15,
        color: highlight ? p.accent : p.wellText,
      ),
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: p.well,
        border: Border.all(color: highlight ? p.accent : p.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 7,
                letterSpacing: 0.6,
                color: highlight ? p.accent : p.wellDim,
              ),
            ),
          ),
          Expanded(child: text),
        ],
      ),
    );
  }
}
