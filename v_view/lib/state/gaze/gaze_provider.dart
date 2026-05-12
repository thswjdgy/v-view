import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../data/remote/gaze/gaze_analyzer.dart';
import '../../domain/gaze/gaze_metrics.dart';

class GazeState {
  final bool isRunning;
  final List<GazeFrame> frames;
  final GazeMetrics? latestMetrics;

  const GazeState({
    this.isRunning = false,
    this.frames = const [],
    this.latestMetrics,
  });

  GazeState copyWith({
    bool? isRunning,
    List<GazeFrame>? frames,
    GazeMetrics? latestMetrics,
  }) {
    return GazeState(
      isRunning: isRunning ?? this.isRunning,
      frames: frames ?? this.frames,
      latestMetrics: latestMetrics,
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

  void start() => state = state.copyWith(isRunning: true, frames: []);

  void stop() {
    final metrics = _analyzer.computeMetrics(state.frames);
    state = state.copyWith(isRunning: false, latestMetrics: metrics);
  }

  Future<void> processFrame(InputImage inputImage) async {
    if (!state.isRunning) return;
    final frame = await _analyzer.analyze(inputImage);
    state = state.copyWith(frames: [...state.frames, frame]);
  }

  void reset() => state = const GazeState();

  GazeMetrics computeFinalMetrics() =>
      _analyzer.computeMetrics(state.frames);
}
