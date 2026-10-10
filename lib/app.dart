import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'state/providers/extension_badge_provider.dart';
import 'state/providers/extension_sync_provider.dart';
import 'state/providers/home_widget_provider.dart';
import 'state/providers/notification_provider.dart';
import 'state/providers/settings_provider.dart';
import 'state/providers/sync_provider.dart';
import 'state/providers/taskbar_progress_provider.dart';
import 'ui/screens/auth_screen.dart';
import 'ui/screens/event_detail_screen.dart';
import 'ui/screens/event_form_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/theme/app_theme.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/event/new',
      builder: (context, state) => const EventFormScreen(),
    ),
    GoRoute(
      path: '/event/:id',
      builder: (context, state) =>
          EventDetailScreen(eventId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/event/:id/edit',
      builder: (context, state) =>
          EventFormScreen(eventId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
  ],
);

class DashApp extends ConsumerWidget {
  const DashApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      settingsProvider.select((s) => s.value?.themeMode ?? ThemeMode.system),
    );
    // Just watching these keeps the sync engine, notification sweep, and
    // taskbar progress alive - see their respective provider doc comments.
    ref.watch(syncEngineProvider);
    ref.watch(notificationDriverProvider);
    ref.watch(taskbarProgressProvider);
    ref.watch(homeWidgetDriverProvider);
    ref.watch(extensionBadgeProvider);
    ref.watch(extensionNewTabProvider);
    ref.watch(extensionRemindersProvider);

    return MaterialApp.router(
      title: 'TimeUntil',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
