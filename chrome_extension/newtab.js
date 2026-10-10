// Hand-written, not part of the Flutter build (build.sh never touches it).
//
// Runs every time a new tab opens (chrome_url_overrides.newtab ->
// newtab.html). The Flutter app mirrors its "Replace new tab page"
// setting into chrome.storage.local.newTabEnabled (see
// lib/state/providers/extension_sync_provider.dart); absent means the
// default, which is on.
//
// Off: send this tab to Chrome's built-in new tab page. An extension
// can't un-register its override at runtime, so this redirect is how the
// switch works - expect a brief flash before Chrome's page appears.

const CHROME_NEW_TAB_PAGE = 'chrome://new-tab-page/';

(async () => {
  let enabled = true;
  try {
    const { newTabEnabled } = await chrome.storage.local.get('newTabEnabled');
    enabled = newTabEnabled !== false;
  } catch (_) {
    // Storage unreadable: fall back to showing the app rather than
    // stranding the user on a blank page.
  }

  if (enabled) {
    location.replace('index.html');
    return;
  }

  try {
    const tab = await chrome.tabs.getCurrent();
    await chrome.tabs.update(tab.id, { url: CHROME_NEW_TAB_PAGE });
  } catch (_) {
    document.body.textContent =
      'TimeUntil new tab is turned off. Open TimeUntil > Settings to turn it back on.';
  }
})();
