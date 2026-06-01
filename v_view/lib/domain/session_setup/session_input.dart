enum InterviewType { job, personality, university }

class SessionInput {
  final InterviewType type;
  final String position;
  final String company;
  final String selfIntroduction;
  final int questionCount;
  final int timerMinutes;

  const SessionInput({
    required this.type,
    required this.position,
    required this.company,
    required this.selfIntroduction,
    this.questionCount = 3,
    this.timerMinutes = 2,
  });

  SessionInput copyWith({
    InterviewType? type,
    String? position,
    String? company,
    String? selfIntroduction,
    int? questionCount,
    int? timerMinutes,
  }) {
    return SessionInput(
      type: type ?? this.type,
      position: position ?? this.position,
      company: company ?? this.company,
      selfIntroduction: selfIntroduction ?? this.selfIntroduction,
      questionCount: questionCount ?? this.questionCount,
      timerMinutes: timerMinutes ?? this.timerMinutes,
    );
  }
}
