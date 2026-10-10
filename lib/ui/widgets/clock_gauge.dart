import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Alternative to [DotGrid]/[GrowthRings]: progress as ticks radiating
/// around a circle like a clock/gauge face, filling clockwise from 12
/// o'clock. Like [GrowthRings], [tickCount] is a fixed generic scale
/// (not one tick per calendar unit - that wouldn't work for a 960-month
/// life span), so this is a fraction-based radial indicator that happens
/// to look like a literal clock.
class ClockGauge extends StatelessWidget {
  const ClockGauge({
    super.key,
    required this.filled,
    required this.total,
    required this.color,
    this.tickCount = 24,
    this.showPercentage = false,
  });

  final int filled;
  final int total;
  final Color color;
  final int tickCount;
  final bool showPercentage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emptyColor = isDark
        ? Colors.white.withValues(alpha: 0.22)
        : Colors.black.withValues(alpha: 0.20);
    final fraction = total <= 0 ? 0.0 : (filled / total).clamp(0.0, 1.0);

    return CustomPaint(
      painter: _ClockGaugePainter(
        fraction: fraction,
        tickCount: tickCount,
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

class _ClockGaugePainter extends CustomPainter {
  _ClockGaugePainter({
    required this.fraction,
    required this.tickCount,
    required this.filledColor,
    required this.emptyColor,
  });

  final double fraction;
  final int tickCount;
  final Color filledColor;
  final Color emptyColor;

  static const double _maxOuterRadius = 170;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || tickCount <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(
      _maxOuterRadius,
      math.min(size.width, size.height) / 2 - 2,
    );
    if (maxRadius <= 0) return;

    final tickOuter = maxRadius;
    final tickInner = maxRadius * 0.78;
    final tickWidth = math.max(2.0, maxRadius * 0.12);
    final filledCount = (fraction * tickCount).round().clamp(0, tickCount);

    final emptyPaint = Paint()
      ..strokeWidth = tickWidth
      ..strokeCap = StrokeCap.round
      ..color = emptyColor;
    final filledPaint = Paint()
      ..strokeWidth = tickWidth
      ..strokeCap = StrokeCap.round
      ..color = filledColor;

    for (var i = 0; i < tickCount; i++) {
      final angle = -math.pi / 2 + i * (2 * math.pi / tickCount);
      final direction = Offset(math.cos(angle), math.sin(angle));
      final p1 = center + direction * tickInner;
      final p2 = center + direction * tickOuter;
      canvas.drawLine(p1, p2, i < filledCount ? filledPaint : emptyPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ClockGaugePainter oldDelegate) {
    return fraction != oldDelegate.fraction ||
        tickCount != oldDelegate.tickCount ||
        filledColor != oldDelegate.filledColor ||
        emptyColor != oldDelegate.emptyColor;
  }
}
