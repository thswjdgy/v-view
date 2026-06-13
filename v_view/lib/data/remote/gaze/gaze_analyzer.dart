import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../../domain/gaze/gaze_metrics.dart';

class GazeFrame {
  final bool isGazing;
  final bool faceDetected;
  final DateTime timestamp;

  const GazeFrame({
    required this.isGazing,
    required this.faceDetected,
    required this.timestamp,
  });
}

class GazeAnalyzer {
  static const _distractionThresholdMs = 1000;

  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: false,
      enableLandmarks: false,
      enableTracking: false,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  Future<GazeFrame> analyze(InputImage image) async {
    try {
      final faces = await _detector.processImage(image);
      if (faces.isEmpty) {
        return GazeFrame(
          isGazing: false,
          faceDetected: false,
          timestamp: DateTime.now(),
        );
      }
      final face = faces.first;
      return GazeFrame(
        isGazing: _isLookingAtCamera(face),
        faceDetected: true,
        timestamp: DateTime.now(),
      );
    } catch (_) {
      return GazeFrame(
        isGazing: false,
        faceDetected: false,
        timestamp: DateTime.now(),
      );
    }
  }

  // 시선이 카메라 중앙을 향하는지 판단 (Euler Y, Z 각도 기준)
  bool _isLookingAtCamera(Face face) {
    final headEulerY = face.headEulerAngleY ?? 0;
    final headEulerZ = face.headEulerAngleZ ?? 0;
    return headEulerY.abs() < 15 && headEulerZ.abs() < 15;
  }

  GazeMetrics computeMetrics(List<GazeFrame> frames) {
    if (frames.isEmpty) return GazeMetrics.empty;

    final total = frames.length;
    final gazeCount = frames.where((f) => f.isGazing).length;
    final faceDetectedCount = frames.where((f) => f.faceDetected).length;

    final gazeRate = total > 0 ? (gazeCount / total) * 100 : 0.0;

    final quality = _assessQuality(faceDetectedCount, total);

    final distractionStats = _computeDistractionStats(frames);

    return GazeMetrics(
      gazeRate: gazeRate,
      distractionCount: distractionStats.$1,
      totalDistractionSeconds: distractionStats.$2,
      maxDistractionSeconds: distractionStats.$3,
      quality: quality,
      qualityNote: quality != GazeQuality.normal ? '측정 불가/참고용' : null,
    );
  }

  GazeQuality _assessQuality(int faceDetectedCount, int total) {
    if (total == 0) return GazeQuality.unavailable;
    final detectionRate = faceDetectedCount / total;
    if (detectionRate < 0.3) return GazeQuality.unavailable;
    if (detectionRate < 0.6) return GazeQuality.reference;
    return GazeQuality.normal;
  }

  // 분산 상태가 연속 1초 이상일 때만 1회로 카운트
  (int count, double totalSeconds, double maxSeconds) _computeDistractionStats(
      List<GazeFrame> frames) {
    int count = 0;
    double totalSeconds = 0;
    double maxSeconds = 0;

    DateTime? distractionStart;

    for (int i = 0; i < frames.length; i++) {
      final frame = frames[i];
      if (!frame.isGazing && frame.faceDetected) {
        distractionStart ??= frame.timestamp;
      } else {
        if (distractionStart != null) {
          final durationMs =
              frame.timestamp.difference(distractionStart).inMilliseconds;
          if (durationMs >= _distractionThresholdMs) {
            count++;
            final seconds = durationMs / 1000;
            totalSeconds += seconds;
            if (seconds > maxSeconds) maxSeconds = seconds;
          }
          distractionStart = null;
        }
      }
    }

    if (distractionStart != null && frames.isNotEmpty) {
      final durationMs = frames.last.timestamp
          .difference(distractionStart)
          .inMilliseconds;
      if (durationMs >= _distractionThresholdMs) {
        count++;
        final seconds = durationMs / 1000;
        totalSeconds += seconds;
        if (seconds > maxSeconds) maxSeconds = seconds;
      }
    }

    return (count, totalSeconds, maxSeconds);
  }

  Future<void> dispose() => _detector.close();
}
