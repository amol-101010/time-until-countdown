import 'dart:typed_data';

/// Non-web fallback for lib/platform/chrome_extension_bridge.dart - a
/// Chrome extension only exists as a web build, so every other platform
/// (Windows/Android) gets a no-op here instead of trying to import
/// dart:js_interop, which doesn't exist off the web.
bool get isChromeExtension => false;

void writePinnedBadgeState({
  required String? eventId,
  DateTime? cycleEnd,
  String? colorHex,
}) {}

void writeNewTabEnabled(bool enabled) {}

void writeReminderSchedule(String json) {}

Future<bool> downloadPng(Uint8List bytes, String filename) async => false;

Future<bool> copyPngToClipboard(Uint8List bytes) async => false;
