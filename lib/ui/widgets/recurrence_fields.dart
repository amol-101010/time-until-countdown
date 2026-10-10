import 'package:flutter/material.dart';

import '../../models/event.dart';

/// The recurring-branch fields of the create/edit form: frequency, plus
/// the day-of-week and cycle-time pickers that only apply to `daily`
/// (see progress_calculator.dart's cycle-resolution rules).
class RecurrenceFields extends StatelessWidget {
  const RecurrenceFields({
    super.key,
    required this.frequency,
    required this.daysOfWeek,
    required this.cycleStartTime,
    required this.cycleEndTime,
    required this.onFrequencyChanged,
    required this.onDaysOfWeekChanged,
    required this.onCycleStartTimeChanged,
    required this.onCycleEndTimeChanged,
  });

  final RecurrenceFrequency frequency;
  final Set<Weekday> daysOfWeek;
  final TimeOfDay? cycleStartTime;
  final TimeOfDay? cycleEndTime;

  final ValueChanged<RecurrenceFrequency> onFrequencyChanged;
  final ValueChanged<Set<Weekday>> onDaysOfWeekChanged;
  final ValueChanged<TimeOfDay?> onCycleStartTimeChanged;
  final ValueChanged<TimeOfDay?> onCycleEndTimeChanged;

  static const _weekdayLabels = {
    Weekday.mon: 'Mon',
    Weekday.tue: 'Tue',
    Weekday.wed: 'Wed',
    Weekday.thu: 'Thu',
    Weekday.fri: 'Fri',
    Weekday.sat: 'Sat',
    Weekday.sun: 'Sun',
  };

  @override
  Widget build(BuildContext context) {
    final isDaily = frequency == RecurrenceFrequency.daily;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<RecurrenceFrequency>(
          initialValue: frequency,
          decoration: const InputDecoration(labelText: 'Repeats'),
          items: RecurrenceFrequency.values
              .map(
                (f) => DropdownMenuItem(value: f, child: Text(_frequencyLabel(f))),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onFrequencyChanged(value);
          },
        ),
        if (isDaily) ...[
          const SizedBox(height: 12),
          const Text('On these days (leave all off for every day)'),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: Weekday.values.map((day) {
              final selected = daysOfWeek.contains(day);
              return FilterChip(
                label: Text(_weekdayLabels[day]!),
                selected: selected,
                onSelected: (value) {
                  final next = Set<Weekday>.from(daysOfWeek);
                  if (value) {
                    next.add(day);
                  } else {
                    next.remove(day);
                  }
                  onDaysOfWeekChanged(next);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TimeField(
                  label: 'Start time',
                  value: cycleStartTime,
                  onChanged: onCycleStartTimeChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeField(
                  label: 'End time',
                  value: cycleEndTime,
                  onChanged: onCycleEndTimeChanged,
                ),
              ),
            ],
          ),
        ],
      ],
    );
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

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: value ?? const TimeOfDay(hour: 9, minute: 0),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(value == null ? 'Full day' : value!.format(context)),
      ),
    );
  }
}
