import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import '../i18n/strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// The public legal pages served by the backend (`/legal/...`).
enum LegalPage { privacy, terms, deleteAccount }

extension on LegalPage {
  String get path => switch (this) {
        LegalPage.privacy => 'privacy',
        LegalPage.terms => 'terms',
        LegalPage.deleteAccount => 'delete-account',
      };
}

/// Opens a legal page in the external browser, in the app's language.
Future<void> openLegalPage(String lang, LegalPage page) async {
  final Uri uri = Uri.parse(AppConfig.legalUrl(page.path, lang));
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // No browser available; nothing sensible to do.
  }
}

/// "By signing up you accept the Terms of use and the Privacy policy",
/// with both names tappable. Used under the sign-up forms.
class LegalConsentText extends ConsumerStatefulWidget {
  const LegalConsentText({super.key, this.textAlign = TextAlign.center});

  final TextAlign textAlign;

  @override
  ConsumerState<LegalConsentText> createState() => _LegalConsentTextState();
}

class _LegalConsentTextState extends ConsumerState<LegalConsentText> {
  late final TapGestureRecognizer _terms = TapGestureRecognizer();
  late final TapGestureRecognizer _privacy = TapGestureRecognizer();

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final String lang = s.lang;
    _terms.onTap = () => openLegalPage(lang, LegalPage.terms);
    _privacy.onTap = () => openLegalPage(lang, LegalPage.privacy);
    final TextStyle base =
        AppTextStyles.caption.copyWith(color: context.palette.textSecondary);
    final TextStyle link = base.copyWith(
      color: context.palette.caramelText,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );
    return Text.rich(
      TextSpan(style: base, children: <InlineSpan>[
        TextSpan(text: s.consentPrefix),
        TextSpan(text: s.termsOfUse, style: link, recognizer: _terms),
        TextSpan(text: s.consentAnd),
        TextSpan(text: s.privacyPolicy, style: link, recognizer: _privacy),
        TextSpan(text: s.consentSuffix),
      ]),
      textAlign: widget.textAlign,
    );
  }
}

/// Two small links ("Privacy policy · Terms of use") for screen footers.
class LegalFooterLinks extends ConsumerWidget {
  const LegalFooterLinks({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final TextStyle style = AppTextStyles.caption
        .copyWith(color: context.palette.textSecondary);
    Widget link(String label, LegalPage page) => InkWell(
          onTap: () => openLegalPage(s.lang, page),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(label,
                style: style.copyWith(decoration: TextDecoration.underline)),
          ),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        link(s.privacyPolicy, LegalPage.privacy),
        Text('·', style: style),
        link(s.termsOfUse, LegalPage.terms),
      ],
    );
  }
}
