# AI Agent 활용 보고서
## v-view — AI 면접 코치 앱

> 발표자: 손정협  
> 발표 시간: 약 10분  
> 사용 AI Agent: **Claude Code** (Anthropic)

---

## 1. 프로젝트 개요 (1분)

**v-view**는 AI가 맞춤 면접 질문을 생성하고, 실시간 시선 분석으로 피드백을 제공하는 모바일 면접 코치 앱입니다.

| 항목 | 내용 |
|---|---|
| 플랫폼 | Flutter (Android / iOS / Web) |
| AI Agent | Claude Code (CLI) |
| 기간 | 7주 (Week 1~7) |
| 총 커밋 | 40+ 커밋 |
| 테스트 | 45개 (전체 통과) |

---

## 2. AI Agent를 어떻게 활용했나 (2분)

### 2.1 활용 방식

```
개발자 역할: 방향 설정 · 검증 · 의사결정 · 설명
Claude Code: 코드 생성 · 리팩토링 · 테스트 · 문서화
```

단순한 코드 생성이 아닌 **대화형 개발** 방식을 채택했습니다.

1. `CLAUDE.md` + `AGENTS.md`로 프로젝트 컨텍스트 주입
2. TODO.md 기반으로 단계적 작업 지시
3. 각 결과물을 직접 검토하고 방향 수정
4. `flutter analyze` + `flutter test` 통과를 커밋 조건으로 설정

### 2.2 세션별 활용 내역

| Week | AI Agent 생성 내용 | 개발자 기여 |
|---|---|---|
| 1~2 | 기능명세서, WBS, CLAUDE.md | 주제 선정, 요구사항 정의 |
| 3 | 4-layer 아키텍처, ADR 4종, SETUP.md | 기술 스택 최종 결정 |
| 4 | 전체 화면 뼈대, 상태 관리 6종, Hive 연동 | 흐름 검증, 버그 발견 |
| 5 | 웹 플랫폼 지원, 시선 배지, 테스트 45개 | 카메라/마이크 요구사항 제시 |
| 5+ | 타이머 버그 수정, 발표 보고서 | 버그 재현, 수정 방향 판단 |

---

## 3. 실제 생성된 산출물 (3분)

### 3.1 코드 산출물 (주요)

```
lib/
├── data/remote/ai/claude_api_service.dart   — OpenAI gpt-4o-mini 질문/피드백 생성
├── data/remote/gaze/gaze_analyzer.dart      — ML Kit 시선 분석 로직
├── state/ (6개 Provider)                    — Riverpod 상태 관리 전체
├── ui/ (10개 화면·위젯)                     — Flutter UI 전체
└── domain/ (5개 엔티티)                     — 비즈니스 도메인 모델
```

### 3.2 테스트 산출물

| 파일 | 테스트 수 | 주요 검증 내용 |
|---|---|---|
| `gaze_analyzer_test.dart` | 10개 | 시선 분산 1초 기준, 응시율 공식 |
| `interview_notifier_test.dart` | 20개 | 상태 전환, 타이머, Fake API 연동 |
| `report_notifier_test.dart` | 6개 | fallback 리포트 생성 |
| `session_input_notifier_test.dart` | 7개 | 입력 유효성 조건 |
| `widget_test.dart` | 1개 | placeholder |
| **합계** | **45개** | **전체 통과** |

### 3.3 문서 산출물

| 문서 | 내용 |
|---|---|
| `CLAUDE.md` | AI Agent 코딩 원칙 7개 섹션 |
| `AGENTS.md` | AI Agent 작업 지침 |
| `docs/ARCHITECTURE.md` | Mermaid 다이어그램 포함 시스템 구조 |
| `docs/ADR/` | Flutter, Riverpod, Hive, OpenAI gpt-4o-mini 선택 근거 |
| `docs/SETUP.md` | 5분 실행 가이드 (OS별) |
| `WIKI.md` | LLM & Vibe Coding Wiki (바이브 코딩 암묵지) |
| `AUTHORING.손정협.md` | 개인 AI Agent 부트스트래핑 방법론 |

