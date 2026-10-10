import 'package:flutter/material.dart';

/// A named group of events (see [Event.groupName]), now a real synced
/// entity rather than a local-only UI preference - previously the group
/// icon lived only in shared_preferences, which meant it never left the
/// device it was set on. Keyed by [name] (not a separate id): group names
/// are already the join key every [Event.groupName] uses, and renaming
/// isn't supported yet, so there's no case where that key needs to change
/// under an existing group.
class EventGroup {
  const EventGroup({
    required this.name,
    this.icon,
    this.updatedAt,
    this.deletedAt,
  });

  final String name;
  final IconData? icon;

  /// Sync bookkeeping - see Event.updatedAt/deletedAt for the same pattern.
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  EventGroup copyWith({IconData? icon, bool clearIcon = false}) {
    return EventGroup(
      name: name,
      icon: clearIcon ? null : (icon ?? this.icon),
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }
}
