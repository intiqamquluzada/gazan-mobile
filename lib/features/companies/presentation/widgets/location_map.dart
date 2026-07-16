import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A static OpenStreetMap preview of a business location. Tapping it (or the
/// "Yol göstər" button) opens the device's maps app for directions. No API
/// key required — tiles come from the public OSM server.
class LocationMap extends ConsumerWidget {
  const LocationMap({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.companyName,
  });

  final double latitude;
  final double longitude;
  final String companyName;

  Future<void> _openDirections() async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final LatLng point = LatLng(latitude, longitude);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(s.address, style: AppTextStyles.h3),
              const Spacer(),
              TextButton.icon(
                onPressed: _openDirections,
                icon: const Icon(Icons.directions_rounded, size: 18),
                label: Text(s.directions),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: SizedBox(
              height: 170,
              child: Stack(
                children: <Widget>[
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: point,
                      initialZoom: 15,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                      onTap: (_, __) => _openDirections(),
                    ),
                    children: <Widget>[
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'az.qazan.app',
                      ),
                      MarkerLayer(
                        markers: <Marker>[
                          Marker(
                            point: point,
                            width: 44,
                            height: 44,
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.primary,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
