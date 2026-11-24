import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/social_sign_in.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
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
        authorizationCode: c.authorizationCode,
      );
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      debugPrint('social sign-in failed: $e');
      // Google's status code (e.g. 10 = app fingerprint not registered)
      // tells us the cause when a tester reports it.
      final String? code =
          RegExp(r'ApiException: (\d+)').firstMatch('$e')?.group(1);
      messenger.showSnackBar(SnackBar(
        content: Text(code == null
            ? s.socialSignInFailed
            : '${s.socialSignInFailed} ($code)'),
      ));
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

    final AppPalette p = context.palette;
    // White buttons with a hairline neutral border and dark text — the
    // provider marks carry the colour.
    final ButtonStyle style = OutlinedButton.styleFrom(
      backgroundColor: p.surface,
      foregroundColor: p.textPrimary,
      side: BorderSide(color: p.border),
      minimumSize: const Size.fromHeight(48),
      shape: const StadiumBorder(),
      textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                s.orContinueWith,
                style: AppTextStyles.bodySm.copyWith(color: p.textTertiary),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (google)
          OutlinedButton.icon(
            style: style,
            onPressed: _busy ? null : () => _run(SocialSignIn.google),
            icon: const SizedBox.square(
              dimension: 19,
              child: CustomPaint(painter: _GoogleMark()),
            ),
            label: Text(s.signInWithGoogle),
          ),
        if (google && apple) const SizedBox(height: AppSpacing.md),
        if (apple)
          OutlinedButton.icon(
            style: style,
            onPressed: _busy ? null : () => _run(SocialSignIn.apple),
            icon: Icon(Icons.apple_rounded, size: 21, color: p.textPrimary),
            label: Text(s.signInWithApple),
          ),
      ],
    );
  }
}

/// The four-colour Google "G", drawn so no image asset is needed.
class _GoogleMark extends CustomPainter {
  const _GoogleMark();

  @override
  void paint(Canvas canvas, Size size) {
    final double d = size.shortestSide;
    final double sw = d * 0.2;
    final Rect r = Rect.fromCircle(
      center: Offset(d / 2, d / 2),
      radius: (d - sw) / 2,
    );
    Paint arc(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw;
    const double deg = math.pi / 180;
    canvas.drawArc(
        r, -40 * deg, -100 * deg, false, arc(const Color(0xFFEA4335)));
    canvas.drawArc(
        r, -140 * deg, -80 * deg, false, arc(const Color(0xFFFBBC05)));
    canvas.drawArc(
        r, 140 * deg, -90 * deg, false, arc(const Color(0xFF34A853)));
    canvas.drawArc(r, 50 * deg, -50 * deg, false, arc(const Color(0xFF4285F4)));
    canvas.drawRect(
      Rect.fromLTWH(d / 2, d / 2 - sw / 2, (d - sw) / 2 + sw / 2, sw),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(_GoogleMark oldDelegate) => false;
}
