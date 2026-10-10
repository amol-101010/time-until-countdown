import 'package:flutter/material.dart';

import '../../models/event.dart';
import '../../state/providers/settings_provider.dart';
import 'clock_gauge.dart';
import 'dot_grid.dart';
import 'growth_rings.dart';
import 'sand_timer.dart';

/// Single dispatch point for [VisualStyle] -> the widget that renders it.
/// Every screen that shows an event's progress goes through this instead
/// of switching on [VisualStyle] itself, so adding a 5th style is a
/// one-place change.
class ProgressVisual extends StatelessWidget {
  const ProgressVisual({
    super.key,
    required this.visualStyle,
    required this.filled,
    required this.total,
    required this.color,
    required this.shape,
    this.showPercentage = false,
    this.compact = false,
    this.maxGridUnitsRendered,
  });

  final VisualStyle visualStyle;
  final int filled;
  final int total;
  final Color color;
  final GridShape shape;

  /// Only meaningful for [VisualStyle.growthRings] and
  /// [VisualStyle.clockGauge], which can draw a centered percentage
  /// (see their own doc comments for why grid/sand timer don't).
  final bool showPercentage;

  /// True for a small preview context (a home-screen card) rather than a
  /// large hero area (the detail screen): stretches the grid to fill its
  /// given rect instead of clustering (see [DotGrid.stretchToFit]), and
  /// uses fewer growth rings so they stay legible at a small size.
  final bool compact;

  /// Forwarded to [DotGrid.maxUnitsRendered].
  final int? maxGridUnitsRendered;

  @override
  Widget build(BuildContext context) {
    switch (visualStyle) {
      case VisualStyle.grid:
        return DotGrid(
          filled: filled,
          total: total,
          color: color,
          shape: shape,
          stretchToFit: compact,
          maxUnitsRendered: maxGridUnitsRendered,
        );
      case VisualStyle.growthRings:
        return GrowthRings(
          filled: filled,
          total: total,
          color: color,
          ringCount: compact ? 4 : 6,
          showPercentage: showPercentage,
        );
      case VisualStyle.clockGauge:
        return ClockGauge(
          filled: filled,
          total: total,
          color: color,
          showPercentage: showPercentage,
        );
      case VisualStyle.sandTimer:
        return SandTimer(filled: filled, total: total, color: color);
    }
  }
}
