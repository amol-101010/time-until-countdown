#!/usr/bin/env bash
# Rebuilds the Flutter web app and refreshes this extension folder from it.
# Run from anywhere; paths are relative to this script's location.
set -euo pipefail
cd "$(dirname "$0")/.."

flutter build web --no-tree-shake-icons --no-web-resources-cdn

cd chrome_extension
rm -rf assets canvaskit
cp -r ../build/web/assets .
cp -r ../build/web/canvaskit .
cp ../build/web/drift_worker.js .
cp ../build/web/flutter.js .
cp ../build/web/flutter_bootstrap.js .
cp ../build/web/index.html .
cp ../build/web/main.dart.js .
cp ../build/web/sqlite3.wasm .
cp ../build/web/version.json .
cp ../build/web/favicon.png .

# `flutter build web` bundles every CanvasKit renderer variant (skwasm,
# skwasm_heavy, wimp) regardless of which one actually gets used -
# flutter_bootstrap.js's buildConfig only ever declares the "canvaskit"
# renderer for this app, so those variants are dead weight (~11.5MB) that
# never gets fetched at runtime. Same for assets/NOTICES (~1.5MB of
# license text nothing reads). Strip them here rather than at the Flutter
# build step, since `flutter build web` doesn't offer a flag for this.
rm -f canvaskit/skwasm*.wasm canvaskit/skwasm*.js canvaskit/skwasm*.js.symbols
rm -f canvaskit/wimp*.wasm canvaskit/wimp*.js canvaskit/wimp*.js.symbols
rm -f assets/NOTICES

# We only ship to Chromium-based browsers. flutter.js's loader picks the
# smaller canvaskit/chromium/ variant at runtime whenever the browser has
# the ImageDecoder API and Intl.v8BreakIterator/Segmenter - true for every
# Chromium build - falling back to the top-level "full" variant only for
# non-Chromium engines (Firefox/Safari), which we don't target. Drop the
# top-level variant too.
rm -f canvaskit/canvaskit.wasm canvaskit/canvaskit.js canvaskit/canvaskit.js.symbols

# The copied index.html re-adds <link rel="manifest" href="manifest.json">,
# which fights with this folder's manifest.json being the Chrome EXTENSION
# manifest (not a PWA one) - strip it back out every rebuild.
sed -i '/<link rel="manifest" href="manifest.json">/d' index.html

# popup.html is a separate, hand-authored file (not copied from build/web/)
# that just wraps the same flutter_bootstrap.js/main.dart.js with an
# explicit fixed size, since a Chrome extension popup doesn't auto-size to
# its content the way index.html's other targets (new tab, side panel) do.
# It picks up app code changes automatically via those shared files - no
# regeneration needed here.

echo "chrome_extension/ refreshed. Reload it from chrome://extensions."
