import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/persistence/database.dart';
import '../../data/repositories/drift_event_repository.dart';
import '../../data/repositories/drift_group_repository.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/group_repository.dart';

/// Single app-lifetime database instance. Not autoDispose: the connection
/// should stay open for as long as the app runs.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return DriftEventRepository(ref.watch(databaseProvider));
});

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return DriftGroupRepository(ref.watch(databaseProvider));
});
