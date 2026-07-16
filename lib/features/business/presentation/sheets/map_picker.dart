import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Opens a full-screen map so the business owner can pin their exact
/// location. Tap anywhere to move the marker, use the "my location"
/// button to jump to the device's position, then confirm. Returns the
/// chosen `(lat, lng)` or null if cancelled.
///
/// Uses OpenStreetMap tiles (no API key). Swap the [TileLayer] for a
/// Google raster tile source later if a Maps key is provisioned.
Future<({double lat, double lng})?> pickLocationOnMap(
  BuildContext context, {
  double? initialLat,
  double? initialLng,
}) {
  return Navigator.of(context).push<({double lat, double lng})?>(
    MaterialPageRoute<({double lat, double lng})?>(
      fullscreenDialog: true,
      builder: (_) => _MapPickerScreen(
        initialLat: initialLat,
        initialLng: initialLng,
      ),
    ),
  );
}

class _MapPickerScreen extends ConsumerStatefulWidget {
  const _MapPickerScreen({this.initialLat, this.initialLng});

  final double? initialLat;
  final double? initialLng;

  @override
  ConsumerState<_MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends ConsumerState<_MapPickerScreen> {
  // Baku city centre — a sensible default when the owner has no coords yet.
  static const LatLng _fallback = LatLng(40.4093, 49.8671);

  final MapController _map = MapController();
  late LatLng _selected;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _selected = (widget.initialLat != null && widget.initialLng != null)
        ? LatLng(widget.initialLat!, widget.initialLng!)
        : _fallback;
  }

  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }
      final Position pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final LatLng me = LatLng(pos.latitude, pos.longitude);
      setState(() => _selected = me);
      _map.move(me, 16);
    } catch (_) {
      // ignore — the owner can still tap to place the pin manually
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    return Scaffold(
      appBar: AppBar(title: Text(s.pickLocationTitle)),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              s.mapTapHint,
              style: AppTextStyles.bodySm
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
                FlutterMap(
                  mapController: _map,
                  options: MapOptions(
                    initialCenter: _selected,
                    initialZoom: 15,
                    onTap: (_, LatLng p) => setState(() => _selected = p),
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
                          point: _selected,
                          width: 46,
                          height: 46,
                          alignment: Alignment.topCenter,
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primary,
                            size: 44,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: FloatingActionButton.small(
                    heroTag: 'myloc',
                    onPressed: _locating ? null : _goToMyLocation,
                    child: _locating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location_rounded),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${_selected.latitude.toStringAsFixed(6)}, '
                    '${_selected.longitude.toStringAsFixed(6)}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(
                        (
                          lat: _selected.latitude,
                          lng: _selected.longitude,
                        ),
                      ),
                      icon: const Icon(Icons.check_rounded),
                      label: Text(s.confirmThisLocation),
                      style: FilledButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
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
