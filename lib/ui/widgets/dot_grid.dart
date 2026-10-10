import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/event.dart';

/// Renders `total` units (dots or dashes) in a grid, with the first
/// `filled` of them drawn in [color] and the rest in a faint outline.
///
/// Single [CustomPainter] draw call regardless of unit count, so this
/// stays cheap to repaint on every clock tick even at large counts (e.g.
/// a year at day-granularity is 365 units).
class DotGrid extends StatelessWidget {
  const DotGrid({
    super.key,
    required this.filled,
    required this.total,
    required this.color,
    required this.shape,
    this.maxUnitsRendered,
    this.stretchToFit = false,
  });

  final int filled;
  final int total;
  final Color color;
  final GridShape shape;

  /// Caps the number of units actually drawn (sampling down proportionally)
  /// independent of [total] - used for compact card previews so list
  /// scrolling stays smooth regardless of an event's real granularity.
  final int? maxUnitsRendered;

  /// false (default): units render at a natural, capped size and the
  /// resulting cluster is centered - for a large area like the detail
  /// screen, where filling every pixel would blow the units up huge with
  /// gaps between them (see EventDetailScreen).
  ///
  /// true: units stretch to fill the given space edge to edge, like the
  /// old behavior - for a small area that's already sized to fit a
  /// preview, like the home screen's list cards (see EventCard), where
  /// filling the given rect is exactly the point.
  final bool stretchToFit;

  @override
  Widget build(BuildContext context) {
    final cap = maxUnitsRendered;
    final effectiveTotal = (cap != null && total > cap) ? cap : total;
    final effectiveFilled = effectiveTotal == total
        ? filled
        : ((filled / total) * effectiveTotal).round();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emptyColor = isDark
        ? Colors.white.withValues(alpha: 0.22)
        : Colors.black.withValues(alpha: 0.20);

    return CustomPaint(
      painter: _DotGridPainter(
        filled: effectiveFilled,
        total: effectiveTotal,
        filledColor: color,
        emptyColor: emptyColor,
        shape: shape,
        stretchToFit: stretchToFit,
      ),
      size: Size.infinite,
    );
  }
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter({
    required this.filled,
    required this.total,
    required this.filledColor,
    required this.emptyColor,
    required this.shape,
    required this.stretchToFit,
  });

  final int filled;
  final int total;
  final Color filledColor;
  final Color emptyColor;
  final GridShape shape;
  final bool stretchToFit;

  /// Upper bound on the center-to-center spacing between units. Without
  /// this, a grid placed in a large area (e.g. the detail screen's
  /// Expanded region) would stretch to fill it - a handful of dots ending
  /// up tiny with huge gaps between them instead of forming a tight,
  /// Life-Dots-style cluster.
  static const double _maxCellSize = 48;

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0 || size.width <= 0 || size.height <= 0) return;

    final isDash = shape == GridShape.dash;
    // Dashes read as a single filling timeline, so aim for a
    // wider-than-tall cluster; dots pack into a roughly square one. This
    // is the cluster's own target shape, independent of the container's
    // aspect ratio - the container only caps how big it's allowed to get.
    final targetAspect = isDash ? 3.0 : 1.0;

    // stretchToFit fits the container's actual shape (a preview rect
    // that's already sized how it should look); cluster mode ignores the
    // container's shape and aims for the cluster's own target aspect,
    // since the container there is just an oversized bounding area.
    //
    // Dashes specifically stay a single row in stretchToFit: they read as
    // one continuous filling timeline, and wrapping that into multiple
    // rows in a compact preview breaks the metaphor (looks like a
    // misaligned bar chart rather than a progress strip). Dots don't have
    // that issue - a wrapped field of dots still reads fine.
    final columns = stretchToFit
        ? (isDash ? total : _bestColumnCountForContainer(total, size, targetAspect))
        : _bestColumnCount(total, targetAspect);
    final rows = (total / columns).ceil();

    final naturalCellSize = math.min(size.width / columns, size.height / rows);
    final cellSize = stretchToFit
        ? naturalCellSize
        : math.min(_maxCellSize, naturalCellSize);
    final unitWidth = isDash ? cellSize * 0.8 : cellSize * 0.68;
    final unitHeight = isDash ? cellSize * 0.32 : cellSize * 0.68;

    // Center the cluster in the available space, unless stretchToFit
    // deliberately fills it edge to edge (see the field doc comment).
    final gridWidth = columns * cellSize;
    final gridHeight = rows * cellSize;
    final offsetX = stretchToFit ? 0.0 : (size.width - gridWidth) / 2;
    final offsetY = stretchToFit ? 0.0 : (size.height - gridHeight) / 2;

    final filledPaint = Paint()..color = filledColor;
    final emptyPaint = Paint()..color = emptyColor;

    for (var i = 0; i < total; i++) {
      final col = i % columns;
      final row = i ~/ columns;
      final cx = offsetX + cellSize * (col + 0.5);
      final cy = offsetY + cellSize * (row + 0.5);
      final rect = Rect.fromCenter(
        center: Offset(cx, cy),
        width: unitWidth,
        height: unitHeight,
      );
      final paint = i < filled ? filledPaint : emptyPaint;

      if (isDash) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(unitHeight / 2)),
          paint,
        );
      } else {
        canvas.drawOval(rect, paint);
      }
    }
  }

  /// Picks a column count giving the cluster its target width:height
  /// [aspect] on its own terms (e.g. sqrt(total) for a square cluster),
  /// not influenced by the container's shape - the container only bounds
  /// how large the resulting cluster is allowed to render (see [paint]).
  static int _bestColumnCount(int total, double aspect) {
    if (total <= 1) return 1;
    var columns = math.sqrt(total * aspect).round();
    columns = columns.clamp(1, total);
    return columns;
  }

  /// Like [_bestColumnCount], but fits [size]'s actual aspect ratio
  /// instead of [aspect] - used by [stretchToFit] so a preview rect ends
  /// up with a sensible row/column split for its real shape (e.g. a wide
  /// short card doesn't end up needing many tall rows).
  static int _bestColumnCountForContainer(int total, Size size, double aspect) {
    if (total <= 1) return 1;
    final idealRatio = (size.width / size.height) / aspect;
    var columns = math.sqrt(total * idealRatio).round();
    columns = columns.clamp(1, total);
    return columns;
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) {
    return filled != oldDelegate.filled ||
        total != oldDelegate.total ||
        filledColor != oldDelegate.filledColor ||
        emptyColor != oldDelegate.emptyColor ||
        shape != oldDelegate.shape;
  }
}
