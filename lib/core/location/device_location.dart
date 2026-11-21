import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../platform/app_variant.dart';

/// The device's current coordinates, or null when unavailable (permission
/// denied, location services off, or an error). Fetched once and cached
/// for the session; call `ref.invalidate(deviceLocationProvider)` to
/// refresh. Everything is best-effort — a null result simply hides the
/// distance labels, it never blocks the UI.
final FutureProvider<({double lat, double lng})?> deviceLocationProvider =
    FutureProvider<({double lat, double lng})?>((Ref ref) async {
  if (!PlatformCaps.hasLocation) return null;
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

/// A fresh position for an NFC tap, for the venue geofence. Never prompts and
/// never holds the tap up: a fix that takes too long falls back to a recent
/// last-known position, and otherwise to null (the server then limits the
/// card to one tap a day instead of rejecting it).
Future<({double lat, double lng})?> quickFreshLocation() async {
  if (!PlatformCaps.hasLocation) return null;
  try {
    return await _freshFix().timeout(const Duration(seconds: 4));
  } catch (_) {
    return null;
  }
}

Future<({double lat, double lng})?> _freshFix() async {
  if (!await Geolocator.isLocationServiceEnabled()) return null;
  final LocationPermission perm = await Geolocator.checkPermission();
  if (perm == LocationPermission.denied ||
      perm == LocationPermission.deniedForever) {
    return null;
  }
  try {
    final Position pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 3),
      ),
    );
    return (lat: pos.latitude, lng: pos.longitude);
  } catch (_) {
    final Position? last = await Geolocator.getLastKnownPosition();
    if (last == null ||
        DateTime.now().difference(last.timestamp).inMinutes > 5) {
      return null;
    }
    return (lat: last.latitude, lng: last.longitude);
  }
}

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
