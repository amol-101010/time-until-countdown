import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dash/domain/progress_calculator.dart';
import 'package:dash/models/event.dart';

void main() {
  group('unitsBetween', () {
    test('returns 0 when end is not after start', () {
      final t = DateTime(2026, 1, 1);
      expect(ProgressCalculator.unitsBetween(t, t, Granularity.day), 0);
      expect(
        ProgressCalculator.unitsBetween(
          t,
          t.subtract(const Duration(days: 1)),
          Granularity.day,
        ),
        0,
      );
    });

    test('counts whole calendar months, not fixed 30-day chunks', () {
      // Jan 31 -> Mar 1 is 1 full month (Jan 31->Feb 31 doesn't exist, so
      // it only completes on/after Feb 28/29's equivalent day-of-month).
      final start = DateTime(2026, 1, 31);
      final end = DateTime(2026, 3, 1);
      expect(ProgressCalculator.unitsBetween(start, end, Granularity.month), 1);
    });

    test('counts whole years across a 50-year span without day drift', () {
      final start = DateTime(2016, 1, 1);
      final end = DateTime(2066, 1, 1);
      expect(ProgressCalculator.unitsBetween(start, end, Granularity.year), 50);
    });
  });

  group('resolveCycle - daily with daysOfWeek (Workday, Mon-Fri 9:00-17:00)', () {
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

    test('mid-cycle on an applicable weekday', () {
      // 2026-01-07 is a Wednesday.
      final now = DateTime(2026, 1, 7, 13, 0);
      final cycle = ProgressCalculator.resolveCycle(workday, now);
      expect(cycle.start, DateTime(2026, 1, 7, 9, 0));
      expect(cycle.end, DateTime(2026, 1, 7, 17, 0));
    });

    test('before the cycle starts today clamps filled to 0', () {
      final now = DateTime(2026, 1, 7, 7, 0); // 7am, before 9am start
      final event = Event(
        id: 'workday',
        title: 'Workday',
        color: const Color(0xFF000000),
        isRecurring: true,
        granularity: Granularity.hour,
        shape: GridShape.dash,
        recurrence: workday,
      );
      final result = ProgressCalculator.compute(event, now);
      expect(result.filled, 0);
      expect(result.total, 8);
    });

    test('on a non-applicable day (Saturday), falls back to the most recent'
        ' applicable weekday (Friday), fully elapsed', () {
      // 2026-01-10 is a Saturday; the prior Friday is 2026-01-09.
      final now = DateTime(2026, 1, 10, 10, 0);
      final cycle = ProgressCalculator.resolveCycle(workday, now);
      expect(cycle.start, DateTime(2026, 1, 9, 9, 0));
      expect(cycle.end, DateTime(2026, 1, 9, 17, 0));

      final event = Event(
        id: 'workday',
        title: 'Workday',
        color: const Color(0xFF000000),
        isRecurring: true,
        granularity: Granularity.hour,
        shape: GridShape.dash,
        recurrence: workday,
      );
      final result = ProgressCalculator.compute(event, now);
      // now is well after Friday's cycle end, so progress clamps at 100%
      // rather than reporting more elapsed units than the cycle has.
      expect(result.filled, result.total);
      expect(result.fraction, 1.0);
    });
  });

  group('nextCycleAfter - daily with daysOfWeek (Workday, Mon-Fri 9:00-17:00)', () {
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

    test('advances Wednesday -> Thursday, not back to Wednesday', () {
      // 2026-01-07 is a Wednesday.
      final wednesday = ProgressCalculator.resolveCycle(
        workday,
        DateTime(2026, 1, 7, 13, 0),
      );
      final next = ProgressCalculator.nextCycleAfter(workday, wednesday);
      expect(next.start, DateTime(2026, 1, 8, 9, 0)); // Thursday
      expect(next.end, DateTime(2026, 1, 8, 17, 0));
    });

    test('skips the weekend: Friday -> Monday', () {
      // 2026-01-09 is a Friday.
      final friday = ProgressCalculator.resolveCycle(
        workday,
        DateTime(2026, 1, 9, 13, 0),
      );
      final next = ProgressCalculator.nextCycleAfter(workday, friday);
      expect(next.start, DateTime(2026, 1, 12, 9, 0)); // Monday
      expect(next.end, DateTime(2026, 1, 12, 17, 0));
    });
  });

  group('nextCycleAfter - weekly/monthly/yearly', () {
    test('monthly advances March -> April', () {
      final march = ProgressCalculator.resolveCycle(
        const RecurrenceRule(frequency: RecurrenceFrequency.monthly),
        DateTime(2026, 3, 15),
      );
      final next = ProgressCalculator.nextCycleAfter(
        const RecurrenceRule(frequency: RecurrenceFrequency.monthly),
        march,
      );
      expect(next.start, DateTime(2026, 4, 1));
      expect(next.end, DateTime(2026, 5, 1));
    });
  });

  group('resolveCycle - weekly/monthly/yearly (built-in style views)', () {
    test('weekly resolves to the current ISO week (Mon-Sun)', () {
      // 2026-01-07 is a Wednesday.
      final now = DateTime(2026, 1, 7, 12, 0);
      final cycle = ProgressCalculator.resolveCycle(
        const RecurrenceRule(frequency: RecurrenceFrequency.weekly),
        now,
      );
      expect(cycle.start, DateTime(2026, 1, 5)); // Monday
      expect(cycle.end, DateTime(2026, 1, 12)); // next Monday
    });

    test('monthly resolves to the current calendar month', () {
      final now = DateTime(2026, 3, 15, 12, 0);
      final cycle = ProgressCalculator.resolveCycle(
        const RecurrenceRule(frequency: RecurrenceFrequency.monthly),
        now,
      );
      expect(cycle.start, DateTime(2026, 3, 1));
      expect(cycle.end, DateTime(2026, 4, 1));

      final total = ProgressCalculator.unitsBetween(
        cycle.start,
        cycle.end,
        Granularity.day,
      );
      expect(total, 31); // March has 31 days
    });

    test('yearly resolves to the current calendar year', () {
      final now = DateTime(2026, 6, 1);
      final cycle = ProgressCalculator.resolveCycle(
        const RecurrenceRule(frequency: RecurrenceFrequency.yearly),
        now,
      );
      expect(cycle.start, DateTime(2026, 1, 1));
      expect(cycle.end, DateTime(2027, 1, 1));
    });
  });

  group('one-time events', () {
    test('past start date: elapsed / progress towards default 50y span', () {
      final event = Event(
        id: 'marriage',
        title: 'Marriage',
        color: const Color(0xFF000000),
        isRecurring: false,
        granularity: Granularity.year,
        shape: GridShape.dot,
        startDate: DateTime(2016, 1, 1),
        // no endDate -> defaults to startDate + 50y
      );
      final now = DateTime(2026, 1, 1); // exactly 10 years later
      final result = ProgressCalculator.compute(event, now);
      expect(result.total, 50);
      expect(result.filled, 10);
      expect(result.fraction, closeTo(0.2, 1e-9));
    });

    test('future start date behaves as a not-started countdown (0 filled)', () {
      final event = Event(
        id: 'trip',
        title: 'Big Trip',
        color: const Color(0xFF000000),
        isRecurring: false,
        granularity: Granularity.month,
        shape: GridShape.dot,
        startDate: DateTime(2027, 1, 1),
        endDate: DateTime(2028, 1, 1),
      );
      final now = DateTime(2026, 1, 1); // before startDate
      final result = ProgressCalculator.compute(event, now);
      expect(result.filled, 0);
      expect(result.total, 12);
      expect(result.fraction, 0.0);
    });

    test('now past endDate clamps filled to total instead of overshooting', () {
      // This is the same defensive clamp that protects against a DST
      // transition making a "24h" recurring cycle actually 23 or 25 real
      // hours: elapsed units are always clamped to [0, total] regardless
      // of why the raw elapsed count could exceed the nominal span.
      final event = Event(
        id: 'old-event',
        title: 'Old Event',
        color: const Color(0xFF000000),
        isRecurring: false,
        granularity: Granularity.month,
        shape: GridShape.dot,
        startDate: DateTime(2020, 1, 1),
        endDate: DateTime(2021, 1, 1),
      );
      final now = DateTime(2026, 1, 1); // 5 years past endDate
      final result = ProgressCalculator.compute(event, now);
      expect(result.total, 12);
      expect(result.filled, 12);
      expect(result.fraction, 1.0);
    });
  });

  group('status - one-time events', () {
    Event tripEvent() => Event(
          id: 'trip',
          title: 'Trip',
          color: const Color(0xFF000000),
          isRecurring: false,
          granularity: Granularity.day,
          shape: GridShape.dot,
          startDate: DateTime(2026, 6, 1),
          endDate: DateTime(2026, 6, 10),
        );

    test('todo before the start date', () {
      final result = ProgressCalculator.compute(tripEvent(), DateTime(2026, 5, 1));
      expect(result.status, TaskStatus.todo);
    });

    test('doing between start and end', () {
      final result = ProgressCalculator.compute(tripEvent(), DateTime(2026, 6, 5));
      expect(result.status, TaskStatus.doing);
    });

    test('done at/after the end date', () {
      final result = ProgressCalculator.compute(tripEvent(), DateTime(2026, 6, 10));
      expect(result.status, TaskStatus.done);
    });
  });

  group('status - recurring events', () {
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

    Event workdayEvent() => Event(
          id: 'workday',
          title: 'Workday',
          color: const Color(0xFF000000),
          isRecurring: true,
          granularity: Granularity.hour,
          shape: GridShape.dash,
          recurrence: workday,
        );

    test('todo before today\'s cycle starts', () {
      // 2026-01-07 is a Wednesday.
      final result =
          ProgressCalculator.compute(workdayEvent(), DateTime(2026, 1, 7, 8, 0));
      expect(result.status, TaskStatus.todo);
    });

    test('doing mid-cycle', () {
      final result =
          ProgressCalculator.compute(workdayEvent(), DateTime(2026, 1, 7, 13, 0));
      expect(result.status, TaskStatus.doing);
    });

    test('done on a non-applicable day (Saturday), most recent cycle fully elapsed', () {
      // 2026-01-10 is a Saturday.
      final result =
          ProgressCalculator.compute(workdayEvent(), DateTime(2026, 1, 10, 12, 0));
      expect(result.status, TaskStatus.done);
    });
  });
}
