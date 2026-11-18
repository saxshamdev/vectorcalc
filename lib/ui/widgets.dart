import 'package:flutter/material.dart';

import '../theme/themes.dart';

/// A flat panel with a hairline border and a hard (unblurred) drop shadow.
class PixelPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final bool shadow;

  const PixelPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.color,
    this.borderColor,
    this.shadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: color ?? p.panel,
        border: Border.all(color: borderColor ?? p.border),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: p.shadow.withValues(alpha: 0.45),
                  offset: const Offset(0, 3),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      padding: padding,
      child: child,
    );
  }
}

extension PaletteContext on BuildContext {
  Palette get palette => Theme.of(this).extension<PaletteTheme>()?.palette ??
      appThemes.first.night;
}

class PaletteTheme extends ThemeExtension<PaletteTheme> {
  final Palette palette;
  const PaletteTheme(this.palette);

  @override
  PaletteTheme copyWith({Palette? palette}) =>
      PaletteTheme(palette ?? this.palette);

  @override
  PaletteTheme lerp(ThemeExtension<PaletteTheme>? other, double t) {
    if (other is! PaletteTheme) return this;
    return t < 0.5 ? this : other;
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  final Color? color;
  const SectionLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: 8,
        letterSpacing: 1.2,
        height: 1.6,
        color: color ?? p.keySub,
      ),
    );
  }
}

class PixelPill extends StatelessWidget {
  final String text;
  final bool active;
  final Color? color;
  final Color? textColor;
  final double fontSize;

  const PixelPill(
    this.text, {
    super.key,
    this.active = false,
    this.color,
    this.textColor,
    this.fontSize = 7,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = color ?? p.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: active ? c : Colors.transparent,
        border: Border.all(
          color: active ? c : (textColor ?? p.wellDim).withValues(alpha: 0.6),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'PressStart2P',
          fontSize: fontSize,
          height: 1.2,
          letterSpacing: 0.6,
          color: active ? p.onAccent : (textColor ?? p.wellDim),
        ),
      ),
    );
  }
}

class PixelButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool filled;
  final bool compact;

  const PixelButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.filled = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 6 : 9,
        ),
        decoration: BoxDecoration(
          color: filled ? p.accent : p.keyFn,
          border: Border.all(color: filled ? p.accent : p.border),
          boxShadow: [
            BoxShadow(
              color: p.shadow.withValues(alpha: 0.4),
              offset: const Offset(0, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: compact ? 13 : 15,
                color: filled ? p.onAccent : p.keyText,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: filled ? p.onAccent : p.keyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SegmentedOption<T> {
  final T value;
  final String label;
  const SegmentedOption(this.value, this.label);
}

class PixelSegmented<T> extends StatelessWidget {
  final List<SegmentedOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;
  final bool expand;

  const PixelSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final children = options.map((o) {
      final sel = o.value == value;
      final child = GestureDetector(
        onTap: () => onChanged(o.value),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: sel ? p.accent : Colors.transparent,
            border: Border.all(
              color: sel ? p.accent : p.border.withValues(alpha: 0.7),
            ),
          ),
          child: Text(
            o.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: sel ? p.onAccent : p.keyText,
            ),
          ),
        ),
      );
      return expand ? Expanded(child: child) : child;
    }).toList();

    return Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          children[i],
        ],
      ],
    );
  }
}

class SettingRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget trailing;

  const SettingRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: p.keyText,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 11, color: p.keySub),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}

class PixelSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const PixelSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? p.accent : p.keyFn,
          border: Border.all(color: value ? p.accent : p.border),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 16,
            height: 16,
            color: value ? p.onAccent : p.keySub,
          ),
        ),
      ),
    );
  }
}

/// A single calculator key.
class KeyCap extends StatefulWidget {
  final String label;
  final String? sup;
  final String? shiftLabel;
  final String? alphaLabel;
  final Color face;
  final Color textColor;
  final Color subColor;
  final Color accentColor;
  final Color? shiftColor;
  final Color? alphaColor;
  final bool active;
  final bool accentFill;
  final double labelSize;
  final double legendSize;
  final bool bigFont;
  final VoidCallback onTap;

  const KeyCap({
    super.key,
    required this.label,
    required this.face,
    required this.textColor,
    required this.subColor,
    required this.accentColor,
    required this.onTap,
    this.sup,
    this.shiftLabel,
    this.alphaLabel,
    this.shiftColor,
    this.alphaColor,
    this.active = false,
    this.accentFill = false,
    this.labelSize = 15,
    this.legendSize = 8,
    this.bigFont = false,
  });

  @override
  State<KeyCap> createState() => _KeyCapState();
}

