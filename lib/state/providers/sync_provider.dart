import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/sync/sync_engine.dart';
import 'auth_provider.dart';
import 'database_provider.dart';

/// Runs a [SyncEngine] for as long as a user is signed in; disposed (and
/// recreated) whenever the signed-in user changes, including to/from
/// signed-out. No-op (stays null) when signed out or Supabase isn't
/// configured, so the app is fully local-only in both cases.
final syncEngineProvider = Provider<SyncEngine?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;

  final engine = SyncEngine(
    localRepo: ref.watch(eventRepositoryProvider),
    localGroupRepo: ref.watch(groupRepositoryProvider),
    userId: user.id,
  );
  engine.start();
  ref.onDispose(engine.dispose);
  return engine;
});
