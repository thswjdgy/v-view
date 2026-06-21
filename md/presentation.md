---
marp: true
theme: default
paginate: true
backgroundColor: '#ffffff'
style: |
  section { font-family: 'Noto Sans KR', sans-serif; font-size: 22px; }
  h1 { color: #3949ab; }
  h2 { color: #3949ab; border-bottom: 2px solid #3949ab; padding-bottom: 8px; }
  code { background: #f5f5f5; padding: 2px 6px; border-radius: 4px; }
  table { font-size: 18px; }
---

# v-view
## AI 기반 가상 면접 코칭 앱

**손정효** · Flutter + OpenAI API · 2026

---

## What — 무엇을 만들었나

> 취업 준비생이 혼자서도 실전 면접 연습을 할 수 있는 AI 코칭 앱

- 📋 **AI 맞춤 질문 생성** — 직종·자기소개서 기반 OpenAI gpt-4o-mini
- 👁️ **실시간 시선 분석** — ML Kit으로 카메라 응시율 측정
- 📊 **피드백 리포트** — 시선 지표 + AI 개선 포인트 TOP3
- 🗂️ **면접 기록 관리** — 히스토리 목록, 상세 재열람, 삭제
- 🔐 **Firebase Auth 로그인/회원가입** — 이메일 + Firestore 사용자 저장

---

## Why — 왜 만들었나

| 문제 | 해결 |
|---|---|
| 면접 코칭 비용 부담 | AI가 무제한 질문 생성 |
| 시선 처리 피드백 없음 | ML Kit 실시간 분석 |
| 연습 기록 관리 어려움 | 로컬 히스토리 자동 저장 |
| 개인정보 유출 우려 | 영상 미저장, 기기 로컬만 |

---

## 기술 스택

| 분류 | 선택 | 이유 |
|---|---|---|
| Framework | Flutter 3.38 | 단일 코드베이스, 카메라·ML 생태계 |
| State | Riverpod 2.6 | 컴파일타임 안전성, Provider 계층 분리 |
| Local DB | Hive 2.2 | 스키마리스, 빠른 읽기, 코드젠 불필요 |
| AI | OpenAI gpt-4o-mini | 빠른 응답, 한국어 품질, cost efficiency |
| Auth | Firebase Auth + Firestore | 무서버, 실시간 인증 상태 스트림 |
| Vision | ML Kit | 온디바이스 처리, 개인정보 보호 |

---

## 아키텍처 — 레이어 구조

```
UI Layer        ← 화면, 위젯
    ↓
State Layer     ← Riverpod Notifier (비즈니스 로직)
    ↓
Domain Layer    ← Entity, 규칙 (순수 Dart)
    ↑
Data Layer      ← Local (Hive) / Remote (Dio, ML Kit)
```

- UI는 State만 참조, Data를 직접 호출하지 않음
- Domain은 외부 의존성 없는 순수 모델

---

## 핵심 구현 — 시선 분석 파이프라인

```
CameraImage (매 프레임)
    ↓ CameraFrameConverter
InputImage (ML Kit 포맷)
    ↓ GazeAnalyzer.analyze()
GazeFrame (isGazing, faceDetected, timestamp)
    ↓ GazeNotifier.processFrame()
GazeState.frames 누적
    ↓ GazeAnalyzer.computeMetrics()
GazeMetrics (응시율, 분산 횟수, 분산 시간)
```

**핵심 규칙:** 시선 분산 **1초 이상** 연속 → 1회 카운트

---

## 테스트 전략

| 대상 | 파일 | 테스트 수 |
|---|---|---|
| 시선 분석 | `gaze_analyzer_test.dart` | 10개 |
| 면접 진행 | `interview_notifier_test.dart` | 20개 |
| 세션 입력 | `session_input_notifier_test.dart` | 7개 |
| 리포트 상태 | `report_notifier_test.dart` | 7개 |
| 위젯 | `widget_test.dart` | 1개 |

```
flutter test → 45/45 통과
flutter analyze → 이슈 0개
```

---

## AI Agent 활용 방식

**Claude Code (claude-sonnet-4-6)** 와 페어 프로그래밍

1. `CLAUDE.md` — 프로젝트 컨텍스트·원칙 주입
2. `AGENTS.md` — 레이어 규칙, 비즈니스 규칙 명세
3. 세션 시작마다 AGENTS.md 읽기 → 일관성 유지
4. 커밋 단위로 `flutter analyze` 통과 보장

> "AI가 코드를 짜고, 사람이 방향을 결정한다"

*자세한 방법론: `AUTHORING.손정효.md`*

---

## Q&A 예상 질문

**Q. 시선 분산 1초 기준을 왜 정했나?**
A. 순간 눈 깜빡임(0.3초)과 실제 주의 분산을 구분하기 위한 실용적 임계값

**Q. Riverpod vs Provider?**
A. 컴파일타임 안전성, 전역 ProviderScope, 테스트 시 override 용이

**Q. AI 실패 시 어떻게 처리?**
A. try/catch → 시선 지표 기반 fallback 리포트 자동 생성

**Q. Hive vs SQLite?**
A. 스키마 마이그레이션 불필요, Map 직렬화로 충분한 단순 구조

---

## 마무리

- **MVP 6개 기능 + Firebase Auth** 구현 완료
- `flutter test` **45개** 전부 통과
- `flutter analyze` 이슈 0개
- 릴리즈 APK 빌드 완료 (`app-release.apk` 80MB)
- AI Agent와 함께한 바이브 코딩 → `AUTHORING.손정효.md`

**GitHub:** `thswjdgy/v-view`

---

# 감사합니다
