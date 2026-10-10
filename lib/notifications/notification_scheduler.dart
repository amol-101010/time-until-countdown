import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/progress_calculator.dart';
import '../models/event.dart';

/// Schedules opt-in local reminders for events (see [Event.remindersEnabled]).
///
/// Always schedules exactly one upcoming notification per event, never a
/// platform "repeating" one: Windows doesn't support repeat notifications
/// at all, so the same one-shot-then-reschedule mechanism is used on every
/// platform. [scheduleNext] is called right after a save (for immediate
/// feedback) and swept periodically by notification_provider.dart's
/// driver (to pick up "this one fired, queue the next one" - there's no
/// reliable fire-time callback across platforms/app states, so this is a
/// polling catch-up rather than an exact trigger).
///
/// Limitation worth knowing: the catch-up sweep only runs while the app
/// is open. A single already-scheduled reminder survives a reboot (the
/// plugin's own Android boot receiver, registered in AndroidManifest.xml,
/// re-registers it with AlarmManager), but if the app stays closed across
/// more than one reminder cycle, only that one next occurrence fires -
/// later ones won't be queued until the app is opened again. Fine for
/// opt-in reminders on a personal app; not a guaranteed-delivery alarm
/// system.
class NotificationScheduler {
  NotificationScheduler._(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const _windowsAppUserModelId = 'xyz.amolchavan.timeuntil';
  // Fixed GUID identifying this app's notification activation callback on
  // Windows - not a secret, just needs to stay constant across builds.
  static const _windowsGuid = '1da43d08-209f-48c2-94cc-43f21af66f1a';

  static const _androidChannelId = 'event_reminders';

  static Future<NotificationScheduler> create() async {
    tz_data.initializeTimeZones();
    try {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz.identifier));
    } catch (_) {
      // Leaves tz.local at its UTC default. Reminders would then fire
      // offset from true local time, but this is rare and better than
      // crashing startup over it.
    }

    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        windows: WindowsInitializationSettings(
          appName: 'TimeUntil',
          appUserModelId: _windowsAppUserModelId,
          guid: _windowsGuid,
        ),
      ),
    );
    return NotificationScheduler._(plugin);
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Schedules the next reminder for [event], or cancels any pending one
  /// if reminders are off or nothing is left to notify about (a one-time
  /// event that has already fully elapsed).
  Future<void> scheduleNext(Event event, {DateTime? now}) async {
    if (!event.remindersEnabled) {
      await cancel(event.id);
      return;
    }

    final trigger = nextTriggerFor(event, now ?? DateTime.now());
    if (trigger == null) {
      await cancel(event.id);
      return;
    }

    await _plugin.zonedSchedule(
      id: _notificationId(event.id),
      title: event.title,
      body: messageFor(event),
      scheduledDate: tz.TZDateTime.from(trigger, tz.local),
      notificationDetails: NotificationDetails(
        android: const AndroidNotificationDetails(
          _androidChannelId,
          'Event reminders',
          channelDescription: "Reminders for events you've turned on notifications for",
        ),
        windows: const WindowsNotificationDetails(),
      ),
      // "roughly on time, works while idle" - avoids needing Android 12+'s
      // SCHEDULE_EXACT_ALARM permission for what's just a reminder, not a
      // precision alarm.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancel(String eventId) =>
      _plugin.cancel(id: _notificationId(eventId));

  static int _notificationId(String eventId) => eventId.hashCode & 0x7fffffff;

  /// Notification body text for [event] - shared with the Chrome
  /// extension's reminder mirror (extension_sync_provider.dart).
  static String messageFor(Event event) {
    return event.isRecurring ? '${event.title} is starting' : '${event.title} reminder';
  }

  /// Next instant to notify at, or null once there's nothing left:
  /// - Recurring event: [Event.reminderTime] applied to the current
  ///   cycle's start *date*, rolling forward each time today's time has
  ///   passed. Null if no reminder time has been set yet.
  /// - One-time event, repeating mode ([Event.reminderRepeatFrequency]
  ///   set): the same rolling-forward logic, but against a synthetic
  ///   cycle built from that frequency instead of the event's own
  ///   [RecurrenceRule] (a one-time event doesn't have one) - and capped
  ///   to stop once [Event.startDate] passes, since reminding about an
  ///   event after it's already started doesn't make sense.
  /// - One-time event, one-shot mode (the default):
  ///   [Event.reminderDateTime] if it's still upcoming, else null
  ///   (already fired or never set).
  ///
  /// Public (unlike the rest of this class's internals) so this pure,
  /// deterministic piece of logic can be unit tested directly - see
  /// test/notifications/notification_scheduler_test.dart.
  static DateTime? nextTriggerFor(Event event, DateTime now) {
    if (event.isRecurring) {
      final reminderTime = event.reminderTime;
      if (reminderTime == null) return null;
      return _nextRecurringTrigger(event.recurrence!, reminderTime, now);
    }

    final repeatFrequency = event.reminderRepeatFrequency;
    if (repeatFrequency != null) {
      final reminderTime = event.reminderTime;
      final startDate = event.startDate;
      if (reminderTime == null || startDate == null) return null;
      if (!now.isBefore(startDate)) return null;
      final syntheticRule = RecurrenceRule(
        frequency: repeatFrequency,
        cycleStartTime: reminderTime,
      );
      final trigger = _nextRecurringTrigger(syntheticRule, reminderTime, now);
      return (trigger != null && trigger.isBefore(startDate)) ? trigger : null;
    }

    final reminderDateTime = event.reminderDateTime;
    return (reminderDateTime != null && reminderDateTime.isAfter(now))
        ? reminderDateTime
        : null;
  }

  /// [reminderTime] applied to the current cycle (per [rule]) that
  /// contains [now], rolling forward to the next cycle once that time has
  /// already passed today. Shared by recurring events (using their own
  /// [RecurrenceRule]) and one-time events in repeating mode (using a
  /// synthetic one built from [Event.reminderRepeatFrequency]) - see
  /// [nextTriggerFor].
  static DateTime? _nextRecurringTrigger(
    RecurrenceRule rule,
    TimeOfDay reminderTime,
    DateTime now,
  ) {
    final currentCycle = ProgressCalculator.resolveCycle(rule, now);
    final todayCandidate = _atTime(currentCycle.start, reminderTime);
    if (todayCandidate.isAfter(now)) return todayCandidate;
    final next = ProgressCalculator.nextCycleAfter(rule, currentCycle);
    final nextCandidate = _atTime(next.start, reminderTime);
    return nextCandidate.isAfter(now) ? nextCandidate : null;
  }

  /// [date]'s calendar date combined with [time] - i.e. reminderTime
  /// applied to whatever day a cycle happens to start on.
  static DateTime _atTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}
