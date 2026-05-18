import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import '../utils/extensions.dart';

/// Brand monogram tile used wherever a business is shown.
///
/// Replaces the old emoji "logo": a rounded square filled with a soft tint
/// of the company's brand color and its initials in the brand color. Reads
/// as a real product mark, scales cleanly, and never looks like clip-art.
/// If a real logo URL ever lands on the model, pass [imageUrl] and it is
/// shown instead, with the monogram as a graceful fallback.
class CompanyLogo extends StatelessWidget {
  const CompanyLogo({
    super.key,
    required this.name,
    required this.brandColor,
    this.imageUrl,
    this.size = 56,
    this.radius = 16,
  });

  final String name;
  final Color brandColor;
  final String? imageUrl;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final BorderRadius shape = BorderRadius.circular(radius);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          brandColor.withValues(alpha: 0.14),
          Theme.of(context).colorScheme.surface,
        ),
        borderRadius: shape,
        border: Border.all(color: brandColor.withValues(alpha: 0.20)),
        image: imageUrl != null && imageUrl!.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? null
          : Text(
              name.initials,
              style: AppTextStyles.h3.copyWith(
                color: brandColor,
                fontSize: size * 0.34,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
    );
  }
}
