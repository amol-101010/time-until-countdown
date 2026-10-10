import '../models/event.dart';

/// The resolved time span of one occurrence (a "cycle") of a recurring
/// event, or the whole span of a one-time event.
class Cycle {
  const Cycle(this.start, this.end);

  final DateTime start;
  final DateTime end;
}

/// An event's status relative to "now", derived purely from its start/end
/// times - never stored, since it would just drift out of sync with the
/// clock. [doing] covers a recurring event's current cycle too: e.g. a
/// "Workday" rule reads [done] on a Saturday (Friday's cycle fully
/// elapsed, Monday's hasn't started) even though the event itself keeps
/// recurring.
enum TaskStatus { todo, doing, done }

/// The result of measuring an [Event]'s progress at a point in time.
class ProgressResult {
  const ProgressResult({
    required this.filled,
    required this.total,
    required this.cycleStart,
    required this.cycleEnd,
    required this.status,
  });

  /// Whole units elapsed since [cycleStart], clamped to [0, total].
  final int filled;

  /// Total whole units between [cycleStart] and [cycleEnd].
  final int total;

  final DateTime cycleStart;
  final DateTime cycleEnd;

  final TaskStatus status;

  /// 0.0-1.0 progress through the span. 0 when [total] is 0.
  double get fraction => total == 0 ? 0.0 : (filled / total).clamp(0.0, 1.0);
}

/// Pure functions computing an [Event]'s dot/dash-grid progress. No
/// widget or persistence dependencies, so this is fully unit-testable.
class ProgressCalculator {
  const ProgressCalculator._();

  static ProgressResult compute(Event event, DateTime now) {
    final cycle = event.isRecurring
        ? resolveCycle(event.recurrence!, now)
        : Cycle(
            event.startDate!,
            event.endDate ?? Event.defaultEndDate(event.startDate!),
          );

    final total = unitsBetween(cycle.start, cycle.end, event.granularity);
    final elapsed = unitsBetween(cycle.start, now, event.granularity);
    final filled = elapsed.clamp(0, total);

    final TaskStatus status;
    if (now.isBefore(cycle.start)) {
      status = TaskStatus.todo;
    } else if (!now.isBefore(cycle.end)) {
      status = TaskStatus.done;
    } else {
      status = TaskStatus.doing;
    }

    return ProgressResult(
      filled: filled,
      total: total,
      cycleStart: cycle.start,
      cycleEnd: cycle.end,
      status: status,
    );
  }

  /// Resolves the current occurrence's [start, end) span for a recurring
  /// rule, relative to [now]:
  /// - daily: today (or, if [RecurrenceRule.daysOfWeek] is set, the most
  ///   recent applicable weekday), bounded by cycleStartTime/cycleEndTime
  ///   (defaulting to the full calendar day).
  /// - weekly: the current ISO week (Monday-Sunday).
  /// - monthly: the current calendar month.
  /// - yearly: the current calendar year.
  static Cycle resolveCycle(RecurrenceRule rule, DateTime now) {
    switch (rule.frequency) {
      case RecurrenceFrequency.daily:
        return _resolveDailyCycle(rule, now);
      case RecurrenceFrequency.weekly:
        return _resolveWeeklyCycle(now);
      case RecurrenceFrequency.monthly:
        return _resolveMonthlyCycle(now);
      case RecurrenceFrequency.yearly:
        return _resolveYearlyCycle(now);
    }
  }

  static Cycle _resolveDailyCycle(RecurrenceRule rule, DateTime now) {
    var candidateDate = DateTime(now.year, now.month, now.day);
    final days = rule.daysOfWeek;

    if (days != null && days.isNotEmpty) {
      var found = false;
      for (var i = 0; i < 7; i++) {
        final d = candidateDate.subtract(Duration(days: i));
        if (days.contains(d.weekday_)) {
          candidateDate = d;
          found = true;
          break;
        }
      }
      if (!found) {
        // No applicable weekday in the last 7 days (malformed rule) -
        // fall back to today rather than looping forever.
        candidateDate = DateTime(now.year, now.month, now.day);
      }
    }

    return _dailyCycleForDate(rule, candidateDate);
  }

