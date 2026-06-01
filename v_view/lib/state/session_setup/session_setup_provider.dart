import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/session_setup/session_input.dart';
import '../../data/local/session/session_input_local_datasource.dart';

final _datasource = SessionInputLocalDatasource();

final sessionInputProvider =
    StateNotifierProvider<SessionInputNotifier, SessionInput>((ref) {
  return SessionInputNotifier(_datasource.load(), _datasource);
});

class SessionInputNotifier extends StateNotifier<SessionInput> {
  final SessionInputLocalDatasource? _ds;

  SessionInputNotifier(SessionInput? saved, [this._ds])
      : super(saved ??
            const SessionInput(
              type: InterviewType.job,
              position: '',
              company: '',
              selfIntroduction: '',
            ));

  void update(SessionInput input) {
    state = input;
    _ds?.save(input);
  }

  void setType(InterviewType type) => update(state.copyWith(type: type));
  void setPosition(String v) => update(state.copyWith(position: v));
  void setCompany(String v) => update(state.copyWith(company: v));
  void setSelfIntroduction(String v) =>
      update(state.copyWith(selfIntroduction: v));
  void setQuestionCount(int v) => update(state.copyWith(questionCount: v));
  void setTimerMinutes(int v) => update(state.copyWith(timerMinutes: v));

  bool get isValid =>
      state.position.trim().isNotEmpty &&
      state.company.trim().isNotEmpty &&
      state.selfIntroduction.trim().isNotEmpty;
}
