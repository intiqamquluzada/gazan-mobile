import 'dart:convert';
import 'dart:typed_data';

import 'package:ndef_record/ndef_record.dart';

/// What we write on (and read from) a venue's NFC card.
///
/// The card carries two NDEF records:
///  1. an external record `qazan.az:tag` whose payload is the card token;
///  2. an Android Application Record, so tapping the card opens Qazan even
///     when the app is closed — no web domain needed for that to work.
///
/// The token alone is not a credential: the server also checks the chip's
/// UID, the per-user cooldown, the daily cap and the venue geofence.
class NfcPayload {
  const NfcPayload._();

  static const String externalType = 'qazan.az:tag';
  static const String androidPackage = 'az.qazan.app';
  static const String _aarType = 'android.com:pkg';

  /// Message to write onto a blank tag during provisioning.
  static NdefMessage messageFor(String token) {
    return NdefMessage(
      records: <NdefRecord>[
        NdefRecord(
          typeNameFormat: TypeNameFormat.external,
          type: Uint8List.fromList(utf8.encode(externalType)),
          identifier: Uint8List(0),
          payload: Uint8List.fromList(utf8.encode(token)),
        ),
        NdefRecord(
          typeNameFormat: TypeNameFormat.external,
          type: Uint8List.fromList(utf8.encode(_aarType)),
          identifier: Uint8List(0),
          payload: Uint8List.fromList(utf8.encode(androidPackage)),
        ),
      ],
    );
  }

  /// Pulls the token out of a tag's message, or null when the tag is not ours.
  static String? tokenOf(NdefMessage? message) {
    if (message == null) return null;
    for (final NdefRecord r in message.records) {
      final String type = utf8.decode(r.type, allowMalformed: true);
      if (type == externalType) {
        final String token = utf8.decode(r.payload, allowMalformed: true).trim();
        if (token.isNotEmpty) return token;
      }
    }
    return null;
  }

  /// Chip serial as uppercase hex ("04A1B2…") — the server binds a card to it.
  static String uidHex(Uint8List? id) {
    if (id == null || id.isEmpty) return '';
    return id
        .map((int b) => b.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();
  }
}
