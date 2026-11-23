import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../i18n/strings.dart';
import '../network/api_exception.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_icons.dart';
import 'empty_state.dart';

/// Error code the server sends when a business owner has no venue yet.
const String kBusinessNotSetUp = 'BUSINESS_NOT_SET_UP';

bool isBusinessNotSetUp(Object e) =>
    e is ApiException && e.code == kBusinessNotSetUp;

/// What a failed load should say to a person: never raw exception text,
/// stack traces or HTTP jargon.
({String title, String body, IconData icon}) friendlyError(S s, Object e) {
  if (e is ApiException) {
    if (e.isNetwork) {
      return (
        title: s.errOfflineTitle,
        body: s.errOfflineBody,
        icon: Icons.wifi_off_rounded
      );
    }
    if (e.code == kBusinessNotSetUp) {
      return (
        title: s.bizSetupTitle,
        body: s.bizSetupBody,
        icon: Icons.storefront_outlined
      );
    }
    if (e.status >= 500) {
      return (
        title: s.errServerTitle,
        body: s.errServerBody,
        icon: Icons.cloud_off_rounded
      );
    }
    if (e.isUnauthorized || e.isForbidden) {
      return (
        title: s.errNoAccessTitle,
        body: s.errNoAccessBody,
        icon: Icons.lock_outline_rounded
      );
    }
    if (e.isNotFound) {
      return (
        title: s.errNotFoundTitle,
        body: s.errNotFoundBody,
        icon: Icons.search_off_rounded
      );
    }
    // Other 4xx: the server already wrote a localized, human message.
    return (title: s.errLoadTitle, body: e.message, icon: AppIcons.error);
  }
  return (title: s.errLoadTitle, body: s.errGenericBody, icon: AppIcons.error);
}

/// Full-size, calm placeholder for a screen or section that failed to load,
/// with a "Try again" button. A business owner without a venue gets a
/// "set up your business" prompt instead of an error.
class ErrorState extends ConsumerWidget {
  const ErrorState({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    if (isBusinessNotSetUp(error)) return const BusinessSetupPrompt();
    final ({String title, String body, IconData icon}) m =
        friendlyError(s, error);
    return EmptyState(
      title: m.title,
      subtitle: m.body,
      icon: m.icon,
      action: onRetry == null
          ? null
          : OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size(160, 46)),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(s.retry),
            ),
    );
  }
}

/// One-line version for small sections inside a larger screen.
class InlineError extends ConsumerWidget {
  const InlineError({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AppPalette p = context.palette;
    final ({String title, String body, IconData icon}) m =
        friendlyError(s, error);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: p.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: <Widget>[
          Icon(m.icon, size: 20, color: p.caramelText),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(m.title,
                style: AppTextStyles.bodySm.copyWith(color: p.textPrimary)),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: Text(s.retry)),
        ],
      ),
    );
  }
}

/// Shown to a business owner who has not created a venue yet.
class BusinessSetupPrompt extends ConsumerWidget {
  const BusinessSetupPrompt({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    return EmptyState(
      title: s.bizSetupTitle,
      subtitle: s.bizSetupBody,
      icon: Icons.storefront_outlined,
      action: FilledButton.icon(
        style: FilledButton.styleFrom(minimumSize: const Size(200, 50)),
        onPressed: () => context.go('/business/profile'),
        icon: const Icon(Icons.edit_rounded, size: 18),
        label: Text(s.bizSetupAction),
      ),
    );
  }
}

/// Text for a snackbar or inline message after an action failed. Server
/// messages are already localized and human; anything else (plugin errors,
/// type errors) is replaced by [fallback] instead of being shown raw.
String errorText(S s, Object e, {String? fallback}) {
  if (e is ApiException) {
    if (e.isNetwork) return s.errOfflineBody;
    if (e.status >= 500) return s.errServerBody;
    return e.message;
  }
  return fallback ?? s.errGenericBody;
}
