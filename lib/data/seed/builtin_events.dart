import 'package:flutter/material.dart';

import '../../models/event.dart';
import '../repositories/event_repository.dart';

class BuiltInEventIds {
  const BuiltInEventIds._();

  static const today = 'builtin_today';
  static const week = 'builtin_week';
  static const month = 'builtin_month';
  static const year = 'builtin_year';
  static const life = 'builtin_life';

  static const core = [today, week, month, year];
}

/// The four built-ins that need no user configuration. Fixed ids + fully
/// static fields, so upserting them is idempotent - safe to call on every
/// app launch without first checking whether they already exist. All
/// tagged "system" so they read as distinct from user-created events (and
/// so the tag filter row can single them out) - see
/// lib/state/providers/settings_provider.dart's hiddenBuiltInEventIds for
/// how a user hides individual ones instead of deleting them outright
/// (which isn't offered for built-ins at all).
List<Event> coreBuiltInEvents() {
  return [
    Event(
      id: BuiltInEventIds.today,
      title: 'Today',
      color: const Color(0xFF2196F3),
      icon: Icons.today,
      isBuiltIn: true,
      isRecurring: true,
      granularity: Granularity.hour,
      shape: GridShape.dash,
      recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
      tag: 'system',
    ),
    Event(
      id: BuiltInEventIds.week,
      title: 'This Week',
      color: const Color(0xFF00BCD4),
      icon: Icons.view_week,
      isBuiltIn: true,
      isRecurring: true,
      granularity: Granularity.day,
      shape: GridShape.dot,
      recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.weekly),
      tag: 'system',
    ),
    Event(
      id: BuiltInEventIds.month,
      title: 'This Month',
      color: const Color(0xFF9C27B0),
      icon: Icons.calendar_view_month,
      isBuiltIn: true,
      isRecurring: true,
      granularity: Granularity.day,
      shape: GridShape.dot,
      recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.monthly),
      tag: 'system',
    ),
    Event(
      id: BuiltInEventIds.year,
      title: 'This Year',
      color: const Color(0xFF4CAF50),
      icon: Icons.calendar_today,
      isBuiltIn: true,
      isRecurring: true,
      granularity: Granularity.day,
      shape: GridShape.dot,
      recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.yearly),
      tag: 'system',
    ),
  ];
}

/// Builds the "My Life" built-in from the user's settings. Only meaningful
/// once a birthdate is set (see SettingsProvider); until then the Home
/// screen shows an empty-state prompt instead of seeding this event.
Event lifeEvent({
  required DateTime birthDate,
  required int lifeExpectancyYears,
}) {
  return Event(
    id: BuiltInEventIds.life,
    title: 'My Life',
    color: const Color(0xFFFF9800),
    icon: Icons.favorite,
    isBuiltIn: true,
    isRecurring: false,
    granularity: Granularity.month,
    shape: GridShape.dot,
    startDate: birthDate,
    endDate: DateTime(
      birthDate.year + lifeExpectancyYears,
      birthDate.month,
      birthDate.day,
    ),
  );
}

Future<void> seedCoreBuiltIns(EventRepository repo) async {
  for (final event in coreBuiltInEvents()) {
    await repo.upsert(event);
  }
}
