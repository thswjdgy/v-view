import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../domain/interview/interview_question.dart';
import '../../domain/report/session_report.dart';
import '../../domain/session_setup/session_input.dart';
import '../../state/gaze/gaze_provider.dart';
import '../../state/interview/interview_provider.dart';
import '../../state/report/report_provider.dart';
import '../../state/session_setup/session_setup_provider.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _generateReport());
  }

  void _generateReport() {
    final interviewState = ref.read(interviewProvider);
    final gazeState = ref.read(gazeProvider);
    final sessionInput = ref.read(sessionInputProvider);
    final gazeMetrics = gazeState.latestMetrics ??
        ref.read(gazeProvider.notifier).computeFinalMetrics();

    final qaList = interviewState.questions.map((q) {
      final answer = interviewState.userAnswers[q.id] ?? '';
      return QuestionAnswer(
        question: q,
        userAnswer: answer,
        answerDurationSeconds: 0,
      );
    }).toList();

    ref.read(reportProvider.notifier).generate(
          interviewType: sessionInput.type,
          position: sessionInput.position,
          company: sessionInput.company,
          qaList: qaList,
          gazeMetrics: gazeMetrics,
          totalDurationSeconds: interviewState.elapsedSeconds,
        );
  }

  Future<void> _copyToClipboard(
      BuildContext context, ReportState state) async {
    final report = state.report!;
    final typeName = switch (report.interviewType) {
      InterviewType.job => '직무면접',
      InterviewType.personality => '인성면접',
      InterviewType.university => '대학입시면접',
    };
    final buf = StringBuffer();
    buf.writeln('v-view 면접 리포트');
    buf.writeln('면접 유형: $typeName');
    buf.writeln(
        '화면 응시율: ${report.gazeMetrics.gazeRate.toStringAsFixed(0)}%');
    buf.writeln('시선 분산: ${report.gazeMetrics.distractionCount}회');
    if (report.improvementPoints.isNotEmpty) {
      buf.writeln();
      buf.writeln('개선 포인트');
      for (int i = 0; i < report.improvementPoints.length; i++) {
        final p = report.improvementPoints[i];
        buf.writeln('${i + 1}. ${p.title}: ${p.description}');
      }
    }
    await Clipboard.setData(ClipboardData(text: buf.toString()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('리포트가 클립보드에 복사됐습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        title: const Text('면접 리포트'),
        actions: [
          if (state.phase == ReportPhase.done && state.report != null)
            IconButton(
              icon: const Icon(Icons.copy_rounded),
              tooltip: '리포트 복사',
              onPressed: () => _copyToClipboard(context, state),
            ),
        ],
      ),
      body: switch (state.phase) {
        ReportPhase.generating => const _GeneratingView(),
        ReportPhase.done when state.report != null =>
          _buildReport(context, state),
        ReportPhase.error => _ErrorView(onRetry: _generateReport),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildReport(BuildContext context, ReportState state) {
    final report = state.report!;
    final gazeScore = report.gazeMetrics.gazeRate;
    final answerScore = _answerScore(report);
    final expressionScore = _expressionScore(report);
    final totalScore = (gazeScore * 0.4 + answerScore * 0.4 + expressionScore * 0.2)
        .clamp(0.0, 100.0);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroSection(totalScore: totalScore),
                const SizedBox(height: 16),
                _MetricsSection(
                  gazeScore: gazeScore,
                  answerScore: answerScore,
                  expressionScore: expressionScore,
                ),
                const SizedBox(height: 16),
                if (!report.isAiFeedbackAvailable)
                  const _NoAiBanner(),
                _AiFeedbackCard(
                  report: report,
                  gazeScore: gazeScore,
                  answerScore: answerScore,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DuoButton(
                label: '다시 연습하기',
                icon: Icons.replay_rounded,
                onPressed: () =>
                    Navigator.popUntil(context, (r) => r.isFirst),
              ),
              const SizedBox(height: 8),
              _OutlineButton(
                label: '기록 저장하기',
                icon: Icons.bookmark_rounded,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('기록이 저장됐어요 👍')),
                  );
                  Navigator.popUntil(context, (r) => r.isFirst);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _answerScore(SessionReport report) {
    if (report.qaList.isEmpty) return 0;
    final answered = report.qaList
        .where((qa) => qa.userAnswer.trim().isNotEmpty)
        .length;
    return (answered / report.qaList.length * 100).clamp(0.0, 100.0);
  }

  double _expressionScore(SessionReport report) {
    final answered = report.qaList
        .where((qa) => qa.userAnswer.trim().isNotEmpty)
        .toList();
    if (answered.isEmpty) return 0;
    final avgWords = answered
            .map((qa) =>
                qa.userAnswer.trim().split(RegExp(r'\s+')).length)
            .reduce((a, b) => a + b) /
        answered.length;
    return (avgWords / 80 * 100).clamp(20.0, 98.0);
  }
}

// ── Generating view ────────────────────────────────────────────────────────

class _GeneratingView extends StatelessWidget {
  const _GeneratingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_rounded,
                size: 40, color: AppColors.primaryContainer),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(
              color: AppColors.primaryContainer, strokeWidth: 3),
          const SizedBox(height: 20),
          const Text(
            'AI가 피드백을 생성 중입니다...',
            style: TextStyle(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error view ─────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 56, color: AppColors.error),
          const SizedBox(height: 16),
          const Text(
            '리포트 생성에 실패했습니다.',
            style: TextStyle(
                color: AppColors.onSurface, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _DuoButton(label: '다시 시도', onPressed: onRetry),
        ],
      ),
    );
  }
}

// ── No-AI banner ───────────────────────────────────────────────────────────

class _NoAiBanner extends StatelessWidget {
  const _NoAiBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9600).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFFF9600).withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Color(0xFFFF9600), size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'AI 피드백 생성에 실패하여 시선 지표 기반 결과만 제공됩니다.',
              style: TextStyle(
                  color: AppColors.onSurface, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero section ───────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final double totalScore;
  const _HeroSection({required this.totalScore});

  @override
  Widget build(BuildContext context) {
    final score = totalScore.round();
    final emoji = score >= 80 ? '🎉' : score >= 60 ? '💪' : '📝';

    return Column(
      children: [
        // Mascot
        Bounce(
          from: 14,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primaryContainer.withValues(alpha: 0.4),
                  width: 2.5),
            ),
            child: const Icon(Icons.smart_toy_rounded,
                size: 60, color: AppColors.primaryContainer),
          ),
        ),
        const SizedBox(height: 16),
        // Score card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceContainer, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D1A2238),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                '모의 면접 결과',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              FadeInUp(
                from: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '총점 ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '$score점',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(emoji, style: const TextStyle(fontSize: 28)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                score >= 80
                    ? '수고하셨습니다! 훌륭한 답변이었어요.'
                    : score >= 60
                        ? '좋은 시작이에요! 계속 연습하면 더 좋아질 거예요.'
                        : '꾸준한 연습이 실력 향상의 지름길이에요.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Metrics section ────────────────────────────────────────────────────────

class _MetricsSection extends StatelessWidget {
  final double gazeScore;
  final double answerScore;
  final double expressionScore;

  const _MetricsSection({
    required this.gazeScore,
    required this.answerScore,
    required this.expressionScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceContainer, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1A2238),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded,
                  size: 20, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                '세부 평가 지표',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _MetricBar(label: '시선 집중도', value: gazeScore),
          const SizedBox(height: 16),
          _MetricBar(label: '답변 안정감', value: answerScore),
          const SizedBox(height: 16),
          _MetricBar(label: '표현력', value: expressionScore),
        ],
      ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  final String label;
  final double value;
  const _MetricBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final pct = value.clamp(0.0, 100.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              '${pct.round()}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: pct / 100),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOut,
          builder: (ctx, val, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: val,
                minHeight: 12,
                backgroundColor: AppColors.surfaceContainerHigh,
                valueColor: const AlwaysStoppedAnimation(
                    AppColors.primaryContainer),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── AI feedback card ───────────────────────────────────────────────────────

class _AiFeedbackCard extends StatelessWidget {
  final SessionReport report;
  final double gazeScore;
  final double answerScore;

  const _AiFeedbackCard({
    required this.report,
    required this.gazeScore,
    required this.answerScore,
  });

  String _strengthText() {
    if (gazeScore >= 80 && answerScore >= 80) {
      return '시선 집중도와 답변 완성도 모두 우수해요! 면접관에게 자신감 있는 모습을 보여줄 수 있을 거예요.';
    } else if (gazeScore >= 80) {
      return '시선 처리가 매우 자연스러웠어요. 카메라를 바라보는 습관이 잘 잡혀 있습니다!';
    } else if (answerScore >= 80) {
      return '대부분의 질문에 성실하게 답변하셨어요. 질문에 대한 준비가 잘 되어 있습니다!';
    }
    return '면접 연습을 완료하셨어요! 꾸준한 연습이 실력 향상의 지름길입니다.';
  }

  String _improvementText() {
    if (report.improvementPoints.isNotEmpty) {
      final p = report.improvementPoints.first;
      return '${p.title}: ${p.description}';
    }
    if (gazeScore < 60) {
      return '카메라를 더 자주 바라보는 연습이 필요해요. 시선이 분산되면 면접관에게 자신감이 없어 보일 수 있어요.';
    }
    return '답변할 때 STAR 기법(상황→과제→행동→결과)을 활용하면 더 구조적인 답변을 할 수 있어요.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceContainer, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1A2238),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.smart_toy_rounded,
                    size: 18, color: AppColors.onPrimaryContainer),
              ),
              const SizedBox(width: 8),
              const Text(
                'AI 피드백',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: AppColors.outlineVariant, height: 1),
          ),
          // 잘한 점
          _FeedbackItem(
            icon: Icons.thumb_up_rounded,
            title: '잘한 점',
            content: _strengthText(),
            accentColor: AppColors.primaryContainer,
          ),
          const SizedBox(height: 12),
          // 개선할 점
          _FeedbackItem(
            icon: Icons.trending_up_rounded,
            title: '개선할 점',
            content: _improvementText(),
            accentColor: AppColors.secondaryContainer,
          ),
        ],
      ),
    );
  }
}

