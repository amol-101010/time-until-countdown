import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets_native/widget_updater.dart';
import 'clock_provider.dart';
import 'event_list_provider.dart';
import 'settings_provider.dart';

/// Refreshes the Android home-screen widget on clock ticks and whenever
/// settings/events change while the app is running (Android's own update
/// throttling covers refresh while it isn't - see widget_updater.dart).
///
/// Just watching this (see app.dart) keeps it running.
final homeWidgetDriverProvider = Provider<void>((ref) {
  // kIsWeb first: dart:io's Platform.* throws on web instead of
  // reporting false.
  if (kIsWeb || !Platform.isAndroid) return;

  void refresh() {
    final now = ref.read(clockProvider).value;
    final events = ref.read(eventListProvider).value;
    final settings = ref.read(settingsProvider).value;
    if (now == null || events == null || settings == null) return;
    updateHomeWidget(events: events, settings: settings, now: now);
  }

  ref.listen(clockProvider, (previous, next) => refresh());
  ref.listen(eventListProvider, (previous, next) => refresh());
  ref.listen(settingsProvider, (previous, next) => refresh());
});
