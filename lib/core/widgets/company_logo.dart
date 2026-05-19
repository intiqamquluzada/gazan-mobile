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
    final bool hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    final Widget monogram = Container(
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
      ),
      child: Text(
        name.initials,
        style: AppTextStyles.h3.copyWith(
          color: brandColor,
          fontSize: size * 0.34,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
    );

    if (!hasImage) return monogram;

    // Monogram sits underneath; the network image covers it once loaded.
    // On error/while loading the monogram shows through — never a blank box.
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          monogram,
          ClipRRect(
            borderRadius: shape,
            child: Image.network(
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              frameBuilder: (BuildContext _, Widget child, int? frame,
                  bool wasSyncLoaded) {
                if (wasSyncLoaded || frame != null) return child;
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
