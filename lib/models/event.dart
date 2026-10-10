import 'package:flutter/material.dart';

/// What a single unit (dot or dash) in the grid represents.
enum Granularity { minute, hour, day, week, month, year }

enum RecurrenceFrequency { daily, weekly, monthly, yearly }

enum Weekday { mon, tue, wed, thu, fri, sat, sun }

/// Render style for a grid's units.
enum GridShape { dot, dash }

extension GranularityDuration on Granularity {
  /// Approximate duration of one unit, used for cycle-length math.
  /// Month/year use calendar-aware resolution elsewhere; this is only
  /// used where a fixed duration is safe (minute/hour/day/week).
  Duration get approxDuration {
    switch (this) {
      case Granularity.minute:
        return const Duration(minutes: 1);
      case Granularity.hour:
        return const Duration(hours: 1);
      case Granularity.day:
        return const Duration(days: 1);
      case Granularity.week:
        return const Duration(days: 7);
      case Granularity.month:
        return const Duration(days: 30);
      case Granularity.year:
        return const Duration(days: 365);
    }
  }
}

extension WeekdayFromDateTime on DateTime {
  Weekday get weekday_ => Weekday.values[weekday - 1];
}

class RecurrenceRule {
  const RecurrenceRule({
    required this.frequency,
    this.daysOfWeek,
    this.cycleStartTime,
    this.cycleEndTime,
  });

  final RecurrenceFrequency frequency;

  /// Only meaningful when [frequency] is [RecurrenceFrequency.daily].
  /// e.g. "Workday" = daily, restricted to Mon-Fri.
  final List<Weekday>? daysOfWeek;

  /// Only used for daily/weekly frequencies; the time-of-day bounds of
  /// each occurrence (e.g. 9:00-17:00 for a workday).
  final TimeOfDay? cycleStartTime;
  final TimeOfDay? cycleEndTime;

  RecurrenceRule copyWith({
    RecurrenceFrequency? frequency,
    List<Weekday>? daysOfWeek,
    TimeOfDay? cycleStartTime,
    TimeOfDay? cycleEndTime,
  }) {
    return RecurrenceRule(
      frequency: frequency ?? this.frequency,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      cycleStartTime: cycleStartTime ?? this.cycleStartTime,
      cycleEndTime: cycleEndTime ?? this.cycleEndTime,
    );
  }

  Map<String, dynamic> toJson() => {
        'frequency': frequency.name,
        'daysOfWeek': daysOfWeek?.map((d) => d.name).toList(),
        'cycleStartTimeMinutes': cycleStartTime == null
            ? null
            : cycleStartTime!.hour * 60 + cycleStartTime!.minute,
        'cycleEndTimeMinutes': cycleEndTime == null
            ? null
            : cycleEndTime!.hour * 60 + cycleEndTime!.minute,
      };

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) {
    TimeOfDay? timeFromMinutes(dynamic value) {
      if (value == null) return null;
      final minutes = value as int;
      return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    }

    return RecurrenceRule(
      frequency: RecurrenceFrequency.values
          .byName(json['frequency'] as String),
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
          ?.map((e) => Weekday.values.byName(e as String))
          .toList(),
      cycleStartTime: timeFromMinutes(json['cycleStartTimeMinutes']),
      cycleEndTime: timeFromMinutes(json['cycleEndTimeMinutes']),
    );
  }
}

/// A trackable span of time rendered as a dot/dash grid.
///
/// Covers both the built-in views (Today/This Month/This Year/My Life,
/// seeded as [isBuiltIn] events) and user-created custom events, either
/// one-time ([isRecurring] == false, using [startDate]/[endDate]) or
/// recurring ([isRecurring] == true, using [recurrence]).
class Event {
  const Event({
    required this.id,
    required this.title,
    required this.color,
    this.icon,
    this.isBuiltIn = false,
    required this.isRecurring,
    required this.granularity,
    required this.shape,
    this.recurrence,
    this.startDate,
    this.endDate,
    this.remindersEnabled = false,
    this.reminderTime,
    this.reminderDateTime,
    this.reminderRepeatFrequency,
    this.tag,
    this.groupName,
    this.updatedAt,
    this.deletedAt,
  }) : assert(
          isRecurring ? recurrence != null : startDate != null,
          'Recurring events need a recurrence rule; one-time events need a startDate.',
        );

  final String id;
  final String title;
  final Color color;
  final IconData? icon;
  final bool isBuiltIn;
  final bool isRecurring;
  final Granularity granularity;
  final GridShape shape;

  final RecurrenceRule? recurrence;

  final DateTime? startDate;
  final DateTime? endDate;

  /// Opt-in, off by default: whether a local notification should fire
  /// for this event. See lib/notifications/notification_scheduler.dart.
  final bool remindersEnabled;

