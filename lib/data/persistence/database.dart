import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// One row per Event (see lib/models/event.dart). One-time and recurring
/// fields share this single flat table (nullable columns for whichever
/// branch isn't in use) rather than separate tables, since every Event is
/// exactly one or the other and there's no need to join.
///
/// Row data class is named EventRow (via @DataClassName) rather than the
/// drift-default "Event" singularization, which would otherwise collide
/// with the domain model's Event class in lib/models/event.dart.
@DataClassName('EventRow')
class Events extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get colorValue => integer()();
  IntColumn get iconCodePoint => integer().nullable()();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();
  BoolColumn get isRecurring => boolean()();
  TextColumn get granularity => text()(); // Granularity enum name
  TextColumn get shape => text()(); // GridShape enum name

  // Recurring branch (set when isRecurring == true).
  TextColumn get recurrenceFrequency => text().nullable()();
  // Comma-separated Weekday enum names, e.g. "mon,tue,wed,thu,fri".
  TextColumn get recurrenceDaysOfWeek => text().nullable()();
  IntColumn get recurrenceCycleStartMinutes => integer().nullable()();
  IntColumn get recurrenceCycleEndMinutes => integer().nullable()();

  // One-time branch (set when isRecurring == false).
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();

  // Sync bookkeeping (schema v2). Not user-facing - see Event.updatedAt /
  // Event.deletedAt in lib/models/event.dart for what these mean.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // Notifications (schema v3). See Event.remindersEnabled.
  BoolColumn get remindersEnabled =>
      boolean().withDefault(const Constant(false))();

  // Notifications (schema v4). See Event.reminderTime/reminderDateTime.
  IntColumn get reminderTimeMinutes => integer().nullable()();
  DateTimeColumn get reminderDateTime => dateTime().nullable()();

  // Notifications (schema v5). See Event.reminderRepeatFrequency.
  TextColumn get reminderRepeatFrequency => text().nullable()();

  // Schema v6. See Event.tag.
  TextColumn get tag => text().nullable()();

  // Schema v7. See Event.groupName.
  TextColumn get groupName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One row per event group (see lib/models/event_group.dart and
/// Event.groupName above). Schema v8. Keyed by name, not a separate id -
/// group names are already the join key every Event.groupName uses.
@DataClassName('GroupRow')
class Groups extends Table {
  TextColumn get name => text()();
  IntColumn get iconCodePoint => integer().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {name};
}

@DriftDatabase(tables: [Events, Groups])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // SQLite's ALTER TABLE ADD COLUMN only allows a *constant*
            // default. updatedAt's real default (currentDateAndTime ->
            // CURRENT_TIMESTAMP) isn't one, so m.addColumn(events,
            // events.updatedAt) fails with "Cannot add a column with
            // non-constant default". Add it with a constant placeholder
            // instead and backfill via UPDATE, which has no such
            // restriction.
            await m.database.customStatement(
              'ALTER TABLE events ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0',
            );
            await m.database.customStatement(
              "UPDATE events SET updated_at = CAST(strftime('%s', 'now') AS INTEGER)",
            );
            await m.addColumn(events, events.deletedAt);
          }
          if (from < 3) {
            await m.addColumn(events, events.remindersEnabled);
          }
          if (from < 4) {
            await m.addColumn(events, events.reminderTimeMinutes);
            await m.addColumn(events, events.reminderDateTime);
          }
          if (from < 5) {
            await m.addColumn(events, events.reminderRepeatFrequency);
          }
          if (from < 6) {
            await m.addColumn(events, events.tag);
          }
          if (from < 7) {
            await m.addColumn(events, events.groupName);
          }
          if (from < 8) {
            await m.createTable(groups);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'dash_events',
      // Ignored on native platforms - required on web, where sqlite3 has
      // to run as WebAssembly. Both files are static assets checked into
      // web/ (sqlite3.wasm downloaded from the sqlite3 package's GitHub
      // releases matching our resolved version; drift_worker.js copied
      // from the drift package itself), not fetched at runtime.
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}
