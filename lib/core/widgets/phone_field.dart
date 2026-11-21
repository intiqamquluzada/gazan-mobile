import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/strings.dart';
import '../location/default_country.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/phone_util.dart';

/// Phone number input with a country-code picker. Defaults to Azerbaijan
/// and follows the IP/region country once it is known, unless the user has
/// already started typing or picked a country.
class PhoneField extends ConsumerStatefulWidget {
  const PhoneField({
    super.key,
    required this.controller,
    required this.onDialChanged,
    this.isRequired = true,
    this.label,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final TextEditingController controller;

  /// Reports the selected dial code ("+994"). Store it; do not rebuild on it.
  final ValueChanged<String> onDialChanged;
  final bool isRequired;
  final String? label;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  ConsumerState<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends ConsumerState<PhoneField> {
  String _iso = 'AZ';
  bool _userPicked = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual<AsyncValue<String>>(
      defaultCountryCodeProvider,
      (AsyncValue<String>? _, AsyncValue<String> next) {
        final String? cc = next.valueOrNull;
        if (cc != null) Future<void>.microtask(() => _applyCountry(cc));
      },
      fireImmediately: true,
    );
  }

  void _applyCountry(String cc) {
    if (!mounted || _userPicked || widget.controller.text.isNotEmpty) return;
    try {
      final String? dial = CountryCode.fromCountryCode(cc).dialCode;
      if (dial == null || dial.isEmpty) return;
      setState(() => _iso = cc);
      widget.onDialChanged(dial);
    } catch (_) {
      // Unknown ISO code — keep the current default.
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.label ?? s.phone,
          style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: context.palette.border),
          ),
          child: Row(
            children: <Widget>[
              CountryCodePicker(
                key: ValueKey<String>(_iso),
                onChanged: (CountryCode c) {
                  _userPicked = true;
                  _iso = c.code ?? _iso;
                  final String? dial = c.dialCode;
                  if (dial != null) widget.onDialChanged(dial);
                },
                initialSelection: _iso,
                favorite: const <String>['+994', 'AZ', '+90', 'TR', '+7'],
                showFlag: true,
                showDropDownButton: true,
                padding: EdgeInsets.zero,
                textStyle: AppTextStyles.body,
              ),
              const SizedBox(height: 24, child: VerticalDivider(width: 1)),
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  keyboardType: TextInputType.phone,
                  textInputAction: widget.textInputAction,
                  onFieldSubmitted: widget.onSubmitted,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[+0-9 ()-]')),
                  ],
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(
                    hintText: '50 123 45 67',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  ),
                  validator: (String? v) {
                    final String val = (v ?? '').trim();
                    if (val.isEmpty) {
                      return widget.isRequired ? s.phoneRequired : null;
                    }
                    return PhoneUtil.isValid(val) ? null : s.phoneNumberInvalid;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The dial code for the device's most likely country, for screens that
/// have to interpret a bare national number without showing a picker.
String defaultDialCode(WidgetRef ref) {
  final String? cc = ref.read(defaultCountryCodeProvider).valueOrNull;
  if (cc != null) {
    try {
      final String? dial = CountryCode.fromCountryCode(cc).dialCode;
      if (dial != null && dial.isNotEmpty) return dial;
    } catch (_) {}
  }
  return '+994';
}
