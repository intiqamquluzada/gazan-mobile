import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// The device's current coordinates, or null when unavailable (permission
/// denied, location services off, or an error). Fetched once and cached
/// for the session; call `ref.invalidate(deviceLocationProvider)` to
/// refresh. Everything is best-effort — a null result simply hides the
/// distance labels, it never blocks the UI.
final FutureProvider<({double lat, double lng})?> deviceLocationProvider =
    FutureProvider<({double lat, double lng})?>((Ref ref) async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return null;
    }

    final Position pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );
    return (lat: pos.latitude, lng: pos.longitude);
  } catch (_) {
    return null;
  }
});

/// Great-circle distance in kilometres between the device and a target
/// point, or null if either the device location or the target coords are
/// missing.
double? distanceKmBetween({
  required ({double lat, double lng})? device,
  required double? targetLat,
  required double? targetLng,
}) {
  if (device == null || targetLat == null || targetLng == null) return null;
  final double meters = Geolocator.distanceBetween(
    device.lat,
    device.lng,
    targetLat,
    targetLng,
  );
  return meters / 1000.0;
}
