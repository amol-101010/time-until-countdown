import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/progress_calculator.dart';
import '../../models/event.dart';
import '../../state/pin_actions.dart';
import '../../state/providers/settings_provider.dart';
import '../../utils/date_utils.dart';
import 'status_badge.dart';
import 'tag_chip.dart';

/// A compact, todo-list-style row for [HomeViewMode.list]: title, end
/// date, and percentage, with a gradient background standing in for a
/// separate progress visual - the gradient itself splits at the elapsed
/// fraction (event color up to that point, fading to near-transparent
/// after), so the row reads as "time completed vs remaining" without
/// needing the vertical space a dot grid/rings/gauge would take. Meant
/// especially for tight spaces like the Chrome extension's popup.
///
/// The trailing column shows percentage complete above a live countdown
/// (see [formatCountdown]) - both carry a hover tooltip labeling what they
/// are. The pin toggle (see lib/state/pin_actions.dart) only appears on
/// hover, so it doesn't compete with that trailing info at rest.
class EventListTile extends ConsumerStatefulWidget {
  const EventListTile({
    super.key,
    required this.event,
    required this.now,
    required this.onTap,
  });

  final Event event;
  final DateTime now;
  final VoidCallback onTap;

  @override
  ConsumerState<EventListTile> createState() => _EventListTileState();
}

class _EventListTileState extends ConsumerState<EventListTile> {
  bool _hovering = false;
  Timer? _secondTicker;

  /// How much of the gradient's transition is a soft blend (as a
  /// fraction of the row's width) rather than a hard edge, so the
  /// completed/remaining boundary reads as a gradient rather than a
  /// razor-sharp split.
  static const double _blend = 0.06;

  @override
  void initState() {
    super.initState();
    // [clockProvider] (widget.now) only ticks once a minute - fine for
    // progress/percentage, but formatCountdown's seconds digit needs to
    // visibly tick once an event is under a day from ending. A cheap
    // once-a-second check rather than bumping the app-wide clock: only
    // triggers a rebuild of *this* row while it's actually within that
    // last-day window, so rows far from done cost nothing extra.
    _secondTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final cycleEnd =
          ProgressCalculator.compute(widget.event, widget.now).cycleEnd;
      final remaining = cycleEnd.difference(DateTime.now());
      if (!remaining.isNegative && remaining < const Duration(days: 1)) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _secondTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final now = widget.now;
    final result = ProgressCalculator.compute(event, now);
    // Real wall-clock time for the countdown text specifically (not
    // widget.now, which only advances once a minute) - see initState.
    final countdownNow = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fraction = result.fraction;
    final isPinned = ref.watch(
      settingsProvider.select((s) => s.value?.pinnedEventId == event.id),
    );

    final leftStop = (fraction - _blend).clamp(0.0, 1.0);
    final rightStop = (fraction + _blend).clamp(0.0, 1.0);
    final filledAlpha = isDark ? 0.40 : 0.28;
    final emptyAlpha = isDark ? 0.16 : 0.10;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 0.5),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              event.color.withValues(alpha: filledAlpha),
              event.color.withValues(alpha: filledAlpha),
              event.color.withValues(alpha: emptyAlpha),
              event.color.withValues(alpha: emptyAlpha),
            ],
            stops: [0.0, leftStop, rightStop, 1.0],
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              child: Row(
                children: [
                  if (event.icon != null) ...[
                    Icon(event.icon, color: event.color, size: 16),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          event.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: 4,
                          runSpacing: 2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Ends ${DateFormat.yMMMd().format(result.cycleEnd)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            StatusBadge(status: result.status),
                            if (event.tag != null) TagChip(tag: event.tag!),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 3),
                  AnimatedOpacity(
                    opacity: (_hovering || isPinned) ? 1 : 0.4,
                    duration: const Duration(milliseconds: 120),
                    child: IconButton(
                      icon: Icon(
                        isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                        size: 16,
                        color: isPinned ? event.color : null,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      tooltip: isPinned ? 'Unpin' : 'Pin',
                      onPressed: () => togglePin(ref, event),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: 'Percentage complete',
                        child: Text(
                          '${(fraction * 100).round()}%',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: event.color,
                              ),
                        ),
                      ),
                      Tooltip(
                        message: 'Time remaining',
                        child: Text(
                          formatCountdown(countdownNow, result.cycleEnd),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
