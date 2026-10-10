import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/progress_calculator.dart';
import '../../models/event.dart';
import '../../state/pin_actions.dart';
import '../../state/providers/settings_provider.dart';
import '../../utils/date_utils.dart';
import 'progress_visual.dart';
import 'status_badge.dart';
import 'tag_chip.dart';

class EventCard extends ConsumerWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.now,
    required this.onTap,
  });

  final Event event;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ProgressCalculator.compute(event, now);
    final visualStyle = ref.watch(
      settingsProvider.select((s) => s.value?.visualStyle ?? VisualStyle.grid),
    );

    final isPinned = ref.watch(
      settingsProvider.select((s) => s.value?.pinnedEventId == event.id),
    );

    // Grid stretches to fill the whole wide preview strip; every other
    // style is a roughly square shape, so it gets a small centered box
    // instead of being stretched into an odd aspect ratio.
    final visual = ProgressVisual(
      visualStyle: visualStyle,
      filled: result.filled,
      total: result.total,
      color: event.color,
      shape: event.shape,
      compact: true,
      maxGridUnitsRendered: 60,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (event.icon != null) ...[
                Icon(event.icon, color: event.color, size: 20),
                const SizedBox(width: 9),
              ],
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      formatProgressSummary(
                        filled: result.filled,
                        total: result.total,
                        granularity: event.granularity,
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 3,
                      children: [
                        StatusBadge(status: result.status),
                        if (event.tag != null) TagChip(tag: event.tag!),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 36,
                  child: visualStyle == VisualStyle.grid
                      ? visual
                      : Center(
                          child: SizedBox(width: 36, height: 36, child: visual),
                        ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  size: 18,
                  color: isPinned ? event.color : null,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
                tooltip: isPinned ? 'Unpin' : 'Pin',
                onPressed: () => togglePin(ref, event),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
