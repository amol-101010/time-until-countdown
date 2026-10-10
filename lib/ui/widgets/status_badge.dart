import 'package:flutter/material.dart';

import '../../domain/progress_calculator.dart';

/// Small pill showing an event's auto-derived [TaskStatus] (see
/// ProgressResult.status) - never user-set, always computed from the
/// event's start/end times relative to now.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TaskStatus.todo => ('Todo', Colors.blueGrey),
      TaskStatus.doing => ('Doing', Colors.orange),
      TaskStatus.done => ('Done', Colors.green),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
