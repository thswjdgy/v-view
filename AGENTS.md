# AGENTS.md — v-view AI Agent 운용 지침서

> **v-view** 프로젝트에서 Claude Code(AI Agent)를 활용한 바이브 코딩(Vibe Coding) 프로세스,
> 운용 규칙(Rules), 커스텀 스킬(Skills), 자동화 명령어(Commands)를 단일 문서로 통합합니다.
> 이 파일은 팀원·AI Agent 모두가 참조하는 **단일 진실 소스(Single Source of Truth)**입니다.

---

## 목차

1. [AI Agent Workflow & Architecture](#1-ai-agent-workflow--architecture)
2. [Core Rules & Instructions](#2-core-rules--instructions)
3. [Agent Skills & Specialized Commands](#3-agent-skills--specialized-commands)
4. [바이브 코딩 최적화 기법](#4-바이브-코딩-최적화-기법)
5. [프로젝트 컨텍스트 참조](#5-프로젝트-컨텍스트-참조)

---

## 1. AI Agent Workflow & Architecture

### 1.1 채택 Agent 구성

| Agent | 역할 | 사용 도구 |
|---|---|---|
| **Claude Code (Primary Agent)** | 코드 생성·수정·디버깅·커밋 전 과정 총괄 | Edit, Read, Bash, Grep, Glob, PowerShell |
| **Explore Subagent** | 코드베이스 심층 탐색 및 파일 맵 생성 | Grep, Glob, Read (읽기 전용) |
| **Monitor** | 백그라운드 빌드·앱 실행 상태 비동기 추적 | tail -f + grep 파이프라인 |

### 1.2 5단계 개발 Workflow

```
┌─────────────────────────────────────────────────────────┐
│  VIBE CODING WORKFLOW — v-view                          │
│                                                         │
│  1. DIAGNOSE   →   2. PLAN   →   3. IMPLEMENT          │
│       ↑                                  ↓              │
│  5. COMMIT   ←   4. VERIFY (adb + screenshot)          │
└─────────────────────────────────────────────────────────┘
```

**① DIAGNOSE (진단)**
- Explore Subagent로 관련 Provider·파일·의존성을 한 번에 파악
- `flutter analyze` 로 기존 오류 목록 확보 후 수정 범위 결정
- 건드리면 안 되는 보호 파일 목록을 먼저 확인 (Section 2.1 참조)

**② PLAN (계획)**
- 변경 파일·변경 이유·검증 방법을 표로 정리
- 범위 최소화 원칙: "이 변경이 요청에서 직접 추적 가능한가?" 자가 검증
- 수정 우선순위: 버그 수정 → 기능 추가 → UI 개선 순

**③ IMPLEMENT (구현)**
- `Edit` 도구로 외과적 수정(Surgical Change) — 파일 전체 재작성 금지
- 변경 직후 IDE Diagnostics 훅으로 lint 오류 즉시 감지 및 수정
- 독립적인 파일 수정은 병렬로 처리하여 속도 최적화

**④ VERIFY (검증)**
- `flutter run -d emulator-5554` 백그라운드 실행
- `adb shell uiautomator dump` 로 UI 좌표를 정확히 파악 후 `adb shell input tap`
- `adb shell screencap` → `Read` 도구로 실제 렌더링 시각 확인
- `flutter analyze [파일]` 로 정적 분석 통과 최종 확인

**⑤ COMMIT (커밋)**
- `git add [파일 명시]` — `git add .` 절대 금지 (`.env` 등 민감 파일 보호)
- 커밋 메시지: `feat/fix/chore: 한 줄 요약` 형식 준수
- 로컬 브랜치(week{n}) → push → main merge → push 순서 고수

### 1.3 병렬 Agent 처리 패턴

시간이 걸리는 작업은 독립적인 경우 병렬로 실행합니다.

```
[병렬 처리 예시]
Bash: flutter build apk (background) ┐
Read: 관련 파일 분석                  ├─→ Monitor로 완료 알림 수신
Grep: 패턴 탐색                       ┘        ↓
                                          결과 통합 후 처리
```

---

## 2. Core Rules & Instructions

> 이 Rules는 AI Agent의 시스템 프롬프트 역할을 하며 모든 세션에서 최우선 적용됩니다.

### 2.1 절대 금지 Rules (Hard Rules)

```
🚫 API 키 하드코딩 — .env 파일 분리 필수 (dotenv.env['OPENAI_API_KEY'])
🚫 원본 카메라 영상/오디오 로컬 저장 금지
🚫 보호 파일 수정 금지:
     - lib/state/gaze/gaze_provider.dart
     - lib/data/remote/gaze/gaze_analyzer.dart
     - lib/data/remote/speech_service.dart
     - lib/data/remote/camera_frame_converter.dart
🚫 FilledButton 사용 금지 — primary(#006B58)와 primaryContainer(#00C9A7) 색상 충돌
🚫 git add -A / git add . 사용 금지 — 파일 경로를 명시적으로 지정
🚫 v2 기능(STT, 표정 분석) 선구현 금지
🚫 요청하지 않은 파일 수정 금지 — 변경된 모든 줄은 요청에서 추적 가능해야 함
```

### 2.2 코드 품질 Rules

| Rule | 내용 |
|---|---|
| **Surgical Change** | 요청 범위만 수정. 인접 "개선할 것 같은" 코드 손대지 않음 |
| **No Premature Abstraction** | 요청하지 않은 유틸 클래스·헬퍼 함수 생성 금지 |
| **Orphan Cleanup** | 내가 만든 미사용 import·변수는 내가 즉시 정리 |
| **No Dead Code Comment** | `// 삭제됨`, `// 이전 버전` 주석 잔류 금지 |
| **No Error Handling Theater** | 발생 불가능한 시나리오에 대한 try-catch 추가 금지 |
| **Minimum Viable Error** | 오류 처리는 시스템 경계(사용자 입력, 외부 API)에만 적용 |

### 2.3 아키텍처 Rules

```
UI (lib/ui/)
  └─ watch/read ──▶ State (lib/state/ — Riverpod Providers)
                        └─ call ──▶ Domain (lib/domain/ — 순수 Dart)
                                       ├─▶ data/local/  (Hive)
                                       └─▶ data/remote/ (OpenAI API, Firebase, ML Kit)
```

**레이어 의존성 방향 (단방향)**
- `ui/` → `state/` 만 참조. `data/` 직접 참조 금지
- `domain/` → 어떤 레이어도 import하지 않음 (순수 Dart 엔티티)
- `data/` → `domain/` 만 참조

**Provider 상태 초기화 Rule**
```dart
// 새 면접 세션 시작 시 반드시 쌍으로 호출
ref.read(interviewProvider.notifier).reset();  // 질문·답변·인덱스 초기화
ref.read(gazeProvider.notifier).reset();        // 시선 프레임·메트릭 초기화
```

**Hive 저장 Rule**
- 영구 저장 대상: `SessionReport` (기록)만
- 면접 중간 상태 (`InterviewState`, `GazeState`) 는 메모리 only

### 2.4 디자인 시스템 Rules

| 항목 | 값 |
|---|---|
| Primary Color | `#00C9A7` (민트-틸) |
| Secondary Color | `#FF6B6B` (코랄) |
| Background | 흰색 |
| Text | `#1A2238` |
| Border Radius | 16 ~ 20 px |
| 테마 모드 | 라이트 모드 전용 |
| CTA 버튼 | Duolingo 3D-press 스타일 (`primaryContainer` 기반) |

**Duolingo 3D-press 버튼 구현 Rule**
```dart
// ✅ 올바른 구현 — pressed 시 border 자체를 null로 제거
border: _pressed
    ? null
    : Border(bottom: BorderSide(color: AppColors.primaryShadow, width: 4)),

// ❌ 잘못된 구현 — width:0 + borderRadius 조합은 Flutter assertion 오류 발생
// border: Border(bottom: BorderSide(width: _pressed ? 0 : 4))  ← 금지
```

### 2.5 AI API 프롬프트 Rules

```dart
// 시스템 프롬프트: JSON만 반환하도록 강제
static const _jsonSystem =
    '반드시 유효한 JSON만 반환하세요. 설명이나 마크다운 코드블록을 포함하지 마세요.';
```

- 꼬리질문: AI가 `needsFollowUp: true/false`로 직접 판단, 항상 생성 금지
- 꼬리질문 깊이: 최대 2단계 (`_followUpDepth()` 재귀 카운팅으로 제어)
- API 실패 시: 최소 리포트(시선 지표만) fallback 제공

### 2.6 커밋 메시지 Rules

```
feat: 새 기능 추가
fix:  버그 수정
docs: 문서만 수정
refactor: 기능 변경 없는 코드 개선
chore: 빌드·설정 변경
```

---

## 3. Agent Skills & Specialized Commands

### 3.1 자주 사용한 Agent Skills

| Skill | 트리거 | 동작 설명 |
|---|---|---|
| `/run` | 앱 실행·스크린샷 검증 요청 시 | `flutter run` + adb 스크린샷 파이프라인 자동 실행 |
| `/code-review` | 커밋 전 품질 검토 | diff 분석, 버그·중복·비효율 포인트 리포트 생성 |
| `Explore Subagent` | "어디에 저장되나요?" 유형 질문 | 코드베이스 전체 탐색 후 파일 경로·스니펫 반환 |
| `Monitor` | 백그라운드 빌드 완료 대기 | `tail -f` + 정규식 필터로 완료/실패 이벤트만 수신 |

### 3.2 Flutter 개발 Commands

```bash
# 에뮬레이터 실행 & 앱 빌드
flutter emulators --launch Pixel_8
flutter run -d emulator-5554

# 정적 분석 (수정 직후 즉시 실행)
flutter analyze lib/ui/home/home_screen.dart

# 빌드 검증
flutter build apk --debug     # 빠른 확인
flutter build apk --release   # 배포 전 최종 검증

# 의존성 동기화
flutter pub get
```

### 3.3 adb 기반 UI 자동 검증 Commands

```bash
# 에뮬레이터 해상도 확인 (좌표 계산 기준점)
adb shell wm size                                    # → Physical size: 1080x2400

# UI 요소 좌표 정확히 추출
adb shell uiautomator dump /sdcard/ui.xml
adb pull /sdcard/ui.xml %TEMP%/ui.xml
# → grep으로 버튼 bounds 추출: bounds="[53,2173][1028,2338]"
# → 중심 좌표: x=(53+1028)/2=540, y=(2173+2338)/2=2255

# 정확한 좌표로 탭 입력
adb shell input tap 540 2255

# 스크롤
adb shell input swipe 540 1600 540 800 500

# 스크린샷 촬영 → Read 도구로 시각 확인
adb shell screencap -p /sdcard/screen.png
adb pull /sdcard/screen.png %TEMP%/screen.png
```

### 3.4 Git Workflow Commands

```bash
# 브랜치 전략: week{n} → main
git checkout week8
git add lib/ui/home/home_screen.dart lib/state/interview/interview_provider.dart
git commit -m "fix: 세션 초기화 버그 수정"
git push -u origin week8

# main 머지
git checkout main
git merge week8 --no-ff -m "fix: week8 세션 초기화 버그 수정 (main)"
git push origin main
```

### 3.5 Gradle 빌드 진단 Commands

```bash
# 의존성 트리 확인
./gradlew :app:dependencies

# 상세 오류 스택트레이스
./gradlew assembleDebug --stacktrace

# Flutter SDK 기본 NDK 버전 확인
grep "ndkVersion" flutter/packages/flutter_tools/gradle/bin/main/FlutterExtension.kt
```

### 3.6 기능별 파일 맵

| 기능 | UI | State | Domain | Data |
|---|---|---|---|---|
| 세션 설정 | ui/session_setup/ | state/session_setup/ | domain/session_setup/ | data/local/session/ |
| 면접 진행 | ui/interview/ | state/interview/ | domain/interview/ | data/remote/ai/ |
| AI 질문 목록 | ui/questions/ | state/interview/ | domain/interview/ | data/remote/ai/ |
| 시선 분석 | — | state/gaze/ | domain/gaze/ | data/remote/gaze/ |
| 피드백 리포트 | ui/report/ | state/report/ | domain/report/ | data/local/report/ |
| 히스토리 | ui/history/ | state/history/ | domain/history/ | data/local/history/ |
| 인증 | ui/auth/ | state/auth/ | — | data/remote/auth/ |

---

## 4. 바이브 코딩 최적화 기법

### 4.1 CLAUDE.md를 에이전트 시스템 컨트롤 타워로 활용

`CLAUDE.md`를 단순한 문서가 아닌 **AI Agent의 영구 시스템 프롬프트**로 운용했습니다. 세션이 새로 시작될 때마다 에이전트가 이 파일을 자동으로 참조하여 일관된 행동을 보장합니다.

```
[운용 방식]
1. "절대 건드리지 마" 파일 목록을 CLAUDE.md에 명시
   → AI가 gaze_provider.dart를 자의적으로 수정하는 실수 원천 차단

2. "FilledButton 사용 금지" 같은 디자인 룰을 등록
   → 매 세션마다 재설명 없이 에이전트가 자동으로 준수

3. API 키 하드코딩 금지를 Hard Rule로 등록
   → 보안 취약점 발생 가능성을 아키텍처 레벨에서 차단
```

**핵심**: 규칙은 대화로 지시하지 않고 파일에 쓴다. 파일은 기억하지만 대화는 잊힌다.

### 4.2 "진단 먼저 → 수정 나중에" 원칙

무작정 수정 요청을 피하고, **Explore Subagent를 통한 데이터 기반 진단**을 선행했습니다.

```
❌ 비효율적 방식
"버그 고쳐줘"
→ Agent가 잘못된 파일 수정 → 반복 수정 → 컨텍스트 낭비

✅ 최적화된 방식
"아래 데이터들이 어디에 저장되는지 전부 찾아줘" (Explore Subagent 투입)
→ Provider 맵 확보 → 수정 범위 확정 → 단번에 정확한 수정
```

실제 적용 사례: 세션 초기화 버그 수정 시 6개 Provider를 한 번에 매핑한 뒤,
`_startNewSession()` 단일 함수로 모든 진입점(CTA 버튼 + 하단 탭)을 통제했습니다.

### 4.3 병렬 처리로 대기 시간 제거

AI Agent는 독립적인 도구 호출을 동시에 실행할 수 있습니다. 이를 의도적으로 설계했습니다.

```
[직렬 처리 — 비효율]
파일A 읽기 → 파일B 읽기 → 빌드 실행   (순차, 느림)

[병렬 처리 — 최적화]
파일A 읽기 ┐
파일B 읽기 ┼─→ 동시 실행 → 결과 통합 → 빌드 실행
파일C 읽기 ┘
```

실제 적용: `flutter analyze` + 여러 파일 읽기를 동시 요청하고, Monitor로 빌드 완료를
비동기 수신하면서 다음 파일 수정을 병행하여 총 대기 시간을 최소화했습니다.

### 4.4 스크린샷 기반 UI 검증 루프

코드만으로 UI를 추측하지 않고 **adb 스크린샷 → Read 도구 시각 확인**으로
실제 렌더링을 매번 검증하는 루프를 구축했습니다.

```
[UI 검증 자동화 파이프라인]

코드 수정
    ↓
flutter run (background) + Monitor 알림 대기
    ↓
adb shell screencap → adb pull → Read 도구로 이미지 로드
    ↓
레이아웃·색상·텍스트 시각 확인
    ↓
문제 발견 시 → 코드 수정 → 재검증 루프
```

**핵심 노하우**: 에뮬레이터 해상도(1080×2400)와 화면 표시 스케일(표시 너비 540px, ÷2)의
차이로 탭 좌표가 어긋나는 문제를 `adb shell uiautomator dump`로 정확한 `bounds` 값을
추출해 해결했습니다. "버튼이 어디에 있는지 추측하지 말고 측정하라."

### 4.5 Provider 상태 관리: "Reset-then-Start" 이중 방어 기법

Riverpod의 전역 상태 특성상 이전 세션 데이터가 잔류하는 버그가 구조적으로 발생합니다.
이를 막기 위해 **진입점 방어 + 화면 진입 방어** 이중 구조를 설계했습니다.

```dart
// [방어 1] 진입점 — 두 곳 모두에 reset 적용 (home_screen.dart)
void _startNewSession() {
  ref.read(interviewProvider.notifier).reset();   // 질문·답변·인덱스 초기화
  ref.read(gazeProvider.notifier).reset();         // 시선 프레임·메트릭 초기화
  Navigator.push(...SessionSetupScreen...);
}
```

```dart
// [방어 2] QuestionListScreen — 첫 build 전에 동기 reset으로 이전 질문 flash 방지
@override
void initState() {
  super.initState();
  ref.read(interviewProvider.notifier).reset();   // 첫 build 이전 동기 실행
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(interviewProvider.notifier).start(input);  // API 호출은 비동기
  });
}
```

```dart
// [방어 3] _Body — idle + empty 상태도 loading view로 처리, 빈 리스트 노출 방지
if (iv.phase == InterviewPhase.loadingQuestions ||
    (iv.phase == InterviewPhase.idle && iv.questions.isEmpty)) {
  return const _LoadingView();
}
```

이 구조로 ①진입점에서 메모리 정리, ②첫 프레임에 빈 상태 보장,
③API 응답 후 질문 로드라는 3단계 타이밍을 정확히 제어합니다.

### 4.6 Lint-as-Guardrail: IDE 훅으로 오류 즉시 포착

코드 수정 직후 IDE Diagnostics 훅이 자동 실행되어 빌드 전 단계에서 오류를 잡습니다.

```
Edit 도구로 파일 수정
    ↓
IDE Diagnostics 훅 자동 실행 (PostToolUse 이벤트)
    ↓
lint 경고·오류 즉시 감지
    ↓
같은 응답 턴 안에서 즉시 수정 → 사용자 노출 없이 해결
```

실제 사례: Duolingo 버튼에서 `border: Border(... width: 0)` + `borderRadius` 충돌이
7개 파일에 퍼진 것을 `flutter analyze` + `Grep` 으로 한 번에 탐지, 일괄 수정했습니다.

### 4.7 "No-Touch 파일" 선언으로 회귀 버그 방지

핵심 기능 파일을 CLAUDE.md에 **명시적 보호 목록**으로 등록했습니다.
AI Agent는 이 파일들에서 기존 메서드(`.reset()`, `.start()`)를 **호출**하되,
파일 자체는 수정하지 않습니다.

```
보호 대상 파일:
├── lib/state/gaze/gaze_provider.dart           ← ML Kit 시선 분석 핵심 로직
├── lib/data/remote/gaze/gaze_analyzer.dart     ← 응시율 계산 알고리즘
├── lib/data/remote/speech_service.dart         ← 음성 처리
└── lib/data/remote/camera_frame_converter.dart ← 카메라 프레임 변환
```

"관련 있어 보이는" 파일을 AI가 자의적으로 수정하다 발생하는 회귀 버그를
이 선언 하나로 원천 차단했습니다.

---

## 5. 프로젝트 컨텍스트 참조

### 5.1 기술 스택

| 분류 | 기술 | 버전 |
|---|---|---|
| Framework | Flutter | 3.38 |
| State | Riverpod | 2.6.1 |
| Vision | ML Kit Face Detection | 0.11.1 |
| AI | OpenAI API (gpt-4o-mini) | — |
| Local DB | Hive | 1.1.0 |
| Auth | Firebase Auth + Firestore | — |
| Network | Dio | 5.9.2 |
| Env | flutter_dotenv | 5.2.1 |

### 5.2 환경 확인 Commands

```bash
flutter pub get         # 의존성 설치
flutter analyze         # 전체 정적 분석
flutter test            # 유닛 테스트
flutter build apk --release  # 릴리즈 빌드
```

### 5.3 핵심 비즈니스 규칙

1. **시선 분산 카운트**: 연속 1초(1000ms) 이상 분산 상태 유지 시 1회
2. **응시율 공식**: `(응시 프레임 수 / 전체 측정 프레임 수) × 100`
3. **꼬리질문 제한**: 최대 2단계 깊이 (`_followUpDepth()`)
4. **AI 실패 fallback**: `_fallbackImprovements()` 호출로 최소 리포트 제공
5. **자기소개서 입력**: 최대 1000자

### 5.4 AI Agent 적용 이력

| Week | 주요 Agent 작업 내용 |
|---|---|
| Week 5~6 | 시스템 아키텍처 설계, Riverpod Provider 구조, Hive 스키마 정의 |
| Week 7 | ML Kit Gaze Provider, OpenAI 질문 생성 프롬프트 최적화 |
| Week 8 | Duolingo 스타일 UI 전면 개편 (홈·세션설정·면접·리포트 4개 화면 신규) |
| Week 8+ | 꼬리질문 AI 판단 로직, 세션 초기화 버그 수정, Gradle 설정 최적화 |

> 전체 커밋 이력: [github.com/thswjdguq/v-view](https://github.com/thswjdguq/v-view)
> 코딩 원칙 상세: [md/CLAUDE.md](md/CLAUDE.md)
