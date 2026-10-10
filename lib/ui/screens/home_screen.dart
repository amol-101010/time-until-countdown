import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../data/seed/builtin_events.dart';
import '../../models/event.dart';
import '../../state/providers/bootstrap_provider.dart';
import '../../state/providers/clock_provider.dart';
import '../../state/providers/database_provider.dart';
import '../../state/providers/event_list_provider.dart';
import '../../state/providers/group_icons_provider.dart';
import '../../state/providers/settings_provider.dart';
import '../widgets/event_card.dart';
import '../widgets/event_list_tile.dart';
import '../widgets/icon_picker.dart';
import '../../platform/chrome_extension_bridge.dart';
import '../widgets/open_in_tab_button.dart';
import '../widgets/quick_add_sheet.dart';
import '../widgets/sign_in_banner.dart';

/// Moves [event] into [groupName] (or clears its group, if null) by
/// dragging it onto a group header or the ungrouped drop zone - see
/// [_GroupSection] and [_UngroupedDropZone]. Ensures the target group's
/// [EventGroup] row exists (same as picking a group in the edit form).
Future<void> _moveEventToGroup(
  WidgetRef ref,
  Event event,
  String? groupName,
) async {
  if (event.groupName == groupName) return;
  await ref.read(eventRepositoryProvider).upsert(
        event.copyWith(groupName: groupName, clearGroupName: groupName == null),
      );
  if (groupName != null) {
    await ref.read(groupRepositoryProvider).ensureExists(groupName);
  }
}

/// Fixed display order for the built-in events, so they read as a natural
/// day -> week -> month -> year -> life progression regardless of which
/// order they happen to sit in the DB (e.g. "This Week" was added after
/// the others, in builtin_events.dart, and would otherwise trail at the
/// end from insertion order instead of sitting right after "Today").
const _builtInOrder = {
  BuiltInEventIds.today: 0,
  BuiltInEventIds.week: 1,
  BuiltInEventIds.month: 2,
  BuiltInEventIds.year: 3,
  BuiltInEventIds.life: 4,
};

/// Puts built-ins first, in [_builtInOrder]'s sequence, followed by every
/// other event in its existing relative order (untouched - no need to
/// guess at a "correct" order for user-created events).
List<Event> _orderedEvents(List<Event> events) {
  final builtIns = events.where((e) => _builtInOrder.containsKey(e.id)).toList()
    ..sort((a, b) => _builtInOrder[a.id]!.compareTo(_builtInOrder[b.id]!));
  final others = events.where((e) => !_builtInOrder.containsKey(e.id)).toList();
  return [...builtIns, ...others];
}

/// Which tag the home screen's list is filtered to - null means "All".
/// Page-local UI state (not a persisted setting): resets each app
/// session, which is the expected behavior for a filter.
final _tagFilterProvider = StateProvider<String?>((ref) => null);

