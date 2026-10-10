import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Business id carried in the sub-window's arguments so lib/main.dart knows
/// to run [PinOverlayApp] instead of the normal [DashApp] - see the
/// multi_window branch there.
const String pinOverlayBusinessId = 'pin_overlay';

/// Method name the main window invokes on an open overlay window to ask it
/// to close itself (see [PinOverlayWindowHandler.register], set up inside
/// the overlay window's own main()).
const String pinOverlayCloseMethod = 'pin_overlay_close';

Map<String, dynamic> _pinOverlayArguments(String eventId) => {
      'businessId': pinOverlayBusinessId,
      'eventId': eventId,
    };

/// Whether the floating pin overlay can exist on this platform at all.
/// `desktop_multi_window` only ships native implementations for
/// Windows/macOS/Linux - on Android/iOS/web a pinned task can't be shown as
/// a separate always-on-top OS window the way it can on desktop. Android
/// would need a different mechanism entirely (a SYSTEM_ALERT_WINDOW overlay
/// service), which isn't implemented here.
bool get pinOverlaySupported =>
    !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

extension _CloseableWindow on WindowController {
  Future<void> requestClose() => invokeMethod(pinOverlayCloseMethod);
}

/// Creates, replaces, and closes the single floating "pinned task" window.
/// Only one can be open at a time - pinning a different event closes the
/// old overlay and opens a fresh one rather than updating an existing
/// window's content in place, since that would need extra cross-isolate
/// messaging for a case (switching which event is pinned while one is
/// already open) that's rare enough not to be worth it.
class PinOverlayController {
  PinOverlayController._();

  static WindowController? _controller;

  static Future<void> show(String eventId) async {
    if (!pinOverlaySupported) return;

    final existing = _controller;
    _controller = null;
    if (existing != null) {
      try {
        await existing.requestClose();
      } on PlatformException {
        // Already gone (e.g. closed via its own close button) - fine.
      }
    }

    final controller = await WindowController.create(
      WindowConfiguration(
        hiddenAtLaunch: true,
        arguments: jsonEncode(_pinOverlayArguments(eventId)),
      ),
    );
    _controller = controller;
    await controller.show();
  }

  static Future<void> close() async {
    if (!pinOverlaySupported) return;
    final controller = _controller;
    if (controller == null) return;
    _controller = null;
    try {
      await controller.requestClose();
    } on PlatformException {
      // Already gone - fine.
    }
  }

  static bool get isOpen => _controller != null;
}

/// Registered inside the pin-overlay sub-window's own main() so the main
/// window can ask it to close (see [PinOverlayController.close]).
class PinOverlayWindowHandler {
  PinOverlayWindowHandler._();

  static Future<void> register(
    WindowController controller,
    Future<void> Function() onCloseRequested,
  ) {
    return controller.setWindowMethodHandler((call) async {
      switch (call.method) {
        case pinOverlayCloseMethod:
          await onCloseRequested();
          return null;
        default:
          throw MissingPluginException('Not implemented: ${call.method}');
      }
    });
  }
}
