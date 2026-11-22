import 'dart:async';
import 'dart:typed_data';

import 'package:ndef_record/ndef_record.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager/nfc_manager_ios.dart';

import 'nfc_payload.dart';

/// What one of our cards told the phone.
class NfcRead {
  const NfcRead({required this.token, required this.uid});

  final String? token;
  final String uid;
}

/// Pulls token and chip serial out of a discovered tag on either platform.
NfcRead parseNfcTag(NfcTag tag) {
  final NdefAndroid? android = NdefAndroid.from(tag);
  if (android != null) {
    return NfcRead(
      token: NfcPayload.tokenOf(android.cachedNdefMessage),
      uid: NfcPayload.uidHex(NfcTagAndroid.from(tag)?.id),
    );
  }
  final NdefMessage? ios = NdefIos.from(tag)?.cachedNdefMessage;
  final Uint8List? id = MiFareIos.from(tag)?.identifier ??
      Iso7816Ios.from(tag)?.identifier ??
      Iso15693Ios.from(tag)?.identifier;
  return NfcRead(token: NfcPayload.tokenOf(ios), uid: NfcPayload.uidHex(id));
}

/// True when the iOS scan sheet closed because the user dismissed it (X,
/// Cancel, tap outside) or it timed out — not a failure worth an error.
bool isNfcDismissal(NfcReaderSessionErrorIos e) =>
    e.code == NfcReaderErrorCodeIos.readerSessionInvalidationErrorUserCanceled ||
    e.code == NfcReaderErrorCodeIos.readerSessionInvalidationErrorSessionTimeout;

/// Reads a single tag and ends the session. Returns null when the user
/// cancels the iOS sheet. NTAG cards are ISO 14443, so only that is polled.
Future<NfcRead?> readOneNfcTag({required String alertMessage}) async {
  // A dismissed iOS sheet leaves the plugin's session behind, and the next
  // start fails with "session_already_exists" — clear it first.
  await stopNfcSession();
  final Completer<NfcRead?> done = Completer<NfcRead?>();
  unawaited(NfcManager.instance
      .startSession(
    pollingOptions: <NfcPollingOption>{NfcPollingOption.iso14443},
    alertMessageIos: alertMessage,
    onSessionErrorIos: (NfcReaderSessionErrorIos _) {
      unawaited(stopNfcSession());
      if (!done.isCompleted) done.complete(null);
    },
    onDiscovered: (NfcTag tag) {
      final NfcRead read = parseNfcTag(tag);
      unawaited(NfcManager.instance.stopSession().catchError((Object _) {}));
      if (!done.isCompleted) done.complete(read);
    },
  )
      .catchError((Object e) {
    if (!done.isCompleted) done.completeError(e);
  }));
  return done.future;
}

Future<void> stopNfcSession() async {
  try {
    await NfcManager.instance.stopSession();
  } catch (_) {
    // No session running.
  }
}
