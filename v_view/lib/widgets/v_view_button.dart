import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

// 듀오링고 스타일 3D 버튼
//
// 동작 원리 (designex/stitch_v_view_ai_interview_coach (4)/code.html 참고):
//   기본: Container 하단에 4px 두꺼운 테두리(primaryShadow #00967C) → 입체감
//   누름: translateY(4px) + border-bottom 제거 → 버튼이 눌리는 느낌
//   transition: 80ms ease-in-out (CSS 원본 100ms에서 체감 기준 80ms로 조정)
class VViewButton extends StatefulWidget {
  const VViewButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;

  @override
  State<VViewButton> createState() => _VViewButtonState();
}

class _VViewButtonState extends State<VViewButton> {
  bool _pressed = false;

  bool get _disabled => widget.onPressed == null || widget.isLoading;

  void _onTapDown(TapDownDetails _) {
    if (_disabled) return;
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    if (!_pressed) return;
    setState(() => _pressed = false);
    widget.onPressed?.call();
  }

  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final disabled = _disabled;

    // 눌린 상태: 4px 아래로 내려가고 하단 그림자 사라짐
    final topOffset   = _pressed ? 4.0 : 0.0;
    final shadowWidth = _pressed ? 0.0 : 4.0;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: 56 + shadowWidth, // 눌리면 전체 높이도 줄어들어 자연스럽게
        margin: EdgeInsets.only(top: topOffset),
        decoration: BoxDecoration(
          color: disabled ? AppColors.surfaceContainerHigh : AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            bottom: BorderSide(
              color: disabled
                  ? AppColors.outlineVariant
                  : AppColors.primaryShadow,
              width: shadowWidth,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: _buildContent(disabled),
      ),
    );
  }

  Widget _buildContent(bool disabled) {
    if (widget.isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.onPrimaryContainer,
        ),
      );
    }

    final textColor = disabled ? AppColors.onSurfaceVariant : AppColors.onPrimaryContainer;
    final textWidget = Text(
      widget.label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: 0,
        height: 1,
      ),
    );

    if (widget.icon == null) return textWidget;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        textWidget,
        const SizedBox(width: 8),
        IconTheme(
          data: IconThemeData(color: textColor, size: 20),
          child: widget.icon!,
        ),
      ],
    );
  }
}