class _KeyCapState extends State<KeyCap> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final offset = _down ? 1.0 : 2.0;
    final shiftColor =
        widget.active ? p.onAccent : (widget.shiftColor ?? widget.accentColor);
    final alphaColor =
        widget.active ? p.onAccent : (widget.alphaColor ?? widget.subColor);
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: offset),
        child: Container(
          decoration: BoxDecoration(
            color: widget.active ? widget.accentColor : widget.face,
            border: Border.all(
              color: widget.active
                  ? widget.accentColor
                  : (widget.accentFill
                      ? widget.accentColor
                      : p.border.withValues(alpha: 0.85)),
            ),
          ),
          child: Stack(
            children: [
              if (widget.shiftLabel != null)
                Positioned(
                  left: 3,
                  right: widget.alphaLabel != null ? 20 : 3,
                  top: 2,
                  child: Text(
                    widget.shiftLabel!,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontSize: widget.legendSize,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: shiftColor.withValues(alpha: 0.95),
                    ),
                  ),
                ),
              if (widget.alphaLabel != null)
                Positioned(
                  right: 3,
                  left: widget.shiftLabel != null ? 20 : 3,
                  top: 2,
                  child: Text(
                    widget.alphaLabel!,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontSize: widget.legendSize,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: alphaColor.withValues(alpha: 0.95),
                    ),
                  ),
                ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(2, 4, 2, 2),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _keyLabel(p),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _keyLabel(Palette p) {
    final color = widget.active ? p.onAccent : widget.textColor;
    final style = TextStyle(
      fontFamily: widget.bigFont ? 'VT323' : null,
      fontSize: widget.labelSize,
      height: 1,
      fontWeight: widget.bigFont ? FontWeight.w400 : FontWeight.w600,
      letterSpacing: widget.bigFont ? 0 : 0.2,
      color: color,
    );
    if (widget.sup == null) {
      return Text(
        widget.label,
        textAlign: TextAlign.center,
        maxLines: 1,
        style: style,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, maxLines: 1, style: style),
        Transform.translate(
          offset: Offset(0, -widget.labelSize * 0.28),
          child: Text(
            widget.sup!,
            maxLines: 1,
            style: style.copyWith(fontSize: widget.labelSize * 0.62),
          ),
        ),
      ],
    );
  }
}

/// The four-way REPLAY rocker that sits between the top function keys.
class ReplayPad extends StatelessWidget {
  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final bool compact;

  const ReplayPad({
    super.key,
    required this.onUp,
    required this.onDown,
    required this.onLeft,
    required this.onRight,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final size = compact ? 20.0 : 24.0;

    Widget cell(Widget? child, VoidCallback? onTap) => Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Center(child: child ?? const SizedBox.shrink()),
          ),
        );

    Widget arrow(IconData icon, VoidCallback onTap) =>
        cell(Icon(icon, size: size, color: p.keyText), onTap);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Container(
        decoration: BoxDecoration(
          color: p.keyFn,
          border: Border.all(color: p.border.withValues(alpha: 0.85)),
        ),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  cell(null, null),
                  arrow(Icons.arrow_drop_up, onUp),
                  cell(null, null),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  arrow(Icons.chevron_left, onLeft),
                  cell(
                    Container(
                      width: 6,
                      height: 6,
                      color: p.keySub.withValues(alpha: 0.8),
                    ),
                    null,
                  ),
                  arrow(Icons.chevron_right, onRight),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  cell(null, null),
                  arrow(Icons.arrow_drop_down, onDown),
                  cell(null, null),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const String _superscriptGlyphs = '⁰¹²³⁴⁵⁶⁷⁸⁹⁻⁺';

/// Renders a string, drawing superscript glyphs (as produced by
/// [superscript] in `core/format.dart`) at a smaller size.
///
/// The pixel display font has no superscript coverage, so exponents are sized
/// down explicitly instead of relying on font fallback.
class SuperscriptText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final TextOverflow overflow;

  const SuperscriptText(
    this.text, {
    super.key,
    required this.style,
    this.textAlign = TextAlign.left,
    this.overflow = TextOverflow.clip,
  });

  List<TextSpan> _spans() {
    final spans = <TextSpan>[];
    final buffer = StringBuffer();
    final baseSize = style.fontSize ?? 14;

    void flush() {
      if (buffer.isEmpty) return;
      spans.add(TextSpan(text: buffer.toString(), style: style));
      buffer.clear();
    }

    for (final rune in text.runes) {
      final ch = String.fromCharCode(rune);
      if (_superscriptGlyphs.contains(ch)) {
        flush();
        spans.add(
          TextSpan(
            text: ch,
            style: style.copyWith(fontSize: baseSize * 0.62, height: 1),
          ),
        );
      } else {
        buffer.write(ch);
      }
    }
    flush();
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: _spans()),
      textAlign: textAlign,
      maxLines: 1,
      softWrap: false,
      overflow: overflow,
    );
  }
}
