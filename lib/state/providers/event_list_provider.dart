import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/event.dart';
import 'database_provider.dart';

/// Live stream of all persisted events (built-ins + custom), sorted by
/// insertion order from the repository. UI reads this directly; nothing
/// needs to manually refresh it after a create/edit/delete since drift's
/// query stream re-emits on any write to the events table.
final eventListProvider = StreamProvider<List<Event>>((ref) {
  return ref.watch(eventRepositoryProvider).watchAll();
});
