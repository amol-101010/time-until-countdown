import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/progress_calculator.dart';
import '../../models/event.dart';
import '../../platform/chrome_extension_bridge.dart';
import 'clock_provider.dart';
import 'event_list_provider.dart';
import 'settings_provider.dart';

/// Mirrors the pinned event's end time onto the Chrome extension's toolbar
/// icon badge (via chrome_extension/background.js, which does the actual
/// countdown math and repaints the badge every minute independently of
/// this - see lib/platform/chrome_extension_bridge.dart). A no-op
/// everywhere except when actually running as the extension.
///
/// Watches (not just reads) settings/events/clock, so pinning/unpinning in
/// the UI updates the badge immediately.
final extensionBadgeProvider = Provider<void>((ref) {
  if (!isChromeExtension) return;

  final settings = ref.watch(settingsProvider).value;
  final now = ref.watch(clockProvider).value;
  final events = ref.watch(eventListProvider).value;
  final pinnedEventId = settings?.pinnedEventId;

  if (pinnedEventId == null || now == null) {
    writePinnedBadgeState(eventId: null);
    return;
  }

  Event? event;
  for (final e in events ?? const <Event>[]) {
    if (e.id == pinnedEventId) {
      event = e;
      break;
    }
  }
  if (event == null) {
    writePinnedBadgeState(eventId: null);
    return;
  }

  final result = ProgressCalculator.compute(event, now);
  final colorValue = event.color.toARGB32() & 0xFFFFFF;
  writePinnedBadgeState(
    eventId: event.id,
    cycleEnd: result.cycleEnd,
    colorHex: '#${colorValue.toRadixString(16).padLeft(6, '0')}',
  );
});
