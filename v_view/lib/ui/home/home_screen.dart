import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/history/session_history.dart';
import '../../domain/session_setup/session_input.dart';
import '../../state/auth/auth_provider.dart'
    show authStateProvider, authNotifierProvider;
import '../../state/gaze/gaze_provider.dart';
import '../../state/history/history_provider.dart';
import '../../state/interview/interview_provider.dart';
import '../../state/report/report_provider.dart';
import '../../state/session_setup/session_setup_provider.dart';
import '../../theme/app_theme.dart';
import '../history/history_detail_screen.dart';
import '../history/history_list_screen.dart';
import '../session_setup/session_setup_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;

  void _startNewSession() {
    // 새 면접 시작 — 이전 세션 데이터 전부 초기화 (기록(history)은 제외)
    ref.read(sessionInputProvider.notifier).reset();
    ref.read(interviewProvider.notifier).reset();
    ref.read(gazeProvider.notifier).reset();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SessionSetupScreen()),
    );
  }

  void _onNavTap(int index) {
    if (index == 0) {
      setState(() => _navIndex = 0);
    } else if (index == 1) {
      // 연습
      _startNewSession();
    } else if (index == 2) {
      // 기록
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HistoryListScreen()),
      );
    } else if (index == 3) {
      // 마이
      _showAccountSheet();
    }
  }

  void _showAccountSheet() {
    final user = ref.read(authStateProvider).valueOrNull;
    final name = user?.displayName ?? user?.email ?? '사용자';
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.primaryContainer, width: 2),
              ),
              child: Icon(Icons.person_rounded,
                  size: 32, color: AppColors.primaryContainer),
            ),
            const SizedBox(height: 12),
            Text(name,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface)),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.logout_rounded,
                  color: AppColors.onSurfaceVariant),
              title: Text('로그아웃',
                  style: TextStyle(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                ref.read(authNotifierProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(historyProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final firstName = _parseFirstName(
        user?.displayName ?? user?.email ?? '면접러');

    final avgScore = _avgScore(items);
    final streak = _computeStreak(items);
    final recent = items.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(firstName),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 인사말 ──────────────────────────────────
            _GreetingSection(firstName: firstName),
            const SizedBox(height: 20),
            // ── 모티베이션 + CTA 나란히 ─────────────────
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 5,
                    child: _MotivationCard(
                        avgScore: avgScore, streak: streak),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 7,
                    child: _CtaCard(
                      onTap: _startNewSession,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // ── 최근 연습 기록 ──────────────────────────
            _RecentSection(
              items: recent,
              onViewAll: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const HistoryListScreen()),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }

  AppBar _buildAppBar(String firstName) {
    return AppBar(
      backgroundColor: AppColors.surfaceContainerLowest,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Text(
            'v-view',
            style: TextStyle(
              color: AppColors.primaryContainer,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle_outlined),
          tooltip: '계정',
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'signout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 18),
                  SizedBox(width: 8),
                  Text('로그아웃'),
                ],
              ),
            ),
          ],
          onSelected: (val) {
            if (val == 'signout') {
              ref.read(authNotifierProvider.notifier).signOut();
            }
          },
        ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────
  String _parseFirstName(String raw) {
    if (raw.contains('@')) return raw.split('@').first;
    return raw.isNotEmpty ? raw : '면접러';
  }

  double _avgScore(List<SessionHistoryItem> items) {
    if (items.isEmpty) return 0;
    return items.map((e) => e.gazeRate).reduce((a, b) => a + b) /
        items.length;
  }

  int _computeStreak(List<SessionHistoryItem> items) {
    if (items.isEmpty) return 0;
    final today = DateTime.now();
    final todayDate =
        DateTime(today.year, today.month, today.day);
    final dates = items
        .map((e) =>
            DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    int streak = 0;
    for (int i = 0; i < dates.length; i++) {
      if (dates[i] == todayDate.subtract(Duration(days: i))) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}

// ── 인사말 섹션 ────────────────────────────────────────────────────────────
class _GreetingSection extends StatelessWidget {
  final String firstName;
  const _GreetingSection({required this.firstName});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurface,
          height: 1.4,
          letterSpacing: -0.3,
        ),
        children: const [
          TextSpan(text: '안녕하세요 👋\n'),
          TextSpan(text: '오늘도 연습해볼까요?'),
        ],
      ),
    );
  }
}

// ── 모티베이션 카드 ────────────────────────────────────────────────────────
class _MotivationCard extends StatelessWidget {
  final double avgScore;
  final int streak;
  const _MotivationCard({required this.avgScore, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceContainer, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 주간 목표 레이블
          Text(
            '주간 목표',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          // 연속 뱃지
          if (streak > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceContainerHigh),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_fire_department_rounded,
                      size: 14, color: AppColors.secondaryContainer),
                  const SizedBox(width: 3),
                  Text(
                    '$streak일 연속!',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          // 평균 점수
          Text(
            '최근 평균',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                avgScore == 0
                    ? '-'
                    : avgScore.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  height: 1,
                ),
              ),
              if (avgScore > 0)
                Text(
                  '점',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // 원형 진행 링
          Center(
            child: _CircularScore(
              score: avgScore / 100,
              size: 72,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 원형 점수 링 ──────────────────────────────────────────────────────────
class _CircularScore extends StatelessWidget {
  final double score; // 0.0–1.0
  final double size;
  const _CircularScore({required this.score, required this.size});

  Color get _arcColor {
    if (score >= 0.8) return AppColors.primaryContainer;
    if (score >= 0.5) return const Color(0xFFFF9600);
    if (score > 0) return AppColors.secondaryContainer;
    return AppColors.surfaceContainerHigh;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ArcPainter(
              progress: score.clamp(0.0, 1.0),
              trackColor: AppColors.surfaceContainerHigh,
              valueColor: _arcColor,
            ),
          ),
          Icon(
            Icons.emoji_events_rounded,
            size: size * 0.38,
            color: score > 0 ? _arcColor : AppColors.outlineVariant,
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color valueColor;

  const _ArcPainter({
    required this.progress,
    required this.trackColor,
    required this.valueColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 8.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final valuePaint = Paint()
      ..color = valueColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        valuePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.valueColor != valueColor;
}

// ── CTA 카드 ───────────────────────────────────────────────────────────────
class _CtaCard extends StatefulWidget {
  final VoidCallback onTap;
  const _CtaCard({required this.onTap});

  @override
  State<_CtaCard> createState() => _CtaCardState();
}

class _CtaCardState extends State<_CtaCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surfaceContainerLow.withValues(alpha: 0.5),
                    AppColors.surfaceContainer.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI 모의면접 badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryFixed,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'AI 모의면접',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onTertiaryFixedVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '실전처럼\n완벽하게\n준비해볼까요?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'V-Bot이 맞춤 질문과\n피드백으로 도와줄게요.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                // 마스코트 + 말풍선
                AnimatedBuilder(
                  animation: _bounceAnim,
                  builder: (context, _) => Transform.translate(
                    offset: Offset(0, _bounceAnim.value),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer
                                .withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryContainer
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(
                            Icons.smart_toy_rounded,
                            size: 36,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                        // 말풍선
                        Positioned(
                          top: -18,
                          left: 46,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.cardShadow,
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                  color: AppColors.outlineVariant
                                      .withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              '화이팅! 🎯',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // CTA 버튼
                _SmallDuoButton(
                  label: '면접 연습 시작하기',
                  onTap: widget.onTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallDuoButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _SmallDuoButton({required this.label, required this.onTap});

  @override
  State<_SmallDuoButton> createState() => _SmallDuoButtonState();
}

class _SmallDuoButtonState extends State<_SmallDuoButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        margin: EdgeInsets.only(top: _pressed ? 3 : 0),
        padding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: _pressed
              ? null
              : Border(
                  bottom: BorderSide(
                      color: AppColors.primaryShadow, width: 3),
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                widget.label,
                style: TextStyle(
                  color: AppColors.onPrimaryContainer,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_rounded,
                size: 16, color: AppColors.onPrimaryContainer),
          ],
        ),
      ),
    );
  }
}

// ── 최근 연습 기록 섹션 ───────────────────────────────────────────────────
class _RecentSection extends ConsumerWidget {
  final List<SessionHistoryItem> items;
  final VoidCallback onViewAll;
  const _RecentSection({required this.items, required this.onViewAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '최근 연습 기록',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Text(
                '전체보기',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              label: Icon(Icons.chevron_right,
                  size: 16, color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          _EmptyState()
        else
          ...items.map((item) => _HistoryCard(item: item)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(Icons.history_rounded,
              size: 40, color: AppColors.surfaceContainerHigh),
          const SizedBox(height: 12),
          Text(
            '아직 연습 기록이 없어요.',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '첫 면접을 시작해보세요!',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends ConsumerWidget {
  final SessionHistoryItem item;
  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('yyyy.MM.dd').format(item.createdAt);
    final typeName = switch (item.interviewType) {
      InterviewType.job => '직무면접',
      InterviewType.personality => '인성면접',
      InterviewType.university => '대학입시',
    };
    final durationMin =
        (item.totalDurationSeconds / 60).ceil();
    final gazeRate = item.gazeRate;

    final (arcColor, label) = gazeRate >= 80
        ? (AppColors.primaryContainer, '우수함')
        : gazeRate >= 60
            ? (const Color(0xFFFF9600), '보통')
            : (AppColors.secondaryContainer, '분발');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final report =
              ref.read(reportProvider.notifier).loadById(item.id);
          if (report != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      HistoryDetailScreen(reportId: item.id)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('리포트를 불러올 수 없습니다.')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 날짜 badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      dateStr,
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      typeName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.position,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 13, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 3),
                  Text(
                    '$durationMin분 진행',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // 점수 링
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(36, 36),
                          painter: _ArcPainter(
                            progress: gazeRate / 100,
                            trackColor: AppColors.surfaceContainerHigh,
                            valueColor: arcColor,
                          ),
                        ),
                        Text(
                          gazeRate.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: arcColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_rounded,
                      size: 18, color: AppColors.outlineVariant),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 하단 네비게이션 바 ─────────────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  static const _tabs = [
    (icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: '홈'),
    (
      icon: Icons.mic_none_rounded,
      activeIcon: Icons.mic_rounded,
      label: '연습'
    ),
    (
      icon: Icons.history_rounded,
      activeIcon: Icons.history_rounded,
      label: '기록'
    ),
    (
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: '마이'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: AppColors.surfaceContainerHigh, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final tab = _tabs[i];
            final active = i == currentIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 64,
                      height: 32,
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primaryContainer
                                .withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        active ? tab.activeIcon : tab.icon,
                        size: 22,
                        color: active
                            ? AppColors.primaryContainer
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: active
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: active
                            ? AppColors.onSurface
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
