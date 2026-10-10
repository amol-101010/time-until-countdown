import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../domain/progress_calculator.dart';
import '../../models/event.dart';
import '../../overlay/pin_overlay_controller.dart';
import '../../platform/chrome_extension_bridge.dart';
import '../../state/pin_actions.dart';
import '../../state/providers/clock_provider.dart';
import '../../state/providers/database_provider.dart';
import '../../state/providers/event_list_provider.dart';
import '../../state/providers/settings_provider.dart';
import '../../utils/date_utils.dart';
import '../widgets/progress_visual.dart';
import '../widgets/share_progress_dialog.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  final _visualKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventListProvider);
    final nowAsync = ref.watch(clockProvider);

    return eventsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Failed to load: $error'))),
      data: (events) {
        Event? event;
        for (final e in events) {
          if (e.id == widget.eventId) {
            event = e;
            break;
          }
        }
        if (event == null) {
          return const Scaffold(body: Center(child: Text('Event not found')));
        }
        final resolvedEvent = event;
        final now = nowAsync.value ?? DateTime.now();
        final result = ProgressCalculator.compute(resolvedEvent, now);
        final dateFormat = DateFormat.yMMMd();
        final visualStyle = ref.watch(
          settingsProvider.select((s) => s.value?.visualStyle ?? VisualStyle.grid),
        );
        final summary = formatProgressSummary(
          filled: result.filled,
          total: result.total,
          granularity: resolvedEvent.granularity,
        );
        final dateRange =
            '${dateFormat.format(result.cycleStart)} – ${dateFormat.format(result.cycleEnd)}';
        final pinnedEventId = ref.watch(
          settingsProvider.select((s) => s.value?.pinnedEventId),
        );
        final isPinned = pinnedEventId == resolvedEvent.id;

        return Scaffold(
          appBar: AppBar(
            title: Text(resolvedEvent.title),
            actions: [
              IconButton(
                icon: Icon(isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                tooltip: isPinned
                    ? 'Unpin'
                    : pinOverlaySupported
                        ? 'Pin (shows a floating overlay + time remaining)'
                        : 'Pin (shows time remaining in list view)',
                onPressed: () => togglePin(ref, resolvedEvent),
              ),
              if (isChromeExtension)
                IconButton(
                  icon: const Icon(Icons.ios_share),
                  tooltip: 'Share as image',
                  onPressed: () => showShareProgressDialog(
                    context,
                    event: resolvedEvent,
                    result: result,
                    now: now,
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.print_outlined),
                tooltip: 'Print',
                onPressed: () => _printGrid(
                  title: resolvedEvent.title,
                  summary: summary,
                  dateRange: dateRange,
                ),
              ),
              if (!resolvedEvent.isBuiltIn) ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: () =>
                      context.push('/event/${resolvedEvent.id}/edit'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  onPressed: () => _confirmDelete(context, ref, resolvedEvent),
                ),
              ],
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final info = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(summary, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(dateRange, style: Theme.of(context).textTheme.bodyMedium),
                    if (resolvedEvent.isRecurring) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Recurring · resets each cycle',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                );
                final visual = RepaintBoundary(
                  key: _visualKey,
                  child: ProgressVisual(
                    visualStyle: visualStyle,
                    filled: result.filled,
                    total: result.total,
                    color: resolvedEvent.color,
                    shape: resolvedEvent.shape,
                    showPercentage: true,
                  ),
                );

                // Below ~500px wide (the Chrome extension popup, in
                // particular), a side-by-side Row squeezes the visual into
                // a narrow sliver off to one side instead of centering it -
                // stack vertically instead, with the visual centered in
                // its own square area.
                if (constraints.maxWidth < 500) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      info,
                      const SizedBox(height: 16),
                      Expanded(child: Center(child: visual)),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 260, child: info),
                    const SizedBox(width: 24),
                    Expanded(child: visual),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _printGrid({
    required String title,
    required String summary,
    required String dateRange,
  }) async {
    final boundary = _visualKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final pngBytes = byteData.buffer.asUint8List();

    final doc = pw.Document();
    final pdfImage = pw.MemoryImage(pngBytes);
    doc.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text(summary, style: const pw.TextStyle(fontSize: 14)),
            pw.Text(dateRange, style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 24),
            pw.Expanded(child: pw.Center(child: pw.Image(pdfImage))),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(name: title, onLayout: (_) => doc.save());
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Event event,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete event?'),
        content: Text('This removes "${event.title}" permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(eventRepositoryProvider).delete(event.id);
      if (context.mounted) context.pop();
    }
  }
}
