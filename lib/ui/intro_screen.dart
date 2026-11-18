import 'package:flutter/material.dart';

import 'animated_logo.dart';
import 'widgets.dart';

/// Retro boot screen: the animated mark, a wordmark, and a segmented slide
/// bar that fills while the app settles. It always runs to completion.
class IntroScreen extends StatefulWidget {
  final VoidCallback onDone;

  const IntroScreen({super.key, required this.onDone});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  static const int _segments = 26;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2900),
  );

  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _finish();
    });
    _controller.forward();
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    widget.onDone();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.chassis,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _IntroScanlines(
                  p.wellText.withValues(alpha: p.isDark ? 0.05 : 0.035),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, c) {
                  final compact = c.maxHeight < 520;
                  final logoHeight = (c.maxHeight * 0.24)
                      .clamp(compact ? 56.0 : 72.0, 132.0)
                      .toDouble();
                  final barWidth =
                      c.maxWidth.clamp(220.0, 340.0).toDouble() * 0.82;
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final progress = Curves.easeInOutCubic.transform(
                        _controller.value,
                      );
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: c.maxHeight - 24,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedLogo(
                                height: logoHeight,
                                semanticLabel: 'VECTORCALC boot mark',
                              ),
                              SizedBox(height: compact ? 10 : 18),
                              Text(
                                'VECTORCALC',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'PressStart2P',
                                  fontSize: c.maxWidth < 360 ? 14 : 18,
                                  letterSpacing: c.maxWidth < 360 ? 1.6 : 3,
                                  color: p.keyText,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SectionLabel('PRECISION ENGINE', color: p.accent),
                              SizedBox(height: compact ? 18 : 36),
                              SizedBox(
                                width: barWidth,
                                child: _BootBar(
                                  progress: progress,
                                  segments: _segments,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _BootStatus(
                                progress: progress,
                                seconds: _controller.value * 2.9,
                              ),
                              SizedBox(height: compact ? 14 : 28),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  PixelPill('OFFLINE', textColor: p.keySub),
                                  const SizedBox(width: 6),
                                  PixelPill('NO NETWORK', textColor: p.keySub),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BootBar extends StatelessWidget {
  final double progress;
  final int segments;

  const _BootBar({required this.progress, required this.segments});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final exact = (progress.clamp(0.0, 1.0)) * segments;
    final filled = exact.floor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'LOADING',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 7,
                letterSpacing: 1.4,
                color: p.keySub,
              ),
            ),
            const Spacer(),
            Text(
              '${(progress * 100).round().toString().padLeft(3, '0')}%',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 17,
                height: 1,
                color: p.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        SizedBox(
          height: 16,
          child: Row(
            children: [
              for (var i = 0; i < segments; i++) ...[
                if (i > 0) const SizedBox(width: 2),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: i < filled
                          ? p.accent
                          : (i == filled
                                ? p.accent.withValues(
                                    alpha: 0.18 + 0.72 * (exact - filled),
                                  )
                                : Colors.transparent),
                      border: Border.all(
                        color: i <= filled
                            ? p.accent
                            : p.border.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Container(width: 5, height: 5, color: p.accent),
            const SizedBox(width: 6),
            Text(
              'NATURAL-V.P.A.M.',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 5.5,
                letterSpacing: 0.8,
                color: p.keySub.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BootStatus extends StatelessWidget {
  final double progress;
  final double seconds;

  const _BootStatus({required this.progress, required this.seconds});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final label = switch (progress) {
      < 0.28 => 'CHECKING MEMORY',
      < 0.55 => 'LOADING ENGINE',
      < 0.82 => 'BUILDING KEYPAD',
      _ => 'READY',
    };
    final cursorOn = (seconds * 3.2) % 1 < 0.55;
    return SizedBox(
      height: 18,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'VT323',
              fontSize: 15,
              height: 1,
              letterSpacing: 0.8,
              color: p.wellDim,
            ),
          ),
          const SizedBox(width: 5),
          Opacity(
            opacity: cursorOn ? 1 : 0,
            child: Container(width: 7, height: 12, color: p.accent),
          ),
        ],
      ),
    );
  }
}

class _IntroScanlines extends CustomPainter {
  final Color color;
  _IntroScanlines(this.color);

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
  bool shouldRepaint(covariant _IntroScanlines old) => old.color != color;
}
