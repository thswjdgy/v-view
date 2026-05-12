import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../domain/history/session_history.dart';

class GazeTrendChart extends StatelessWidget {
  final List<SessionHistoryItem> recentSessions;

  const GazeTrendChart({super.key, required this.recentSessions});

  @override
  Widget build(BuildContext context) {
    if (recentSessions.length < 2) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              '2회 이상 면접 후 추이 그래프가 표시됩니다.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    final sessions = recentSessions.length > 5
        ? recentSessions.sublist(recentSessions.length - 5)
        : recentSessions;

    final gazeSpots = sessions.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.gazeRate);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 12),
              child: Text(
                '최근 5회 응시율 추이',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    ),
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: 25,
                        getTitlesWidget: (v, _) => Text(
                          '${v.toInt()}%',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx < 0 || idx >= sessions.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            '${idx + 1}회',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: gazeSpots,
                      isCurved: true,
                      color: Colors.indigo,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        getDotPainter: (_, _, _, _) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: Colors.indigo,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.indigo.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
