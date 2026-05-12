import 'package:flutter_test/flutter_test.dart';
import 'package:v_view/data/remote/gaze/gaze_analyzer.dart';

void main() {
  late GazeAnalyzer analyzer;

  setUp(() {
    analyzer = GazeAnalyzer();
  });

  group('GazeAnalyzer.computeMetrics', () {
    group('응시율 계산', () {
      test('전체 프레임 응시 시 응시율 100%', () {
        final frames = List.generate(
          10,
          (i) => GazeFrame(
            isGazing: true,
            faceDetected: true,
            timestamp: DateTime(2026, 1, 1).add(Duration(milliseconds: i * 100)),
          ),
        );
        final metrics = analyzer.computeMetrics(frames);
        expect(metrics.gazeRate, closeTo(100.0, 0.1));
      });

      test('응시율 공식: 응시 프레임 / 전체 프레임 × 100', () {
        final frames = List.generate(
          10,
          (i) => GazeFrame(
            isGazing: i < 8,
            faceDetected: true,
            timestamp: DateTime(2026, 1, 1).add(Duration(milliseconds: i * 100)),
          ),
        );
        final metrics = analyzer.computeMetrics(frames);
        expect(metrics.gazeRate, closeTo(80.0, 0.1));
      });

      test('빈 프레임 목록 시 GazeMetrics.empty 반환', () {
        final metrics = analyzer.computeMetrics([]);
        expect(metrics.gazeRate, 0.0);
        expect(metrics.distractionCount, 0);
      });
    });

    group('시선 분산 횟수 (1초 임계값)', () {
      test('분산 상태가 1초 미만이면 카운트되지 않는다', () {
        final frames = [
          GazeFrame(
            isGazing: false,
            faceDetected: true,
            timestamp: DateTime(2026, 1, 1, 0, 0, 0, 0),
          ),
          GazeFrame(
            isGazing: true,
            faceDetected: true,
            timestamp: DateTime(2026, 1, 1, 0, 0, 0, 900), // 0.9초
          ),
        ];
        final metrics = analyzer.computeMetrics(frames);
        expect(metrics.distractionCount, 0);
      });

      test('분산 상태가 정확히 1초이면 1회 카운트된다', () {
        final frames = [
          GazeFrame(
            isGazing: false,
            faceDetected: true,
            timestamp: DateTime(2026, 1, 1, 0, 0, 0, 0),
          ),
          GazeFrame(
            isGazing: true,
            faceDetected: true,
            timestamp: DateTime(2026, 1, 1, 0, 0, 1, 0), // 1.0초
          ),
        ];
        final metrics = analyzer.computeMetrics(frames);
        expect(metrics.distractionCount, 1);
      });

      test('분산 상태가 1초 이상이면 1회 카운트된다', () {
        final frames = [
          GazeFrame(
            isGazing: false,
            faceDetected: true,
            timestamp: DateTime(2026, 1, 1, 0, 0, 0, 0),
          ),
          GazeFrame(
            isGazing: true,
            faceDetected: true,
            timestamp: DateTime(2026, 1, 1, 0, 0, 1, 100), // 1.1초
          ),
        ];
        final metrics = analyzer.computeMetrics(frames);
        expect(metrics.distractionCount, 1);
      });

      test('두 번의 1초 이상 분산 시 2회 카운트된다', () {
        final t = DateTime(2026, 1, 1);
        final frames = [
          GazeFrame(isGazing: false, faceDetected: true, timestamp: t),
          GazeFrame(
              isGazing: true,
              faceDetected: true,
              timestamp: t.add(const Duration(milliseconds: 1100))),
          GazeFrame(
              isGazing: false,
              faceDetected: true,
              timestamp: t.add(const Duration(milliseconds: 2000))),
          GazeFrame(
              isGazing: true,
              faceDetected: true,
              timestamp: t.add(const Duration(milliseconds: 3200))),
        ];
        final metrics = analyzer.computeMetrics(frames);
        expect(metrics.distractionCount, 2);
      });

      test('얼굴 미검출 프레임은 분산으로 카운트되지 않는다', () {
        final frames = [
          GazeFrame(
            isGazing: false,
            faceDetected: false, // 얼굴 미검출
            timestamp: DateTime(2026, 1, 1, 0, 0, 0, 0),
          ),
          GazeFrame(
            isGazing: true,
            faceDetected: true,
            timestamp: DateTime(2026, 1, 1, 0, 0, 2, 0), // 2초 후
          ),
        ];
        final metrics = analyzer.computeMetrics(frames);
        expect(metrics.distractionCount, 0);
      });
    });

    group('품질 평가', () {
      test('얼굴 검출률 30% 미만이면 unavailable', () {
        final frames = List.generate(10, (i) {
          return GazeFrame(
            isGazing: false,
            faceDetected: i < 2, // 20% 검출
            timestamp: DateTime(2026, 1, 1).add(Duration(seconds: i)),
          );
        });
        final metrics = analyzer.computeMetrics(frames);
        expect(metrics.quality.name, 'unavailable');
      });

      test('얼굴 검출률 60% 이상이면 normal', () {
        final frames = List.generate(10, (i) {
          return GazeFrame(
            isGazing: true,
            faceDetected: i < 8, // 80% 검출
            timestamp: DateTime(2026, 1, 1).add(Duration(seconds: i)),
          );
        });
        final metrics = analyzer.computeMetrics(frames);
        expect(metrics.quality.name, 'normal');
      });
    });
  });
}
