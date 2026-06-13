import 'package:hive_flutter/hive_flutter.dart';

const _boxSession = 'sessions';
const _boxReport = 'reports';
const _boxHistory = 'history';
const _boxSessionInput = 'session_input';
const _boxSettings = 'settings';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<Map>(_boxSession),
      Hive.openBox<Map>(_boxReport),
      Hive.openBox<Map>(_boxHistory),
      Hive.openBox<Map>(_boxSessionInput),
      Hive.openBox(_boxSettings),
    ]);
  }

  static Box<Map> get sessionBox => Hive.box<Map>(_boxSession);
  static Box<Map> get reportBox => Hive.box<Map>(_boxReport);
  static Box<Map> get historyBox => Hive.box<Map>(_boxHistory);
  static Box<Map> get sessionInputBox => Hive.box<Map>(_boxSessionInput);
  static Box get settingsBox => Hive.box(_boxSettings);
}
