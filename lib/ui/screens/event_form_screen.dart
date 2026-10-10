import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../domain/progress_calculator.dart';
import '../../models/event.dart';
import '../../state/providers/database_provider.dart'
    show eventRepositoryProvider, groupRepositoryProvider;
import '../../state/providers/event_list_provider.dart';
import '../../state/providers/notification_provider.dart';
import '../widgets/group_picker.dart';
import '../widgets/icon_picker.dart';
import '../widgets/recurrence_fields.dart';

/// Create/edit form. Pass [eventId] to edit an existing custom event;
/// leave it null to create a new one. Built-in events aren't editable
/// here (Home/Detail screens don't route to this form for them).
class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({super.key, this.eventId});

  final String? eventId;

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _titleController = TextEditingController();
  final _tagController = TextEditingController();
  bool _initializedFromExisting = false;

  Color _color = const Color(0xFF2196F3);
  IconData? _icon;
  bool _isRecurring = false;
  Granularity _granularity = Granularity.day;
  GridShape? _shapeOverride;

  RecurrenceFrequency _frequency = RecurrenceFrequency.daily;
  Set<Weekday> _daysOfWeek = {};
  TimeOfDay? _cycleStartTime;
  TimeOfDay? _cycleEndTime;

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  bool _remindersEnabled = false;
  TimeOfDay? _reminderTime;
  DateTime? _reminderDateTime;
  RecurrenceFrequency? _reminderRepeatFrequency;

  String? _groupName;

  bool get _isEditing => widget.eventId != null;

  GridShape get _shape =>
      _shapeOverride ??
      Event.defaultShapeFor(isRecurring: _isRecurring, granularity: _granularity);

  bool get _usesRepeatingOneTimeReminder =>
      !_isRecurring && _reminderRepeatFrequency != null;

  @override
  void dispose() {
    _titleController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _loadExisting(Event event) {
    if (_initializedFromExisting) return;
    _initializedFromExisting = true;
    _titleController.text = event.title;
    _color = event.color;
    _icon = event.icon;
    _isRecurring = event.isRecurring;
    _granularity = event.granularity;
    _shapeOverride = event.shape;
    if (event.recurrence != null) {
      _frequency = event.recurrence!.frequency;
      _daysOfWeek = event.recurrence!.daysOfWeek?.toSet() ?? {};
      _cycleStartTime = event.recurrence!.cycleStartTime;
      _cycleEndTime = event.recurrence!.cycleEndTime;
    }
    _startDate = event.startDate ?? DateTime.now();
    _endDate = event.endDate;
    _remindersEnabled = event.remindersEnabled;
    _reminderTime = event.reminderTime;
    _reminderDateTime = event.reminderDateTime;
    _reminderRepeatFrequency = event.reminderRepeatFrequency;
    _tagController.text = event.tag ?? '';
    _groupName = event.groupName;
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      final eventsAsync = ref.watch(eventListProvider);
      return eventsAsync.when(
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, stack) =>
            Scaffold(body: Center(child: Text('Failed to load: $error'))),
        data: (events) {
          Event? existing;
          for (final e in events) {
            if (e.id == widget.eventId) {
              existing = e;
              break;
            }
          }
          if (existing == null) {
            return const Scaffold(body: Center(child: Text('Event not found')));
          }
          _loadExisting(existing);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final previewTotal = _previewTotal();
    final showDotCountWarning = previewTotal > 2000;
    final allEvents = ref.watch(eventListProvider).value ?? const [];
    final existingTags = allEvents
        .map((e) => e.tag)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
    final existingGroups = allEvents
        .map((e) => e.groupName)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit event' : 'New event')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Color'),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _pickColor,
                child: CircleAvatar(backgroundColor: _color, radius: 14),
              ),
              const SizedBox(width: 24),
              const Text('Icon'),
              const SizedBox(width: 12),
              IconPickerField(
                icon: _icon,
                color: _color,
                onChanged: (value) => setState(() => _icon = value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tagController,
            decoration: const InputDecoration(
              labelText: 'Tag (optional)',
              hintText: 'e.g. Work, Home',
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (existingTags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final tag in existingTags)
                  ChoiceChip(
                    label: Text(tag),
                    selected: _tagController.text == tag,
                    onSelected: (selected) => setState(() {
                      _tagController.text = selected ? tag : '';
                    }),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          GroupPickerField(
            groupName: _groupName,
            existingGroups: existingGroups,
            onChanged: (value) => setState(() => _groupName = value),
          ),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('One-time')),
              ButtonSegment(value: true, label: Text('Recurring')),
            ],
            selected: {_isRecurring},
            onSelectionChanged: (selection) {
              setState(() => _isRecurring = selection.first);
            },
          ),
          const SizedBox(height: 16),
          if (_isRecurring)
            RecurrenceFields(
              frequency: _frequency,
              daysOfWeek: _daysOfWeek,
              cycleStartTime: _cycleStartTime,
              cycleEndTime: _cycleEndTime,
              onFrequencyChanged: (value) => setState(() => _frequency = value),
              onDaysOfWeekChanged: (value) => setState(() => _daysOfWeek = value),
              onCycleStartTimeChanged: (value) =>
                  setState(() => _cycleStartTime = value),
              onCycleEndTimeChanged: (value) => setState(() => _cycleEndTime = value),
            )
          else
            _OneTimeFields(
              startDate: _startDate,
              endDate: _endDate,
              onStartDateChanged: (value) => setState(() => _startDate = value),
              onEndDateChanged: (value) => setState(() => _endDate = value),
            ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Granularity>(
            initialValue: _granularity,
            decoration: const InputDecoration(labelText: 'One unit ='),
            items: Granularity.values
                .map(
                  (g) => DropdownMenuItem(
                    value: g,
                    child: Text(_granularityLabel(g)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _granularity = value);
            },
          ),
          const SizedBox(height: 16),
          const Text('Shape'),
          const SizedBox(height: 4),
          SegmentedButton<GridShape>(
            segments: const [
              ButtonSegment(value: GridShape.dot, label: Text('Dot')),
              ButtonSegment(value: GridShape.dash, label: Text('Dash')),
            ],
            selected: {_shape},
            onSelectionChanged: (selection) {
              setState(() => _shapeOverride = selection.first);
            },
          ),
          if (showDotCountWarning) ...[
            const SizedBox(height: 12),
            Text(
              'That\'s $previewTotal units - consider a coarser unit '
              '(e.g. hours instead of minutes) for a more readable grid.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Remind me'),
            subtitle: Text(
              _isRecurring
                  ? 'Notify at a set time every cycle'
                  : 'Notify once, or repeating, at a time you choose',
            ),
            value: _remindersEnabled,
            onChanged: (value) => setState(() {
              _remindersEnabled = value;
              if (value) {
                if (_isRecurring || _reminderRepeatFrequency != null) {
                  _reminderTime ??= const TimeOfDay(hour: 9, minute: 0);
                } else {
                  _reminderDateTime ??= _startDate;
                }
              }
            }),
          ),
          if (_remindersEnabled) ...[
            if (_isRecurring)
              _ReminderTimeTile(
                time: _reminderTime,
                onChanged: (value) => setState(() => _reminderTime = value),
              )
            else ...[
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Once')),
                  ButtonSegment(value: true, label: Text('Repeating')),
                ],
                selected: {_reminderRepeatFrequency != null},
                onSelectionChanged: (selection) => setState(() {
                  if (selection.first) {
                    _reminderRepeatFrequency ??= RecurrenceFrequency.daily;
                    _reminderTime ??= const TimeOfDay(hour: 9, minute: 0);
                  } else {
                    _reminderRepeatFrequency = null;
                  }
                }),
              ),
              const SizedBox(height: 8),
              if (_reminderRepeatFrequency == null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Reminder date & time'),
                  subtitle: Text(
                    _reminderDateTime == null
                        ? 'Not set'
                        : DateFormat.yMMMd().add_jm().format(_reminderDateTime!),
                  ),
                  trailing: const Icon(Icons.event_outlined),
                  onTap: () async {
                    final base = _reminderDateTime ?? _startDate;
                    final date = await showDatePicker(
                      context: context,
                      initialDate: base,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2200),
                    );
                    if (date == null || !context.mounted) return;
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(base),
                    );
                    if (time == null) return;
                    setState(() {
                      _reminderDateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  },
                )
              else ...[
                DropdownButtonFormField<RecurrenceFrequency>(
                  initialValue: _reminderRepeatFrequency,
                  decoration: const InputDecoration(labelText: 'Repeat'),
                  items: RecurrenceFrequency.values
                      .map(
                        (f) => DropdownMenuItem(
                          value: f,
                          child: Text(_frequencyLabel(f)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _reminderRepeatFrequency = value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                _ReminderTimeTile(
                  time: _reminderTime,
                  onChanged: (value) => setState(() => _reminderTime = value),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stops once the start date passes',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ],
          const SizedBox(height: 8),
          FilledButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }

  int _previewTotal() {
    if (_isRecurring) {
      final rule = RecurrenceRule(
        frequency: _frequency,
        daysOfWeek: _daysOfWeek.isEmpty ? null : _daysOfWeek.toList(),
        cycleStartTime: _cycleStartTime,
        cycleEndTime: _cycleEndTime,
      );
      final cycle = ProgressCalculator.resolveCycle(rule, DateTime.now());
      return ProgressCalculator.unitsBetween(cycle.start, cycle.end, _granularity);
    }
    final end = _endDate ?? Event.defaultEndDate(_startDate);
    return ProgressCalculator.unitsBetween(_startDate, end, _granularity);
  }

  Future<void> _pickColor() async {
    var picked = _color;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _color,
            onColorChanged: (value) => picked = value,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    setState(() => _color = picked);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final event = Event(
      id: widget.eventId ?? const Uuid().v4(),
      title: title,
      color: _color,
      icon: _icon,
      isRecurring: _isRecurring,
      granularity: _granularity,
      shape: _shape,
      recurrence: _isRecurring
          ? RecurrenceRule(
              frequency: _frequency,
              daysOfWeek: _daysOfWeek.isEmpty ? null : _daysOfWeek.toList(),
              cycleStartTime: _cycleStartTime,
              cycleEndTime: _cycleEndTime,
            )
          : null,
      startDate: _isRecurring ? null : _startDate,
      endDate: _isRecurring ? null : _endDate,
      remindersEnabled: _remindersEnabled,
      reminderTime:
          (_isRecurring || _usesRepeatingOneTimeReminder) ? _reminderTime : null,
      reminderDateTime:
          (!_isRecurring && !_usesRepeatingOneTimeReminder) ? _reminderDateTime : null,
      reminderRepeatFrequency:
          _usesRepeatingOneTimeReminder ? _reminderRepeatFrequency : null,
      tag: _tagController.text.trim().isEmpty
          ? null
          : _tagController.text.trim(),
      groupName: _groupName,
    );

    await ref.read(eventRepositoryProvider).upsert(event);
    if (_groupName != null) {
      await ref.read(groupRepositoryProvider).ensureExists(_groupName!);
    }

    // Immediate feedback rather than waiting for the next clock tick's
    // sweep (see notification_provider.dart's notificationDriverProvider).
    final scheduler = ref.read(notificationSchedulerProvider).value;
    await scheduler?.scheduleNext(event);

    if (mounted) context.pop();
  }

  static String _granularityLabel(Granularity g) {
    switch (g) {
      case Granularity.minute:
        return 'Minute';
      case Granularity.hour:
        return 'Hour';
      case Granularity.day:
        return 'Day';
      case Granularity.week:
        return 'Week';
      case Granularity.month:
        return 'Month';
      case Granularity.year:
        return 'Year';
    }
  }

  static String _frequencyLabel(RecurrenceFrequency f) {
    switch (f) {
      case RecurrenceFrequency.daily:
        return 'Daily';
      case RecurrenceFrequency.weekly:
        return 'Weekly';
      case RecurrenceFrequency.monthly:
        return 'Monthly';
      case RecurrenceFrequency.yearly:
        return 'Yearly';
    }
  }
}

class _ReminderTimeTile extends StatelessWidget {
  const _ReminderTimeTile({required this.time, required this.onChanged});

  final TimeOfDay? time;
  final ValueChanged<TimeOfDay> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Reminder time'),
      subtitle: Text(time == null ? 'Not set' : time!.format(context)),
      trailing: const Icon(Icons.access_time),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time ?? const TimeOfDay(hour: 9, minute: 0),
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}

class _OneTimeFields extends StatelessWidget {
  const _OneTimeFields({
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  final DateTime startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;

  @override
  Widget build(BuildContext context) {
    final dateTimeFormat = DateFormat.yMMMd().add_jm();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Start date & time'),
          subtitle: Text(dateTimeFormat.format(startDate)),
          trailing: const Icon(Icons.calendar_month_outlined),
          onTap: () async {
            final picked =
                await _pickDateAndTime(context, initial: startDate);
            if (picked != null) onStartDateChanged(picked);
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('End date & time (optional)'),
          subtitle: Text(
            endDate == null
                ? 'Defaults to 50 years after start'
                : dateTimeFormat.format(endDate!),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (endDate != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => onEndDateChanged(null),
                ),
              const Icon(Icons.calendar_month_outlined),
            ],
          ),
          onTap: () async {
            final picked =
                await _pickDateAndTime(context, initial: endDate ?? startDate);
            if (picked != null) onEndDateChanged(picked);
          },
        ),
      ],
    );
  }

  /// Date picker followed by a time picker, combined into one [DateTime] -
  /// always offered for both start and end, regardless of the event's
  /// granularity, so an end time is never unreachable (previously only the
  /// date could be set, silently pinning every one-time event's end to
  /// midnight).
  Future<DateTime?> _pickDateAndTime(
    BuildContext context, {
    required DateTime initial,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (date == null || !context.mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}
