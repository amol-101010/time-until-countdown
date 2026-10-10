// MV3 background service worker. Not part of the Flutter build - hand
// written and untouched by build.sh, which only copies Flutter's own
// output files into this folder.
//
// Two jobs, both driven by data the Flutter app mirrors into
// chrome.storage.local whenever it is open (see
// lib/state/providers/extension_badge_provider.dart and
// lib/state/providers/extension_sync_provider.dart):
//
// 1. Toolbar badge: a live countdown for the pinned event. The worker does
//    the countdown math itself and repaints every minute, so the badge
//    keeps ticking while no popup/side panel is open.
// 2. Reminders: Flutter writes the upcoming reminder times (storage key
//    `reminders`, a JSON string of {key, title, body, at}); this worker
//    fires them with chrome.notifications, so they arrive with the app
//    closed. An exact alarm is set for the soonest one, and the per-minute
//    tick is a safety net in case the worker was asleep or the browser was
//    closed at that moment.

const ALARM_NAME = 'dash-badge-tick';
const REMINDER_ALARM = 'dash-reminder-next';

// A reminder missed while the browser was closed is still shown if it is
// at most this old; anything older is skipped rather than spamming a stale
// "starting now" notification at startup.
const MAX_LATE_MS = 6 * 60 * 60 * 1000;
// How long fired keys are remembered (they only need to outlive the
// reminder's own entry in the schedule).
const FIRED_RETENTION_MS = 3 * 24 * 60 * 60 * 1000;

chrome.alarms.create(ALARM_NAME, { periodInMinutes: 1 });
chrome.alarms.onAlarm.addListener((alarm) => {
  if (alarm.name === ALARM_NAME) {
    updateBadge();
    checkReminders();
  } else if (alarm.name === REMINDER_ALARM) {
    checkReminders();
  }
});
chrome.storage.onChanged.addListener((changes, area) => {
  if (area !== 'local') return;
  if ('pinnedEventEndMillis' in changes || 'pinnedEventColor' in changes) {
    updateBadge();
  }
  if ('reminders' in changes) checkReminders();
});
chrome.runtime.onStartup.addListener(() => {
  updateBadge();
  checkReminders();
});
chrome.runtime.onInstalled.addListener(() => {
  updateBadge();
  checkReminders();
});

// Clicking a reminder opens the app in a tab.
chrome.notifications.onClicked.addListener((notificationId) => {
  chrome.notifications.clear(notificationId);
  chrome.tabs.create({ url: chrome.runtime.getURL('index.html') });
});

async function updateBadge() {
  const { pinnedEventEndMillis, pinnedEventColor } = await chrome.storage.local.get([
    'pinnedEventEndMillis',
    'pinnedEventColor',
  ]);

  if (!pinnedEventEndMillis) {
    await chrome.action.setBadgeText({ text: '' });
    return;
  }

  await chrome.action.setBadgeText({
    text: formatBadge(pinnedEventEndMillis - Date.now()),
  });
  await chrome.action.setBadgeBackgroundColor({
    color: pinnedEventColor || '#616161',
  });
}

function formatBadge(remainingMs) {
  if (remainingMs <= 0) return 'done';
  const minutes = Math.floor(remainingMs / 60000);
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);
  if (days >= 1) return `${days}d`;
  if (hours >= 1) return `${hours}h`;
  return `${minutes}m`;
}

function parseReminders(raw) {
  try {
    const list = JSON.parse(raw || '[]');
    return Array.isArray(list) ? list : [];
  } catch (_) {
    return [];
  }
}

// Shows every reminder that has come due and not been shown yet, then arms
// an exact alarm for the next upcoming one.
async function checkReminders() {
  const { reminders, firedReminders } = await chrome.storage.local.get([
    'reminders',
    'firedReminders',
  ]);
  const schedule = parseReminders(reminders);
  const fired = firedReminders && typeof firedReminders === 'object' ? firedReminders : {};
  const now = Date.now();
  let firedChanged = false;

  for (const r of schedule) {
    if (typeof r.at !== 'number' || r.at > now || fired[r.key]) continue;
    fired[r.key] = now;
    firedChanged = true;
    if (now - r.at > MAX_LATE_MS) continue;
    chrome.notifications.create(r.key, {
      type: 'basic',
      iconUrl: 'icons/icon128.png',
      title: r.title || 'TimeUntil',
      message: r.body || '',
      priority: 1,
    });
  }

  for (const key of Object.keys(fired)) {
    if (now - fired[key] > FIRED_RETENTION_MS) {
      delete fired[key];
      firedChanged = true;
    }
  }
  if (firedChanged) await chrome.storage.local.set({ firedReminders: fired });

  const next = schedule
    .filter((r) => typeof r.at === 'number' && r.at > now && !fired[r.key])
    .reduce((soonest, r) => (soonest === null || r.at < soonest ? r.at : soonest), null);
  if (next === null) {
    await chrome.alarms.clear(REMINDER_ALARM);
  } else {
    await chrome.alarms.create(REMINDER_ALARM, { when: next });
  }
}
