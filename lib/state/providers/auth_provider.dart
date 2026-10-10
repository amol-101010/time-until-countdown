import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';

/// Null when signed out or when Supabase isn't configured yet (see
/// SupabaseConfig.isConfigured) - the app works fully local-only in
/// either case, sync just doesn't run (see sync_engine.dart).
final authStateProvider = StreamProvider<User?>((ref) {
  if (!SupabaseConfig.isConfigured) {
    return Stream.value(null);
  }
  final auth = Supabase.instance.client.auth;
  return auth.onAuthStateChange.map((data) => data.session?.user).distinct(
        (a, b) => a?.id == b?.id,
      );
});

final isSignedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).value != null;
});
