import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../state/interview/interview_provider.dart';
import '../../state/session_setup/session_setup_provider.dart';
import '../interview/interview_screen.dart';

class QuestionListScreen extends ConsumerStatefulWidget {
  const QuestionListScreen({super.key});

  @override
  ConsumerState<QuestionListScreen> createState() =>
      _QuestionListScreenState();
}

class _QuestionListScreenState extends ConsumerState<QuestionListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final iv = ref.read(interviewProvider);
      if (iv.questions.isEmpty) {
        final input = ref.read(sessionInputProvider);
        ref.read(interviewProvider.notifier).start(input);
      }
    });
  }

  void _startFullInterview() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const InterviewScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iv = ref.watch(interviewProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.onSurface,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI가 만든 면접 질문',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          _Body(iv: iv, onPractice: _startFullInterview),
          // Fixed bottom CTA
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomCta(
              enabled: iv.phase == InterviewPhase.inProgress &&
                  iv.questions.isNotEmpty,
              onPressed: _startFullInterview,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Body ───────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final InterviewState iv;
  final VoidCallback onPractice;
  const _Body({required this.iv, required this.onPractice});

  @override
  Widget build(BuildContext context) {
    if (iv.phase == InterviewPhase.loadingQuestions) {
      return const _LoadingView();
    }
    if (iv.errorMessage != null) {
      return _ErrorView(message: iv.errorMessage!);
    }
    return _QuestionListView(questions: iv.questions, onPractice: onPractice);
  }
}

// ── Loading view ───────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              size: 40,
              color: AppColors.primaryContainer,
            ),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(
            color: AppColors.primaryContainer,
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          const Text(
            'V-Bot이 면접 질문을 생성 중이에요...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '자기소개서를 분석하고 있어요 🤔',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error view ─────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            _OutlineButton(
              label: '돌아가기',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Question list ──────────────────────────────────────────────────────────

class _QuestionListView extends StatelessWidget {
  final List questions;
  final VoidCallback onPractice;
  const _QuestionListView(
      {required this.questions, required this.onPractice});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
      children: [
        // ── Header ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI가 만든 면접 질문',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '자기소개서를 바탕으로 V-Bot이 핵심 질문을 뽑아냈어요!',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.primaryContainer.withValues(alpha: 0.4),
                      width: 2),
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  size: 28,
                  color: AppColors.primaryContainer,
                ),
              ),
            ],
          ),
        ),
        // ── Tip card ─────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.tips_and_updates_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                        height: 1.5),
                    children: [
                      const TextSpan(text: '각 질문을 미리 읽고 '),
                      TextSpan(
                        text: "'전체 면접 시작하기'",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(text: '를 눌러 면접을 시작하세요.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // ── Cards ─────────────────────────────────────────────
        ...List.generate(questions.length, (i) {
          final q = questions[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _QuestionCard(
              index: i + 1,
              questionText: q.text,
              onPractice: onPractice,
            ),
          );
        }),
      ],
    );
  }
}

// ── Question card ──────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  final int index;
  final String questionText;
  final VoidCallback onPractice;

  const _QuestionCard({
    required this.index,
    required this.questionText,
    required this.onPractice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
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
          // ── Number badge ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Q$index',
              style: const TextStyle(
                color: AppColors.onPrimaryContainer,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ── Question text ──
          Text(
            questionText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A2238),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          // ── Practice button ──
          Align(
            alignment: Alignment.centerRight,
            child: _PracticeButton(onPressed: onPractice),
          ),
        ],
      ),
    );
  }
}

// ── Practice button ────────────────────────────────────────────────────────

class _PracticeButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _PracticeButton({required this.onPressed});

  @override
  State<_PracticeButton> createState() => _PracticeButtonState();
}

class _PracticeButtonState extends State<_PracticeButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: _hovered
              ? AppColors.surfaceContainerLow
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.outlineVariant, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic_rounded,
                size: 18,
                color: _hovered
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant),
            const SizedBox(width: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 120),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _hovered
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
              child: const Text('연습하기'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom CTA ─────────────────────────────────────────────────────────────

class _BottomCta extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;
  const _BottomCta({required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface.withValues(alpha: 0),
            AppColors.surface,
          ],
          stops: const [0, 0.35],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: _DuoButton(
        label: '전체 면접 시작하기',
        icon: Icons.play_arrow_rounded,
        enabled: enabled,
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}

// ── Duo CTA button ────────────────────────────────────────────────────────

class _DuoButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool enabled;
  final VoidCallback? onPressed;

  const _DuoButton({
    required this.label,
    required this.enabled,
    this.icon,
    this.onPressed,
  });

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

    return GestureDetector(
      onTapDown: widget.enabled
          ? (_) => setState(() => _pressed = true)
          : null,
      onTapUp: widget.enabled
          ? (_) => setState(() => _pressed = false)
          : null,
      onTapCancel: widget.enabled
          ? () => setState(() => _pressed = false)
          : null,
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: double.infinity,
        margin: EdgeInsets.only(top: widget.enabled && _pressed ? 4 : 0),
        padding: const EdgeInsets.symmetric(vertical: 17),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: widget.enabled
              ? Border(
                  bottom: BorderSide(
                    color: AppColors.primaryShadow,
                    width: _pressed ? 0 : 4,
                  ),
                )
              : Border.all(color: AppColors.outlineVariant, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: fg, size: 22),
              const SizedBox(width: 8),
            ],
            Text(
              widget.label,
              style: TextStyle(
                color: fg,
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
  final VoidCallback onPressed;
  const _OutlineButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primaryContainer, width: 2),
        foregroundColor: AppColors.primary,
        padding:
            const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
