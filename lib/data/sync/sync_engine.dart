import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/event.dart';
import '../../models/event_group.dart';
import '../repositories/event_repository.dart';
import '../repositories/group_repository.dart';

/// Two-way sync between the local [EventRepository]/[GroupRepository]
/// (source of truth for the UI) and Supabase `events`/`groups` tables (see
/// supabase/schema.sql), scoped to one signed-in user.
///
/// Conflict resolution is last-write-wins by `updatedAt`. [_lastSyncedUpdatedAt]
/// doubles as both "what have we already pushed" and "what have we already
/// pulled" bookkeeping: after either a push or a pull for a given event id,
/// its entry is set to that event's updatedAt, so the *other* direction's
/// listener sees no diff for that id and doesn't re-send it - this is what
/// prevents push/pull feedback loops without any special-casing. Groups use
/// the same bookkeeping, keyed by group name instead of event id (see
/// [_lastSyncedGroupUpdatedAt]).
class SyncEngine {
  SyncEngine({
    required this.localRepo,
    required this.localGroupRepo,
    required this.userId,
  }) : _client = Supabase.instance.client;

  final EventRepository localRepo;
  final GroupRepository localGroupRepo;
  final String userId;
  final SupabaseClient _client;

  final Map<String, DateTime> _lastSyncedUpdatedAt = {};
  final Map<String, DateTime> _lastSyncedGroupUpdatedAt = {};

  StreamSubscription<List<Event>>? _localSub;
  StreamSubscription<List<Map<String, dynamic>>>? _remoteSub;
  StreamSubscription<List<EventGroup>>? _localGroupSub;
  StreamSubscription<List<Map<String, dynamic>>>? _remoteGroupSub;

  Future<void> start() async {
    await _initialSync();
    await _initialGroupSync();
    _localSub = localRepo.watchAllIncludingDeleted().listen(_onLocalChange);
    _remoteSub = _client
        .from('events')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen(_onRemoteChange);
    _localGroupSub =
        localGroupRepo.watchAllIncludingDeleted().listen(_onLocalGroupChange);
    _remoteGroupSub = _client
        .from('groups')
        .stream(primaryKey: ['user_id', 'name'])
        .eq('user_id', userId)
        .listen(_onRemoteGroupChange);
  }

  void dispose() {
    _localSub?.cancel();
    _remoteSub?.cancel();
    _localGroupSub?.cancel();
    _remoteGroupSub?.cancel();
  }

  Future<void> _initialSync() async {
    final remoteRows = await _client.from('events').select().eq(
          'user_id',
          userId,
        );
    final remoteEvents = remoteRows.map(_rowToEvent).toList();
    final localEvents = await localRepo.watchAllIncludingDeleted().first;
    final localById = {for (final e in localEvents) e.id: e};

    for (final remote in remoteEvents) {
      final local = localById[remote.id];
      final remoteIsNewer =
          local == null || remote.updatedAt!.isAfter(local.updatedAt!);
      if (remoteIsNewer) {
        await localRepo.upsertRaw(remote);
      }
      _lastSyncedUpdatedAt[remote.id] = remote.updatedAt!;
    }

    for (final local in localEvents) {
      if (_lastSyncedUpdatedAt[local.id] != local.updatedAt) {
        await _pushEvent(local);
      }
    }
  }

  Future<void> _onLocalChange(List<Event> events) async {
    for (final event in events) {
      if (_lastSyncedUpdatedAt[event.id] != event.updatedAt) {
        await _pushEvent(event);
      }
    }
  }

  Future<void> _onRemoteChange(List<Map<String, dynamic>> rows) async {
    for (final row in rows) {
      final remote = _rowToEvent(row);
      if (_lastSyncedUpdatedAt[remote.id] == remote.updatedAt) {
        continue; // echo of our own push, or already applied.
      }
      _lastSyncedUpdatedAt[remote.id] = remote.updatedAt!;
      await localRepo.upsertRaw(remote);
    }
  }

  Future<void> _pushEvent(Event event) async {
    await _client.from('events').upsert(_eventToRow(event, userId));
    _lastSyncedUpdatedAt[event.id] = event.updatedAt!;
  }

  Future<void> _initialGroupSync() async {
    final remoteRows =
        await _client.from('groups').select().eq('user_id', userId);
    final remoteGroups = remoteRows.map(_rowToGroup).toList();
    final localGroups = await localGroupRepo.watchAllIncludingDeleted().first;
    final localByName = {for (final g in localGroups) g.name: g};

    for (final remote in remoteGroups) {
      final local = localByName[remote.name];
      final remoteIsNewer =
          local == null || remote.updatedAt!.isAfter(local.updatedAt!);
      if (remoteIsNewer) {
        await localGroupRepo.upsertRaw(remote);
      }
      _lastSyncedGroupUpdatedAt[remote.name] = remote.updatedAt!;
    }

    for (final local in localGroups) {
      if (_lastSyncedGroupUpdatedAt[local.name] != local.updatedAt) {
        await _pushGroup(local);
      }
    }
  }

