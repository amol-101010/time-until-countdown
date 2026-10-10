import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How progress renders across the app. [grid] (dots/dashes) is the
/// default and original style. [growthRings] (lib/ui/widgets/growth_rings.dart),
/// [clockGauge] (lib/ui/widgets/clock_gauge.dart), and [sandTimer]
/// (lib/ui/widgets/sand_timer.dart, animated) are alternatives.
enum VisualStyle { grid, growthRings, clockGauge, sandTimer }

/// How the home screen lays out events. [cards] (the default) is the
/// original spacious layout with the full progress visual per event.
/// [list] is a compact todo-list-style row per event instead - handy
/// where space is tight (the Chrome extension's popup, in particular).
enum HomeViewMode { cards, list }

class Settings {
  const Settings({
    this.birthDate,
    this.lifeExpectancyYears = 80,
    this.themeMode = ThemeMode.system,
    this.taskbarProgressEnabled = false,
    this.taskbarProgressEventId,
    this.visualStyle = VisualStyle.grid,
    this.homeWidgetEventId,
    this.syncBannerDismissed = false,
    this.homeViewMode = HomeViewMode.cards,
    this.pinnedEventId,
    this.hiddenBuiltInEventIds = const {},
    this.newTabEnabled = true,
  });

  final DateTime? birthDate;
  final int lifeExpectancyYears;
  final ThemeMode themeMode;

  final bool taskbarProgressEnabled;

  /// Which event drives the Windows taskbar progress indicator. Null
  /// means "the default" (the built-in "Today" event) - see
  /// taskbar_progress_provider.dart.
  final String? taskbarProgressEventId;

  final VisualStyle visualStyle;

  /// Which event the Android home-screen widget displays. Null means the
  /// default ("Today") - see widget_updater.dart.
  final String? homeWidgetEventId;

  /// Whether the user has dismissed the "sign in to sync" banner (see
  /// lib/ui/widgets/sign_in_banner.dart). Sticky until they sign in or
  /// clear app data - not shown again once dismissed, so it doesn't nag.
  final bool syncBannerDismissed;

  final HomeViewMode homeViewMode;

  /// The event currently shown in the floating always-on-top pin overlay
  /// (see lib/overlay/pin_overlay_controller.dart). Null means nothing is
  /// pinned. Only one event can be pinned at a time.
  final String? pinnedEventId;

  /// Built-in event ids (see BuiltInEventIds) the user has chosen to hide
  /// from the home screen - a lighter-weight alternative to deleting them,
  /// since built-ins can't be deleted outright (they're reseeded on every
  /// launch). Doesn't affect tag filtering, taskbar/widget pickers, or
  /// anything else - purely a home-screen display filter.
  final Set<String> hiddenBuiltInEventIds;

  /// Chrome extension only: whether new browser tabs open TimeUntil
  /// instead of Chrome's own new tab page. On by default (the extension
  /// registers the override); mirrored to chrome.storage.local for
  /// chrome_extension/newtab.js - see extension_sync_provider.dart.
  final bool newTabEnabled;

  Settings copyWith({
    DateTime? birthDate,
    int? lifeExpectancyYears,
    ThemeMode? themeMode,
    bool? taskbarProgressEnabled,
    String? taskbarProgressEventId,
    VisualStyle? visualStyle,
    String? homeWidgetEventId,
    bool? syncBannerDismissed,
    HomeViewMode? homeViewMode,
    String? pinnedEventId,
    bool clearPinnedEventId = false,
    Set<String>? hiddenBuiltInEventIds,
    bool? newTabEnabled,
  }) {
    return Settings(
      birthDate: birthDate ?? this.birthDate,
      lifeExpectancyYears: lifeExpectancyYears ?? this.lifeExpectancyYears,
      themeMode: themeMode ?? this.themeMode,
      taskbarProgressEnabled:
          taskbarProgressEnabled ?? this.taskbarProgressEnabled,
      taskbarProgressEventId:
          taskbarProgressEventId ?? this.taskbarProgressEventId,
      visualStyle: visualStyle ?? this.visualStyle,
      homeWidgetEventId: homeWidgetEventId ?? this.homeWidgetEventId,
      syncBannerDismissed: syncBannerDismissed ?? this.syncBannerDismissed,
      homeViewMode: homeViewMode ?? this.homeViewMode,
      pinnedEventId:
          clearPinnedEventId ? null : (pinnedEventId ?? this.pinnedEventId),
      hiddenBuiltInEventIds:
          hiddenBuiltInEventIds ?? this.hiddenBuiltInEventIds,
      newTabEnabled: newTabEnabled ?? this.newTabEnabled,
    );
  }
}

