import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../data/remote/gaze/gaze_analyzer.dart';
import '../../domain/gaze/gaze_metrics.dart';

class GazeState {
  final bool isRunning;
  final List<GazeFrame> frames;
  final GazeMetrics? latestMetrics;
  final bool isCurrentlyGazing;
  final bool faceDetected;

  const GazeState({
    this.isRunning = false,
    this.frames = const [],
    this.latestMetrics,
    this.isCurrentlyGazing = true,
    this.faceDetected = false,
  });

  GazeState copyWith({
    bool? isRunning,
    List<GazeFrame>? frames,
    GazeMetrics? latestMetrics,
    bool? isCurrentlyGazing,
    bool? faceDetected,
  }) {
    return GazeState(
      isRunning: isRunning ?? this.isRunning,
      frames: frames ?? this.frames,
      latestMetrics: latestMetrics,
      isCurrentlyGazing: isCurrentlyGazing ?? this.isCurrentlyGazing,
      faceDetected: faceDetected ?? this.faceDetected,
    );
  }
}

final gazeAnalyzerProvider = Provider((_) => GazeAnalyzer());

final gazeProvider =
    StateNotifierProvider<GazeNotifier, GazeState>((ref) {
  return GazeNotifier(ref.read(gazeAnalyzerProvider));
});

class GazeNotifier extends StateNotifier<GazeState> {
  final GazeAnalyzer _analyzer;

  GazeNotifier(this._analyzer) : super(const GazeState());

  bool _processing = false;

  void start() => state = state.copyWith(isRunning: true, frames: []);

  void stop() {
    final metrics = _analyzer.computeMetrics(state.frames);
    state = state.copyWith(isRunning: false, latestMetrics: metrics);
  }

  Future<void> processFrame(InputImage inputImage) async {
    if (!state.isRunning || _processing) return;
    _processing = true;
    try {
      final frame = await _analyzer.analyze(inputImage);
      state = state.copyWith(
        frames: [...state.frames, frame],
        isCurrentlyGazing: frame.isGazing,
        faceDetected: frame.faceDetected,
      );
    } finally {
      _processing = false;
    }
  }

  void reset() => state = const GazeState();

  GazeMetrics computeFinalMetrics() =>
      _analyzer.computeMetrics(state.frames);
}
