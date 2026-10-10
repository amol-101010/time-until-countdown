import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/event.dart';
import '../../notifications/notification_scheduler.dart';
import '../../platform/chrome_extension_bridge.dart';
import 'clock_provider.dart';
import 'event_list_provider.dart';
import 'settings_provider.dart';

/// Mirrors the "Replace new tab page" setting into chrome.storage.local
/// for chrome_extension/newtab.js. A no-op outside the Chrome extension.
final extensionNewTabProvider = Provider<void>((ref) {
  if (!isChromeExtension) return;
  final enabled = ref.watch(
    settingsProvider.select((s) => s.value?.newTabEnabled),
  );
  if (enabled != null) writeNewTabEnabled(enabled);
});

/// How many upcoming occurrences of one event's reminder are handed to the
/// service worker, and the cap across all events. The worker can only fire
/// what it was given, so this is how far ahead reminders keep working with
/// the app closed (e.g. a daily reminder survives ~a month unopened).
const _maxOccurrencesPerEvent = 30;
const _maxScheduleEntries = 400;

/// Builds the schedule the service worker fires reminders from: for every
/// reminders-enabled event, its next [_maxOccurrencesPerEvent] trigger
/// times, soonest first. Pure so it can be unit tested.
List<Map<String, Object>> buildReminderSchedule(
  List<Event> events,
  DateTime now,
) {
  final entries = <Map<String, Object>>[];
  for (final event in events) {
    if (!event.remindersEnabled || event.deletedAt != null) continue;

    var cursor = now;
    for (var i = 0; i < _maxOccurrencesPerEvent; i++) {
      final trigger = NotificationScheduler.nextTriggerFor(event, cursor);
      if (trigger == null) break;
      final at = trigger.millisecondsSinceEpoch;
      entries.add({
        'key': '${event.id}@$at',
        'title': event.title,
        'body': NotificationScheduler.messageFor(event),
        'at': at,
      });
      cursor = trigger.add(const Duration(minutes: 1));
    }
  }
  entries.sort((a, b) => (a['at']! as int).compareTo(b['at']! as int));
  return entries.length > _maxScheduleEntries
      ? entries.sublist(0, _maxScheduleEntries)
      : entries;
}

String? _lastWrittenSchedule;

/// Keeps the extension's reminder schedule fresh while the app is open;
/// the service worker (chrome_extension/background.js) does the firing.
/// Re-evaluated on every clock tick so recurring reminders roll forward.
final extensionRemindersProvider = Provider<void>((ref) {
  if (!isChromeExtension) return;

  final events = ref.watch(eventListProvider).value;
  final now = ref.watch(clockProvider).value;
  if (events == null || now == null) return;

  final json = jsonEncode(buildReminderSchedule(events, now));
  if (json == _lastWrittenSchedule) return;
  _lastWrittenSchedule = json;
  writeReminderSchedule(json);
});