  static Cycle _dailyCycleForDate(RecurrenceRule rule, DateTime candidateDate) {
    final start = rule.cycleStartTime == null
        ? candidateDate
        : DateTime(
            candidateDate.year,
            candidateDate.month,
            candidateDate.day,
            rule.cycleStartTime!.hour,
            rule.cycleStartTime!.minute,
          );
    final end = rule.cycleEndTime == null
        ? candidateDate.add(const Duration(days: 1))
        : DateTime(
            candidateDate.year,
            candidateDate.month,
            candidateDate.day,
            rule.cycleEndTime!.hour,
            rule.cycleEndTime!.minute,
          );

    return Cycle(start, end);
  }

  /// The next cycle strictly after [current] - i.e. "when does this
  /// recurring event next start", used by the notification scheduler to
  /// queue the following reminder once one fires.
  ///
  /// Deliberately separate from [resolveCycle]: that method answers "what
  /// cycle contains this instant" (for progress display, where a `daily`
  /// event with a same-day time window like Workday 9:00-17:00 should
  /// keep showing *today's* cycle, or the most recent one, over a
  /// weekend). Reusing it here would be wrong - passing `current.end` as
  /// `now` for a same-day window lands back on the same calendar day (or,
  /// for a weekday-only rule checked on a non-applicable day, searches
  /// *backward* to the most recent applicable day instead of forward to
  /// the next one).
  static Cycle nextCycleAfter(RecurrenceRule rule, Cycle current) {
    if (rule.frequency != RecurrenceFrequency.daily) {
      // weekly/monthly/yearly: current.end is already the first instant
      // of the next period, so resolving "now" at that instant correctly
      // advances - no same-day ambiguity like the daily case has.
      return resolveCycle(rule, current.end);
    }

    var candidateDate = DateTime(
      current.start.year,
      current.start.month,
      current.start.day,
    ).add(const Duration(days: 1));

    final days = rule.daysOfWeek;
    if (days != null && days.isNotEmpty) {
      for (var i = 0; i < 7; i++) {
        if (days.contains(candidateDate.weekday_)) break;
        candidateDate = candidateDate.add(const Duration(days: 1));
      }
    }

    return _dailyCycleForDate(rule, candidateDate);
  }

  static Cycle _resolveWeeklyCycle(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: today.weekday - 1));
    return Cycle(start, start.add(const Duration(days: 7)));
  }

  static Cycle _resolveMonthlyCycle(DateTime now) {
    return Cycle(
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month + 1, 1),
    );
  }

  static Cycle _resolveYearlyCycle(DateTime now) {
    return Cycle(DateTime(now.year, 1, 1), DateTime(now.year + 1, 1, 1));
  }

  /// Whole units of [granularity] between [start] and [end]. Returns 0 if
  /// [end] is not after [start] (covers "now" before a future one-time
  /// event's start, i.e. a not-yet-started countdown).
  ///
  /// minute/hour/week use real elapsed duration (correctly reflecting DST
  /// shifts, since [DateTime.difference] is based on the underlying
  /// timestamp); month/year use calendar-aware whole-unit counting so a
  /// 50-year span isn't distorted by fixed 365-day-year assumptions.
  static int unitsBetween(DateTime start, DateTime end, Granularity granularity) {
    if (!end.isAfter(start)) return 0;
    switch (granularity) {
      case Granularity.minute:
        return end.difference(start).inMinutes;
      case Granularity.hour:
        return end.difference(start).inHours;
      case Granularity.day:
        return end.difference(start).inDays;
      case Granularity.week:
        return end.difference(start).inDays ~/ 7;
      case Granularity.month:
        return _monthsBetween(start, end);
      case Granularity.year:
        return _monthsBetween(start, end) ~/ 12;
    }
  }

  static int _monthsBetween(DateTime start, DateTime end) {
    var months = (end.year - start.year) * 12 + (end.month - start.month);
    if (end.day < start.day) months -= 1;
    return months < 0 ? 0 : months;
  }
}
