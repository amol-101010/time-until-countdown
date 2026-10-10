import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/seed/builtin_events.dart';
import 'database_provider.dart';
import 'settings_provider.dart';

/// Seeds the static built-ins (Today/This Month/This Year) once, syncs the
/// "My Life" built-in to the current birthdate/life-expectancy settings,
/// and keeps it in sync on future settings changes. Screens gate their
/// first paint on this via `ref.watch(appBootstrapProvider)`.
final appBootstrapProvider = FutureProvider<void>((ref) async {
  final repo = ref.watch(eventRepositoryProvider);
  await seedCoreBuiltIns(repo);

  Future<void> syncLifeEvent(Settings settings) async {
    final birthDate = settings.birthDate;
    if (birthDate == null) return;
    await repo.upsert(
      lifeEvent(
        birthDate: birthDate,
        lifeExpectancyYears: settings.lifeExpectancyYears,
      ),
    );
  }

  final initialSettings = await ref.read(settingsProvider.future);
  await syncLifeEvent(initialSettings);

  ref.listen(settingsProvider, (previous, next) {
    final settings = next.value;
    if (settings != null) {
      syncLifeEvent(settings);
    }
  });
});