class _FeedbackItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color accentColor;

  const _FeedbackItem({
    required this.icon,
    required this.title,
    required this.content,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left accent bar
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: accentColor),
                      const SizedBox(width: 4),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: accentColor == AppColors.primaryContainer
                              ? AppColors.primary
                              : AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Duo CTA button ─────────────────────────────────────────────────────────

class _DuoButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  const _DuoButton({required this.label, required this.onPressed, this.icon});

  @override
  State<_DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<_DuoButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: double.infinity,
        margin: EdgeInsets.only(top: _pressed ? 4 : 0),
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            bottom: BorderSide(
                color: AppColors.primaryShadow, width: _pressed ? 0 : 4),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: AppColors.onPrimaryContainer, size: 22),
              const SizedBox(width: 8),
            ],
            Text(
              widget.label,
              style: const TextStyle(
                color: AppColors.onPrimaryContainer,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Outline button ─────────────────────────────────────────────────────────

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  const _OutlineButton(
      {required this.label, required this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null
            ? Icon(icon, size: 20, color: AppColors.primary)
            : const SizedBox.shrink(),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: AppColors.surfaceContainerLowest,
          padding: const EdgeInsets.symmetric(vertical: 15),
          side: const BorderSide(color: AppColors.primaryContainer, width: 2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
