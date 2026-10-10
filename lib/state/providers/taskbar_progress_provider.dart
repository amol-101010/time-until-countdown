import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

import '../../data/seed/builtin_events.dart';
import '../../domain/progress_calculator.dart';
import '../../models/event.dart';
import 'clock_provider.dart';
import 'event_list_provider.dart';
import 'settings_provider.dart';

/// Mirrors one event's progress onto the Windows taskbar icon (like
/// Explorer's file-copy progress). No-op on every other platform.
///
/// Watches (not just reads) settings/events/clock, so toggling the
/// setting in the UI updates the taskbar immediately rather than waiting
/// for the next minute's clock tick - just watching this provider (see
/// app.dart) keeps it running.
final taskbarProgressProvider = Provider<void>((ref) {
  // kIsWeb must be checked first: dart:io's Platform.* throws on web
  // (unimplemented there) rather than just reporting false.
  if (kIsWeb || !Platform.isWindows) return;

  final settings = ref.watch(settingsProvider).value;
  final now = ref.watch(clockProvider).value;
  final events = ref.watch(eventListProvider).value;

  if (settings == null || !settings.taskbarProgressEnabled || now == null) {
    WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
    return;
  }

  final targetId = settings.taskbarProgressEventId ?? BuiltInEventIds.today;
  Event? event;
  for (final e in events ?? const <Event>[]) {
    if (e.id == targetId) {
      event = e;
      break;
    }
  }
  if (event == null) {
    WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
    return;
  }

  final result = ProgressCalculator.compute(event, now);
  WindowsTaskbar.setProgressMode(TaskbarProgressMode.normal);
  WindowsTaskbar.setProgress(result.filled, result.total == 0 ? 1 : result.total);
});
