import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../domain/event_templates.dart';
import '../../domain/quick_add_parser.dart';
import '../../models/event.dart';
import '../../state/providers/database_provider.dart';
import '../../utils/date_utils.dart';

/// Chrome extension quick-add: type a casual line ("Trip on Dec 25",
/// "in 3 weeks") or tap a template, and the countdown is created straight
/// away. See [parseQuickAdd] and [eventTemplates].
Future<void> showQuickAddSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const _QuickAddSheet(),
  );
}

class _QuickAddSheet extends ConsumerStatefulWidget {
  const _QuickAddSheet();

  @override
  ConsumerState<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<_QuickAddSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  QuickAddResult? get _parsed => parseQuickAdd(_controller.text, DateTime.now());

  Future<void> _addParsed() async {
    final result = _parsed;
    if (result == null) return;
    final now = DateTime.now();
    final event = eventFromQuickAdd(const Uuid().v4(), result, now);
    await _save(event);
  }

  Future<void> _addTemplate(EventTemplate template) async {
    await _save(template.build(const Uuid().v4(), DateTime.now()));
  }

  Future<void> _save(Event event) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await ref.read(eventRepositoryProvider).upsert(event);
    navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text('Added "${event.title}"')));
  }

  @override
  Widget build(BuildContext context) {
    final parsed = _parsed;
    final theme = Theme.of(context);
    final hint = _controller.text.trim().isEmpty
        ? 'Try "Trip on Dec 25", "in 3 weeks" or "Friday 5pm"'
        : parsed == null
            ? 'No date found - add one like "Dec 25" or "in 2 weeks"'
            : '${parsed.title} -> ${DateFormat.yMMMd().add_jm().format(parsed.target)}'
                ' (${formatCountdown(DateTime.now(), parsed.target)})';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick add', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'What and when?',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle),
                  tooltip: 'Add',
                  onPressed: parsed == null ? null : _addParsed,
                ),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _addParsed(),
            ),
            const SizedBox(height: 6),
            Text(
              hint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: parsed == null && _controller.text.trim().isNotEmpty
                    ? theme.colorScheme.error
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text('Templates', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final template in eventTemplates)
                  ActionChip(
                    avatar: Icon(template.icon, size: 18, color: template.color),
                    label: Text(template.label),
                    onPressed: () => _addTemplate(template),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
