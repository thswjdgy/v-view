import 'dart:async';
import 'package:camera/camera.dart';
import '../../services/speech_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../theme/app_theme.dart';
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
  bool _isSubmitting = false;

  SpeechService? _speechService;
  bool _sttActive = false;
  StreamSubscription<String>? _sttSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initCamera();
      _startSession();
      _initSpeech();
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
    _sttSub?.cancel();
    _speechService?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initSpeech() async {
    final service = SpeechService();
    final ok = await service.initialize();
    if (!mounted) return;
    if (ok) {
      _sttSub = service.textStream.listen((text) {
        if (!mounted) return;
        _answerController.text = text;
        _answerController.selection =
            TextSelection.collapsed(offset: text.length);
      });
      setState(() => _speechService = service);
    } else {
      await service.dispose();
    }
  }

  Future<void> _toggleMic() async {
    final service = _speechService;
    if (service == null) return;
    if (_sttActive) {
      await service.stopListening();
      if (mounted) setState(() => _sttActive = false);
    } else {
      _answerController.clear();
      await service.startListening();
      if (mounted) setState(() => _sttActive = true);
    }
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
    if (ref.read(interviewProvider).questions.isEmpty) {
      ref.read(interviewProvider.notifier).start(input);
    }
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
    if (_isSubmitting) return;
    if (_sttActive) {
      await _speechService?.stopListening();
      if (mounted) setState(() => _sttActive = false);
    }
    setState(() => _isSubmitting = true);
    final answer = _answerController.text.trim();
    _answerController.clear();
    _timer?.cancel();
    await ref.read(interviewProvider.notifier).nextQuestion(answer);
    if (mounted) setState(() => _isSubmitting = false);
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
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Full-screen camera background
            if (_cameraReady && _cameraController != null)
              Positioned.fill(
                child: CameraPreview(_cameraController!),
              ),
            // Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
            // UI layer
            SafeArea(child: _buildBody(context, state)),
          ],
        ),
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

    return Column(
      children: [
        // ── Top bar: quit + progress + gaze ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              _GlassButton(
                onTap: () => _showExitDialog(context),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProgressBar(
                  current: state.currentIndex,
                  total: state.questions.length,
                ),
              ),
              const SizedBox(width: 12),
              _GazeIndicator(),
            ],
          ),
        ),
        // ── Status banners ──
        if (_cameraError || _micDenied)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                if (_cameraError)
                  _StatusBanner(
                    icon: Icons.videocam_off,
                    message: '카메라 없음 — 시선 분석 비활성',
                    color: Colors.orange,
                  ),
                if (_micDenied)
                  _StatusBanner(
                    icon: Icons.mic_off,
                    message: '마이크 권한 없음',
                    color: Colors.orange,
                  ),
              ],
            ),
          ),
        // ── Question card (glass) ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _GlassPanel(
            borderRadius: 20,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.secondaryContainer
                                  .withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          'Q${state.currentIndex + 1} / ${state.questions.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondaryContainer,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TimerWidget(seconds: state.timerSeconds),
                    ],
                  ),
                  const SizedBox(height: 12),
                  QuestionCard(
                    question: q,
                    index: state.currentIndex,
                    total: state.questions.length,
                  ),
                ],
              ),
            ),
          ),
        ),
        // ── Answer area expands ──
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: _GlassPanel(
              borderRadius: 16,
              child: Stack(
                children: [
                  TextField(
                    controller: _answerController,
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.5),
                    decoration: InputDecoration(
                      hintText: '답변을 입력하세요...',
                      hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      filled: false,
                    ),
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                  ),
                  if (_speechService != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: _MicButton(
                        active: _sttActive,
                        onTap: _toggleMic,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        // ── Bottom control bar (glass) ──
        _GlassPanel(
          borderRadius: 24,
          bottomRounded: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _OutlineGlassButton(
                    label: '종료',
                    onTap: () => _showExitDialog(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: _PrimaryGlassButton(
                    label: state.isLastQuestion ? '완료' : '다음 질문',
                    loading: _isSubmitting,
                    onTap: _isSubmitting ? null : _submitAndNext,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPausedBody(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _GlassPanel(
          borderRadius: 24,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pause_circle_outline_rounded,
                    color: Colors.white, size: 48),
                const SizedBox(height: 16),
                const Text(
                  '면접이 일시정지되었습니다.',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
                const SizedBox(height: 24),
                _PrimaryGlassButton(
                    label: '재개', onTap: _resumeSession),
                const SizedBox(height: 12),
                _OutlineGlassButton(
                    label: '종료 및 리포트', onTap: _finishSession),
              ],
            ),
          ),
        ),
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
          ElevatedButton(
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

// ── Glass panel helper ────────────────────────────────────────────────────
class _GlassPanel extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool bottomRounded;

  const _GlassPanel({
    required this.child,
    this.borderRadius = 16,
    this.bottomRounded = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: bottomRounded
            ? BorderRadius.circular(borderRadius)
            : BorderRadius.vertical(top: Radius.circular(borderRadius)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: child,
    );
  }
}

// ── Glass icon button ─────────────────────────────────────────────────────
class _GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _GlassButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: child,
      ),
    );
  }
}

// ── Mic button ────────────────────────────────────────────────────────────
class _MicButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  const _MicButton({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: active
              ? AppColors.secondaryContainer.withValues(alpha: 0.9)
              : AppColors.primaryContainer.withValues(alpha: 0.85),
          shape: BoxShape.circle,
        ),
        child: Icon(
          active ? Icons.mic_rounded : Icons.mic_none_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

// ── Progress bar ──────────────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : current / total;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        builder: (context, value, _) => LinearProgressIndicator(
          value: value,
          minHeight: 8,
          backgroundColor: Colors.white.withValues(alpha: 0.3),
          valueColor:
              AlwaysStoppedAnimation<Color>(AppColors.primaryContainer),
        ),
      ),
    );
  }
}

