import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/i18n/strings.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/avatar.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../auth/domain/app_user.dart';
import '../../../media/data/media_repository.dart';
import '../../data/profile_remote_data_source.dart';
import '../sheets/_sheet_handle.dart';

/// True while a profile photo is being uploaded or removed, so every avatar
/// on screen shows the same progress state.
final StateProvider<bool> avatarBusyProvider =
    StateProvider<bool>((Ref ref) => false);

/// The signed-in user's avatar. Tapping it opens "Upload new photo" /
/// "Remove photo"; the change is saved straight away.
class EditableAvatar extends ConsumerWidget {
  const EditableAvatar({super.key, this.size = 56, this.fallbackName});

  final double size;

  /// Name for the initials when the user has none (e.g. business fallback).
  final String? fallbackName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppUser? user = ref.watch(currentUserProvider);
    final bool busy = ref.watch(avatarBusyProvider);
    final AppPalette p = context.palette;
    final double badge = (size * 0.36).clamp(20.0, 30.0);
    return Semantics(
      button: true,
      label: ref.watch(sProvider).avatarTitle,
      child: GestureDetector(
        onTap: busy ? null : () => showAvatarActions(context, ref),
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Avatar(
                name: user?.fullName ?? fallbackName ?? 'Q',
                imageUrl: user?.avatarUrl,
                size: size,
              ),
              if (busy)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.media.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SizedBox.square(
                        dimension: size * 0.34,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: AppColors.onDark,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: badge,
                  height: badge,
                  decoration: BoxDecoration(
                    color: p.action,
                    shape: BoxShape.circle,
                    border: Border.all(color: p.surface, width: 2),
                  ),
                  child: Icon(
                    Icons.photo_camera_rounded,
                    size: badge * 0.55,
                    color: AppColors.onDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet with the photo actions. "Remove" only shows when there is a
/// photo to remove.
Future<void> showAvatarActions(BuildContext context, WidgetRef ref) async {
  final S s = ref.read(sProvider);
  final bool hasPhoto =
      (ref.read(currentUserProvider)?.avatarUrl ?? '').isNotEmpty;
  final String? choice = await showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    showDragHandle: false,
    builder: (BuildContext ctx) {
      final AppPalette p = ctx.palette;
      Widget option(String value, IconData icon, String title, String sub,
          {bool danger = false}) {
        final Color tint = danger ? AppColors.dangerText : p.action;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: danger ? p.dangerSoft : p.caramelSoft,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: tint),
          ),
          title: Text(title,
              style: AppTextStyles.bodyLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: danger ? AppColors.dangerText : p.textPrimary)),
          subtitle: Text(sub, style: AppTextStyles.bodySm),
          onTap: () => Navigator.of(ctx).pop(value),
        );
      }

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SheetHandle(),
              const SizedBox(height: AppSpacing.lg),
              Text(s.avatarTitle, style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.md),
              option('upload', Icons.photo_library_rounded, s.avatarUpload,
                  s.avatarUploadSub),
              if (hasPhoto)
                option('remove', Icons.delete_outline_rounded, s.avatarRemove,
                    s.avatarRemoveSub,
                    danger: true),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(s.cancel),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (choice == null || !context.mounted) return;
  if (choice == 'upload') {
    await _upload(context, ref);
  } else if (choice == 'remove') {
    await _remove(context, ref);
  }
}

Future<void> _upload(BuildContext context, WidgetRef ref) async {
  final S s = ref.read(sProvider);
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final XFile? file = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 800,
    maxHeight: 800,
    imageQuality: 85,
  );
  if (file == null) return;
  ref.read(avatarBusyProvider.notifier).state = true;
  try {
    final Uint8List bytes = await file.readAsBytes();
    if (bytes.length > 5 * 1024 * 1024) {
      messenger.showSnackBar(SnackBar(content: Text(s.avatarTooLarge)));
      return;
    }
    final String url = await ref.read(mediaRepositoryProvider).uploadImage(
          bytes: bytes,
          filename: file.name,
          contentType: _contentType(file.name),
        );
    await ref
        .read(profileRemoteDataSourceProvider)
        .updateProfile(avatarUrl: url);
    ref.read(authControllerProvider.notifier).updateProfile(avatarUrl: url);
    messenger.showSnackBar(SnackBar(content: Text(s.avatarUpdated)));
  } on ApiException catch (e) {
    messenger.showSnackBar(
        SnackBar(content: Text(e.isNetwork ? s.avatarFailed : e.message)));
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(s.avatarFailed)));
  } finally {
    ref.read(avatarBusyProvider.notifier).state = false;
  }
}

Future<void> _remove(BuildContext context, WidgetRef ref) async {
  final S s = ref.read(sProvider);
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  ref.read(avatarBusyProvider.notifier).state = true;
  try {
    await ref.read(profileRemoteDataSourceProvider).removeAvatar();
    ref.read(authControllerProvider.notifier).updateProfile(clearAvatar: true);
    messenger.showSnackBar(SnackBar(content: Text(s.avatarRemoved)));
  } on ApiException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(s.errorTryAgain)));
  } finally {
    ref.read(avatarBusyProvider.notifier).state = false;
  }
}

String _contentType(String name) {
  final String n = name.toLowerCase();
  if (n.endsWith('.png')) return 'image/png';
  // image_picker re-encodes to JPEG when a quality is set, so HEIC
  // originals arrive as JPEG bytes (the server accepts jpeg/png/webp/gif).
  if (n.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}