  /// Time of day the reminder fires. For a recurring event, every cycle
  /// (on the cycle's start date) - e.g. a Workday cycle can start at 9:00
  /// with the reminder set for 8:45. For a one-time event, only used when
  /// [reminderRepeatFrequency] is set (repeating mode); ignored in
  /// one-shot mode, where [reminderDateTime] carries both the date and
  /// time.
  final TimeOfDay? reminderTime;

  /// One-time events in one-shot mode only ([reminderRepeatFrequency] is
  /// null): the exact date/time the single reminder fires - independent
  /// of [startDate]/[endDate] so it can be set to whatever moment is
  /// actually useful to be reminded at. Ignored for recurring events and
  /// for one-time events in repeating mode.
  final DateTime? reminderDateTime;

  /// One-time events only: when set, the reminder repeats at this
  /// frequency (at [reminderTime] each occurrence) instead of firing once
  /// at [reminderDateTime] - e.g. a daily nudge counting down to the
  /// event. Stops once [startDate] passes. Null means one-shot mode
  /// (the default). Ignored for recurring events, which are always
  /// "repeating" by virtue of the event itself recurring.
  final RecurrenceFrequency? reminderRepeatFrequency;

  /// Single free-form category label (e.g. "Work", "Home"). Null means
  /// untagged. One per event, not a multi-label set - see the home
  /// screen's tag filter for how this is used to organize events.
  final String? tag;

  /// Optional parent group name (e.g. "Q1 Goals") - purely organizational,
  /// unlike [tag]: it's how the home screen decides which events to
  /// collapse together under a shared, tappable header, for when many
  /// events would otherwise clutter the list. Null means ungrouped (shown
  /// individually, same as before groups existed). Named "groupName" -
  /// not "group" - because that's a reserved word in the SQL used for
  /// sync (see supabase/schema.sql).
  final String? groupName;

  /// Sync/conflict-resolution bookkeeping, not user-facing. Null means
  /// "not yet persisted" - [DriftEventRepository.upsert] always stamps the
  /// current time on a normal save; only the sync engine writes an exact
  /// value here (preserving a remote row's timestamp for last-write-wins).
  final DateTime? updatedAt;

  /// Soft-delete tombstone: non-null means this event was deleted. Kept
  /// (not hard-deleted) so the deletion can propagate to other synced
  /// devices instead of silently vanishing when they eventually pull.
  final DateTime? deletedAt;

  /// The default assumed span (in years) for a one-time event left
  /// without an end date at creation (mirrors how "My Life" assumes a
  /// life expectancy).
  static const int defaultOneTimeSpanYears = 50;

  /// Calendar-aware default end date for a one-time event with no
  /// explicit [endDate]. Uses calendar year addition rather than a fixed
  /// `Duration` in days, since a duration-based approximation drifts
  /// against real calendar years (leap days accumulate: 50 duration-years
  /// of 365 days lands ~13 days short of 50 actual calendar years).
  static DateTime defaultEndDate(DateTime start) {
    return DateTime(
      start.year + defaultOneTimeSpanYears,
      start.month,
      start.day,
      start.hour,
      start.minute,
    );
  }

  /// Picks a sensible default [GridShape] for a new event: continuous
  /// recurring events with a sub-day granularity read better as a filling
  /// bar (dash); everything else reads better as discrete countable units
  /// (dot).
  static GridShape defaultShapeFor({
    required bool isRecurring,
    required Granularity granularity,
  }) {
    final isSubDay =
        granularity == Granularity.minute || granularity == Granularity.hour;
    return (isRecurring && isSubDay) ? GridShape.dash : GridShape.dot;
  }

  Event copyWith({
    String? id,
    String? title,
    Color? color,
    IconData? icon,
    bool? isBuiltIn,
    bool? isRecurring,
    Granularity? granularity,
    GridShape? shape,
    RecurrenceRule? recurrence,
    DateTime? startDate,
    DateTime? endDate,
    bool? remindersEnabled,
    TimeOfDay? reminderTime,
    DateTime? reminderDateTime,
    RecurrenceFrequency? reminderRepeatFrequency,
    String? tag,
    String? groupName,
    bool clearGroupName = false,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      isRecurring: isRecurring ?? this.isRecurring,
      granularity: granularity ?? this.granularity,
      shape: shape ?? this.shape,
      recurrence: recurrence ?? this.recurrence,
      startDate: startDate ?? this.startDate,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      reminderRepeatFrequency:
          reminderRepeatFrequency ?? this.reminderRepeatFrequency,
      tag: tag ?? this.tag,
      groupName: clearGroupName ? null : (groupName ?? this.groupName),
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      endDate: endDate ?? this.endDate,
    );
  }
}
