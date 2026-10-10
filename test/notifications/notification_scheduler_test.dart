import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dash/models/event.dart';
import 'package:dash/notifications/notification_scheduler.dart';

void main() {
  group('nextTriggerFor - recurring', () {
    final workday = RecurrenceRule(
      frequency: RecurrenceFrequency.daily,
      daysOfWeek: const [
        Weekday.mon,
        Weekday.tue,
        Weekday.wed,
        Weekday.thu,
        Weekday.fri,
      ],
      cycleStartTime: const TimeOfDay(hour: 9, minute: 0),
      cycleEndTime: const TimeOfDay(hour: 17, minute: 0),
    );

    Event workdayEvent({TimeOfDay? reminderTime}) => Event(
          id: 'workday',
          title: 'Workday',
          color: const Color(0xFF000000),
          isRecurring: true,
          granularity: Granularity.hour,
          shape: GridShape.dash,
          recurrence: workday,
          remindersEnabled: true,
          reminderTime: reminderTime,
        );

    test('returns null when no reminder time has been set', () {
      // 2026-01-07 is a Wednesday.
      final now = DateTime(2026, 1, 7, 8, 0);
      expect(NotificationScheduler.nextTriggerFor(workdayEvent(), now), isNull);
    });

    test("today's reminder time, when it hasn't passed yet", () {
      // Wednesday 8:00, reminder set for 8:45 - still ahead of now.
      final now = DateTime(2026, 1, 7, 8, 0);
      final trigger = NotificationScheduler.nextTriggerFor(
        workdayEvent(reminderTime: const TimeOfDay(hour: 8, minute: 45)),
        now,
      );
      expect(trigger, DateTime(2026, 1, 7, 8, 45));
    });

    test('rolls over to the next occurrence once today\'s time has passed', () {
      // Wednesday 9:00, reminder set for 8:45 - already passed today.
      final now = DateTime(2026, 1, 7, 9, 0);
      final trigger = NotificationScheduler.nextTriggerFor(
        workdayEvent(reminderTime: const TimeOfDay(hour: 8, minute: 45)),
        now,
      );
      expect(trigger, DateTime(2026, 1, 8, 8, 45)); // Thursday
    });

    test('rolling over on Friday skips the weekend to Monday', () {
      // Friday 9:00, reminder already passed for today.
      final now = DateTime(2026, 1, 9, 9, 0);
      final trigger = NotificationScheduler.nextTriggerFor(
        workdayEvent(reminderTime: const TimeOfDay(hour: 8, minute: 45)),
        now,
      );
      expect(trigger, DateTime(2026, 1, 12, 8, 45)); // Monday
    });
  });

  group('nextTriggerFor - one-time', () {
    Event oneTimeEvent({DateTime? reminderDateTime}) => Event(
          id: 'trip',
          title: 'Trip',
          color: const Color(0xFF000000),
          isRecurring: false,
          granularity: Granularity.day,
          shape: GridShape.dot,
          startDate: DateTime(2026, 6, 1),
          remindersEnabled: true,
          reminderDateTime: reminderDateTime,
        );

    test('returns the reminder date/time when it is still upcoming', () {
      final now = DateTime(2026, 1, 1);
      final reminder = DateTime(2026, 5, 30, 10, 0);
      expect(
        NotificationScheduler.nextTriggerFor(
          oneTimeEvent(reminderDateTime: reminder),
          now,
        ),
        reminder,
      );
    });

    test('returns null once the reminder date/time has passed', () {
      final now = DateTime(2026, 6, 2);
      final reminder = DateTime(2026, 5, 30, 10, 0);
      expect(
        NotificationScheduler.nextTriggerFor(
          oneTimeEvent(reminderDateTime: reminder),
          now,
        ),
        isNull,
      );
    });

    test('returns null when no reminder date/time has been set', () {
      final now = DateTime(2026, 1, 1);
      expect(
        NotificationScheduler.nextTriggerFor(oneTimeEvent(), now),
        isNull,
      );
    });
  });

  group('nextTriggerFor - one-time, repeating mode', () {
    Event repeatingEvent({
      required RecurrenceFrequency frequency,
      required TimeOfDay reminderTime,
      DateTime? startDate,
    }) =>
        Event(
          id: 'trip',
          title: 'Trip',
          color: const Color(0xFF000000),
          isRecurring: false,
          granularity: Granularity.day,
          shape: GridShape.dot,
          startDate: startDate ?? DateTime(2026, 6, 1),
          remindersEnabled: true,
          reminderTime: reminderTime,
          reminderRepeatFrequency: frequency,
        );

    test('daily: fires today if the time has not passed yet', () {
      final now = DateTime(2026, 5, 20, 8, 0);
      final trigger = NotificationScheduler.nextTriggerFor(
        repeatingEvent(
          frequency: RecurrenceFrequency.daily,
          reminderTime: const TimeOfDay(hour: 9, minute: 0),
        ),
        now,
      );
      expect(trigger, DateTime(2026, 5, 20, 9, 0));
    });

    test('daily: rolls to tomorrow once today\'s time has passed', () {
      final now = DateTime(2026, 5, 20, 10, 0);
      final trigger = NotificationScheduler.nextTriggerFor(
        repeatingEvent(
          frequency: RecurrenceFrequency.daily,
          reminderTime: const TimeOfDay(hour: 9, minute: 0),
        ),
        now,
      );
      expect(trigger, DateTime(2026, 5, 21, 9, 0));
    });

    test('stops once the event\'s start date has passed', () {
      // The rolled-over occurrence would land on the start date itself.
      final now = DateTime(2026, 5, 31, 10, 0);
      final trigger = NotificationScheduler.nextTriggerFor(
        repeatingEvent(
          frequency: RecurrenceFrequency.daily,
          reminderTime: const TimeOfDay(hour: 9, minute: 0),
          startDate: DateTime(2026, 6, 1),
        ),
        now,
      );
      expect(trigger, isNull);
    });

    test('stops immediately if now is already at/after the start date', () {
      final now = DateTime(2026, 6, 1, 0, 0);
      final trigger = NotificationScheduler.nextTriggerFor(
        repeatingEvent(
          frequency: RecurrenceFrequency.daily,
          reminderTime: const TimeOfDay(hour: 9, minute: 0),
          startDate: DateTime(2026, 6, 1),
        ),
        now,
      );
      expect(trigger, isNull);
    });

    test('weekly: fires on the ISO week\'s Monday at the reminder time', () {
      // 2026-05-20 is a Wednesday; the current week's Monday is 05-18.
      final now = DateTime(2026, 5, 20, 8, 0);
      final trigger = NotificationScheduler.nextTriggerFor(
        repeatingEvent(
          frequency: RecurrenceFrequency.weekly,
          reminderTime: const TimeOfDay(hour: 9, minute: 0),
          startDate: DateTime(2026, 12, 1),
        ),
        now,
      );
      expect(trigger, DateTime(2026, 5, 25, 9, 0)); // next Monday
    });
  });
}
