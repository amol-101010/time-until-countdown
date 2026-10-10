import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/supabase_config.dart';
import '../../state/providers/auth_provider.dart';
import '../../state/providers/settings_provider.dart';

/// A dismissible call-to-action on the home screen nudging signed-out
/// users toward creating an account, since sync only happens for
/// signed-in users (see sync_engine.dart) and the sign-in screen
/// otherwise only surfaces inside Settings, where it's easy to miss.
///
/// Renders nothing when Supabase isn't configured, the user is already
/// signed in, or they've dismissed it before (see
/// Settings.syncBannerDismissed).
class SignInBanner extends ConsumerWidget {
  const SignInBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!SupabaseConfig.isConfigured) return const SizedBox.shrink();

    final isSignedIn = ref.watch(isSignedInProvider);
    final dismissed = ref.watch(
      settingsProvider.select((s) => s.value?.syncBannerDismissed ?? false),
    );
    if (isSignedIn || dismissed) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.cloud_sync_outlined, color: theme.colorScheme.onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sign in to sync',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Keep your events backed up and in sync across devices',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => context.push('/auth'),
              child: const Text('Sign in'),
            ),
            IconButton(
              icon: Icon(Icons.close, color: theme.colorScheme.onPrimaryContainer, size: 20),
              tooltip: 'Dismiss',
              onPressed: () =>
                  ref.read(settingsProvider.notifier).dismissSyncBanner(),
            ),
          ],
        ),
      ),
    );
  }
}
