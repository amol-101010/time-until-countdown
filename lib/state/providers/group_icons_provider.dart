import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/event_group.dart';
import 'database_provider.dart';

/// Live list of non-deleted groups - the persisted, syncable version of
/// per-group state (currently just [EventGroup.icon]; see
/// lib/models/event_group.dart for why this is a real DB entity now
/// instead of a local-only shared_preferences map).
final groupsProvider = StreamProvider<List<EventGroup>>((ref) {
  return ref.watch(groupRepositoryProvider).watchAll();
});

/// Convenience view of [groupsProvider] for [_GroupSection]'s header icon -
/// just the groups that have one set.
final groupIconsProvider = Provider<Map<String, IconData>>((ref) {
  final groups = ref.watch(groupsProvider).value ?? const [];
  return {
    for (final g in groups)
      if (g.icon != null) g.name: g.icon!,
  };
});

/// Sets (or clears, with `icon: null`) the icon shown in a group's header.
/// A plain write helper rather than a notifier method, since there's no
/// other per-group state yet to bundle it with.
Future<void> setGroupIcon(WidgetRef ref, String groupName, IconData? icon) {
  return ref
      .read(groupRepositoryProvider)
      .upsert(EventGroup(name: groupName, icon: icon));
}
