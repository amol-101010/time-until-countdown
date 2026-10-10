import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event.dart';
import '../overlay/pin_overlay_controller.dart';
import 'providers/settings_provider.dart';

/// Pins/unpins [event] as *the* pinned event (only one at a time - pinning
/// a different event replaces whichever was pinned before). Used from
/// [EventListTile]'s pin icon and [EventDetailScreen]'s app bar action, so
/// both stay in sync through the same [Settings.pinnedEventId].
///
/// The pinned event drives the floating desktop overlay (see
/// lib/overlay/pin_overlay_controller.dart) on Windows/macOS/Linux; on
/// other platforms (including the Chrome extension) pinning still marks
/// the row so its pin icon reads as active, even though no overlay opens.
Future<void> togglePin(WidgetRef ref, Event event) async {
  final pinnedEventId = ref.read(settingsProvider).value?.pinnedEventId;
  final isPinned = pinnedEventId == event.id;

  if (isPinned) {
    await ref.read(settingsProvider.notifier).setPinnedEventId(null);
    await PinOverlayController.close();
  } else {
    await ref.read(settingsProvider.notifier).setPinnedEventId(event.id);
    await PinOverlayController.show(event.id);
  }
}
