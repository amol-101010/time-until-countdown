import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/supabase_config.dart';
import 'overlay/pin_overlay_controller.dart';
import 'ui/overlay/pin_overlay_app.dart';

/// `desktop_multi_window` routes every window (main and sub-windows alike)
/// through this same `main()`; which one this is gets decided by asking
/// the plugin, not by raw process args - see
/// lib/overlay/pin_overlay_controller.dart and the package's own example.
/// On Android/iOS/web, the plugin has no implementation, so this is skipped
/// entirely and the app always starts as the normal main window.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    final windowController = await WindowController.fromCurrentEngine();
    if (windowController.arguments.isNotEmpty) {
      final windowArguments =
          jsonDecode(windowController.arguments) as Map<String, dynamic>;
      if (windowArguments['businessId'] == pinOverlayBusinessId) {
        runApp(
          ProviderScope(
            child:
                PinOverlayApp(eventId: windowArguments['eventId'] as String),
          ),
        );
        return;
      }
    }
  }

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
  }
  runApp(const ProviderScope(child: DashApp()));
}
