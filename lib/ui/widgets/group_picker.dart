import 'package:flutter/material.dart';

/// Sentinel item value for the "create a new group" menu entry -
/// distinct from both `null` ("no group") and any real group name.
const String _newGroupSentinel = '__dash_new_group__';

/// Dropdown for [Event.groupName]: pick an existing group, "No group", or
/// "+ New group..." (which prompts for a name via a small dialog before
/// calling [onChanged]). A dropdown rather than free text, unlike the tag
/// field, so creating a group reads as a deliberate action.
class GroupPickerField extends StatelessWidget {
  const GroupPickerField({
    super.key,
    required this.groupName,
    required this.existingGroups,
    required this.onChanged,
  });

  final String? groupName;
  final List<String> existingGroups;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    // The dropdown's current value must be one of its own item values -
    // if the event's group was deleted elsewhere (no events reference it
    // any more), fall back to "No group" rather than crashing.
    final currentValue =
        groupName != null && existingGroups.contains(groupName)
            ? groupName
            : null;

    return DropdownButtonFormField<String?>(
      initialValue: currentValue,
      decoration: const InputDecoration(labelText: 'Group (optional)'),
      items: [
        const DropdownMenuItem(value: null, child: Text('No group')),
        for (final g in existingGroups) DropdownMenuItem(value: g, child: Text(g)),
        const DropdownMenuItem(
          value: _newGroupSentinel,
          child: Text('+ New group…'),
        ),
      ],
      onChanged: (value) async {
        if (value == _newGroupSentinel) {
          final created = await _promptNewGroupName(context);
          if (created != null && created.isNotEmpty) onChanged(created);
          return;
        }
        onChanged(value);
      },
    );
  }

  Future<String?> _promptNewGroupName(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New group'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Group name'),
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
