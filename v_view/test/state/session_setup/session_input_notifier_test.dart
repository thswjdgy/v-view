import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:v_view/domain/session_setup/session_input.dart';
import 'package:v_view/state/session_setup/session_setup_provider.dart';

// Hive가 초기화되지 않은 테스트 환경에서 Provider를 override해 Datasource를 우회합니다.
ProviderContainer makeContainer() => ProviderContainer(
      overrides: [
        sessionInputProvider
            .overrideWith((_) => SessionInputNotifier(null, null)),
      ],
    );

void main() {
  group('SessionInputNotifier.isValid', () {
    test('필수 입력 3개 모두 있을 때 isValid = true', () {
      final container = makeContainer();
      final notifier = container.read(sessionInputProvider.notifier);
      notifier.setPosition('백엔드 개발자');
      notifier.setCompany('카카오');
      notifier.setSelfIntroduction('저는 3년차 백엔드 개발자입니다.');
      expect(notifier.isValid, true);
    });

    test('position 비어있으면 isValid = false', () {
      final container = makeContainer();
      final notifier = container.read(sessionInputProvider.notifier);
      notifier.setPosition('');
      notifier.setCompany('카카오');
      notifier.setSelfIntroduction('저는...');
      expect(notifier.isValid, false);
    });

    test('company 비어있으면 isValid = false', () {
      final container = makeContainer();
      final notifier = container.read(sessionInputProvider.notifier);
      notifier.setPosition('백엔드 개발자');
      notifier.setCompany('');
      notifier.setSelfIntroduction('저는...');
      expect(notifier.isValid, false);
    });

    test('selfIntroduction 비어있으면 isValid = false', () {
      final container = makeContainer();
      final notifier = container.read(sessionInputProvider.notifier);
      notifier.setPosition('백엔드 개발자');
      notifier.setCompany('카카오');
      notifier.setSelfIntroduction('');
      expect(notifier.isValid, false);
    });

    test('공백만 있으면 isValid = false', () {
      final container = makeContainer();
      final notifier = container.read(sessionInputProvider.notifier);
      notifier.setPosition('   ');
      notifier.setCompany('카카오');
      notifier.setSelfIntroduction('저는...');
      expect(notifier.isValid, false);
    });

    test('setType이 상태를 변경한다', () {
      final container = makeContainer();
      final notifier = container.read(sessionInputProvider.notifier);
      notifier.setType(InterviewType.university);
      expect(container.read(sessionInputProvider).type, InterviewType.university);
    });

    test('update 후 상태가 반영된다', () {
      final container = makeContainer();
      final notifier = container.read(sessionInputProvider.notifier);
      notifier.setPosition('프론트엔드');
      notifier.setCompany('네이버');
      expect(container.read(sessionInputProvider).position, '프론트엔드');
      expect(container.read(sessionInputProvider).company, '네이버');
    });
  });
}
