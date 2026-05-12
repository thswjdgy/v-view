# ADR-002: 상태 관리로 Riverpod 선택

## 상태
Accepted — 2026-05-10

## 컨텍스트

면접 세션 진행 중 여러 화면이 동일한 상태(질문 목록, 시선 지표, 타이머)를
공유해야 한다. 상태 관리 라이브러리 선택이 필요했다.

후보:
- Riverpod
- Provider (기존 Flutter 권장)
- BLoC/Cubit
- GetX

## 결정

**Riverpod (2.x, StateNotifierProvider) 을 선택한다.**

## 이유

1. **컴파일 타임 안전성**: Provider처럼 런타임 에러 없이 타입 체크
2. **테스트 용이성**: `ProviderContainer`로 Provider를 독립적으로 테스트 가능
3. **의존성 오버라이드**: 테스트 시 mock으로 쉽게 교체
4. **코드 생성 불필요**: `StateNotifierProvider`는 코드 생성 없이 사용 가능 (build_runner 충돌 회피)
5. **Flutter 독립성**: Riverpod는 Flutter 없이도 동작 → domain 레이어 테스트에 유리

## 결과

- `StateNotifierProvider` 패턴으로 5개 Notifier 구현 (session, interview, gaze, report, history)
- `ProviderScope`가 앱 루트에 위치
- `riverpod_annotation`/`riverpod_generator` 미사용 (hive_generator와 source_gen 버전 충돌로 제거)

## 대안 검토

| 대안 | 기각 이유 |
|---|---|
| Provider | Riverpod의 하위 호환, 컴파일 타임 안전성 부족 |
| BLoC | 보일러플레이트 과다, 1인 프로젝트에 오버엔지니어링 |
| GetX | 전역 상태로 테스트 어려움, Riverpod 대비 타입 안전성 낮음 |
