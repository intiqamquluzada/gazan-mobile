import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_ios.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/nfc/nfc_reader.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/celebrations.dart';
import '../application/nfc_tap_flow.dart';
import '../data/nfc_repository.dart';

/// "Oxut" — the customer holds their phone against the venue's card.
///
/// The cashier picks the card (stamp campaign or 100 points); the phone just
/// reads it and the server decides what it is worth. Taps made with no
/// connection are queued and flushed when the app comes back online.
class NfcTapScreen extends ConsumerStatefulWidget {
  const NfcTapScreen({super.key});

  @override
  ConsumerState<NfcTapScreen> createState() => _NfcTapScreenState();
}

enum _Phase { checking, unsupported, disabled, waiting, sending, done, error }

class _NfcTapScreenState extends ConsumerState<NfcTapScreen> {
  _Phase _phase = _Phase.checking;
  String? _error;
  NfcTapResult? _result;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  @override
  void dispose() {
    unawaited(stopNfcSession());
    super.dispose();
  }

  Future<void> _start() async {
    try {
      final NfcAvailability a = await NfcManager.instance.checkAvailability();
      if (!mounted) return;
      if (a == NfcAvailability.unsupported) {
        setState(() => _phase = _Phase.unsupported);
        return;
      }
      if (a == NfcAvailability.disabled) {
        setState(() => _phase = _Phase.disabled);
        return;
      }
      setState(() => _phase = _Phase.waiting);
      await NfcManager.instance.startSession(
        // Our cards are NTAG (ISO 14443).
        pollingOptions: <NfcPollingOption>{NfcPollingOption.iso14443},
        alertMessageIos: ref.read(sProvider).nfcHoldPhone,
        onSessionErrorIos: (NfcReaderSessionErrorIos e) {
          if (!mounted || _phase != _Phase.waiting) return;
          setState(() {
            _phase = _Phase.error;
            _error = ref.read(sProvider).nfcCancelled;
          });
        },
        onDiscovered: (NfcTag tag) => unawaited(_onTag(tag)),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _phase = _Phase.error;
          _error = '$e';
        });
      }
    }
  }

  /// Reads the card, then lets the server decide what the tap is worth.
  Future<void> _onTag(NfcTag tag) async {
    if (_busy) return;
    _busy = true;
    // Read up front: the request outlives this screen if the user leaves.
    final S s = ref.read(sProvider);
    final NfcTapFlow flow = ref.read(nfcTapFlowProvider);
    try {
      final NfcRead read = parseNfcTag(tag);
      // End the session so a card left on the phone is not read again.
      await stopNfcSession();

      final String? token = read.token;
      if (token == null) {
        _fail(s.nfcNotOurCard);
        return;
      }

      if (mounted) setState(() => _phase = _Phase.sending);
      await HapticFeedback.mediumImpact();

      final NfcTapResult? res = await flow.submit(token: token, uid: read.uid);
      if (!mounted) return;
      if (res == null) {
        unawaited(_again());
        return;
      }
      setState(() {
        _phase = _Phase.done;
        _result = res;
      });
    } on ApiException catch (e) {
      _fail(e.isNetwork ? s.nfcOfflineQueued : e.message);
    } catch (_) {
      _fail(s.errorTryAgain);
    } finally {
      _busy = false;
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _phase = _Phase.error;
      _error = message;
    });
    HapticFeedback.vibrate();
  }

  Future<void> _again() async {
    setState(() {
      _phase = _Phase.checking;
      _error = null;
      _result = null;
    });
    await _start();
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.nfcTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(child: _body(s)),
        ),
      ),
    );
  }

  Widget _body(S s) {
    switch (_phase) {
      case _Phase.checking:
        return const CircularProgressIndicator();
      case _Phase.unsupported:
        return _Message(
          icon: Icons.phonelink_erase_rounded,
          title: s.nfcUnsupported,
          body: s.nfcUnsupportedBody,
          actionLabel: s.nfcRetry,
          onAction: _again,
        );
      case _Phase.disabled:
        return _Message(
          icon: Icons.nfc_rounded,
          title: s.nfcDisabled,
          body: s.nfcDisabledBody,
          actionLabel: s.nfcRetry,
          onAction: _again,
        );
      case _Phase.waiting:
        return _Waiting(s: s);
      case _Phase.sending:
        return const CircularProgressIndicator();
      case _Phase.error:
        return _Message(
          icon: Icons.error_outline_rounded,
          tint: AppColors.dangerText,
          title: s.nfcFailed,
          body: _error ?? '',
          actionLabel: s.nfcRetry,
          onAction: _again,
        );
      case _Phase.done:
        return _Success(result: _result!, s: s, onAgain: _again);
    }
  }
}

/// Pulsing "hold your phone to the card" state.
class _Waiting extends StatefulWidget {
  const _Waiting({required this.s});

  final S s;

  @override
  State<_Waiting> createState() => _WaitingState();
}

class _WaitingState extends State<_Waiting>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotionOf(context)) {
      _c.value = 0.5;
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 220,
          height: 220,
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) {
              final double t = Curves.easeInOut.transform(_c.value);
              return Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  for (double ring in <double>[1.0, 0.78, 0.56])
                    Container(
                      width: 220 * ring * (0.92 + 0.08 * t),
                      height: 220 * ring * (0.92 + 0.08 * t),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.caramel
                            .withValues(alpha: 0.08 + 0.06 * (1 - t) * ring),
                      ),
                    ),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: AppColors.heroGradient,
                      ),
                    ),
                    child: const Icon(Icons.nfc_rounded,
                        size: 44, color: AppColors.onDark),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(widget.s.nfcHoldPhone,
            textAlign: TextAlign.center, style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.sm),
        Text(widget.s.nfcHoldPhoneBody,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySm
                .copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _Success extends StatelessWidget {
  const _Success({required this.result, required this.s, required this.onAgain});

  final NfcTapResult result;
  final S s;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    final bool stamp = result.isStamp;
    final String headline = result.isSpend
        ? s.spendWaitingBody
        : stamp
            ? '+${result.stampsAdded} ${s.stampWord}'
            : '+${result.pointsAdded} ${s.coinLabel}';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.reward,
            shape: BoxShape.circle,
            boxShadow: AppShadows.brand(AppColors.reward),
          ),
          child: Icon(stamp ? AppIcons.check : AppIcons.token,
              size: 56, color: AppColors.onReward),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(headline,
            textAlign: TextAlign.center, style: AppTextStyles.display),
        const SizedBox(height: AppSpacing.xs),
        Text(result.companyName, style: AppTextStyles.h3),
        if (stamp && result.stampsNow != null) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          Text('${result.stampsNow}/${result.stampsRequired} · '
              '${result.programTitle ?? ''}'),
        ] else if (!result.isSpend) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          Text(s.coinsAtVenue(result.pointsBalance)),
        ],
        const SizedBox(height: AppSpacing.xxl),
        FilledButton(onPressed: onAgain, child: Text(s.nfcAgain)),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
    this.tint,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 64, color: tint ?? AppColors.caramel),
        const SizedBox(height: AppSpacing.lg),
        Text(title, textAlign: TextAlign.center, style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.sm),
        Text(body,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySm
                .copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}
