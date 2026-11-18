import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/functions.dart';
import '../state/calc_state.dart';
import 'widgets.dart';

class DisplayPanel extends StatelessWidget {
  final CalcState state;
  final bool compact;

  const DisplayPanel({super.key, required this.state, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final off = !state.powered;
    return GestureDetector(
      onTap: off ? state.powerOn : null,
      child: Container(
        height: compact ? 132 : 162,
        decoration: BoxDecoration(
          color: p.well,
          border: Border.all(color: p.border),
          boxShadow: [
            BoxShadow(
              color: p.shadow.withValues(alpha: 0.5),
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _Scanlines(p.wellText.withValues(alpha: 0.05)),
                ),
              ),
            ),
            if (!off)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StatusRow(state: state),
                    const SizedBox(height: 6),
                    Expanded(
                      child: _ExpressionView(
                        text: state.expressionWithCaret,
                        color: p.wellText,
                        error: state.error,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _ResultRow(state: state, compact: compact),
                    SizedBox(
                      height: 18,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SuperscriptText(
                          state.notice ?? state.displayAlt ?? '',
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'VT323',
                            fontSize: state.notice != null ? 13 : 15,
                            height: 1,
                            color: state.notice != null
                                ? p.accent
                                : p.wellDim,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final CalcState state;
  const _StatusRow({required this.state});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final f = state.format;
    final fmt = switch (f.mode) {
      DisplayMode.norm => 'NORM',
      DisplayMode.fix => 'FIX ${f.digits}',
      DisplayMode.sci => 'SCI ${f.digits}',
    };
    return Row(
      children: [
        PixelPill(state.angle.label, textColor: p.wellDim),
        const SizedBox(width: 4),
        if (state.memory.v != 0) ...[
          PixelPill('M', textColor: p.wellDim),
          const SizedBox(width: 4),
        ],
        if (state.shiftOn) ...[
          PixelPill('SHIFT', active: true, color: p.accent),
          const SizedBox(width: 4),
        ],
        if (state.alphaOn) ...[
          PixelPill('ALPHA', active: true, color: p.accent),
          const SizedBox(width: 4),
        ],
        if (state.overwrite) ...[
          PixelPill('INS', textColor: p.wellDim),
          const SizedBox(width: 4),
        ],
        const Spacer(),
        if (f.engineering) ...[
          PixelPill(f.siPrefix ? 'ENG SI' : 'ENG', textColor: p.wellDim),
          const SizedBox(width: 4),
        ],
        PixelPill(fmt, textColor: p.wellDim),
        const SizedBox(width: 4),
        PixelPill(
          state.exactPreferred ? 'S⇔D' : 'DEC',
          textColor: p.wellDim,
        ),
      ],
    );
  }
}

class _ExpressionView extends StatefulWidget {
  final String text;
  final Color color;
  final String? error;

  const _ExpressionView({
    required this.text,
    required this.color,
    this.error,
  });

  @override
  State<_ExpressionView> createState() => _ExpressionViewState();
}

class _ExpressionViewState extends State<_ExpressionView> {
  final _controller = ScrollController();

  @override
  void didUpdateWidget(covariant _ExpressionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.hasClients) {
          _controller.jumpTo(_controller.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = widget.error != null ? widget.error! : widget.text;
    final color = widget.error != null ? p.accent : widget.color;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontFamily: 'VT323',
                  fontSize: widget.error != null ? 20 : 24,
                  height: 1,
                  letterSpacing: 0.5,
                  color: color,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ResultRow extends StatelessWidget {
  final CalcState state;
  final bool compact;
  const _ResultRow({required this.state, required this.compact});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = state.displayText;
    final hasValue = text.isNotEmpty;
    return SizedBox(
      height: compact ? 42 : 50,
      child: Align(
        alignment: Alignment.centerRight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: SuperscriptText(
            hasValue ? text : '0',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'VT323',
              fontSize: compact ? 38 : 46,
              height: 1,
              letterSpacing: 0.5,
              color: hasValue
                  ? p.wellText
                  : p.wellText.withValues(alpha: 0.28),
            ),
          ),
        ),
      ),
    );
  }
}

class _Scanlines extends CustomPainter {
  final Color color;
  _Scanlines(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var y = 0.0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _Scanlines old) => old.color != color;
}
