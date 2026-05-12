import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../state/history/history_provider.dart';
import '../../domain/history/session_history.dart';
import '../../domain/session_setup/session_input.dart';
import '../../state/report/report_provider.dart';
import 'history_detail_screen.dart';

class HistoryListScreen extends ConsumerWidget {
  const HistoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('면접 기록'),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: '전체 삭제',
              onPressed: () => _confirmDeleteAll(context, ref),
            ),
        ],
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                '아직 면접 기록이 없습니다.\n첫 면접을 시작해보세요!',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (_, i) => _HistoryCard(item: items[i]),
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
          FilledButton(
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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text('$typeName · ${item.position}'),
        subtitle: Text('$dateStr · 응시율 ${item.gazeRate.toStringAsFixed(0)}%'),
        trailing: const Icon(Icons.chevron_right),
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
          FilledButton(
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
