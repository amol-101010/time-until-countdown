import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Alternative to [DotGrid]: progress as concentric rings, like tree
/// rings, growing outward. Unlike the dot grid, this doesn't render one
/// visual unit per calendar unit (that wouldn't scale - a 365-day year
/// can't be 365 rings). Instead [ringCount] rings each represent an equal
/// slice of the whole 0-100% progress: a ring is fully drawn once its
/// slice completes, and the single ring currently "growing" is drawn as
/// a partial arc - a generic radial progress representation with a
/// growth-ring look, independent of what total/filled/granularity mean.
class GrowthRings extends StatelessWidget {
  const GrowthRings({
    super.key,
    required this.filled,
    required this.total,
    required this.color,
    this.ringCount = 6,
    this.showPercentage = false,
  });

  final int filled;
  final int total;
  final Color color;
  final int ringCount;

  /// Draws the percentage in the center - a nice focal point for a
  /// larger area (the detail screen), but usually left off for compact
  /// contexts (card previews) where the number is already shown as text
  /// alongside the visual.
  final bool showPercentage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emptyColor = isDark
        ? Colors.white.withValues(alpha: 0.22)
        : Colors.black.withValues(alpha: 0.20);
    final fraction = total <= 0 ? 0.0 : (filled / total).clamp(0.0, 1.0);

    return CustomPaint(
      painter: _GrowthRingsPainter(
        fraction: fraction,
        ringCount: ringCount,
        filledColor: color,
        emptyColor: emptyColor,
      ),
      size: Size.infinite,
      child: showPercentage
          ? Center(
              child: Text(
                '${(fraction * 100).round()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            )
          : null,
    );
  }
}

class _GrowthRingsPainter extends CustomPainter {
  _GrowthRingsPainter({
    required this.fraction,
    required this.ringCount,
    required this.filledColor,
    required this.emptyColor,
  });

  final double fraction;
  final int ringCount;
  final Color filledColor;
  final Color emptyColor;

  static const double _maxOuterRadius = 170;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || ringCount <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    // Capped for the same reason as DotGrid's _maxCellSize: without a cap,
    // a large host area (the detail screen's Expanded region) would blow
    // this up into an oversized circle instead of staying a compact,
    // badge-like indicator.
    final maxRadius = math.min(
      _maxOuterRadius,
      math.min(size.width, size.height) / 2 - 2,
    );
    if (maxRadius <= 0) return;

    final ringSpacing = maxRadius / ringCount;
    final strokeWidth = math.max(2.0, ringSpacing * 0.6);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = emptyColor;
    final fillPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = filledColor;
    final tipPaint = Paint()..color = filledColor;

    final scaledProgress = fraction * ringCount;

    for (var i = 0; i < ringCount; i++) {
      final radius = ringSpacing * (i + 1);
      canvas.drawCircle(center, radius, trackPaint);

      final ringProgress = (scaledProgress - i).clamp(0.0, 1.0);
      if (ringProgress <= 0) continue;

      if (ringProgress >= 1.0) {
        canvas.drawCircle(center, radius, fillPaint);
        continue;
      }

      final sweepAngle = ringProgress * 2 * math.pi;
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, fillPaint);

      final tipAngle = -math.pi / 2 + sweepAngle;
      final tip = center +
          Offset(math.cos(tipAngle), math.sin(tipAngle)) * radius;
      canvas.drawCircle(tip, strokeWidth / 2 + 1, tipPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthRingsPainter oldDelegate) {
    return fraction != oldDelegate.fraction ||
        ringCount != oldDelegate.ringCount ||
        filledColor != oldDelegate.filledColor ||
        emptyColor != oldDelegate.emptyColor;
  }
}
