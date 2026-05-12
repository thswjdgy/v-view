import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/session_setup/session_input.dart';
import '../../state/session_setup/session_setup_provider.dart';
import '../interview/interview_screen.dart';

class SessionConfirmScreen extends ConsumerWidget {
  const SessionConfirmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final input = ref.watch(sessionInputProvider);
    final typeName = switch (input.type) {
      InterviewType.job => '직무면접',
      InterviewType.personality => '인성면접',
      InterviewType.university => '대학입시면접',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('면접 시작 전 확인')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionCard(
              title: '세션 정보',
              children: [
                _InfoRow(label: '면접 유형', value: typeName),
                _InfoRow(label: '직종 / 전공', value: input.position),
                _InfoRow(label: '회사 / 학교', value: input.company),
                _InfoRow(
                  label: '자기소개서',
                  value: input.selfIntroduction.length > 60
                      ? '${input.selfIntroduction.substring(0, 60)}...'
                      : input.selfIntroduction,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: '개인정보 처리 안내',
              titleColor: Colors.orange.shade700,
              children: const [
                _BulletRow(text: '카메라 영상은 기기에서 실시간 시선 분석 후 즉시 폐기됩니다.'),
                _BulletRow(text: '원본 영상·오디오는 저장되지 않습니다.'),
                _BulletRow(text: '저장 항목: 입력 텍스트, 시선 지표, 리포트 (기기 로컬만)'),
                _BulletRow(text: '저장된 데이터는 설정에서 언제든 삭제할 수 있습니다.'),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const InterviewScreen()),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('면접 시작', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('돌아가서 수정'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: titleColor,
              ),
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  final String text;
  const _BulletRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.orange)),
          Expanded(
              child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