---

## 4. AI Agent가 어려웠던 부분 — 내가 개입한 곳 (2분)

AI Agent가 완벽하지 않아 **직접 판단해야 했던 사례 3가지**:

### 사례 1: Android 빌드 오류 3회 반복
- **문제**: `camera_android_camerax` 의존성 충돌
- **AI 시도**: resolutionStrategy → 버전 다운그레이드 → afterEvaluate
- **내 개입**: 에러 로그 해석, 각 방법의 한계 판단, 다음 접근 방향 결정
- **결과**: `pluginManager.withPlugin`으로 최종 해결

### 사례 2: 타이머 자동 넘김 버그
- **문제**: `timerSeconds=0`일 때 `nextQuestion()` 매초 중복 호출
- **AI 생성 당시**: 버그 없는 것처럼 보였음
- **내 개입**: 경계 조건(`timerSeconds=0`) 직접 추적하여 버그 발견
- **결과**: 자동 넘김 로직을 `tickTimer()` → `_startTimer()` 콜백으로 이동

### 사례 3: 웹 카메라 스트리밍 오류
- **문제**: 웹에서 `startImageStream()` 호출 → AssertionError
- **AI 생성 당시**: `kIsWeb` 가드 미적용
- **내 개입**: 에러 스택 트레이스 분석, 플랫폼 분기 방향 결정
- **결과**: `if (!kIsWeb)` 가드 추가

---

## 5. AUTHORING.손정협.md — 나만의 방법론 (1분)

7주간 Claude Code와 협업하며 정리한 개인 방법론:

### 핵심 원칙 5가지

1. **컨텍스트 주입 우선** — `CLAUDE.md` + `AGENTS.md`로 AI가 프로젝트를 "알게" 만들기
2. **TODO 기반 세션 시작** — 매 세션 TODO.md 확인 후 우선순위 지시
3. **검증 조건 명시** — "되게 해줘"가 아닌 "테스트 통과 조건 먼저 작성 후 구현"
4. **Analyze → Test → Commit 순서** — 커밋 전 필수 3단계
5. **실패 사례 기록** — LLM-WIKI.md에 패턴·실패 사례·해결책 누적

### 정량적 성과

| 지표 | 수치 |
|---|---|
| 총 커밋 수 | 40+ |
| 생성된 Dart 파일 | 35개 |
| 단위 테스트 | 45개 |
| ADR 문서 | 4개 |
| `dart analyze` | No issues |

---

## 6. 배운 것과 한계 (1분)

### AI Agent가 잘하는 것
- 반복적인 보일러플레이트 코드 생성
- 테스트 케이스 구조화
- 문서 초안 작성
- 레이어 구조 일관성 유지

### AI Agent의 한계 (직접 경험)
- **플랫폼별 차이** 파악 부족 (web/mobile 분기)
- **Gradle 빌드 시스템** 세부 오류 해석
- **경계 조건 버그** (타이머 자동 넘김)
- 생성 코드가 동작하는지 **직접 실행 검증 필요**

### 결론
> AI Agent는 **속도**를 주고,  
> 개발자는 **방향과 검증**을 담당한다.  
> 7주 만에 테스트 45개, 화면 10개, 문서 10종을  
> 혼자서 완성할 수 있었던 이유입니다.

---

## Q&A 예상 질문

**Q. AI가 만든 코드를 본인이 이해하고 있나?**
> 네. 각 레이어의 역할, 상태 흐름, 타이머 로직을 직접 설명할 수 있습니다. 특히 타이머 버그는 제가 직접 발견하고 수정했습니다.

**Q. AI 없이 짠 코드는 어디인가?**
> CLAUDE.md 원칙 설계, 각 ADR의 최종 결정, 버그 재현 조건 분석, 발표 자료 구성이 제 직접 기여입니다.

**Q. AI가 틀린 코드를 생성한 적 있나?**
> 3번 있었습니다. 웹 카메라 스트리밍, 타이머 자동 넘김, Android Gradle 충돌입니다. 각각 제가 에러를 분석하고 수정 방향을 제시했습니다.
