import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../../models/event.dart';
import '../persistence/database.dart';
import 'event_repository.dart';

class DriftEventRepository implements EventRepository {
  DriftEventRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Event>> watchAll() {
    final query = _db.select(_db.events)
      ..where((t) => t.deletedAt.isNull());
    return query.watch().map(
          (rows) => rows.map(_rowToEvent).toList(growable: false),
        );
  }

  @override
  Stream<List<Event>> watchAllIncludingDeleted() {
    return _db.select(_db.events).watch().map(
          (rows) => rows.map(_rowToEvent).toList(growable: false),
        );
  }

  @override
  Future<void> upsert(Event event) {
    final companion = _eventToCompanion(event, updatedAt: DateTime.now());
    return _db.into(_db.events).insertOnConflictUpdate(companion);
  }

  @override
  Future<void> upsertRaw(Event event) {
    final companion = _eventToCompanion(event, updatedAt: event.updatedAt);
    return _db.into(_db.events).insertOnConflictUpdate(companion);
  }

  @override
  Future<void> delete(String id) {
    final now = DateTime.now();
    return (_db.update(_db.events)..where((t) => t.id.equals(id))).write(
      EventsCompanion(updatedAt: Value(now), deletedAt: Value(now)),
    );
  }

  static Event _rowToEvent(EventRow row) {
    final recurrence = row.isRecurring
        ? RecurrenceRule(
            frequency: RecurrenceFrequency.values.byName(row.recurrenceFrequency!),
            daysOfWeek: (row.recurrenceDaysOfWeek == null ||
                    row.recurrenceDaysOfWeek!.isEmpty)
                ? null
                : row.recurrenceDaysOfWeek!
                    .split(',')
                    .map((e) => Weekday.values.byName(e))
                    .toList(),
            cycleStartTime: _minutesToTimeOfDay(row.recurrenceCycleStartMinutes),
            cycleEndTime: _minutesToTimeOfDay(row.recurrenceCycleEndMinutes),
          )
        : null;

    return Event(
      id: row.id,
      title: row.title,
      color: Color(row.colorValue),
      icon: row.iconCodePoint == null
          ? null
          : IconData(row.iconCodePoint!, fontFamily: 'MaterialIcons'),
      isBuiltIn: row.isBuiltIn,
      isRecurring: row.isRecurring,
      granularity: Granularity.values.byName(row.granularity),
      shape: GridShape.values.byName(row.shape),
      recurrence: recurrence,
      startDate: row.startDate,
      endDate: row.endDate,
      remindersEnabled: row.remindersEnabled,
      reminderTime: _minutesToTimeOfDay(row.reminderTimeMinutes),
      reminderDateTime: row.reminderDateTime,
      reminderRepeatFrequency: row.reminderRepeatFrequency == null
          ? null
          : RecurrenceFrequency.values.byName(row.reminderRepeatFrequency!),
      tag: row.tag,
      groupName: row.groupName,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  /// [updatedAt] is threaded in separately (rather than always reading
  /// `event.updatedAt`) so [upsert] can stamp "now" and [upsertRaw] can
  /// preserve an exact value from the sync engine, off the same builder.
  static EventsCompanion _eventToCompanion(Event event, {DateTime? updatedAt}) {
    final recurrence = event.recurrence;
    return EventsCompanion.insert(
      id: event.id,
      title: event.title,
      colorValue: event.color.toARGB32(),
      iconCodePoint: Value(event.icon?.codePoint),
      isBuiltIn: Value(event.isBuiltIn),
      isRecurring: event.isRecurring,
      granularity: event.granularity.name,
      shape: event.shape.name,
      recurrenceFrequency: Value(recurrence?.frequency.name),
      recurrenceDaysOfWeek:
          Value(recurrence?.daysOfWeek?.map((d) => d.name).join(',')),
      recurrenceCycleStartMinutes:
          Value(_timeOfDayToMinutes(recurrence?.cycleStartTime)),
      recurrenceCycleEndMinutes:
          Value(_timeOfDayToMinutes(recurrence?.cycleEndTime)),
      startDate: Value(event.startDate),
      endDate: Value(event.endDate),
      remindersEnabled: Value(event.remindersEnabled),
      reminderTimeMinutes: Value(_timeOfDayToMinutes(event.reminderTime)),
      reminderDateTime: Value(event.reminderDateTime),
      reminderRepeatFrequency: Value(event.reminderRepeatFrequency?.name),
      tag: Value(event.tag),
      groupName: Value(event.groupName),
      updatedAt: updatedAt == null ? const Value.absent() : Value(updatedAt),
      deletedAt: Value(event.deletedAt),
    );
  }

  static TimeOfDay? _minutesToTimeOfDay(int? minutes) {
    if (minutes == null) return null;
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  static int? _timeOfDayToMinutes(TimeOfDay? time) {
    if (time == null) return null;
    return time.hour * 60 + time.minute;
  }
}
