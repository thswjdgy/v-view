import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/report/report_provider.dart';
import '../../state/interview/interview_provider.dart';
import '../../state/gaze/gaze_provider.dart';
import '../../state/session_setup/session_setup_provider.dart';
import '../../domain/interview/interview_question.dart';
import '../../state/history/history_provider.dart';
import 'widgets/gaze_metrics_card.dart';
import 'widgets/gaze_trend_chart.dart';
import 'widgets/improvement_list.dart';
import 'widgets/qa_summary_list.dart';

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
          qaList: qaList,
          gazeMetrics: gazeMetrics,
          totalDurationSeconds: interviewState.questions.length * 120,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('면접 리포트')),
      body: switch (state.phase) {
        ReportPhase.generating => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('AI가 피드백을 생성 중입니다...'),
              ],
            ),
          ),
        ReportPhase.done when state.report != null => _buildReport(
            context, state),
        ReportPhase.error => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('리포트 생성에 실패했습니다.'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _generateReport,
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildReport(BuildContext context, ReportState state) {
    final report = state.report!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!report.isAiFeedbackAvailable)
            const Card(
              color: Colors.amber,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text('AI 피드백 생성에 실패하여 시선 지표만 제공됩니다.'),
              ),
            ),
          GazeMetricsCard(metrics: report.gazeMetrics),
          const SizedBox(height: 16),
          GazeTrendChart(
            recentSessions: ref.read(historyProvider),
          ),
          const SizedBox(height: 16),
          if (report.improvementPoints.isNotEmpty) ...[
            ImprovementList(points: report.improvementPoints),
            const SizedBox(height: 16),
          ],
          QaSummaryList(qaList: report.qaList),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () =>
                  Navigator.popUntil(context, (r) => r.isFirst),
              child: const Text('홈으로'),
            ),
          ),
        ],
      ),
    );
  }
}
