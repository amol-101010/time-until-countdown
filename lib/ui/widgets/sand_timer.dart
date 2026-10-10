import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Alternative to [DotGrid]/[GrowthRings]/[ClockGauge]: progress as an
/// hourglass, sand piled in the bottom chamber proportional to elapsed
/// fraction (and correspondingly less in the top). Unlike the other
/// styles this is animated: a few grains continuously fall through the
/// neck on a short repeating loop, independent of how slowly the real
/// progress fraction itself is changing - the point is to sell "time is
/// passing right now", not to visualize each unit individually.
class SandTimer extends StatefulWidget {
  const SandTimer({
    super.key,
    required this.filled,
    required this.total,
    required this.color,
  });

  final int filled;
  final int total;
  final Color color;

  @override
  State<SandTimer> createState() => _SandTimerState();
}

class _SandTimerState extends State<SandTimer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final frameColor = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : Colors.black.withValues(alpha: 0.35);
    final fraction = widget.total <= 0
        ? 0.0
        : (widget.filled / widget.total).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _SandTimerPainter(
            fraction: fraction,
            animationValue: _controller.value,
            sandColor: widget.color,
            frameColor: frameColor,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// One falling grain's horizontal offset (as a fraction of the neck's
/// half-width) and phase, so grains read as separate particles rather
/// than a single continuous stream.
class _GrainSpec {
  const _GrainSpec(this.dx, this.phase);
  final double dx;
  final double phase;
}

class _SandTimerPainter extends CustomPainter {
  _SandTimerPainter({
    required this.fraction,
    required this.animationValue,
    required this.sandColor,
    required this.frameColor,
  });

  final double fraction;
  final double animationValue;
  final Color sandColor;
  final Color frameColor;

  /// Bounds on the rendered glass size, same reasoning as GrowthRings'
  /// and ClockGauge's own caps: without this, the detail screen's large
  /// Expanded area would stretch the hourglass to fill it instead of
  /// staying a compact, proportioned figure.
  static const double _maxWidth = 170;
  static const double _maxHeight = 260;

  static const _grains = [
    _GrainSpec(-0.35, 0.0),
    _GrainSpec(0.1, 0.33),
    _GrainSpec(-0.05, 0.66),
  ];

  @override
  void paint(Canvas canvas, Size fullSize) {
    if (fullSize.width <= 0 || fullSize.height <= 0) return;

    final w = math.min(_maxWidth, fullSize.width);
    final h = math.min(_maxHeight, fullSize.height);
    if (w <= 0 || h <= 0) return;

    canvas.save();
    canvas.translate((fullSize.width - w) / 2, (fullSize.height - h) / 2);

    final marginX = w * 0.14;
    final topY = h * 0.08;
    final bottomY = h * 0.92;
    final neckY = h / 2;
    final centerX = w / 2;
    final bulbWidth = w - 2 * marginX;
    final neckHalfWidth = math.max(2.0, w * 0.06);
    final topTaper = (neckY - topY) * 0.42;
    final bottomTaper = (bottomY - neckY) * 0.42;

    // Smooth hourglass silhouette: straight top/bottom caps, each side
    // wall a cubic curve tapering into the neck.
    final outline = Path()
      ..moveTo(marginX, topY)
      ..lineTo(w - marginX, topY)
      ..cubicTo(
        w - marginX, topY + topTaper,
        centerX + neckHalfWidth, neckY - topTaper,
        centerX + neckHalfWidth, neckY,
      )
      ..cubicTo(
        centerX + neckHalfWidth, neckY + bottomTaper,
        w - marginX, bottomY - bottomTaper,
        w - marginX, bottomY,
      )
      ..lineTo(marginX, bottomY)
      ..cubicTo(
        marginX, bottomY - bottomTaper,
        centerX - neckHalfWidth, neckY + bottomTaper,
        centerX - neckHalfWidth, neckY,
      )
      ..cubicTo(
        centerX - neckHalfWidth, neckY - topTaper,
        marginX, topY + topTaper,
        marginX, topY,
      )
      ..close();

    // Soft drop shadow grounds the object instead of it floating flat.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, bottomY + h * 0.025),
        width: bulbWidth * 1.05,
        height: h * 0.035,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // A faint left-light/right-shadow tint across the glass body reads as
    // a curved (not flat) surface - drawn before the sand/frame so it
    // sits underneath everything.
    canvas.drawPath(
      outline,
      Paint()
        ..shader = ui.Gradient.linear(Offset(marginX, 0), Offset(w - marginX, 0), [
          frameColor.withValues(alpha: 0.16),
          frameColor.withValues(alpha: 0.02),
          frameColor.withValues(alpha: 0.16),
        ], const [0.0, 0.5, 1.0]),
    );

    canvas.save();
    // Sand is painted as a plain rect clipped to the exact glass outline
    // above (rather than a separately-computed polygon), so its edges
    // always match the curve exactly instead of leaving a gap or
    // overshooting near the walls.
    canvas.clipPath(outline);

    // Bottom chamber: sand piles up from the base toward the neck.
    final bottomSandHeight = fraction * (bottomY - neckY);
    var sandPileSurfaceY = bottomY;
    if (bottomSandHeight > 0) {
      sandPileSurfaceY = bottomY - bottomSandHeight;
      canvas.drawRect(
        Rect.fromLTRB(0, sandPileSurfaceY, w, bottomY),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, sandPileSurfaceY),
            Offset(0, bottomY),
            [
              Color.lerp(sandColor, Colors.white, 0.3)!,
              sandColor,
              Color.lerp(sandColor, Colors.black, 0.18)!,
            ],
            const [0.0, 0.35, 1.0],
          ),
      );
      // A slightly lighter cap on the pile's surface suggests a rounded
      // heap rather than a flat-topped block.
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(centerX, sandPileSurfaceY),
          width: bulbWidth * 0.55,
          height: h * 0.018,
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.16),
      );
    }

    // Top chamber: remaining sand rests just above the neck, draining
    // from there as fraction grows (the surface drops toward the top).
    final remaining = 1 - fraction;
    final topSandHeight = remaining * (neckY - topY);
    if (topSandHeight > 0) {
      final sandSurfaceY = neckY - topSandHeight;
      canvas.drawRect(
        Rect.fromLTRB(0, sandSurfaceY, w, neckY),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, sandSurfaceY),
            Offset(0, neckY),
            [
              Color.lerp(sandColor, Colors.black, 0.1)!,
              sandColor,
              Color.lerp(sandColor, Colors.white, 0.25)!,
            ],
            const [0.0, 0.6, 1.0],
          ),
      );
    }
    canvas.restore();

    // Glass outline.
    canvas.drawPath(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, w * 0.018)
        ..color = frameColor,
    );

    // Thin rim ellipses at the top opening, neck, and base read as a
    // lathed glass object (a solid of revolution) instead of a flat
    // cutout - the classic trick for implying 3D in a 2D icon.
    _drawRim(canvas, Offset(centerX, topY), bulbWidth, h * 0.028, frameColor);
    _drawRim(canvas, Offset(centerX, neckY), neckHalfWidth * 2.4, h * 0.014, frameColor);
    _drawRim(canvas, Offset(centerX, bottomY), bulbWidth, h * 0.028, frameColor);

    // Falling grains: discrete particles (not a continuous stream) that
    // fall from the neck down to the current top of the bottom pile,
    // each on its own staggered loop with a gap so they visibly separate
    // rather than blur into a "dripping pipe" line.
    if (fraction > 0.005 && fraction < 0.995) {
      final grainRadius = math.max(1.0, w * 0.013);
      final startY = neckY - neckHalfWidth;
      final endY = math.max(neckY, sandPileSurfaceY - grainRadius);
      for (final grain in _grains) {
        final t = (animationValue + grain.phase) % 1.0;
        if (t > 0.8) continue; // pause between drops -> discrete, not a stream
        final fallT = t / 0.8;
        final y = startY + fallT * (endY - startY);
        final dx = centerX + grain.dx * neckHalfWidth;
        final opacity = (1 - fallT * 0.25).clamp(0.5, 1.0);
        canvas.drawCircle(
          Offset(dx, y),
          grainRadius,
          Paint()..color = sandColor.withValues(alpha: opacity),
        );
      }
    }

    canvas.restore();
  }

  static void _drawRim(Canvas canvas, Offset center, double width, double height, Color color) {
    canvas.drawOval(
      Rect.fromCenter(center: center, width: width, height: height),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: 0.5),
    );
  }

  @override
  bool shouldRepaint(covariant _SandTimerPainter oldDelegate) {
    return fraction != oldDelegate.fraction ||
        animationValue != oldDelegate.animationValue ||
        sandColor != oldDelegate.sandColor ||
        frameColor != oldDelegate.frameColor;
  }
}
