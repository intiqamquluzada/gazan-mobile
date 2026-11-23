import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Six digit tiles backed by one hidden text field, so paste, the iOS / Android
/// one-time-code suggestion and backspace all behave like a normal input.
/// [onCompleted] fires as soon as the last digit is typed.
class OtpCodeField extends StatefulWidget {
  const OtpCodeField({
    super.key,
    required this.controller,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.hasError = false,
    this.enabled = true,
    this.autofocus = true,
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool hasError;
  final bool enabled;
  final bool autofocus;

  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_redraw);
    _focus.addListener(_redraw);
  }

  @override
  void didUpdateWidget(OtpCodeField old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_redraw);
      widget.controller.addListener(_redraw);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_redraw);
    _focus.dispose();
    super.dispose();
  }

  void _redraw() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final String code = widget.controller.text;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.enabled ? _focus.requestFocus : null,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // The real input: invisible, but it owns focus, keyboard, paste
          // and autofill. Kept full-size so a long-press can paste.
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                enabled: widget.enabled,
                autofocus: widget.autofocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                autofillHints: const <String>[AutofillHints.oneTimeCode],
                showCursor: false,
                enableInteractiveSelection: true,
                maxLength: widget.length,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                ),
                onChanged: (String v) {
                  widget.onChanged?.call(v);
                  if (v.length == widget.length) widget.onCompleted?.call(v);
                },
              ),
            ),
          ),
          IgnorePointer(
            child: Row(
              children: <Widget>[
                for (int i = 0; i < widget.length; i++) ...<Widget>[
                  if (i > 0) const SizedBox(width: AppSpacing.sm),
                  Expanded(child: _tile(p, code, i)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(AppPalette p, String code, int i) {
    final bool filled = i < code.length;
    final bool active = _focus.hasFocus &&
        (i == code.length ||
            (code.length == widget.length && i == widget.length - 1));
    final Color border = widget.hasError
        ? AppColors.danger
        : active
            ? p.action
            : filled
                ? p.caramel.withValues(alpha: 0.45)
                : p.border;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled || active ? p.caramelSoft : p.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: border, width: active ? 2 : 1.4),
        boxShadow: active
            ? <BoxShadow>[
                BoxShadow(
                  color: p.action.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: filled
          ? Text(
              code[i],
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: p.textPrimary,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            )
          : active
              ? Container(width: 2, height: 24, color: p.action)
              : null,
    );
  }
}
