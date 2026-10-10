import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

/// Talks to chrome.storage.local so the extension's background service
/// worker (chrome_extension/background.js, not part of the Flutter build)
/// can show the pinned event's countdown on the toolbar icon's badge even
/// while no popup/side panel is open. See
/// lib/state/providers/extension_badge_provider.dart for what writes here.
///
/// A no-op everywhere except when actually running as a Chrome extension:
/// `chrome` is undefined on a plain web page (or any non-web platform,
/// though [kIsWeb] short-circuits before that matters), so every call below
/// is guarded by [isChromeExtension].

@JS('chrome.runtime.id')
external JSAny? get _chromeRuntimeId;

@JS('chrome.storage.local.set')
external JSPromise<JSAny?> _storageLocalSet(JSObject items);

bool get isChromeExtension {
  if (!kIsWeb) return false;
  try {
    return _chromeRuntimeId != null;
  } catch (_) {
    // `chrome` itself is undefined outside an extension context - a plain
    // web page load, e.g. the Windows/Android app's Flutter web tests.
    return false;
  }
}

/// Writes the pinned event's end time (badge counts down to it) and color
/// (badge background) - or clears both when [eventId] is null (unpinned).
void writePinnedBadgeState({
  required String? eventId,
  DateTime? cycleEnd,
  String? colorHex,
}) {
  if (!isChromeExtension) return;

  final items = JSObject();
  items.setProperty('pinnedEventId'.toJS, (eventId ?? '').toJS);
  items.setProperty(
    'pinnedEventEndMillis'.toJS,
    (cycleEnd?.millisecondsSinceEpoch ?? 0).toJS,
  );
  items.setProperty('pinnedEventColor'.toJS, (colorHex ?? '').toJS);
  _storageLocalSet(items);
}

/// Mirrors the "Replace new tab page" setting for chrome_extension/
/// newtab.js, which reads it on every new tab (see
/// lib/state/providers/extension_sync_provider.dart).
void writeNewTabEnabled(bool enabled) {
  if (!isChromeExtension) return;

  final items = JSObject();
  items.setProperty('newTabEnabled'.toJS, enabled.toJS);
  _storageLocalSet(items);
}

/// Hands the upcoming reminder schedule (a JSON array of
/// `{key, title, body, at}`) to the background service worker, which
/// fires them with chrome.notifications even while the app is closed.
void writeReminderSchedule(String json) {
  if (!isChromeExtension) return;

  final items = JSObject();
  items.setProperty('reminders'.toJS, json.toJS);
  _storageLocalSet(items);
}

JSObject _pngBlob(Uint8List bytes) {
  final options = JSObject()..setProperty('type'.toJS, 'image/png'.toJS);
  return (globalContext['Blob'] as JSFunction).callAsConstructor<JSObject>(
    [bytes.toJS].toJS,
    options,
  );
}

/// Saves [bytes] as a PNG named [filename] via a temporary download link.
/// Returns false if the browser refused.
Future<bool> downloadPng(Uint8List bytes, String filename) async {
  try {
    final url = globalContext['URL'] as JSObject;
    final objectUrl =
        (url.callMethod('createObjectURL'.toJS, _pngBlob(bytes)) as JSString)
            .toDart;
    final document = globalContext['document'] as JSObject;
    final link = document.callMethod('createElement'.toJS, 'a'.toJS) as JSObject;
    link.setProperty('href'.toJS, objectUrl.toJS);
    link.setProperty('download'.toJS, filename.toJS);
    link.callMethod('click'.toJS);
    url.callMethod('revokeObjectURL'.toJS, objectUrl.toJS);
    return true;
  } catch (_) {
    return false;
  }
}

/// Puts [bytes] on the clipboard as an image. Returns false if the
/// browser refused (e.g. the page isn't focused).
Future<bool> copyPngToClipboard(Uint8List bytes) async {
  try {
    final itemData = JSObject()..setProperty('image/png'.toJS, _pngBlob(bytes));
    final item = (globalContext['ClipboardItem'] as JSFunction)
        .callAsConstructor<JSObject>(itemData);
    final clipboard =
        (globalContext['navigator'] as JSObject)['clipboard'] as JSObject;
    final result = clipboard.callMethod('write'.toJS, [item].toJS);
    await (result as JSPromise<JSAny?>).toDart;
    return true;
  } catch (_) {
    return false;
  }
}