/// Whether an event tile is currently being dragged (see [_EventList]'s
/// `tileFor`) - drives [_UngroupedDropZone]'s visibility, which only makes
/// sense to show while there's something to drop on it.
final _isDraggingEventProvider = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(appBootstrapProvider);
    final viewMode = ref.watch(
      settingsProvider.select((s) => s.value?.homeViewMode ?? HomeViewMode.cards),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/icon/app_icon.png',
                width: 28,
                height: 28,
              ),
            ),
            const SizedBox(width: 10),
            const Text('TimeUntil'),
          ],
        ),
        actions: [
          if (isChromeExtension)
            IconButton(
              icon: const Icon(Icons.bolt),
              tooltip: 'Quick add',
              onPressed: () => showQuickAddSheet(context),
            ),
          IconButton(
            icon: Icon(
              viewMode == HomeViewMode.cards
                  ? Icons.view_list_outlined
                  : Icons.view_agenda_outlined,
            ),
            tooltip: viewMode == HomeViewMode.cards
                ? 'Switch to list view'
                : 'Switch to card view',
            onPressed: () => ref.read(settingsProvider.notifier).setHomeViewMode(
                  viewMode == HomeViewMode.cards
                      ? HomeViewMode.list
                      : HomeViewMode.cards,
                ),
          ),
          const OpenInTabButton(),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/event/new'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const SignInBanner(),
          const _TagFilterRow(),
          Expanded(
            child: bootstrap.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('Failed to start: $error')),
              data: (_) => _EventList(viewMode: viewMode),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagFilterRow extends ConsumerWidget {
  const _TagFilterRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allEvents = ref.watch(eventListProvider).value ?? const [];
    final hiddenBuiltIns = ref.watch(
      settingsProvider.select((s) => s.value?.hiddenBuiltInEventIds ?? const {}),
    );
    // Only tags from visible events - if hiding every "system" built-in
    // leaves nothing tagged "system", that filter chip should disappear
    // too rather than offering a filter that always returns empty.
    final visibleEvents = hiddenBuiltIns.isEmpty
        ? allEvents
        : allEvents.where((e) => !hiddenBuiltIns.contains(e.id));
    final tags =
        visibleEvents.map((e) => e.tag).whereType<String>().toSet().toList()
          ..sort();
    if (tags.isEmpty) return const SizedBox.shrink();

    final selected = ref.watch(_tagFilterProvider);
    // The selected tag's own chip just disappeared (its only events got
    // hidden) - drop back to "All" rather than leaving the filter stuck
    // on a tag with no visible chip and no visible matches.
    if (selected != null && !tags.contains(selected)) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(_tagFilterProvider.notifier).state = null,
      );
    }
    // A Row inside a SingleChildScrollView, not a horizontal ListView:
    // Row's default crossAxisAlignment is center, so it reliably centers
    // each chip's natural (unconstrained) height - a horizontal ListView
    // is sliver-backed and, at least on the web/CanvasKit renderer, some
    // chips ended up with their content clipped against the row's height
    // instead of centered within it, even when individually wrapped in
    // Center. Plain widgets, no slivers, nothing left to misbehave.
    // The Row shrink-wraps to its content width, and the parent Column
    // centers children by default - without the Align below it drifts to
    // the middle of the screen instead of sitting under the app bar.
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _FilterChip(
                  label: 'All',
                  selected: selected == null,
                  onSelected: () =>
                      ref.read(_tagFilterProvider.notifier).state = null,
                ),
              ),
              for (final tag in tags)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _FilterChip(
                    label: tag,
                    selected: selected == tag,
                    onSelected: () =>
                        ref.read(_tagFilterProvider.notifier).state = tag,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A filter pill for [_TagFilterRow]. Plain [Container] + [Text] (the same
/// pattern as StatusBadge/TagChip, which render correctly) instead of
/// Material's [ChoiceChip] or an [InkWell]/[Material] combo - both of
/// those clipped/misaligned the label when squeezed into a row shorter
/// than their natural height, and tracking down exactly which layer was
/// responsible (shape-clipping, checkmark-avatar sizing, baseline metrics)
/// wasn't worth it next to a version with no layers left to misbehave.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? scheme.secondaryContainer : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? scheme.secondaryContainer : scheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _EventList extends ConsumerWidget {
  const _EventList({required this.viewMode});

  final HomeViewMode viewMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventListProvider);
    final nowAsync = ref.watch(clockProvider);
    final tagFilter = ref.watch(_tagFilterProvider);
    final hiddenBuiltIns = ref.watch(
      settingsProvider.select((s) => s.value?.hiddenBuiltInEventIds ?? const {}),
    );

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Failed to load events: $error')),
      data: (unorderedEvents) {
        final now = nowAsync.value ?? DateTime.now();
        final rawEvents = _orderedEvents(unorderedEvents);
        final allEvents = hiddenBuiltIns.isEmpty
            ? rawEvents
            : rawEvents.where((e) => !hiddenBuiltIns.contains(e.id)).toList();
        final events = tagFilter == null
            ? allEvents
            : allEvents.where((e) => e.tag == tagFilter).toList();
        if (rawEvents.isEmpty) {
          return const Center(child: Text('No events yet. Tap + to add one.'));
        }
        if (allEvents.isEmpty) {
          return const Center(
            child: Text('All events are hidden. Check Settings to unhide them.'),
          );
        }
        if (events.isEmpty) {
          return const Center(child: Text('No events with this tag.'));
        }

        final isList = viewMode == HomeViewMode.list;
        final itemSpacing = isList ? 6.0 : 9.0;

        Widget tileFor(Event event) {
          void onTap() => context.push('/event/${event.id}');
          final tile = isList
              ? EventListTile(event: event, now: now, onTap: onTap)
              : EventCard(event: event, now: now, onTap: onTap);

          // Draggable onto a _GroupSection header or the ungrouped drop
          // zone to move/remove this event's group - see
          // _moveEventToGroup. A plain (not long-press) Draggable: Flutter's
          // gesture arena already resolves a stationary click as a tap and
          // only claims the gesture as a drag once the pointer actually
          // moves past the touch slop, so onTap still fires normally for a
          // quick click - no need for a press-and-hold delay first.
          return Draggable<Event>(
            data: event,
            onDragStarted: () =>
                ref.read(_isDraggingEventProvider.notifier).state = true,
            onDragEnd: (_) =>
                ref.read(_isDraggingEventProvider.notifier).state = false,
            feedback: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: 360,
                child: Opacity(opacity: 0.85, child: tile),
              ),
            ),
            childWhenDragging: Opacity(opacity: 0.3, child: tile),
            child: tile,
          );
        }

        // Events with a groupName collapse together under a shared,
        // tappable header (see GroupPickerField in the event form);
        // ungrouped events render individually, same as before groups
        // existed.
        final grouped = <String, List<Event>>{};
        final ungrouped = <Event>[];
        for (final event in events) {
          final group = event.groupName;
          if (group == null) {
            ungrouped.add(event);
          } else {
            grouped.putIfAbsent(group, () => []).add(event);
          }
        }
        final groupNames = grouped.keys.toList()..sort();

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (groupNames.isNotEmpty)
              _UngroupedDropZone(itemSpacing: itemSpacing),
            for (final groupName in groupNames) ...[
              _GroupSection(
                key: ValueKey('group-$groupName'),
                name: groupName,
                itemSpacing: itemSpacing,
                children: [for (final e in grouped[groupName]!) tileFor(e)],
              ),
              SizedBox(height: itemSpacing),
            ],
            for (var i = 0; i < ungrouped.length; i++) ...[
              tileFor(ungrouped[i]),
              if (i != ungrouped.length - 1) SizedBox(height: itemSpacing),
            ],
          ],
        );
      },
    );
  }
}