class _Keys {
  static const birthDateMillis = 'birthDateMillis';
  static const lifeExpectancyYears = 'lifeExpectancyYears';
  static const themeMode = 'themeMode';
  static const taskbarProgressEnabled = 'taskbarProgressEnabled';
  static const taskbarProgressEventId = 'taskbarProgressEventId';
  static const visualStyle = 'visualStyle';
  static const homeWidgetEventId = 'homeWidgetEventId';
  static const syncBannerDismissed = 'syncBannerDismissed';
  static const homeViewMode = 'homeViewMode';
  static const pinnedEventId = 'pinnedEventId';
  static const hiddenBuiltInEventIds = 'hiddenBuiltInEventIds';
  static const newTabEnabled = 'newTabEnabled';
}

class SettingsNotifier extends AsyncNotifier<Settings> {
  @override
  Future<Settings> build() async {
    final prefs = await SharedPreferences.getInstance();
    final birthMillis = prefs.getInt(_Keys.birthDateMillis);
    return Settings(
      birthDate: birthMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(birthMillis),
      lifeExpectancyYears: prefs.getInt(_Keys.lifeExpectancyYears) ?? 80,
      themeMode:
          ThemeMode.values[prefs.getInt(_Keys.themeMode) ?? ThemeMode.system.index],
      taskbarProgressEnabled:
          prefs.getBool(_Keys.taskbarProgressEnabled) ?? false,
      taskbarProgressEventId: prefs.getString(_Keys.taskbarProgressEventId),
      visualStyle: VisualStyle.values[prefs.getInt(_Keys.visualStyle) ?? 0],
      homeWidgetEventId: prefs.getString(_Keys.homeWidgetEventId),
      syncBannerDismissed: prefs.getBool(_Keys.syncBannerDismissed) ?? false,
      homeViewMode:
          HomeViewMode.values[prefs.getInt(_Keys.homeViewMode) ?? 0],
      pinnedEventId: prefs.getString(_Keys.pinnedEventId),
      hiddenBuiltInEventIds:
          (prefs.getStringList(_Keys.hiddenBuiltInEventIds) ?? const [])
              .toSet(),
      newTabEnabled: prefs.getBool(_Keys.newTabEnabled) ?? true,
    );
  }

  Future<void> setBirthDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_Keys.birthDateMillis, date.millisecondsSinceEpoch);
    final current = state.value ?? const Settings();
    state = AsyncData(current.copyWith(birthDate: date));
  }

  Future<void> setLifeExpectancyYears(int years) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_Keys.lifeExpectancyYears, years);
    final current = state.value ?? const Settings();
    state = AsyncData(current.copyWith(lifeExpectancyYears: years));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_Keys.themeMode, mode.index);
    final current = state.value ?? const Settings();
    state = AsyncData(current.copyWith(themeMode: mode));
  }

  Future<void> setTaskbarProgressEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_Keys.taskbarProgressEnabled, enabled);
    final current = state.value ?? const Settings();
    state = AsyncData(current.copyWith(taskbarProgressEnabled: enabled));
  }

  Future<void> setTaskbarProgressEventId(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_Keys.taskbarProgressEventId, eventId);
    final current = state.value ?? const Settings();
    state = AsyncData(current.copyWith(taskbarProgressEventId: eventId));
  }

  Future<void> setVisualStyle(VisualStyle style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_Keys.visualStyle, style.index);
    final current = state.value ?? const Settings();
    state = AsyncData(current.copyWith(visualStyle: style));
  }

  Future<void> setHomeWidgetEventId(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_Keys.homeWidgetEventId, eventId);
    final current = state.value ?? const Settings();
    state = AsyncData(current.copyWith(homeWidgetEventId: eventId));
  }

  Future<void> dismissSyncBanner() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_Keys.syncBannerDismissed, true);
    final current = state.value ?? const Settings();
    state = AsyncData(current.copyWith(syncBannerDismissed: true));
  }

  Future<void> setHomeViewMode(HomeViewMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_Keys.homeViewMode, mode.index);
    final current = state.value ?? const Settings();
    state = AsyncData(current.copyWith(homeViewMode: mode));
  }

  Future<void> setPinnedEventId(String? eventId) async {
    final prefs = await SharedPreferences.getInstance();
    if (eventId == null) {
      await prefs.remove(_Keys.pinnedEventId);
    } else {
      await prefs.setString(_Keys.pinnedEventId, eventId);
    }
    final current = state.value ?? const Settings();
    state = AsyncData(
      current.copyWith(pinnedEventId: eventId, clearPinnedEventId: eventId == null),
    );
  }

  Future<void> setNewTabEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_Keys.newTabEnabled, enabled);
    final current = state.value ?? const Settings();
    state = AsyncData(current.copyWith(newTabEnabled: enabled));
  }

  Future<void> setBuiltInEventHidden(String eventId, bool hidden) async {
    final current = state.value ?? const Settings();
    final updated = Set<String>.from(current.hiddenBuiltInEventIds);
    if (hidden) {
      updated.add(eventId);
    } else {
      updated.remove(eventId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_Keys.hiddenBuiltInEventIds, updated.toList());
    state = AsyncData(current.copyWith(hiddenBuiltInEventIds: updated));
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, Settings>(
  SettingsNotifier.new,
);
