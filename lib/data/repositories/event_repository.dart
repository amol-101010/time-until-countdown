import '../../models/event.dart';

/// Storage-agnostic interface for reading/writing [Event]s. UI and state
/// code depend on this, not on drift directly, so persistence can be
/// swapped or mocked in tests.
abstract class EventRepository {
  /// Live, non-deleted events - what the UI shows.
  Stream<List<Event>> watchAll();

  /// Like [watchAll] but includes soft-deleted rows (non-null
  /// [Event.deletedAt]). Used by the sync engine, which needs to see
  /// tombstones so deletes propagate to other devices.
  Stream<List<Event>> watchAllIncludingDeleted();

  /// Normal write path: always stamps [Event.updatedAt] to now,
  /// regardless of what's set on [event]. Used by the UI (create/edit
  /// form, built-in seeding).
  Future<void> upsert(Event event);

  /// Writes [event] exactly as given, including its [Event.updatedAt] and
  /// [Event.deletedAt]. Used only by the sync engine to apply a remote
  /// row without disturbing the timestamp last-write-wins depends on.
  Future<void> upsertRaw(Event event);

  /// Soft-delete: sets [Event.deletedAt] rather than removing the row, so
  /// the deletion can sync to other devices instead of just disappearing
  /// locally. [watchAll] excludes it afterwards.
  Future<void> delete(String id);
}
