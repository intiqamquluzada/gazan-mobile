import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/extensions.dart';

/// Circular avatar that falls back to initials when no image is provided.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 40,
    this.background,
  });

  final String name;
  final String? imageUrl;
  final double size;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final Color bg = background ?? AppColors.primarySoft;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl != null
          ? null
          : Text(
              name.initials,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.primary,
                fontSize: size * 0.36,
              ),
            ),
    );
  }
}
