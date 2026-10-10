import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// True when running as this Chrome extension's popup (chrome_extension/
/// popup.html) specifically - not the side panel or a regular tab, both
/// of which already have a full-size view and don't need an escape
/// hatch. The popup is fixed-size by design (see popup.html's own
/// comment), so this button is how a user gets the roomier full-tab
/// experience on demand instead of the extension forcing it on everyone
/// via a chrome_url_overrides.newtab override.
bool get isChromeExtensionPopup =>
    kIsWeb && Uri.base.path.endsWith('popup.html');

/// AppBar action that opens chrome_extension/index.html in a new browser
/// tab. Only renders anything when [isChromeExtensionPopup] is true -
/// null everywhere else (other platforms, the side panel, a regular tab).
class OpenInTabButton extends StatelessWidget {
  const OpenInTabButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!isChromeExtensionPopup) return const SizedBox.shrink();

    return IconButton(
      icon: const Icon(Icons.open_in_new),
      tooltip: 'Open in new tab',
      onPressed: () {
        final target = Uri.base.replace(path: '/index.html');
        launchUrl(target, webOnlyWindowName: '_blank');
      },
    );
  }
}
