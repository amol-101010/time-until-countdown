import '../../models/event_group.dart';

/// Storage-agnostic interface for reading/writing [EventGroup]s - mirrors
/// [EventRepository]'s shape (and the same sync/tombstone reasoning) so
/// the sync engine can treat groups the same way it treats events.
abstract class GroupRepository {
  /// Live, non-deleted groups.
  Stream<List<EventGroup>> watchAll();

  /// Like [watchAll] but includes soft-deleted rows. Used by the sync
  /// engine so deletes propagate to other devices.
  Stream<List<EventGroup>> watchAllIncludingDeleted();

  /// Normal write path: always stamps [EventGroup.updatedAt] to now.
  Future<void> upsert(EventGroup group);

  /// Creates a bare row for [name] if none exists yet - a no-op if it
  /// already does, so it never clobbers an existing icon. Called whenever
  /// an event is saved with a group name, since [Event.groupName] is just
  /// a string until something actually creates the matching [EventGroup]
  /// row (see GroupPickerField, which only sets that string).
  Future<void> ensureExists(String name);

  /// Writes [group] exactly as given, including its updatedAt/deletedAt.
  /// Used only by the sync engine to apply a remote row.
  Future<void> upsertRaw(EventGroup group);

  /// Soft-delete: sets deletedAt rather than removing the row.
  Future<void> delete(String name);
}