  Future<void> _onLocalGroupChange(List<EventGroup> groups) async {
    for (final group in groups) {
      if (_lastSyncedGroupUpdatedAt[group.name] != group.updatedAt) {
        await _pushGroup(group);
      }
    }
  }

  Future<void> _onRemoteGroupChange(List<Map<String, dynamic>> rows) async {
    for (final row in rows) {
      final remote = _rowToGroup(row);
      if (_lastSyncedGroupUpdatedAt[remote.name] == remote.updatedAt) {
        continue; // echo of our own push, or already applied.
      }
      _lastSyncedGroupUpdatedAt[remote.name] = remote.updatedAt!;
      await localGroupRepo.upsertRaw(remote);
    }
  }

  Future<void> _pushGroup(EventGroup group) async {
    await _client.from('groups').upsert(_groupToRow(group, userId));
    _lastSyncedGroupUpdatedAt[group.name] = group.updatedAt!;
  }

  static EventGroup _rowToGroup(Map<String, dynamic> row) {
    return EventGroup(
      name: row['name'] as String,
      icon: row['icon_code_point'] == null
          ? null
          : IconData(row['icon_code_point'] as int, fontFamily: 'MaterialIcons'),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      deletedAt: (row['deleted_at'] as String?)?.let(DateTime.parse),
    );
  }

  static Map<String, dynamic> _groupToRow(EventGroup group, String userId) {
    return {
      'name': group.name,
      'user_id': userId,
      'icon_code_point': group.icon?.codePoint,
      'updated_at': group.updatedAt!.toIso8601String(),
      'deleted_at': group.deletedAt?.toIso8601String(),
    };
  }

  static Event _rowToEvent(Map<String, dynamic> row) {
    final isRecurring = row['is_recurring'] as bool;
    final recurrence = isRecurring
        ? RecurrenceRule(
            frequency: RecurrenceFrequency.values.byName(
              row['recurrence_frequency'] as String,
            ),
            daysOfWeek: (row['recurrence_days_of_week'] as String?)
                ?.let((s) => s.isEmpty
                    ? null
                    : s.split(',').map((e) => Weekday.values.byName(e)).toList()),
            cycleStartTime: _minutesToTimeOfDay(
              row['recurrence_cycle_start_minutes'] as int?,
            ),
            cycleEndTime: _minutesToTimeOfDay(
              row['recurrence_cycle_end_minutes'] as int?,
            ),
          )
        : null;

    return Event(
      id: row['id'] as String,
      title: row['title'] as String,
      color: Color(row['color_value'] as int),
      icon: row['icon_code_point'] == null
          ? null
          : IconData(row['icon_code_point'] as int, fontFamily: 'MaterialIcons'),
      isBuiltIn: row['is_built_in'] as bool,
      isRecurring: isRecurring,
      granularity: Granularity.values.byName(row['granularity'] as String),
      shape: GridShape.values.byName(row['shape'] as String),
      recurrence: recurrence,
      startDate: (row['start_date'] as String?)?.let(DateTime.parse),
      endDate: (row['end_date'] as String?)?.let(DateTime.parse),
      remindersEnabled: row['reminders_enabled'] as bool? ?? false,
      reminderTime: _minutesToTimeOfDay(row['reminder_time_minutes'] as int?),
      reminderDateTime:
          (row['reminder_date_time'] as String?)?.let(DateTime.parse),
      reminderRepeatFrequency: (row['reminder_repeat_frequency'] as String?)
          ?.let((s) => RecurrenceFrequency.values.byName(s)),
      tag: row['tag'] as String?,
      groupName: row['group_name'] as String?,
      updatedAt: DateTime.parse(row['updated_at'] as String),
      deletedAt: (row['deleted_at'] as String?)?.let(DateTime.parse),
    );
  }

  static Map<String, dynamic> _eventToRow(Event event, String userId) {
    final recurrence = event.recurrence;
    return {
      'id': event.id,
      'user_id': userId,
      'title': event.title,
      'color_value': event.color.toARGB32(),
      'icon_code_point': event.icon?.codePoint,
      'is_built_in': event.isBuiltIn,
      'is_recurring': event.isRecurring,
      'granularity': event.granularity.name,
      'shape': event.shape.name,
      'recurrence_frequency': recurrence?.frequency.name,
      'recurrence_days_of_week':
          recurrence?.daysOfWeek?.map((d) => d.name).join(','),
      'recurrence_cycle_start_minutes':
          _timeOfDayToMinutes(recurrence?.cycleStartTime),
      'recurrence_cycle_end_minutes':
          _timeOfDayToMinutes(recurrence?.cycleEndTime),
      'start_date': event.startDate?.toIso8601String(),
      'end_date': event.endDate?.toIso8601String(),
      'reminders_enabled': event.remindersEnabled,
      'reminder_time_minutes': _timeOfDayToMinutes(event.reminderTime),
      'reminder_date_time': event.reminderDateTime?.toIso8601String(),
      'reminder_repeat_frequency': event.reminderRepeatFrequency?.name,
      'tag': event.tag,
      'group_name': event.groupName,
      'updated_at': event.updatedAt!.toIso8601String(),
      'deleted_at': event.deletedAt?.toIso8601String(),
    };
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

extension _Let<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
