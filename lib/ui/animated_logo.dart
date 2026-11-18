import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'widgets.dart';

/// The VECTORCALC mark with a retro CRT treatment:
///
/// * a slow breathing glow,
/// * a horizontal scanline sweep,
/// * a faint float, and
/// * a short RGB-split glitch every few seconds.
///
/// The artwork is a transparent PNG produced by `tool/make_logo.dart`.
class AnimatedLogo extends StatefulWidget {
  final double height;
  final bool glow;
  final bool showGlitch;
  final String semanticLabel;

  const AnimatedLogo({
    super.key,
    this.height = 44,
    this.glow = true,
    this.showGlitch = true,
    this.semanticLabel = 'VECTORCALC mark',
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  @override
  void initState() {
    super.initState();
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final image = _mark();

    if (reduceMotion) {
      return SizedBox(height: widget.height, child: image);
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final seconds = _controller.value * 6;
          final float = math.sin(seconds * 1.35) * 1.1;
          final pulse = 0.5 + 0.5 * math.sin(seconds * 2.1);
          final glitching =
              widget.showGlitch && (seconds % 3.4) < 0.13;

          return Transform.translate(
            offset: Offset(0, float),
            child: SizedBox(
              height: widget.height,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (widget.glow)
                    Opacity(
                      opacity: 0.16 + 0.20 * pulse,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: _tinted(const Color(0xFF63F0A8)),
                      ),
                    ),
                  if (glitching) ...[
                    Transform.translate(
                      offset: const Offset(-1.6, 0),
                      child: Opacity(
                        opacity: 0.55,
                        child: _tinted(const Color(0xFFFF4D5E)),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(1.6, 0),
                      child: Opacity(
                        opacity: 0.55,
                        child: _tinted(const Color(0xFF43D9FF)),
                      ),
                    ),
                  ],
                  ShaderMask(
                    blendMode: BlendMode.srcATop,
                    shaderCallback: (rect) {
                      final y = ((seconds % 2.4) / 2.4) * 2.4 - 1.2;
                      return LinearGradient(
                        begin: Alignment(0, y - 0.28),
                        end: Alignment(0, y + 0.28),
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.75),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ).createShader(rect);
                    },
                    child: image,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _mark() => Image.asset(
        'assets/logo/mark.png',
        height: widget.height,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
        gaplessPlayback: true,
        semanticLabel: widget.semanticLabel,
        errorBuilder: (context, error, stack) => _fallback(),
      );

  Widget _tinted(Color color) => ColorFiltered(
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        child: _mark(),
      );

  Widget _fallback() {
    final p = context.palette;
    return Container(
      width: widget.height * 0.9,
      height: widget.height * 0.9,
      color: p.accent,
      alignment: Alignment.center,
      child: Text(
        'VC',
        style: TextStyle(
          fontFamily: 'PressStart2P',
          fontSize: widget.height * 0.22,
          color: p.onAccent,
        ),
      ),
    );
  }
}
