import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  FirebaseService._();

  static String handleFirebaseError(Object e) {
    if (e is FirebaseAuthException) {
      return _translateAuthError(e.code);
    }
    return '오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
  }

  static String _translateAuthError(String code) {
    return switch (code) {
      'user-not-found' => '등록되지 않은 이메일입니다.',
      'wrong-password' => '비밀번호가 올바르지 않습니다.',
      'invalid-credential' => '이메일 또는 비밀번호가 올바르지 않습니다.',
      'user-disabled' => '비활성화된 계정입니다.',
      'too-many-requests' => '로그인 시도가 너무 많습니다. 잠시 후 다시 시도해주세요.',
      'email-already-in-use' => '이미 사용 중인 이메일입니다.',
      'weak-password' => '비밀번호는 6자 이상이어야 합니다.',
      'invalid-email' => '올바른 이메일 형식이 아닙니다.',
      'network-request-failed' => '네트워크 연결을 확인해주세요.',
      'requires-recent-login' => '보안을 위해 다시 로그인해주세요.',
      _ => '오류가 발생했습니다. ($code)',
    };
  }
}