// ── Gaze indicator ────────────────────────────────────────────────────────
class _GazeIndicator extends ConsumerWidget {
  const _GazeIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gaze = ref.watch(gazeProvider);
    if (!gaze.isRunning) return const SizedBox.shrink();

    final isGazing = gaze.isCurrentlyGazing;
    final hasFace = gaze.faceDetected;
    final color = !hasFace
        ? Colors.grey
        : isGazing
            ? AppColors.primaryContainer
            : AppColors.secondaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasFace
                ? (isGazing ? Icons.visibility_rounded : Icons.visibility_off_rounded)
                : Icons.face_retouching_off_rounded,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            !hasFace ? '미감지' : isGazing ? '응시' : '분산',
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ── Status banner ─────────────────────────────────────────────────────────
class _StatusBanner extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;
  const _StatusBanner(
      {required this.icon, required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: TextStyle(fontSize: 12, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Primary action button (glass context) ────────────────────────────────
class _PrimaryGlassButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  const _PrimaryGlassButton(
      {required this.label, required this.onTap, this.loading = false});

  @override
  State<_PrimaryGlassButton> createState() => _PrimaryGlassButtonState();
}

class _PrimaryGlassButtonState extends State<_PrimaryGlassButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        margin: EdgeInsets.only(top: _pressed ? 4 : 0),
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            bottom: BorderSide(
                color: AppColors.primaryShadow, width: _pressed ? 0 : 3),
          ),
        ),
        child: widget.loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(
                widget.label,
                style: TextStyle(
                  color: AppColors.onPrimaryContainer,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

// ── Outline button (glass context) ────────────────────────────────────────
class _OutlineGlassButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineGlassButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ── Loading skeleton ──────────────────────────────────────────────────────
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _GlassPanel(
          borderRadius: 20,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                    color: AppColors.primaryContainer),
                const SizedBox(height: 16),
                Text(
                  'AI가 맞춤 질문을 생성 중입니다...',
                  style: TextStyle(
                      color: AppColors.onSurface, fontSize: 14),
                ),
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _opacity,
                  builder: (context, _) => Opacity(
                    opacity: _opacity.value,
                    child: Column(
                      children: [
                        _SkeletonBar(width: double.infinity, height: 16),
                        const SizedBox(height: 8),
                        _SkeletonBar(width: 200, height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
