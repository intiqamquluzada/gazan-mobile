import 'dart:io' show Platform;

import 'package:url_launcher/url_launcher.dart';

/// Opens turn-by-turn directions to a venue in whatever maps app the user
/// has installed.
///
/// * Android — a `geo:` intent, which the OS resolves to the installed map
///   apps (Google Maps, Waze, Yandex, …) and shows a chooser when several
///   exist. Falls back to Google Maps directions on the web.
/// * iOS — Google Maps app if installed, else Apple Maps.
///
/// Deliberately does NOT gate on `canLaunchUrl`: on Android 11+ that returns
/// false for any scheme not declared in the manifest's <queries>, which is
/// exactly why the old button silently did nothing.
Future<bool> openDirections({
  required double latitude,
  required double longitude,
  required String label,
}) async {
  final String ll = '$latitude,$longitude';
  final String name = Uri.encodeComponent(label);
  final List<Uri> attempts = Platform.isIOS
      ? <Uri>[
          Uri.parse('comgooglemaps://?daddr=$ll&directionsmode=driving'),
          Uri.parse('https://maps.apple.com/?daddr=$ll&q=$name'),
        ]
      : <Uri>[
          Uri.parse('geo:$ll?q=$ll($name)'),
          Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$ll'),
        ];
  for (final Uri uri in attempts) {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return true;
      }
    } catch (_) {
      // try the next option
    }
  }
  return false;
}

/// A shareable Google Maps link to the exact spot (works on any device).
String googleMapsLink(double latitude, double longitude) =>
    'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
