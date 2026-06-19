import '../../local/hive_service.dart';
import '../../../domain/session_setup/session_input.dart';

class SessionInputLocalDatasource {
  static const _key = 'last_input';

  void save(SessionInput input) {
    HiveService.sessionInputBox.put(_key, {
      'type': input.type.index,
      'position': input.position,
      'company': input.company,
      'selfIntroduction': input.selfIntroduction,
    });
  }

  void clear() {
    HiveService.sessionInputBox.delete(_key);
  }

  SessionInput? load() {
    final raw = HiveService.sessionInputBox.get(_key);
    if (raw == null) return null;
    return SessionInput(
      type: InterviewType.values[raw['type'] as int],
      position: raw['position'] as String,
      company: raw['company'] as String,
      selfIntroduction: raw['selfIntroduction'] as String,
    );
  }
}
