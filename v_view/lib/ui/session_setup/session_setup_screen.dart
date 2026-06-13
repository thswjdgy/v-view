import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../state/session_setup/session_setup_provider.dart';
import 'session_confirm_screen.dart';
import 'widgets/interview_type_selector.dart';

class SessionSetupScreen extends ConsumerWidget {
  const SessionSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final input = ref.watch(sessionInputProvider);
    final notifier = ref.read(sessionInputProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        title: const Text('면접 세션 설정'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionLabel('면접 유형'),
            const SizedBox(height: 12),
            InterviewTypeSelector(
              selected: input.type,
              onChanged: notifier.setType,
            ),
            const SizedBox(height: 4),
            _InputField(
              label: '직종 / 전공',
              hint: '예) 백엔드 개발자, 컴퓨터공학과',
              initialValue: input.position,
              onChanged: notifier.setPosition,
            ),
            const SizedBox(height: 16),
            _InputField(
              label: '회사 / 학교',
              hint: '예) 카카오, 서울대학교',
              initialValue: input.company,
              onChanged: notifier.setCompany,
            ),
            const SizedBox(height: 16),
            _InputField(
              label: '자기소개서 / 경험 요약',
              hint: '핵심 내용을 붙여넣거나 직접 입력하세요.',
              initialValue: input.selfIntroduction,
              onChanged: notifier.setSelfIntroduction,
              maxLines: 6,
              maxLength: 500,
            ),
            const SizedBox(height: 20),
            _SegmentRow(
              label: '질문 수',
              options: const [3, 5, 7],
              selected: input.questionCount,
              labelBuilder: (v) => '$v개',
              onChanged: notifier.setQuestionCount,
            ),
            const SizedBox(height: 16),
            _SegmentRow(
              label: '질문당 시간',
              options: const [1, 2, 3],
              selected: input.timerMinutes,
              labelBuilder: (v) => '$v분',
              onChanged: notifier.setTimerMinutes,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '원본 영상/오디오는 저장되지 않습니다. 입력 텍스트와 시선 지표만 기기 로컬에 저장됩니다.',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _DuoButton(
              label: '다음',
              enabled: notifier.isValid,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const SessionConfirmScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface),
    );
  }
}

class _SegmentRow<T> extends StatelessWidget {
  final String label;
  final List<T> options;
  final T selected;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;

  const _SegmentRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label),
        const SizedBox(height: 10),
        Row(
          children: options.map((opt) {
            final isSelected = opt == selected;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onChanged(opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryContainer.withValues(alpha: 0.15)
                          : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryContainer
                            : AppColors.outlineVariant,
                        width: isSelected ? 2 : 1.5,
                      ),
                    ),
                    child: Text(
                      labelBuilder(opt),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? AppColors.onPrimaryContainer
                            : AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final int? maxLength;

  const _InputField({
    required this.label,
    required this.hint,
    required this.initialValue,
    required this.onChanged,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label),
        const SizedBox(height: 10),
        TextFormField(
          initialValue: initialValue,
          style: TextStyle(fontSize: 16, color: AppColors.onSurface),
          decoration: InputDecoration(hintText: hint),
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _DuoButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  const _DuoButton(
      {required this.label, required this.onPressed, this.enabled = true});

  @override
  State<_DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<_DuoButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.enabled
        ? AppColors.primaryContainer
        : AppColors.surfaceContainerHigh;
    final fg = widget.enabled
        ? AppColors.onPrimaryContainer
        : AppColors.onSurfaceVariant;
    final shadow = widget.enabled
        ? AppColors.primaryShadow
        : AppColors.outlineVariant;

    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel:
          widget.enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.enabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: double.infinity,
        margin: EdgeInsets.only(top: _pressed ? 4 : 0),
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border(
              bottom: BorderSide(color: shadow, width: _pressed ? 0 : 4)),
        ),
        child: Text(
          widget.label,
          style:
              TextStyle(color: fg, fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
