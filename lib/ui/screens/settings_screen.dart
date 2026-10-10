import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';
import '../../data/seed/builtin_events.dart';
import '../../platform/chrome_extension_bridge.dart';
import '../../state/providers/auth_provider.dart';
import '../../state/providers/event_list_provider.dart';
import '../../state/providers/settings_provider.dart';

String _visualStyleLabel(VisualStyle style) {
  switch (style) {
    case VisualStyle.grid:
      return 'Grid (dots/dashes)';
    case VisualStyle.growthRings:
      return 'Growth rings';
    case VisualStyle.clockGauge:
      return 'Clock gauge';
    case VisualStyle.sandTimer:
      return 'Sand timer (animated)';
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (settings) => ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (SupabaseConfig.isConfigured) ...[
              const _SectionHeader('Account'),
              const _AccountSection(),
              const SizedBox(height: 16),
            ],
            const _SectionHeader('My Life'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              visualDensity: VisualDensity.compact,
              title: const Text('Birthdate'),
              subtitle: Text(
                settings.birthDate == null
                    ? 'Not set'
                    : DateFormat.yMMMd().format(settings.birthDate!),
              ),
              trailing: const Icon(Icons.calendar_month_outlined),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: settings.birthDate ?? DateTime(2000, 1, 1),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  await ref.read(settingsProvider.notifier).setBirthDate(picked);
                }
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              visualDensity: VisualDensity.compact,
              title: const Text('Life expectancy'),
              subtitle: Text('${settings.lifeExpectancyYears} years'),
            ),
            SizedBox(
              height: 32,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: Slider(
                  value: settings.lifeExpectancyYears.toDouble(),
                  min: 40,
                  max: 120,
                  divisions: 80,
                  label: '${settings.lifeExpectancyYears}',
                  onChanged: (value) => ref
                      .read(settingsProvider.notifier)
                      .setLifeExpectancyYears(value.round()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _SectionHeader('Theme'),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (selection) => ref
                  .read(settingsProvider.notifier)
                  .setThemeMode(selection.first),
            ),
            const SizedBox(height: 16),
            const _SectionHeader('Default events'),
            const _BuiltInEventVisibilitySection(),
            const SizedBox(height: 16),
            const _SectionHeader('Visualization'),
            RadioGroup<VisualStyle>(
              groupValue: settings.visualStyle,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setVisualStyle(value);
                }
              },
              child: Column(
                children: [
                  for (final style in VisualStyle.values)
                    RadioListTile<VisualStyle>(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      title: Text(_visualStyleLabel(style)),
                      value: style,
                    ),
                ],
              ),
            ),
            if (isChromeExtension) ...[
              const SizedBox(height: 16),
              const _SectionHeader('Chrome extension'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                visualDensity: VisualDensity.compact,
                title: const Text('Replace new tab page'),
                subtitle: const Text(
                  'Show TimeUntil on every new tab. Turn off to get Chrome's '
                  'default new tab page back.',
                ),
                value: settings.newTabEnabled,
                onChanged: (value) =>
                    ref.read(settingsProvider.notifier).setNewTabEnabled(value),
              ),
            ],
            if (!kIsWeb && Platform.isWindows) ...[
              const SizedBox(height: 16),
              const _SectionHeader('Taskbar'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                visualDensity: VisualDensity.compact,
                title: const Text('Show progress in taskbar'),
                subtitle: const Text('Like Explorer\'s file-copy progress'),
                value: settings.taskbarProgressEnabled,
                onChanged: (value) => ref
                    .read(settingsProvider.notifier)
                    .setTaskbarProgressEnabled(value),
              ),
              if (settings.taskbarProgressEnabled)
                _EventPicker(
                  selectedId:
                      settings.taskbarProgressEventId ?? BuiltInEventIds.today,
                  onChanged: (id) => ref
                      .read(settingsProvider.notifier)
                      .setTaskbarProgressEventId(id),
                ),
            ],
            if (!kIsWeb && Platform.isAndroid) ...[
              const SizedBox(height: 16),
              const _SectionHeader('Home screen widget'),
              _EventPicker(
                selectedId: settings.homeWidgetEventId ?? BuiltInEventIds.today,
                onChanged: (id) =>
                    ref.read(settingsProvider.notifier).setHomeWidgetEventId(id),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact bold section label, used throughout this screen instead of a
/// full-size heading + its own spacing, to keep the settings list dense.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Per-built-in visibility switches (Today/This Week/This Month/This Year,
/// plus "My Life" once a birthdate is set) - built-ins can't be deleted
/// outright (they're reseeded every launch), so hiding is the only way to
/// declutter the home screen of ones a user doesn't care about. Reads the
/// live event list rather than a hardcoded id/title table so it stays in
/// sync automatically if a built-in is ever added or renamed.
class _BuiltInEventVisibilitySection extends ConsumerWidget {
  const _BuiltInEventVisibilitySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventListProvider);
    final hidden = ref.watch(
      settingsProvider.select((s) => s.value?.hiddenBuiltInEventIds ?? const {}),
    );

    return eventsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
      data: (events) {
        final builtIns = events.where((e) => e.isBuiltIn).toList();
        if (builtIns.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            for (final event in builtIns)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                visualDensity: VisualDensity.compact,
                title: Text(event.title),
                value: !hidden.contains(event.id),
                onChanged: (visible) => ref
                    .read(settingsProvider.notifier)
                    .setBuiltInEventHidden(event.id, !visible),
              ),
          ],
        );
      },
    );
  }
}

/// Dropdown of all events, used by the taskbar-progress and home-widget
/// pickers - both need "which event drives this" with the same shape.
class _EventPicker extends ConsumerWidget {
  const _EventPicker({required this.selectedId, required this.onChanged});

  final String selectedId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventListProvider);

    return eventsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
      data: (events) {
        final selectedExists = events.any((e) => e.id == selectedId);

        return DropdownButtonFormField<String>(
          initialValue: selectedExists ? selectedId : null,
          decoration: const InputDecoration(labelText: 'Event'),
          items: events
              .map((e) => DropdownMenuItem(value: e.id, child: Text(e.title)))
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        );
      },
    );
  }
}

class _AccountSection extends ConsumerWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    if (user == null) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        visualDensity: VisualDensity.compact,
        title: const Text('Sign in to sync'),
        subtitle: const Text('Keep events in sync across your devices'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/auth'),
      );
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      visualDensity: VisualDensity.compact,
      title: Text(user.email ?? 'Signed in'),
      subtitle: const Text('Syncing'),
      trailing: TextButton(
        onPressed: () => Supabase.instance.client.auth.signOut(),
        child: const Text('Sign out'),
      ),
    );
  }
}
