import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/phone_util.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/avatar.dart';
import '../../../../core/widgets/phone_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../auth/domain/app_user.dart';
import '../../../auth/domain/user_role.dart';
import '../../../media/data/media_repository.dart';
import '../../data/profile_remote_data_source.dart';
import '_sheet_handle.dart';

class EditProfileSheet extends ConsumerStatefulWidget {
  const EditProfileSheet({super.key});

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  // Same contract as the sign-up / complete-profile phone input.
  String _dialCode = '+994';
  bool _saving = false;
  bool _uploadingAvatar = false;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    final AppUser? u = ref.read(currentUserProvider);
    _name = TextEditingController(text: u?.fullName ?? '');
    _email = TextEditingController(text: u?.email ?? '');
    // Show a home-country number without its dial code (the picker shows
    // it); any other number stays in its full international form.
    final String phone = u?.phone ?? '';
    _phone = TextEditingController(
        text: phone.startsWith(_dialCode)
            ? phone.substring(_dialCode.length)
            : phone);
    _avatarUrl = u?.avatarUrl;
  }

  /// Pick → upload → persist the avatar immediately (no "save" needed),
  /// mirroring the business logo flow.
  Future<void> _pickAvatar() async {
    final XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() => _uploadingAvatar = true);
    try {
      final String url = await ref.read(mediaRepositoryProvider).uploadImage(
            bytes: await file.readAsBytes(),
            filename: file.name,
          );
      await ref
          .read(profileRemoteDataSourceProvider)
          .updateProfile(avatarUrl: url);
      ref.read(authControllerProvider.notifier).updateProfile(avatarUrl: url);
      if (!mounted) return;
      setState(() => _avatarUrl = url);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final AppUser updated =
          await ref.read(profileRemoteDataSourceProvider).updateProfile(
                fullName: _name.text.trim(),
                phone: _phone.text.trim().isEmpty
                    ? null
                    : PhoneUtil.normalize(_phone.text, _dialCode),
              );
      ref.read(authControllerProvider.notifier).updateProfile(
            fullName: updated.fullName,
            phone: updated.phone,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(sProvider).profileUpdated)),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _avatarPicker() {
    final String name = _name.text.trim().isEmpty
        ? (ref.read(currentUserProvider)?.fullName ?? 'Q')
        : _name.text.trim();
    return GestureDetector(
      onTap: _uploadingAvatar ? null : _pickAvatar,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          Avatar(name: name, imageUrl: _avatarUrl, size: 96),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.action,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 2),
            ),
            child: _uploadingAvatar
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onDark,
                    ),
                  )
                : const Icon(Icons.camera_alt_rounded,
                    size: 16, color: AppColors.onDark),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final EdgeInsets bottom = MediaQuery.viewInsetsOf(context);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      padding: bottom,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SheetHandle(),
              const SizedBox(height: AppSpacing.lg),
              Text(s.editProfile, style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.xl),
              Center(child: _avatarPicker()),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                label: s.fullName,
                controller: _name,
                prefixIcon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
                validator: (String? v) =>
                    (v == null || v.trim().length < 2) ? s.enterName : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: s.emailReadOnly,
                controller: _email,
                readOnly: true,
                prefixIcon: Icons.alternate_email_rounded,
              ),
              const SizedBox(height: AppSpacing.lg),
              PhoneField(
                controller: _phone,
                onDialChanged: (String v) => _dialCode = v,
                textInputAction: TextInputAction.done,
                // Customers are identified by phone; business and admin
                // accounts may leave it empty.
                isRequired:
                    ref.read(currentUserProvider)?.role == UserRole.customer,
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: s.save,
                icon: Icons.check_rounded,
                loading: _saving,
                onPressed: _save,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(s.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
