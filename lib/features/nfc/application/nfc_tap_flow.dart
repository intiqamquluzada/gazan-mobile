import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/location/device_location.dart';
import '../../../core/widgets/celebrations.dart';
import '../../../routing/app_router.dart';
import '../../loyalty/application/loyalty_providers.dart';
import '../../rewards/application/rewards_providers.dart';
import '../../wallet/application/wallet_providers.dart';
import '../data/nfc_repository.dart';
import '../presentation/nfc_celebration.dart';

/// Everything that happens after a phone reads one of our cards, whichever
/// path brought the tag in (the NFC tab, or Android opening the app).
///
/// Lives in a provider rather than a widget, so a tap keeps going and its
/// result is still shown when the user switches screens mid-request.
class NfcTapFlow {
  NfcTapFlow(this._ref);

  final Ref _ref;
  String? _lastToken;
  DateTime? _lastAt;
  bool _busy = false;

  /// Posts the tap and shows the result full-screen. Returns null for a
  /// repeat read of the same card (the phone still resting on it).
  Future<NfcTapResult?> submit({
    required String token,
    required String uid,
  }) async {
    if (_busy || _isRepeat(token)) return null;
    _busy = true;
    try {
      final ({double lat, double lng})? loc = await quickFreshLocation();
      final NfcTapResult result = await _ref.read(nfcRepositoryProvider).tap(
            token: token,
            tagUid: uid.isEmpty ? null : uid,
            latitude: loc?.lat,
            longitude: loc?.lng,
          );
      _lastToken = token;
      _lastAt = DateTime.now();
      // The overlay below is this gift's celebration; the cards screen
      // must not show a second one when it reloads.
      if (result.rewardUnlocked) RewardCelebrationLedger.markCelebratedByTap();
      _refreshBalances();
      unawaited(HapticFeedback.heavyImpact());
      _present(result);
      return result;
    } finally {
      _busy = false;
    }
  }

  bool _isRepeat(String token) {
    final DateTime? at = _lastAt;
    return token == _lastToken &&
        at != null &&
        DateTime.now().difference(at).inSeconds < 8;
  }

  void _refreshBalances() {
    _ref
      ..invalidate(coinSummaryProvider)
      ..invalidate(myCardsProvider)
      ..invalidate(myActiveRewardsProvider);
  }

  void _present(NfcTapResult r) {
    final String? spendId = r.spendSessionId;
    if (r.isSpend && spendId != null) {
      unawaited(_ref.read(appRouterProvider).push<void>('/spend/$spendId'));
      return;
    }
    final context = rootNavigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    unawaited(showNfcCelebration(
      context,
      NfcCelebration.fromResult(r),
      onViewRewards: () =>
          unawaited(_ref.read(appRouterProvider).push<void>('/rewards')),
    ));
  }

  /// Sends taps queued while offline; returns how many got through.
  Future<int> flushQueue() async {
    final List<NfcTapResult> sent =
        await _ref.read(nfcRepositoryProvider).flushQueue();
    if (sent.isNotEmpty) _refreshBalances();
    return sent.length;
  }
}

final Provider<NfcTapFlow> nfcTapFlowProvider =
    Provider<NfcTapFlow>((Ref ref) => NfcTapFlow(ref));
