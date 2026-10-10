// Public entry point - picks the real web implementation
// (chrome_extension_bridge_web.dart, uses dart:js_interop) when compiled
// for web, or a no-op stub (chrome_extension_bridge_stub.dart) everywhere
// else, since dart:js_interop isn't available off the web and Windows/
// Android have no toolbar-icon badge to write anyway.
export 'chrome_extension_bridge_stub.dart'
    if (dart.library.js_interop) 'chrome_extension_bridge_web.dart';
