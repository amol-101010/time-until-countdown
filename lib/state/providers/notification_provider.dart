import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notifications/notification_scheduler.dart';
import '../../platform/chrome_extension_bridge.dart';
import 'clock_provider.dart';
import 'event_list_provider.dart';

/// Null in the Chrome extension, where reminders are fired by the
/// extension's background service worker instead - see
/// extension_sync_provider.dart.
final notificationSchedulerProvider = FutureProvider<NotificationScheduler?>((
  ref,
) async {
  if (isChromeExtension) return null;
  final scheduler = await NotificationScheduler.create();
  await scheduler.requestPermissions();
  return scheduler;
});

/// Sweeps every reminders-enabled event on each clock tick, (re)scheduling
/// its next trigger. This is what picks up "a reminder just fired, queue
/// the following one" - see NotificationScheduler's doc comment for why
/// it's a periodic sweep rather than an exact fire-time callback.
///
/// Just watching this (e.g. from app.dart, alongside syncEngineProvider)
/// is what keeps it running.
final notificationDriverProvider = Provider<void>((ref) {
  final schedulerAsync = ref.watch(notificationSchedulerProvider);
  final scheduler = schedulerAsync.value;
  if (scheduler == null) return;

  ref.listen(clockProvider, (previous, next) {
    final now = next.value;
    if (now == null) return;
    final events = ref.read(eventListProvider).value;
    if (events == null) return;
    for (final event in events) {
      scheduler.scheduleNext(event, now: now);
    }
  });
});
