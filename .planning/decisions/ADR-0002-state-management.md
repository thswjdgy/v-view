# ADR-0002: 상태관리 선택 — Riverpod

| 항목 | 내용 |
|------|------|
| **날짜** | 2026-05-10 |
| **상태** | 확정 (Accepted) |
| **작성자** | 손정협 |

---

## 배경 (Context)

Flutter 선택 후, 면접 세션 진행 중 시선 지표가 실시간으로 바뀌고 세션 종료 후 리포트 데이터가 여러 화면에서 공유되어야 한다. 이를 효율적으로 관리할 상태관리 라이브러리가 필요하다.

---

## 결정 (Decision)

**Riverpod 선택**

---

## 대안 (Alternatives)

| 라이브러리 | 장점 | 제외 이유 |
|-----------|------|-----------|
| Provider | 단순함 | Riverpod으로 대체 추세, 타입 안전성 부족 |
| BLoC | 대규모 앱에 강함 | 기능 하나에 파일 3개 필요 → AI가 만든 코드를 이해하고 설명하기 어렵다고 판단 |
| setState | 가장 단순 | 실시간 시선 데이터 + 세션 + 리포트 복합 상태 관리 불가 |

---

## 결과 (Consequences)

**긍정적**
- Flutter 공식 권장 라이브러리
- `StateNotifierProvider`로 복잡한 상태 변화를 단계별로 추적 가능
- 테스트 시 `ProviderContainer` + `overrides`로 Mock 교체 용이 → Hive 없이 단위 테스트 가능

**데이터 흐름**
```
카메라 프레임 → ML Kit 분석 → GazeNotifier.processFrame() → 화면 업데이트
```

---

## 60초 말하기

> "Riverpod을 선택했습니다. Flutter 공식 권장 상태관리이고 실시간 시선 데이터를 StateNotifier로 처리하기에 최적이기 때문입니다. BLoC도 검토했지만, 기능 하나에 파일이 3개 필요한 구조라 AI가 만든 코드를 제가 이해하고 설명하기 어렵다고 판단해서 제외했습니다."

> AI Agent(Claude Code) 초안 생성 / 손정협 직접 검토 확인
