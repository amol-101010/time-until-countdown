import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '../data/seed/builtin_events.dart';
import '../domain/progress_calculator.dart';
import '../models/event.dart';
import '../state/providers/settings_provider.dart';
import '../ui/theme/app_theme.dart';
import '../ui/widgets/progress_visual.dart';
import '../utils/date_utils.dart';

/// Renders the chosen event's progress to a PNG and pushes it to the
/// Android home-screen widget (see android/.../DashWidgetProvider.kt).
///
/// Android throttles background widget updates to roughly every 30
/// minutes regardless of what we ask for - this call is the "whenever the
/// app happens to be running" path, which combined with that OS-driven
/// floor is the same tradeoff notification_scheduler.dart documents for
/// its own periodic sweep: fresh whenever you open the app, coarse
/// otherwise.
Future<void> updateHomeWidget({
  required List<Event> events,
  required Settings settings,
  required DateTime now,
}) async {
  if (kIsWeb || !Platform.isAndroid) return;

  final targetId = settings.homeWidgetEventId ?? BuiltInEventIds.today;
  Event? event;
  for (final e in events) {
    if (e.id == targetId) {
      event = e;
      break;
    }
  }
  if (event == null) return;

  final result = ProgressCalculator.compute(event, now);

  // One static frame - the widget image is a plain PNG (Android
  // RemoteViews can't host a live custom animation), so sandTimer renders
  // as a still hourglass here rather than the animated version seen in
  // the app itself.
  final visual = ProgressVisual(
    visualStyle: settings.visualStyle,
    filled: result.filled,
    total: result.total,
    color: event.color,
    shape: event.shape,
    showPercentage: true,
    compact: true,
  );

  try {
    await HomeWidget.renderFlutterWidget(
      Theme(
        data: AppTheme.light(),
        child: SizedBox(width: 260, height: 130, child: visual),
      ),
      key: 'dash_widget_image',
      logicalSize: const Size(260, 130),
    );
    await HomeWidget.saveWidgetData<String>('dash_widget_title', event.title);
    await HomeWidget.saveWidgetData<String>(
      'dash_widget_subtitle',
      formatProgressSummary(
        filled: result.filled,
        total: result.total,
        granularity: event.granularity,
      ),
    );
    await HomeWidget.updateWidget(
      qualifiedAndroidName: 'xyz.amolchavan.timeuntil.DashWidgetProvider',
    );
  } catch (_) {
    // Best-effort: no widget pinned, or a transient render/IO failure.
    // Nothing user-visible should break because the widget didn't refresh.
  }
}
