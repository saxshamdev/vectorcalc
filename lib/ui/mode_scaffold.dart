import 'package:flutter/material.dart';

import 'widgets.dart';

/// Full-screen chrome shared by the stage-2 mode tools (BASE-N, EQN, …).
class ModeScaffold extends StatelessWidget {
  final String title;
  final String code;
  final Widget child;
  final List<Widget> trailing;

  const ModeScaffold({
    super.key,
    required this.title,
    required this.code,
    required this.child,
    this.trailing = const [],
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.chassis,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
              child: Row(
                children: [
                  _BackButton(),
                  const SizedBox(width: 8),
                  Container(width: 8, height: 8, color: p.accent),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 10,
                            letterSpacing: 1.4,
                            color: p.keyText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          code,
                          style: TextStyle(
                            fontFamily: 'VT323',
                            fontSize: 13,
                            height: 1,
                            letterSpacing: 0.6,
                            color: p.keySub,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...trailing,
                ],
              ),
            ),
            Container(height: 1, color: p.border),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border.all(color: p.border)),
        child: Icon(Icons.arrow_back, size: 17, color: p.keyText),
      ),
    );
  }
}

/// A square, flat text input styled like the calculator's display well.
class PixelField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool digitsOnly;
  final bool multiline;
  final double fontSize;

  const PixelField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.keyboardType,
    this.onChanged,
    this.digitsOnly = false,
    this.multiline = false,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 7,
              letterSpacing: 0.8,
              color: p.keySub,
            ),
          ),
          const SizedBox(height: 5),
        ],
        Container(
          decoration: BoxDecoration(
            color: p.well,
            border: Border.all(color: p.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType ??
                (multiline ? TextInputType.multiline : TextInputType.text),
            maxLines: multiline ? 6 : 1,
            minLines: multiline ? 4 : 1,
            onChanged: onChanged,
            style: TextStyle(
              fontFamily: 'VT323',
              fontSize: fontSize,
              height: 1.2,
              color: p.wellText,
            ),
            cursorColor: p.accent,
            decoration: InputDecoration.collapsed(
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: 'VT323',
                fontSize: fontSize,
                color: p.wellDim.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A labelled numeric field with a fixed narrow width for matrix/vector grids.
class PixelCell extends StatelessWidget {
  final TextEditingController controller;
  final String? prefix;
  final ValueChanged<String>? onChanged;

  const PixelCell({
    super.key,
    required this.controller,
    this.prefix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.well,
        border: Border.all(color: p.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      child: Row(
        children: [
          if (prefix != null)
            Text(
              prefix!,
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 13,
                color: p.wellDim,
              ),
            ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              onChanged: onChanged,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 17,
                height: 1.1,
                color: p.wellText,
              ),
              cursorColor: p.accent,
              decoration: const InputDecoration.collapsed(hintText: '0'),
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact flat button used across the mode screens.
class ModeButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool filled;

  const ModeButton(
    this.label, {
    super.key,
    this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: filled ? p.accent : p.keyFn,
          border: Border.all(color: filled ? p.accent : p.border),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: filled ? p.onAccent : p.keyText,
          ),
        ),
      ),
    );
  }
}

/// A result well that shows one labelled value.
class ResultWell extends StatelessWidget {
  final String label;
  final String value;
  final Color? accent;

  const ResultWell({
    super.key,
    required this.label,
    required this.value,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.well,
        border: Border.all(color: p.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 6.5,
              letterSpacing: 0.8,
              color: p.wellDim,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'VT323',
              fontSize: 19,
              height: 1.15,
              color: accent ?? p.wellText,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared formatting for numeric results in the mode screens.
String fmtNum(double v) {
  if (v.isNaN) return 'NaN';
  if (v.isInfinite) return v.isNegative ? '-∞' : '∞';
  final rounded = v.roundToDouble();
  if ((v - rounded).abs() < 1e-10) {
    if (rounded.abs() < 1e15) return rounded.toInt().toString();
  }
  var s = v.toStringAsPrecision(10);
  if (s.contains('e')) {
    final parts = s.split('e');
    var mant = parts[0];
    if (mant.contains('.')) {
      mant = mant.replaceFirst(RegExp(r'0+$'), '');
      if (mant.endsWith('.')) mant = mant.substring(0, mant.length - 1);
    }
    return '$mant×10^${int.parse(parts[1])}';
  }
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '');
    if (s.endsWith('.')) s = s.substring(0, s.length - 1);
  }
  return s;
}
