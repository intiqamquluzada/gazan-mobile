import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/social_sign_in.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../application/auth_controller.dart';

/// "Continue with Google / Apple". Renders nothing where neither is
/// available. The router takes over after a successful sign-in, including
/// asking for the phone number if the account has none yet.
class SocialButtons extends ConsumerStatefulWidget {
  const SocialButtons({super.key});

  @override
  ConsumerState<SocialButtons> createState() => _SocialButtonsState();
}

class _SocialButtonsState extends ConsumerState<SocialButtons> {
  bool _busy = false;

  Future<void> _run(Future<SocialCredential?> Function() signIn) async {
    if (_busy) return;
    setState(() => _busy = true);
    final S s = ref.read(sProvider);
    final AuthController auth = ref.read(authControllerProvider.notifier);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      final SocialCredential? c = await signIn();
      if (c == null) return;
      await auth.signInSocial(
        provider: c.provider,
        idToken: c.idToken,
        fullName: c.fullName,
      );
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(s.socialSignInFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final bool google = SocialSignIn.googleAvailable;
    final bool apple = SocialSignIn.appleAvailable;
    if (!google && !apple) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(s.orContinueWith, style: AppTextStyles.caption),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (google)
          OutlinedButton.icon(
            onPressed: _busy ? null : () => _run(SocialSignIn.google),
            icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
            label: Text(s.continueWithGoogle),
          ),
        if (google && apple) const SizedBox(height: AppSpacing.md),
        if (apple)
          OutlinedButton.icon(
            onPressed: _busy ? null : () => _run(SocialSignIn.apple),
            icon: const Icon(Icons.apple_rounded, size: 22),
            label: Text(s.continueWithApple),
          ),
      ],
    );
  }
}
