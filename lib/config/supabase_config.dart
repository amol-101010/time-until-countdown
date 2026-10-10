/// Supabase project credentials for cloud sync.
///
/// Fill these in after following docs/SUPABASE_SETUP.md - Project Settings
/// > API in your Supabase dashboard has both values.
///
/// The anon key is safe to ship in the app (it's what Supabase's own docs
/// call the "public" key): it can only do what the row-level security
/// policy in supabase/schema.sql allows, which is "read/write your own
/// rows." Never put the `service_role` key here - that one bypasses RLS
/// entirely and must stay server-side only (this app has no server side).
class SupabaseConfig {
  const SupabaseConfig._();

  static const String url = '';

  /// Supabase's dashboard currently labels this the "anon / public" key;
  /// the SDK itself now calls the same value `publishableKey`.
  static const String publishableKey = '';

  /// Sync (and the sign-in screen) is skipped entirely when this is false,
  /// so the app works exactly as it did before Supabase was added until
  /// you've actually filled in [url]/[publishableKey].
  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}
