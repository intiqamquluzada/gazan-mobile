import 'dart:async';
import 'dart:math' as math;

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

  /// Screenshot / design tooling only: skip the hardware check and show
  /// the "hold your phone to the card" state.
  @visibleForTesting
  static bool previewWaiting = false;

  @override
  ConsumerState<NfcTapScreen> createState() => _NfcTapScreenState();
}

enum _Phase {
  checking,
  unsupported,
  disabled,
  waiting,

  /// The user closed the iOS scan sheet (or it timed out): nothing failed,
  /// so wait calmly for them to start again.
  idle,
  sending,
  repeat,
  done,
  error,
}

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
    if (NfcTapScreen.previewWaiting) {
      setState(() => _phase = _Phase.waiting);
      return;
    }
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
      // A dismissed iOS sheet leaves the plugin's session behind, and the
      // next start fails with "session_already_exists" — clear it first.
      await stopNfcSession();
      await NfcManager.instance.startSession(
        // Our cards are NTAG (ISO 14443).
        pollingOptions: <NfcPollingOption>{NfcPollingOption.iso14443},
        alertMessageIos: ref.read(sProvider).nfcHoldPhone,
        onSessionErrorIos: (NfcReaderSessionErrorIos e) {
          unawaited(stopNfcSession());
          if (!mounted || _phase != _Phase.waiting) return;
          if (isNfcDismissal(e)) {
            setState(() => _phase = _Phase.idle);
            return;
          }
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
          _error = ref.read(sProvider).errorTryAgain;
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
        // Same card still on the phone (or a tap in flight): say so and
        // pause, rather than re-reading and buzzing in a loop.
        setState(() => _phase = _Phase.repeat);
        await Future<void>.delayed(const Duration(seconds: 2));
        if (mounted && _phase == _Phase.repeat) unawaited(_again());
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
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints c) =>
              SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: c.maxHeight - AppSpacing.xl * 2),
              child: Center(child: _body(s)),
            ),
          ),
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
      case _Phase.idle:
        return _Waiting(
          s: s,
          title: s.nfcTitle,
          body: s.nfcIdleBody,
          actionLabel: s.nfcStartScan,
          onAction: _again,
        );
      case _Phase.sending:
        return const CircularProgressIndicator();
      case _Phase.repeat:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(AppIcons.check, size: 64, color: AppColors.caramel),
            const SizedBox(height: AppSpacing.lg),
            Text(s.nfcAlreadyCounted,
                textAlign: TextAlign.center, style: AppTextStyles.h3),
          ],
        );
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

/// "Hold your phone to the card": the 3D phone-and-reader art floats
/// gently while soft mint rings ripple out behind it — a calm, continuous
/// hint that the phone is listening.
class _Waiting extends StatefulWidget {
  const _Waiting({
    required this.s,
    this.title,
    this.body,
    this.actionLabel,
    this.onAction,
  });

  final S s;

  /// Overrides for the idle state (sheet dismissed): its own copy and a
  /// button to scan again. Null keeps the "listening" wording.
  final String? title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  State<_Waiting> createState() => _WaitingState();
}

class _WaitingState extends State<_Waiting>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  @override
  void didUpdateWidget(_Waiting old) {
    super.didUpdateWidget(old);
    _syncMotion();
  }

  /// Ripples mean "the phone is listening", so they stop while idle.
  void _syncMotion() {
    final bool idle = widget.onAction != null;
    if (idle || reduceMotionOf(context)) {
      _c
        ..stop()
        ..value = 0.3;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final double art = (c.maxWidth * 0.86).clamp(240.0, 360.0).toDouble();
        return AnimatedBuilder(
          animation: _c,
          builder: (BuildContext context, Widget? child) {
            final double t = _c.value;
            final double bob = math.sin(t * 2 * math.pi);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: art,
                  height: art * 0.86,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      // Ripples: three rings expanding and fading out.
                      for (int i = 0; i < 3; i++)
                        Builder(builder: (_) {
                          final double r = (t + i / 3) % 1;
                          return Opacity(
                            opacity: (1 - r) * 0.55,
                            child: Container(
                              width: art * (0.55 + 0.5 * r),
                              height: art * (0.55 + 0.5 * r),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: p.surfaceAccent,
                              ),
                            ),
                          );
                        }),
                      Transform.translate(
                        offset: Offset(0, -6 * bob),
                        child: child,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  widget.title ?? widget.s.nfcHoldPhone,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.display.copyWith(
                    color: context.palette.ink,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  widget.body ?? widget.s.nfcHoldPhoneBody,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body
                      .copyWith(color: p.textSecondary, height: 1.5),
                ),
                if (widget.onAction != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: widget.onAction,
                      icon: const Icon(AppIcons.nfc),
                      label: Text(widget.actionLabel ?? widget.s.nfcRetry),
                    ),
                  ),
                ],
              ],
            );
          },
          child: Image.asset(
            'assets/illustrations/onb_nfc.png',
            width: art * 0.92,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          ),
        );
      },
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
    final int? now = result.stampsNow;
    final int? goal = result.stampsRequired;
    final String program = result.programTitle ?? '';
    final String headline = result.isSpend
        ? s.spendWaitingBody
        : stamp
            ? '+${result.stampsAdded} '
                '${result.stampsAdded == 1 ? s.stampWordShort : s.stampWord}'
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
        if (stamp && now != null && goal != null) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          Text(program.isEmpty ? '$now/$goal' : '$now/$goal · $program'),
        ] else if (stamp) ...<Widget>[
          if (program.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(program),
          ],
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
