import 'package:flutter/material.dart';

import '../models/event.dart';
import 'quick_add_parser.dart';

/// A one-tap starting point for a new event (shown in the Chrome
/// extension's quick-add sheet).
class EventTemplate {
  const EventTemplate({
    required this.label,
    required this.icon,
    required this.color,
    required this.build,
  });

  final String label;
  final IconData icon;
  final Color color;

  /// Builds the event for a given moment in time. [id] is the new event's
  /// id; [now] anchors "next ..." dates.
  final Event Function(String id, DateTime now) build;
}

/// Next [month]/[day] strictly after [now]'s date, at midnight.
DateTime nextAnnual(int month, int day, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final thisYear = DateTime(now.year, month, day);
  return thisYear.isAfter(today) ? thisYear : DateTime(now.year + 1, month, day);
}

/// Next [weekday] (DateTime.monday...) at [hour] o'clock that is still
/// ahead of [now] - today if that time hasn't passed yet, else next week.
DateTime nextWeekdayAt(int weekday, int hour, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  var ahead = (weekday - today.weekday) % 7;
  var candidate = DateTime(today.year, today.month, today.day + ahead, hour);
  if (!candidate.isAfter(now)) {
    ahead += 7;
    candidate = DateTime(today.year, today.month, today.day + ahead, hour);
  }
  return candidate;
}

/// A one-time countdown from now to [end].
Event countdownEvent({
  required String id,
  required String title,
  required Color color,
  required IconData icon,
  required DateTime now,
  required DateTime end,
}) {
  final start = DateTime(now.year, now.month, now.day, now.hour, now.minute);
  return Event(
    id: id,
    title: title,
    color: color,
    icon: icon,
    isRecurring: false,
    granularity: granularityForSpan(start, end),
    shape: GridShape.dot,
    startDate: start,
    endDate: end,
  );
}

EventTemplate _countdownTemplate({
  required String label,
  required String title,
  required IconData icon,
  required Color color,
  required DateTime Function(DateTime now) end,
}) {
  return EventTemplate(
    label: label,
    icon: icon,
    color: color,
    build: (id, now) => countdownEvent(
      id: id,
      title: title,
      color: color,
      icon: icon,
      now: now,
      end: end(now),
    ),
  );
}

final List<EventTemplate> eventTemplates = [
  EventTemplate(
    label: 'Workday',
    icon: Icons.work_outline,
    color: const Color(0xFF3F51B5),
    build: (id, now) => Event(
      id: id,
      title: 'Workday',
      color: const Color(0xFF3F51B5),
      icon: Icons.work_outline,
      isRecurring: true,
      granularity: Granularity.hour,
      shape: GridShape.dash,
      recurrence: const RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        daysOfWeek: [
          Weekday.mon,
          Weekday.tue,
          Weekday.wed,
          Weekday.thu,
          Weekday.fri,
        ],
        cycleStartTime: TimeOfDay(hour: 9, minute: 0),
        cycleEndTime: TimeOfDay(hour: 17, minute: 0),
      ),
    ),
  ),
  _countdownTemplate(
    label: 'Weekend',
    title: 'Weekend',
    icon: Icons.weekend_outlined,
    color: const Color(0xFF009688),
    end: (now) => nextWeekdayAt(DateTime.saturday, 0, now),
  ),
  _countdownTemplate(
    label: 'Friday 5pm',
    title: 'End of work week',
    icon: Icons.celebration_outlined,
    color: const Color(0xFFFF7043),
    end: (now) => nextWeekdayAt(DateTime.friday, 17, now),
  ),
  _countdownTemplate(
    label: 'New Year',
    title: 'New Year',
    icon: Icons.auto_awesome,
    color: const Color(0xFF7E57C2),
    end: (now) => nextAnnual(1, 1, now),
  ),
  _countdownTemplate(
    label: 'Christmas',
    title: 'Christmas',
    icon: Icons.park_outlined,
    color: const Color(0xFFE53935),
    end: (now) => nextAnnual(12, 25, now),
  ),
  _countdownTemplate(
    label: "Valentine's Day",
    title: "Valentine's Day",
    icon: Icons.favorite_border,
    color: const Color(0xFFEC407A),
    end: (now) => nextAnnual(2, 14, now),
  ),
  _countdownTemplate(
    label: 'Halloween',
    title: 'Halloween',
    icon: Icons.nightlight_outlined,
    color: const Color(0xFFFB8C00),
    end: (now) => nextAnnual(10, 31, now),
  ),
];

/// Colors cycled through for events made from quick-add text, chosen by a
/// hash of the title so the same text keeps the same color.
const quickAddPalette = [
  Color(0xFF2196F3),
  Color(0xFF9C27B0),
  Color(0xFF4CAF50),
  Color(0xFFFF9800),
  Color(0xFFE91E63),
  Color(0xFF00BCD4),
];

Event eventFromQuickAdd(String id, QuickAddResult result, DateTime now) {
  return countdownEvent(
    id: id,
    title: result.title,
    color: quickAddPalette[result.title.hashCode.abs() % quickAddPalette.length],
    icon: Icons.timer_outlined,
    now: now,
    end: result.target,
  );
}
