# 테스트 전략

---

## 테스트 레벨

| 레벨 | 도구 | 대상 | 목적 |
|---|---|---|---|
| 단위 테스트 | `flutter_test` | domain/, state/ | 핵심 비즈니스 로직 검증 |
| 위젯 테스트 | `flutter_test` | ui/ widgets | UI 렌더링 검증 |
| 통합 테스트 | `integration_test` | 전체 흐름 | E2E 시나리오 |

---

## 핵심 테스트 케이스

### 1. 시선 분산 횟수 계산 (가장 중요)

```dart
// test/domain/gaze/gaze_analyzer_test.dart

test('분산 상태가 1초 미만이면 카운트되지 않는다', () {
  final frames = [
    GazeFrame(isGazing: false, faceDetected: true,
        timestamp: DateTime(2026, 1, 1, 0, 0, 0, 0)),
    GazeFrame(isGazing: true, faceDetected: true,
        timestamp: DateTime(2026, 1, 1, 0, 0, 0, 900)), // 0.9초
  ];
  final metrics = analyzer.computeMetrics(frames);
  expect(metrics.distractionCount, 0); // 1초 미만 → 카운트 안됨
});

test('분산 상태가 1초 이상이면 1회 카운트된다', () {
  final frames = [
    GazeFrame(isGazing: false, faceDetected: true,
        timestamp: DateTime(2026, 1, 1, 0, 0, 0, 0)),
    GazeFrame(isGazing: true, faceDetected: true,
        timestamp: DateTime(2026, 1, 1, 0, 0, 1, 100)), // 1.1초
  ];
  final metrics = analyzer.computeMetrics(frames);
  expect(metrics.distractionCount, 1);
});

test('응시율 공식: 응시 프레임 / 전체 프레임 × 100', () {
  // 10프레임 중 8프레임 응시
  final frames = List.generate(10, (i) => GazeFrame(
    isGazing: i < 8,
    faceDetected: true,
    timestamp: DateTime(2026, 1, 1).add(Duration(milliseconds: i * 100)),
  ));
  final metrics = analyzer.computeMetrics(frames);
  expect(metrics.gazeRate, closeTo(80.0, 0.1));
});
```

### 2. 세션 입력 유효성 검사

```dart
// test/state/session_setup/session_setup_provider_test.dart

test('필수 입력이 모두 있을 때 isValid = true', () {
  final container = ProviderContainer();
  final notifier = container.read(sessionInputProvider.notifier);
  notifier.setPosition('백엔드 개발자');
  notifier.setCompany('카카오');
  notifier.setSelfIntroduction('저는...');
  expect(notifier.isValid, true);
});

test('필수 입력 누락 시 isValid = false', () {
  final container = ProviderContainer();
  final notifier = container.read(sessionInputProvider.notifier);
  notifier.setPosition('');
  expect(notifier.isValid, false);
});
```

### 3. AI 실패 시 최소 리포트 대체

```dart
// test/state/report/report_provider_test.dart

test('OpenAI gpt-4o-mini 실패 시 시선 지표만으로 리포트가 생성된다', () async {
  final mockApi = MockClaudeApiService();
  when(mockApi.generateFeedback(any, any))
      .thenThrow(DioException(...));

  // ReportNotifier가 fallback 리포트를 반환해야 함
  // isAiFeedbackAvailable = false
  // improvementPoints는 비어있지 않음 (시선 기반 fallback)
});
```

---

## 테스트 실행

```bash
# 전체 테스트
flutter test

# 특정 파일
flutter test test/domain/gaze/gaze_analyzer_test.dart

# 커버리지 측정
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 테스트 작성 원칙

1. **비즈니스 규칙 우선**: 시선 분산 1초 기준, 응시율 공식은 반드시 테스트
2. **외부 의존성 모킹**: OpenAI gpt-4o-mini, ML Kit은 Mock 객체 사용
3. **엣지 케이스 포함**: 빈 프레임, 얼굴 미검출, API 실패
4. **Riverpod ProviderContainer 활용**: State 테스트는 실제 Provider 사용

---

## CI에서 테스트 실행 (GitHub Actions 예시)

```yaml
# .github/workflows/test.yml
name: Flutter Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.9'
      - run: cd v_view && flutter pub get
      - run: cd v_view && flutter analyze
      - run: cd v_view && flutter test
```
