import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../../models/event_group.dart';
import '../persistence/database.dart';
import 'group_repository.dart';

class DriftGroupRepository implements GroupRepository {
  DriftGroupRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<EventGroup>> watchAll() {
    final query = _db.select(_db.groups)..where((t) => t.deletedAt.isNull());
    return query.watch().map(
          (rows) => rows.map(_rowToGroup).toList(growable: false),
        );
  }

  @override
  Stream<List<EventGroup>> watchAllIncludingDeleted() {
    return _db.select(_db.groups).watch().map(
          (rows) => rows.map(_rowToGroup).toList(growable: false),
        );
  }

  @override
  Future<void> upsert(EventGroup group) {
    final companion = _groupToCompanion(group, updatedAt: DateTime.now());
    return _db.into(_db.groups).insertOnConflictUpdate(companion);
  }

  @override
  Future<void> upsertRaw(EventGroup group) {
    final companion = _groupToCompanion(group, updatedAt: group.updatedAt);
    return _db.into(_db.groups).insertOnConflictUpdate(companion);
  }

  @override
  Future<void> ensureExists(String name) {
    return _db.into(_db.groups).insert(
          GroupsCompanion.insert(name: name),
          mode: InsertMode.insertOrIgnore,
        );
  }

  @override
  Future<void> delete(String name) {
    final now = DateTime.now();
    return (_db.update(_db.groups)..where((t) => t.name.equals(name))).write(
      GroupsCompanion(updatedAt: Value(now), deletedAt: Value(now)),
    );
  }

  static EventGroup _rowToGroup(GroupRow row) {
    return EventGroup(
      name: row.name,
      icon: row.iconCodePoint == null
          ? null
          : IconData(row.iconCodePoint!, fontFamily: 'MaterialIcons'),
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  static GroupsCompanion _groupToCompanion(
    EventGroup group, {
    DateTime? updatedAt,
  }) {
    return GroupsCompanion.insert(
      name: group.name,
      iconCodePoint: Value(group.icon?.codePoint),
      updatedAt: updatedAt == null ? const Value.absent() : Value(updatedAt),
      deletedAt: Value(group.deletedAt),
    );
  }
}