/// Drag target for removing an event from its group - dropping a dragged
/// tile here clears [Event.groupName]. Only rendered at all when at least
/// one group exists (see _EventList) AND a drag is actually in progress
/// (see [_isDraggingEventProvider]) - a permanently-visible bar read as
/// clutter/confusing when nothing was being dragged, so it now appears
/// only once the user picks up a tile and disappears again on drop.
class _UngroupedDropZone extends ConsumerWidget {
  const _UngroupedDropZone({required this.itemSpacing});

  final double itemSpacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDragging = ref.watch(_isDraggingEventProvider);

    return AnimatedSize(
      duration: const Duration(milliseconds: 150),
      alignment: Alignment.topCenter,
      child: !isDragging
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: EdgeInsets.only(bottom: itemSpacing),
              child: DragTarget<Event>(
                onWillAcceptWithDetails: (details) =>
                    details.data.groupName != null,
                onAcceptWithDetails: (details) =>
                    _moveEventToGroup(ref, details.data, null),
                builder: (context, candidateData, rejectedData) {
                  final active = candidateData.isNotEmpty;
                  final theme = Theme.of(context);
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: active
                            ? theme.colorScheme.primary
                            : theme.dividerColor,
                        width: active ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Drop here to remove from group',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: active ? theme.colorScheme.primary : null,
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

/// A collapsible section of grouped events (see [Event.groupName]).
/// Expanded by default - collapsing is something the user does on
/// demand to declutter, not a state that should hide content by
/// default. Keyed by group name in the parent list so its expand/collapse
/// state survives the clock-driven rebuilds every minute.
///
/// Deliberately NOT built on [ExpansionTile]: its children are measured
/// through an internal size-transition wrapper that gave the event tiles
/// inside unbounded/zero width in practice, silently collapsing their
/// gradient background, icon, and percentage - they rendered as bare
/// text rows instead of matching ungrouped tiles. A plain [Column] behind
/// a manual toggle has no such quirk - children always get the section's
/// own bounded width, the same as every other list item.
class _GroupSection extends ConsumerStatefulWidget {
  const _GroupSection({
    super.key,
    required this.name,
    required this.children,
    required this.itemSpacing,
  });

  final String name;
  final List<Widget> children;
  final double itemSpacing;

  @override
  ConsumerState<_GroupSection> createState() => _GroupSectionState();
}

class _GroupSectionState extends ConsumerState<_GroupSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final groupIcons = ref.watch(groupIconsProvider);
    final icon = groupIcons[widget.name];
    final iconColor = Theme.of(context).colorScheme.primary;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DragTarget<Event>(
            onWillAcceptWithDetails: (details) =>
                details.data.groupName != widget.name,
            onAcceptWithDetails: (details) =>
                _moveEventToGroup(ref, details.data, widget.name),
            builder: (context, candidateData, rejectedData) {
              final active = candidateData.isNotEmpty;
              return Container(
                color: active
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                    : null,
                padding: const EdgeInsets.all(9),
                child: Row(
                  children: [
                    // Outside the toggle InkWell below so tapping it opens
                    // the icon picker instead of also collapsing the
                    // section.
                    IconPickerField(
                      icon: icon,
                      color: iconColor,
                      onChanged: (value) =>
                          setGroupIcon(ref, widget.name, value),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _expanded = !_expanded),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${widget.name} (${widget.children.length})',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Icon(_expanded
                                ? Icons.expand_less
                                : Icons.expand_more),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (_expanded)
            Padding(
              // Horizontal inset left at 0 (unlike the header's 12px) so
              // grouped tiles span the exact same width as ungrouped ones -
              // previously the extra inset made them visibly narrower,
              // breaking the "look like other events" expectation.
              padding: EdgeInsets.only(bottom: widget.itemSpacing),
              child: Column(
                children: [
                  for (var i = 0; i < widget.children.length; i++) ...[
                    widget.children[i],
                    if (i != widget.children.length - 1)
                      SizedBox(height: widget.itemSpacing),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
