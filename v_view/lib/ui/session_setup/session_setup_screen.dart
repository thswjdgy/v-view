import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      appBar: AppBar(title: const Text('면접 세션 설정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('면접 유형', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InterviewTypeSelector(
              selected: input.type,
              onChanged: notifier.setType,
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 12),
            _SegmentRow(
              label: '질문당 시간',
              options: const [1, 2, 3],
              selected: input.timerMinutes,
              labelBuilder: (v) => '$v분',
              onChanged: notifier.setTimerMinutes,
            ),
            const SizedBox(height: 8),
            const Text(
              '※ 원본 영상/오디오는 저장되지 않습니다. 입력 텍스트와 시선 지표만 기기 로컬에 저장됩니다.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: notifier.isValid
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SessionConfirmScreen(),
                          ),
                        )
                    : null,
                child: const Text('다음'),
              ),
            ),
          ],
        ),
      ),
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Row(
          children: options.map((opt) {
            final isSelected = opt == selected;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    foregroundColor: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : null,
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade400,
                    ),
                  ),
                  onPressed: () => onChanged(opt),
                  child: Text(labelBuilder(opt)),
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
