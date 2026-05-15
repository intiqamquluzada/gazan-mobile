import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../companies/application/companies_providers.dart';
import '../../companies/domain/company.dart';
import '../../loyalty/application/loyalty_providers.dart';
import '../../loyalty/domain/loyalty_program.dart';

/// Used by business owners to scan a customer's identity QR. Once a code
/// is detected we open a sheet that lets the owner pick a program and
/// add a stamp through the backend's `/scans` endpoint.
class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  late final MobileScannerController _controller;
  bool _torch = false;
  bool _handling = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetected(BarcodeCapture capture) async {
    if (_handling) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final String? raw = barcodes.first.rawValue;
    if (raw == null) return;
    setState(() => _handling = true);
    await _controller.stop();
    if (!mounted) return;
    await _showConfirmSheet(raw);
    if (!mounted) return;
    await _controller.start();
    setState(() => _handling = false);
  }

  Future<void> _showConfirmSheet(String payload) {
    final String customerId = payload.replaceFirst('qazan://customer/', '');
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (BuildContext _) => _ScanResultSheet(customerId: customerId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('QR-i skan et'),
        actions: <Widget>[
          IconButton(
            icon: Icon(_torch ? Icons.flash_on_rounded : Icons.flash_off_rounded),
            onPressed: () async {
              await _controller.toggleTorch();
              setState(() => _torch = !_torch);
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          MobileScanner(controller: _controller, onDetect: _onDetected),
          IgnorePointer(child: CustomPaint(painter: _ScannerOverlay())),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.huge,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: <Color>[
                    Colors.black.withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                children: <Widget>[
                  Text('Müştərinin QR kodunu çərçivəyə tut',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLg.copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Avtomatik tanınacaq',
                      style: AppTextStyles.bodySm.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────── result sheet ──────────────────────

class _ScanResultSheet extends ConsumerWidget {
  const _ScanResultSheet({required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Company?> companyAsync = ref.watch(myCompanyProvider);
    final Company? company = companyAsync.value;
    if (company == null) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: EmptyState(
          title: 'Biznes profili yoxdur',
          subtitle: 'Skan etmək üçün əvvəlcə biznesini yarat.',
          icon: Icons.storefront_outlined,
        ),
      );
    }
    final AsyncValue<List<LoyaltyProgram>> programsAsync =
        ref.watch(programsForCompanyProvider(company.id));

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: programsAsync.when(
        loading: () => const SizedBox(
          height: 240,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (Object e, _) => EmptyState(
          title: 'Xəta', subtitle: e.toString(),
          icon: Icons.error_outline_rounded,
        ),
        data: (List<LoyaltyProgram> programs) => _ProgramPicker(
          customerId: customerId,
          programs: programs.where((LoyaltyProgram p) => p.isActive).toList(),
        ),
      ),
    );
  }
}

class _ProgramPicker extends ConsumerStatefulWidget {
  const _ProgramPicker({required this.customerId, required this.programs});

  final String customerId;
  final List<LoyaltyProgram> programs;

  @override
  ConsumerState<_ProgramPicker> createState() => _ProgramPickerState();
}

class _ProgramPickerState extends ConsumerState<_ProgramPicker> {
  String? _busyProgramId;

  Future<void> _addStamp(LoyaltyProgram p) async {
    setState(() => _busyProgramId = p.id);
    try {
      await ref.read(loyaltyActionsProvider).scanCustomer(
            customerId: widget.customerId,
            programId: p.id,
            amount: 1,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('+1 möhür: ${p.title}')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _busyProgramId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.programs.isEmpty) {
      return const EmptyState(
        title: 'Aktiv proqram yoxdur',
        subtitle: 'Əvvəlcə proqram yarat.',
        icon: Icons.tune_outlined,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 32),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Müştəri tapıldı',
            textAlign: TextAlign.center, style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.xs),
        Text('Hansı proqrama möhür əlavə edək?',
            textAlign: TextAlign.center, style: AppTextStyles.bodySm),
        const SizedBox(height: AppSpacing.lg),
        for (final LoyaltyProgram p in widget.programs)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: PrimaryButton(
              label: '+1 möhür  ·  ${p.title}',
              icon: p.rewardType.icon,
              variant: PrimaryButtonVariant.tonal,
              loading: _busyProgramId == p.id,
              onPressed: _busyProgramId == null ? () => _addStamp(p) : null,
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Ləğv et'),
        ),
      ],
    );
  }
}

// ──────────────────────── overlay ────────────────────────

class _ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cut = size.width * 0.7;
    final Rect frame = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: cut,
      height: cut,
    );
    final RRect rrect = RRect.fromRectAndRadius(frame, const Radius.circular(28));

    final Path overlay = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(overlay, Paint()..color = Colors.black.withValues(alpha: 0.55));

    final Paint stroke = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    const double cornerLen = 28;

    void corner(Offset p, Offset dx, Offset dy) {
      canvas.drawLine(p, p + dx, stroke);
      canvas.drawLine(p, p + dy, stroke);
    }

    corner(frame.topLeft, const Offset(cornerLen, 0), const Offset(0, cornerLen));
    corner(frame.topRight, const Offset(-cornerLen, 0), const Offset(0, cornerLen));
    corner(frame.bottomLeft, const Offset(cornerLen, 0), const Offset(0, -cornerLen));
    corner(frame.bottomRight,
        const Offset(-cornerLen, 0), const Offset(0, -cornerLen));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
