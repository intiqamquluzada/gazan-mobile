import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../config/app_config.dart';
import '../platform/app_variant.dart';

/// An identity token ready for `POST /auth/social`.
class SocialCredential {
  const SocialCredential({
    required this.provider,
    required this.idToken,
    this.fullName,
    this.authorizationCode,
  });

  final String provider; // GOOGLE | APPLE
  final String idToken;
  final String? fullName;

  /// Apple only: one-time code the server trades for a refresh token, so
  /// it can revoke the Apple session when the account is deleted.
  final String? authorizationCode;
}

/// Native Google / Apple sign-in. Phones only: the Windows business app
/// signs in with phone or email and never touches these plugins.
class SocialSignIn {
  const SocialSignIn._();

  /// Screenshot / design tooling only: show both buttons on any platform.
  @visibleForTesting
  static bool previewButtons = false;

  /// On iOS Google is offered only together with Sign in with Apple:
  /// App Review guideline 4.8 requires an equivalent privacy-focused login
  /// whenever a third-party login is shown.
  static bool get googleAvailable =>
      previewButtons ||
      PlatformCaps.isMobile &&
          !AppVariant.isBusinessApp &&
          AppConfig.googleServerClientId.isNotEmpty &&
          (!PlatformCaps.isIOS || _appleEnabled);

  /// Off unless the build opts in with `--dart-define=APPLE_SIGN_IN=true`:
  /// the backend must have APPLE_CLIENT_IDS configured first, and a button
  /// that cannot sign anyone in fails App Review.
  static const bool _appleEnabled =
      bool.fromEnvironment('APPLE_SIGN_IN', defaultValue: true);

  static bool get appleAvailable =>
      previewButtons ||
      _appleEnabled && PlatformCaps.isIOS && !AppVariant.isBusinessApp;

  /// Returns null when the user backs out of the account picker.
  static Future<SocialCredential?> google() async {
    final GoogleSignIn client = GoogleSignIn(
      clientId:
          AppConfig.googleIosClientId.isEmpty ? null : AppConfig.googleIosClientId,
      serverClientId: AppConfig.googleServerClientId,
      scopes: const <String>['email', 'profile'],
    );
    // Always show the picker instead of silently reusing the last account.
    await client.signOut();
    final GoogleSignInAccount? account = await client.signIn();
    if (account == null) return null;
    final GoogleSignInAuthentication auth = await account.authentication;
    final String? token = auth.idToken;
    if (token == null || token.isEmpty) return null;
    return SocialCredential(
      provider: 'GOOGLE',
      idToken: token,
      fullName: account.displayName,
    );
  }

  /// Returns null when the user cancels the Apple sheet.
  static Future<SocialCredential?> apple() async {
    try {
      final AuthorizationCredentialAppleID c =
          await SignInWithApple.getAppleIDCredential(
        scopes: const <AppleIDAuthorizationScopes>[
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final String? token = c.identityToken;
      if (token == null || token.isEmpty) return null;
      // Apple sends the name only on the very first authorization.
      final String name = <String?>[c.givenName, c.familyName]
          .whereType<String>()
          .join(' ')
          .trim();
      return SocialCredential(
        provider: 'APPLE',
        idToken: token,
        fullName: name.isEmpty ? null : name,
        authorizationCode: c.authorizationCode,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    }
  }
}
