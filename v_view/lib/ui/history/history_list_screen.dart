import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../../theme/app_theme.dart';
import '../../state/history/history_provider.dart';
import '../../state/auth/auth_provider.dart' show authStateProvider, authNotifierProvider;
import '../../domain/history/session_history.dart';
import '../../domain/session_setup/session_input.dart';
import '../../state/report/report_provider.dart';
import '../session_setup/session_setup_screen.dart';
import 'history_detail_screen.dart';

class HistoryListScreen extends ConsumerWidget {
  const HistoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(historyProvider);
    final firebaseUser = ref.watch(authStateProvider).valueOrNull;
    final userName = firebaseUser?.displayName ?? firebaseUser?.email ?? '';
    final firstName = userName.contains('@')
        ? userName.split('@').first
        : userName.isNotEmpty
            ? userName
            : '면접러';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        title: Text(
          'v-view',
          style: TextStyle(
            color: AppColors.primaryContainer,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: '전체 삭제',
              onPressed: () => _confirmDeleteAll(context, ref),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: '계정',
            itemBuilder: (_) => [
              if (userName.isNotEmpty)
                PopupMenuItem(
                  enabled: false,
                  child: Text(userName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
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
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _GreetingHeader(firstName: firstName, count: items.length),
          ),
          if (items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: FadeInUp(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.mic_none_rounded,
                              size: 36, color: AppColors.primaryContainer),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '아직 연습 기록이 없어요.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '첫 면접을 시작해보세요!',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => FadeInUp(
                    delay: Duration(milliseconds: 50 * i),
                    from: 20,
                    child: _HistoryCard(item: items[i]),
                  ),
                  childCount: items.length,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: _DuoButton(
          label: '새 면접 시작',
          icon: Icons.mic_rounded,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SessionSetupScreen()),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('전체 삭제'),
        content: const Text('모든 면접 기록을 삭제합니다. 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(historyProvider.notifier).deleteAll();
            },
            child: const Text('전체 삭제'),
          ),
        ],
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final String firstName;
  final int count;
  const _GreetingHeader({required this.firstName, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '안녕하세요, $firstName님!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '오늘도 면접 실력을 키워봐요.',
            style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
          ),
          if (count > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.primaryContainer.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.emoji_events_rounded,
                      color: AppColors.primaryContainer, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    '총 $count회 연습 완료',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(
            '최근 연습 기록',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
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
    final typeName = switch (item.interviewType) {
      InterviewType.job => '직무면접',
      InterviewType.personality => '인성면접',
      InterviewType.university => '대학입시',
    };
    final dateStr = DateFormat('yyyy.MM.dd HH:mm').format(item.createdAt);
    final gazeRate = item.gazeRate;
    final gazeColor = gazeRate >= 70
        ? AppColors.primaryContainer
        : gazeRate >= 40
            ? const Color(0xFFFF9600)
            : AppColors.secondaryContainer;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final report = ref.read(reportProvider.notifier).loadById(item.id);
          if (report != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HistoryDetailScreen(reportId: item.id),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('리포트를 불러올 수 없습니다.')),
            );
          }
        },
        onLongPress: () => _confirmDelete(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer
                                .withValues(alpha: 0.15),
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
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            item.position,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dateStr,
                      style: TextStyle(
                          fontSize: 13, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${gazeRate.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: gazeColor,
                    ),
                  ),
                  Text(
                    '응시율',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: AppColors.outlineVariant),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('이 세션 기록을 삭제합니다. 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(historyProvider.notifier).delete(item.id);
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

class _DuoButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const _DuoButton(
      {required this.label, required this.icon, required this.onPressed});

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
        margin: EdgeInsets.only(top: _pressed ? 4 : 0),
        padding: const EdgeInsets.symmetric(vertical: 16),
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
            Icon(widget.icon, color: AppColors.onPrimaryContainer),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
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
