import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/remote/gaze/camera_frame_converter.dart';
import '../../state/interview/interview_provider.dart';
import '../../state/session_setup/session_setup_provider.dart';
import '../../state/gaze/gaze_provider.dart';
import '../report/report_screen.dart';
import '../common/error_display.dart';
import 'widgets/question_card.dart';
import 'widgets/timer_widget.dart';

class InterviewScreen extends ConsumerStatefulWidget {
  const InterviewScreen({super.key});

  @override
  ConsumerState<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends ConsumerState<InterviewScreen>
    with WidgetsBindingObserver {
  Timer? _timer;
  final _answerController = TextEditingController();
  int get _defaultTimerSeconds =>
      ref.read(sessionInputProvider).timerMinutes * 60;

  CameraController? _cameraController;
  bool _cameraReady = false;
  bool _cameraError = false;
  bool _micDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initCamera();
      _startSession();
    });
  }

  Future<void> _initCamera() async {
    try {
      final micStatus = await Permission.microphone.status;
      if (mounted && micStatus.isPermanentlyDenied) {
        setState(() { _micDenied = true; });
      }
    } catch (_) {}

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() { _cameraError = true; });
        return;
      }
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        front,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _cameraController = controller;
        _cameraReady = true;
      });
      if (!kIsWeb) {
        controller.startImageStream((image) {
          final inputImage = CameraFrameConverter.convert(
            image: image,
            camera: front,
          );
          if (inputImage != null) {
            ref.read(gazeProvider.notifier).processFrame(inputImage);
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() { _cameraError = true; });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    _cameraController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.paused) {
      _pauseSession();
      _cameraController?.stopImageStream();
    } else if (lifecycle == AppLifecycleState.resumed && !kIsWeb) {
      _cameraController?.startImageStream((image) {
        final camera = _cameraController?.description;
        if (camera == null) return;
        final inputImage =
            CameraFrameConverter.convert(image: image, camera: camera);
        if (inputImage != null) {
          ref.read(gazeProvider.notifier).processFrame(inputImage);
        }
      });
    }
  }

  void _startSession() {
    final input = ref.read(sessionInputProvider);
    ref.read(gazeProvider.notifier).start();
    ref.read(interviewProvider.notifier).start(input);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    ref.read(interviewProvider.notifier).resetTimer(_defaultTimerSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final state = ref.read(interviewProvider);
      if (state.phase != InterviewPhase.inProgress) return;
      if (state.timerSeconds <= 0) {
        _timer?.cancel();
        final answer = state.userAnswers[state.currentQuestion?.id] ?? '';
        _answerController.clear();
        await ref.read(interviewProvider.notifier).nextQuestion(answer);
        if (ref.read(interviewProvider).phase == InterviewPhase.inProgress) {
          _startTimer();
        }
      } else {
        ref.read(interviewProvider.notifier).tickTimer();
      }
    });
  }

  void _pauseSession() {
    _timer?.cancel();
    ref.read(interviewProvider.notifier).pause();
  }

  void _resumeSession() {
    ref.read(interviewProvider.notifier).resume();
    _startTimer();
  }

  Future<void> _submitAndNext() async {
    final answer = _answerController.text.trim();
    _answerController.clear();
    _timer?.cancel();
    await ref.read(interviewProvider.notifier).nextQuestion(answer);
    _startTimer();
  }

  void _finishSession() {
    _timer?.cancel();
    _cameraController?.stopImageStream();
    ref.read(gazeProvider.notifier).stop();
    ref.read(interviewProvider.notifier).finish();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(interviewProvider);

    ref.listen(interviewProvider, (_, next) {
      if (next.phase == InterviewPhase.finished) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ReportScreen()),
        );
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) => _showExitDialog(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('모의 면접'),
          actions: [
            if (_cameraReady)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _CameraPreviewBadge(controller: _cameraController!),
              ),
            if (state.phase == InterviewPhase.inProgress)
              IconButton(
                icon: const Icon(Icons.pause),
                onPressed: _pauseSession,
              ),
          ],
        ),
        body: _buildBody(context, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, InterviewState state) {
    return switch (state.phase) {
      InterviewPhase.loadingQuestions => const _QuestionLoadingSkeleton(),
      InterviewPhase.idle when state.errorMessage != null => ErrorDisplay(
          message: state.errorMessage!,
          onRetry: () {
            final input = ref.read(sessionInputProvider);
            ref.read(interviewProvider.notifier).start(input);
          },
        ),
      InterviewPhase.inProgress => _buildInterviewBody(context, state),
      InterviewPhase.paused => _buildPausedBody(context),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildInterviewBody(BuildContext context, InterviewState state) {
    final q = state.currentQuestion;
    if (q == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TimerWidget(seconds: state.timerSeconds),
          const SizedBox(height: 8),
          _GazeStatusBadge(),
          if (_cameraError) ...[
            const SizedBox(height: 4),
            _StatusBanner(
              icon: Icons.videocam_off,
              message: '카메라가 켜져있지 않습니다. 시선 분석이 비활성화됩니다.',
              color: Colors.orange,
            ),
          ],
          if (_micDenied) ...[
            const SizedBox(height: 4),
            _StatusBanner(
              icon: Icons.mic_off,
              message: '마이크가 켜져있지 않습니다.',
              color: Colors.orange,
            ),
          ],
          const SizedBox(height: 8),
          QuestionCard(
            question: q,
            index: state.currentIndex,
            total: state.questions.length,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _answerController,
              decoration: const InputDecoration(
                hintText: '답변을 입력하세요...',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _showExitDialog,
                  child: const Text('면접 종료'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _submitAndNext,
                  child: Text(state.isLastQuestion ? '완료' : '다음 질문'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPausedBody(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('면접이 일시정지되었습니다.', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _resumeSession,
            child: const Text('재개'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _finishSession,
            child: const Text('종료 및 리포트 보기'),
          ),
        ],
      ),
    );
  }

  void _showExitDialog([BuildContext? ctx]) {
    showDialog(
      context: ctx ?? context,
      builder: (_) => AlertDialog(
        title: const Text('면접 종료'),
        content: const Text('지금까지의 내용으로 리포트를 생성합니다. 종료할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _finishSession();
            },
            child: const Text('종료'),
          ),
        ],
      ),
    );
  }
}

class _QuestionLoadingSkeleton extends StatefulWidget {
  const _QuestionLoadingSkeleton();

  @override
  State<_QuestionLoadingSkeleton> createState() =>
      _QuestionLoadingSkeletonState();
}

class _QuestionLoadingSkeletonState extends State<_QuestionLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'AI가 맞춤 질문을 생성 중입니다...',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _opacity,
            builder: (_, _) => Opacity(
              opacity: _opacity.value,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBar(width: double.infinity, height: 20),
                  const SizedBox(height: 8),
                  _SkeletonBar(width: 260, height: 20),
                  const SizedBox(height: 32),
                  _SkeletonBar(width: double.infinity, height: 120),
                  const SizedBox(height: 16),
                  _SkeletonBar(width: double.infinity, height: 120),
                  const SizedBox(height: 16),
                  _SkeletonBar(width: 200, height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  final double width;
  final double height;
  const _SkeletonBar({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _GazeStatusBadge extends ConsumerWidget {
  const _GazeStatusBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gaze = ref.watch(gazeProvider);
    if (!gaze.isRunning) return const SizedBox.shrink();

    final isGazing = gaze.isCurrentlyGazing;
    final hasFace = gaze.faceDetected;

    final (label, color) = !hasFace
        ? ('얼굴 미감지', Colors.grey)
        : isGazing
            ? ('응시 중', Colors.green)
            : ('시선 분산', Colors.orange);

    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        avatar: Icon(
          hasFace ? (isGazing ? Icons.visibility : Icons.visibility_off) : Icons.face_retouching_off,
          size: 16,
          color: color,
        ),
        label: Text(label, style: TextStyle(fontSize: 12, color: color)),
        backgroundColor: color.withValues(alpha: 0.1),
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _CameraPreviewBadge extends StatelessWidget {
  final CameraController controller;
  const _CameraPreviewBadge({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 48,
        height: 36,
        child: CameraPreview(controller),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;
  const _StatusBanner({required this.icon, required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(fontSize: 12, color: color)),
          ),
        ],
      ),
    );
  }
}
