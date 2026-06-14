import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/interview/interview_question.dart';
import '../../domain/session_setup/session_input.dart';
import '../../data/remote/ai/claude_api_service.dart';

enum InterviewPhase { idle, loadingQuestions, inProgress, paused, finished }

class InterviewState {
  final InterviewPhase phase;
  final List<InterviewQuestion> questions;
  final int currentIndex;
  final Map<String, String> userAnswers;
  final int timerSeconds;
  final int elapsedSeconds;
  final String? errorMessage;

  const InterviewState({
    this.phase = InterviewPhase.idle,
    this.questions = const [],
    this.currentIndex = 0,
    this.userAnswers = const {},
    this.timerSeconds = 120,
    this.elapsedSeconds = 0,
    this.errorMessage,
  });

  InterviewState copyWith({
    InterviewPhase? phase,
    List<InterviewQuestion>? questions,
    int? currentIndex,
    Map<String, String>? userAnswers,
    int? timerSeconds,
    int? elapsedSeconds,
    String? errorMessage,
  }) {
    return InterviewState(
      phase: phase ?? this.phase,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      errorMessage: errorMessage,
    );
  }

  InterviewQuestion? get currentQuestion =>
      questions.isEmpty ? null : questions[currentIndex];

  bool get isLastQuestion => currentIndex >= questions.length - 1;
}

final claudeApiServiceProvider = Provider((_) => ClaudeApiService());

final interviewProvider =
    StateNotifierProvider<InterviewNotifier, InterviewState>((ref) {
  return InterviewNotifier(ref.read(claudeApiServiceProvider));
});

class InterviewNotifier extends StateNotifier<InterviewState> {
  final ClaudeApiService _api;

  InterviewNotifier(this._api) : super(const InterviewState());

  Future<void> start(SessionInput input) async {
    state = state.copyWith(phase: InterviewPhase.loadingQuestions);
    try {
      final questions = await _api.generateQuestions(input);
      state = state.copyWith(
        phase: InterviewPhase.inProgress,
        questions: questions,
        currentIndex: 0,
      );
    } on Exception catch (_) {
      state = state.copyWith(
        phase: InterviewPhase.idle,
        errorMessage: '질문 생성에 실패했습니다. 네트워크를 확인하고 다시 시도해주세요.',
      );
    }
  }

  void submitAnswer(String answer) {
    final q = state.currentQuestion;
    if (q == null) return;
    final updated = Map<String, String>.from(state.userAnswers);
    updated[q.id] = answer;
    state = state.copyWith(userAnswers: updated);
  }

  Future<void> nextQuestion(String answer) async {
    submitAnswer(answer);
    final q = state.currentQuestion!;

    if (answer.isNotEmpty && _followUpDepth(q) < 2) {
      try {
        final followUp = await _api.generateFollowUp(
          question: q,
          userAnswer: answer,
        );
        if (followUp != null) {
          final updated = List<InterviewQuestion>.from(state.questions);
          updated.insert(state.currentIndex + 1, followUp);
          state = state.copyWith(
            questions: updated,
            currentIndex: state.currentIndex + 1,
            phase: InterviewPhase.inProgress,
          );
          return;
        }
      } on Exception {
        // 꼬리 질문 실패 시 다음 기본 질문으로 진행
      }
    }

    if (state.isLastQuestion) {
      state = state.copyWith(phase: InterviewPhase.finished);
    } else {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  // 현재 질문의 꼬리질문 깊이 반환 (기본 질문=0, 1차 꼬리=1, 2차 꼬리=2)
  int _followUpDepth(InterviewQuestion q) {
    if (!q.isFollowUp) return 0;
    int depth = 1;
    String? parentId = q.parentQuestionId;
    while (parentId != null) {
      final parents = state.questions.where((x) => x.id == parentId).toList();
      if (parents.isEmpty) break;
      final parent = parents.first;
      if (!parent.isFollowUp) break;
      depth++;
      parentId = parent.parentQuestionId;
    }
    return depth;
  }

  void reset() => state = const InterviewState();

  void pause() => state = state.copyWith(phase: InterviewPhase.paused);
  void resume() => state = state.copyWith(phase: InterviewPhase.inProgress);

  void finish() => state = state.copyWith(phase: InterviewPhase.finished);

  void tickTimer() {
    state = state.copyWith(
      timerSeconds: state.timerSeconds - 1,
      elapsedSeconds: state.elapsedSeconds + 1,
    );
  }

  void resetTimer(int seconds) =>
      state = state.copyWith(timerSeconds: seconds);
}
