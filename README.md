# v-view — AI 기반 가상 면접 코칭 앱

> 카메라로 시선을 분석하고, OpenAI가 맞춤 질문과 피드백을 제공하는 모바일 면접 코칭 앱

[![Flutter](https://img.shields.io/badge/Flutter-3.38.9-blue)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.6-purple)](https://riverpod.dev)
[![OpenAI](https://img.shields.io/badge/OpenAI-gpt--4o--mini-green)](https://openai.com)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%2BFirestore-orange)](https://firebase.google.com)
[![Tests](https://img.shields.io/badge/tests-45%20passed-brightgreen)](#testing)

---

## 목차

- [프로젝트 개요](#프로젝트-개요)
- [주요 기능](#주요-기능)
- [기술 스택](#기술-스택)
- [Setup Guide (개발 환경 설정 가이드)](#setup-guide-개발-환경-설정-가이드)
- [Build & Deployment (빌드 및 배포)](#build--deployment-빌드-및-배포)
- [Testing (단위 및 통합 테스트)](#testing-단위-및-통합-테스트)
- [Architecture & Directory Structure (앱 구조)](#architecture--directory-structure-앱-구조)
- [Architecture Decision Records (ADR)](#architecture-decision-records-adr)
- [문서](#문서)

---

## 프로젝트 개요

면접 준비생이 혼자서도 실전과 같은 환경에서 연습할 수 있도록:
- **AI 맞춤 질문** — 직종·회사·자기소개서 기반으로 OpenAI gpt-4o-mini가 생성
- **실시간 시선 분석** — ML Kit으로 카메라 응시 여부를 측정 (온디바이스)
- **세션 피드백 리포트** — 시선 지표 + Q&A 요약 + 개선 포인트 TOP3
- **로컬 히스토리** — Hive로 기기에 안전하게 저장, 원본 영상 저장 없음

---

## 주요 기능

| # | 기능 | MVP 범위 |
|---|---|---|
| 1 | AI 맞춤 질문 생성 | 질문 수 3/5/7개 선택 + 꼬리 질문 자동 생성 (OpenAI gpt-4o-mini) |
| 2 | 실시간 시선 분석 | 응시율, 분산 횟수/시간 (ML Kit, 모바일) |
| 3 | 세션 피드백 리포트 | 시선 지표 + AI 피드백 TOP3 + 최근 5회 추이 그래프 |
| 4 | 면접 기록 관리 | 로컬 저장, 목록/상세 조회, 삭제 |
| 5 | 세션 설정 | 면접 유형·질문 수·타이머(1/2/3분) 선택 |
| 6 | 타이머 / 연속 질문 | 질문별 카운트다운, 시간 초과 시 자동 넘김 |
| 7 | 권한·오류 처리 | 카메라/마이크 상태 배너, API 실패 시 fallback 리포트 |
| 8 | 로그인 / 회원가입 | Firebase Auth 이메일 인증 + Firestore 사용자 저장 |

> v2 범위(미구현): STT 발화 분석, 표정/감정 분석

---

## 기술 스택

| 분류 | 기술 | 버전 | 선택 이유 (→ 상세 ADR) |
|---|---|---|---|
| Framework | Flutter | 3.38.9 | Android/iOS 단일 코드베이스 ([ADR-001](#adr-001-크로스플랫폼-프레임워크로-flutter-선택)) |
| Language | Dart | 3.x | AOT 컴파일, 실시간 시선 처리 적합 |
| State | Riverpod | 2.6.1 | 컴파일 타임 안전성, 테스트 용이 ([ADR-002](#adr-002-상태-관리-라이브러리로-riverpod-선택)) |
| Vision | ML Kit Face Detection | 0.11 | 온디바이스 처리, 개인정보 보호 |
| AI | OpenAI API (gpt-4o-mini) | — | 한국어 면접 질문·피드백 생성 ([ADR-004](#adr-004-ai-백엔드로-openai-gpt-4o-mini-선택)) |
| Local DB | Hive | 1.1.0 | Flutter 친화적 키-값 저장 ([ADR-003](#adr-003-로컬-저장소로-hive-선택)) |
| Auth | Firebase Auth + Firestore | 5.x | 이메일 인증, 사용자 데이터 |
| Network | Dio | 5.8 | 인터셉터, 타임아웃 설정 용이 |
| Env | flutter_dotenv | 5.2.1 | API 키 코드 분리 |
| Chart | fl_chart | 0.70.2 | 시선 추이 시각화 |

---

## Setup Guide (개발 환경 설정 가이드)

> 이 섹션만 따라하면 **약 5분 안에** 앱을 실행할 수 있습니다.
> 더 자세한 트러블슈팅 FAQ는 [docs/SETUP.md](docs/SETUP.md) 참조.

### 1. 필요한 도구 및 버전 (개발 환경)

| 도구 | 버전 | 확인 명령 |
|---|---|---|
| OS | Windows 11 / macOS 13+ / Linux | — |
| Flutter SDK | 3.38.9 (stable) | `flutter --version` |
| Dart | 3.10+ | `dart --version` |
| JDK | 17 | `java -version` |
| Android SDK | compileSdk 36 / minSdk 24 (Android 7.0+) | Android Studio → SDK Manager |
| Android NDK | 28.2.13676358 | (Gradle 자동 설치) |
| Git | 2.x | `git --version` |
| Xcode (macOS만) | 15+ | `xcode-select --version` |

전체 도구 설치 상태를 한 번에 확인:
```bash
flutter doctor
```
모든 항목이 `[✓]`여야 합니다.

### 2. 저장소 클론 및 의존성 설치

```bash
git clone https://github.com/thswjdgy/v-view.git
cd v-view/v_view
flutter pub get          # → "Got dependencies!" 출력 시 성공
```

### 3. 환경 변수(.env) 설정 — API 키

> **보안 원칙**: API 키는 코드에 하드코딩하지 않고 `.env` 파일로만 주입합니다.
> `.env`는 `.gitignore`에 포함되어 **절대 커밋되지 않습니다.**

```bash
# macOS / Linux
cp .env.example .env

# Windows (PowerShell)
Copy-Item .env.example .env
```

`.env` 파일을 열어 OpenAI API 키를 입력합니다:
```dotenv
OPENAI_API_KEY=sk-proj-...
```

> API 키 발급: [platform.openai.com](https://platform.openai.com/api-keys) → **Create new secret key**
> `pubspec.yaml`의 `flutter.assets`에 `.env`가 등록되어 있어야 런타임에 로드됩니다.

### 4. 앱 실행

```bash
flutter devices          # 연결된 디바이스 확인
flutter run              # 디버그 모드 (핫 리로드 지원)
flutter run -d <id>      # 디바이스 여러 개일 때 지정
```

| 플랫폼 | 실행 방법 |
|---|---|
| Android 에뮬레이터 | AVD 실행 후 `flutter run -d emulator-5554` |
| Android 실기기 | USB 디버깅 활성화 후 `flutter run` |
| iOS 시뮬레이터 (macOS) | `open -a Simulator` 후 `flutter run` |

> **카메라 기능**: 에뮬레이터는 카메라가 제한되므로, 시선 분석 검증은 실기기를 권장합니다.

---

## Build & Deployment (빌드 및 배포)

> 빌드 산출물부터 배포 타겟까지의 전체 파이프라인입니다.
> 서명·배포 상세는 [docs/DEPLOY.md](docs/DEPLOY.md) 참조.

### 빌드 & 배포 파이프라인 (개념도)

```
[1] 코드 푸시 (git push)
        ↓
[2] CI: 정적 분석 + 테스트 게이트
        flutter analyze  →  flutter test (45개)
        ↓ (통과 시에만 진행)
[3] 빌드 (Build Target 선택)
        ├─ Android APK   → flutter build apk --release
        ├─ Android AAB   → flutter build appbundle --release  (Google Play 권장)
        └─ iOS IPA       → flutter build ios --release        (macOS 필요)
        ↓
[4] 서명 (Signing)
        key.properties + v-view-release.jks 자동 적용
        ↓
[5] 배포 (Deployment Target)
        └─ Firebase App Distribution  → 테스터 그룹 배포
           (또는 Google Play / App Store 스토어 출시)
```

### 빌드 명령어

```bash
# 디버그 빌드 (빠른 확인)
flutter build apk --debug
# → build/app/outputs/flutter-apk/app-debug.apk

# 릴리즈 빌드
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk (약 80MB)

# App Bundle (Google Play 권장 포맷)
flutter build appbundle --release
# → build/app/outputs/bundle/release/app-release.aab
```

### CI/CD 개념 (GitHub Actions 예시)

`.env`는 커밋하지 않으므로, 배포 빌드 시 **CI Secrets에서 주입**합니다.

```yaml
# .github/workflows/build.yml (개념 예시)
name: Build & Deploy
on:
  push:
    branches: [main]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.38.9' }
      - run: cd v_view && flutter pub get
      - run: cd v_view && flutter analyze          # 정적 분석 게이트
      - run: cd v_view && flutter test             # 테스트 게이트 (45개)
      - run: echo "OPENAI_API_KEY=${{ secrets.OPENAI_API_KEY }}" > v_view/.env
      - run: cd v_view && flutter build apk --release
      # → 산출 APK를 Firebase App Distribution으로 배포
```

### 배포 전 체크리스트

- [x] `flutter analyze` — 이슈 없음
- [x] `flutter test` — 45개 전체 통과
- [x] `.env` 실제 키 설정 (미커밋 확인)
- [x] `pubspec.yaml` 버전 (`1.0.0+1`)
- [x] AndroidManifest 권한 (CAMERA, INTERNET, RECORD_AUDIO)
- [x] 릴리즈 서명 (`v-view-release.jks` + `key.properties`)
- [ ] Firebase App Distribution 배포

---

## Testing (단위 및 통합 테스트)

> 전체 테스트 전략 상세는 [docs/TESTING.md](docs/TESTING.md) 참조.

### 테스트 레벨

| 레벨 | 도구 | 대상 | 목적 |
|---|---|---|---|
| **Unit Test (단위)** | `flutter_test` | `domain/`, `state/`, `data/` | 핵심 비즈니스 로직 검증 |
| **Widget Test** | `flutter_test` | `ui/` 위젯 | UI 렌더링 검증 |
| **Integration Test (통합)** | `integration_test` | 전체 흐름 | E2E 시나리오 검증 |

### 실행 방법

```bash
flutter test                  # 전체 단위/위젯 테스트
flutter test test/data/remote/gaze/gaze_analyzer_test.dart   # 특정 파일
flutter test --coverage       # 커버리지 측정 (coverage/lcov.info)
flutter test integration_test # 통합 테스트 (실기기/에뮬레이터)
```

### 실제 실행 결과 (예시)

```
$ flutter test
00:00 +1: GazeAnalyzer.computeMetrics 응시율 계산 전체 프레임 응시 시 응시율 100%
00:00 +5: GazeAnalyzer 분산 상태가 1초 미만이면 카운트되지 않는다
00:01 +28: InterviewNotifier nextQuestion(답변있음) — 꼬리 질문 삽입 후 isFollowUp=true
00:01 +37: SessionInputNotifier.isValid 필수 입력 3개 모두 있을 때 isValid = true
00:01 +45: All tests passed!     ← ✅ 45개 전체 통과
```

### 핵심 테스트 케이스 (Unit Test)

**① 시선 분산 횟수 — 가장 중요한 비즈니스 규칙**
```dart
// test/data/remote/gaze/gaze_analyzer_test.dart
test('분산 상태가 1초 미만이면 카운트되지 않는다', () {
  final frames = [
    GazeFrame(isGazing: false, faceDetected: true, timestamp: t0),
    GazeFrame(isGazing: true,  faceDetected: true, timestamp: t0 + 900ms), // 0.9초
  ];
  expect(analyzer.computeMetrics(frames).distractionCount, 0); // 1초 미만 → 카운트 안됨
});

test('응시율 공식: 응시 프레임 / 전체 프레임 × 100', () {
  // 10프레임 중 8프레임 응시 → 80%
  expect(metrics.gazeRate, closeTo(80.0, 0.1));
});
```

**② 세션 입력 유효성 (State 테스트 — `ProviderContainer` 활용)**
```dart
// test/state/session_setup/session_input_notifier_test.dart
test('필수 입력 3개 모두 있을 때 isValid = true', () {
  notifier.setPosition('백엔드 개발자');
  notifier.setCompany('카카오');
  notifier.setSelfIntroduction('저는 3년차...');
  expect(notifier.isValid, true);
});
```

**③ AI 실패 시 최소 리포트 대체 (Fallback)**
```dart
// test/state/report/report_notifier_test.dart
test('gazeRate < 70이면 화면 응시 유지 개선 포인트가 포함된다', () {
  // OpenAI API 실패 시에도 시선 지표 기반 fallback 리포트 생성 보장
});
```

### 테스트 작성 원칙

1. **비즈니스 규칙 우선** — 시선 분산 1초 기준, 응시율 공식은 반드시 테스트
2. **외부 의존성 모킹** — OpenAI API·ML Kit은 Fake/Mock 객체 사용
3. **엣지 케이스 포함** — 빈 프레임, 얼굴 미검출, API 실패
4. **Riverpod `ProviderContainer`** — State 테스트는 실제 Provider로 검증

---

## Architecture & Directory Structure (앱 구조)

> 시스템 설계 상세는 [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) 참조.

### 레이어 아키텍처 (단방향 의존성)

4계층 클린 아키텍처로, 의존성은 **항상 한 방향으로만** 흐릅니다.

```
┌─────────────────────────────────────────────┐
│   UI Layer (lib/ui/)                         │  화면·위젯
│   session_setup │ interview │ questions      │
│   report │ history │ auth │ home             │
└───────────────────┬─────────────────────────┘
                    │ watch / read (Riverpod)
┌───────────────────▼─────────────────────────┐
│   State Layer (lib/state/)                   │  Riverpod Providers
│   sessionInput │ interview │ gaze            │
│   report │ history │ auth                    │
└───────────────────┬─────────────────────────┘
                    │ call
┌───────────────────▼─────────────────────────┐
│   Domain Layer (lib/domain/)                 │  순수 Dart 엔티티
│   SessionInput │ InterviewQuestion │ Gaze…   │  (어떤 레이어도 import 안 함)
└──────────┬─────────────────────┬─────────────┘
           │                     │
┌──────────▼──────────┐  ┌───────▼──────────────┐
│  data/local/        │  │  data/remote/         │
│  Hive (4 Box)       │  │  OpenAI API           │
│  sessions/reports/  │  │  ML Kit Gaze          │
│  history/input      │  │  Firebase Auth        │
└─────────────────────┘  └───────────────────────┘
```

**의존성 규칙 (Dependency Rule)**
- `ui/` → `state/`만 참조 (data 직접 접근 금지)
- `state/` → `domain/` + `data/` 참조
- `domain/` → 아무것도 import하지 않음 (테스트·재사용성 극대화)
- `data/` → `domain/`만 참조

### 디렉토리 구조

```
v-view/
├── v_view/                       # Flutter 앱 (주 작업 공간)
│   ├── lib/
│   │   ├── main.dart             # 진입점 (ProviderScope, Hive 초기화)
│   │   ├── app.dart              # MaterialApp, 테마, 라우팅
│   │   ├── ui/                   # ── 화면·위젯 (레이어 1)
│   │   │   ├── session_setup/    #   세션 설정
│   │   │   ├── questions/        #   AI 질문 리스트
│   │   │   ├── interview/        #   면접 진행 + 카메라
│   │   │   ├── report/           #   피드백 리포트
│   │   │   ├── history/          #   기록 목록/상세
│   │   │   ├── auth/             #   로그인/회원가입
│   │   │   └── home/             #   홈
│   │   ├── state/                # ── Riverpod Providers (레이어 2)
│   │   ├── domain/               # ── 엔티티 (레이어 3, 순수 Dart)
│   │   ├── data/
│   │   │   ├── local/            #   Hive datasources (레이어 4a)
│   │   │   └── remote/           #   OpenAI·ML Kit·Firebase (레이어 4b)
│   │   └── theme/                # AppTheme, AppColors
│   ├── test/                     # 단위·위젯 테스트 (45개)
│   ├── android/ · ios/           # 플랫폼 네이티브 설정
│   └── pubspec.yaml
├── docs/                         # 설계·운영 문서
│   ├── ARCHITECTURE.md · SETUP.md · DEPLOY.md · TESTING.md
│   └── ADR/                      # 아키텍처 결정 기록 5건
├── AGENTS.md                     # AI Agent 운용 지침
├── CLAUDE.md                     # AI 코딩 원칙
└── README.md
```

**기능별 파일 맵 (수직 슬라이스)**

| 기능 | UI | State | Domain | Data |
|---|---|---|---|---|
| 세션 설정 | ui/session_setup/ | state/session_setup/ | domain/session_setup/ | data/local/session/ |
| 면접 진행 | ui/interview/ | state/interview/ | domain/interview/ | data/remote/ai/ |
| 시선 분석 | ui/interview/ | state/gaze/ | domain/gaze/ | data/remote/gaze/ |
| 리포트 | ui/report/ | state/report/ | domain/report/ | data/local/report/ |
| 히스토리 | ui/history/ | state/history/ | domain/history/ | data/local/history/ |

---

## Architecture Decision Records (ADR)

> 핵심 기술 결정을 표준 포맷(**Context · Decision · Status · Consequence**)으로 기록합니다.
> 원본 전문: [docs/ADR/](docs/ADR/)

### ADR-001: 크로스플랫폼 프레임워크로 Flutter 선택

| 항목 | 내용 |
|---|---|
| **Status (상태)** | ✅ Accepted (2026-05-10) |
| **Context (배경)** | Android/iOS 모두 타겟. 개발 리소스 1인이라 단일 코드베이스가 필수. 후보: Flutter / React Native / 네이티브 분리 개발. |
| **Decision (결정)** | **Flutter (Dart)** 채택. |
| **Consequence (결과)** | (+) `google_mlkit_face_detection`·`camera` 플러그인이 안정적, Dart AOT로 실시간 시선 처리 성능 확보, 자체 렌더링으로 양 플랫폼 UI 일관성. (−) iOS 빌드는 macOS 환경 필요, 네이티브 권한 설정(AndroidManifest/Info.plist) 별도 관리. |

**기각 대안**: React Native(ML Kit 플러그인 불안정, JS Bridge 오버헤드) / 네이티브 분리(1인 유지비용 과다)

### ADR-002: 상태 관리 라이브러리로 Riverpod 선택

| 항목 | 내용 |
|---|---|
| **Status (상태)** | ✅ Accepted (2026-05-10) |
| **Context (배경)** | 면접 세션 중 여러 화면이 동일 상태(질문 목록·시선 지표·타이머)를 공유. 후보: Riverpod / Provider / BLoC / GetX. |
| **Decision (결정)** | **Riverpod 2.x (`StateNotifierProvider`)** 채택. |
| **Consequence (결과)** | (+) 컴파일 타임 안전성으로 런타임 에러 차단, `ProviderContainer`로 독립 단위 테스트 가능, mock 오버라이드 용이, 코드 생성 불필요로 `hive_generator`와 버전 충돌 회피. 5개 Notifier(session·interview·gaze·report·history) 구현. (−) Provider 대비 러닝커브 존재. |

**기각 대안**: Provider(컴파일 안전성 부족) / BLoC(보일러플레이트 과다) / GetX(전역 상태로 테스트 곤란)

### ADR-003: 로컬 저장소로 Hive 선택

| 항목 | 내용 |
|---|---|
| **Status (상태)** | ✅ Accepted (2026-05-10) |
| **Context (배경)** | 세션 기록·리포트·사용자 입력을 기기 로컬에 영구 저장. **원본 카메라 영상은 저장 금지**라는 개인정보 보호 원칙 존재. 후보: Hive / SQLite / shared_preferences / Isar. |
| **Decision (결정)** | **Hive (`hive_flutter` 1.1.0)** 채택. |
| **Consequence (결과)** | (+) Flutter 친화적 설정, 구조화된 Map 직접 저장, 경량, 수동 직렬화로 `hive_generator` 의존성 제거(source_gen 충돌 회피). 4개 Box(`sessions`·`reports`·`history`·`session_input`) 운영, 원본 영상은 어떤 Box에도 미저장. (−) 복잡한 관계형 쿼리 부적합(현 요구엔 불필요). |

**기각 대안**: sqflite(스키마·마이그레이션 부담) / shared_preferences(중첩 구조 저장 불편) / Isar(source_gen 충돌 우려)

### ADR-004: AI 백엔드로 OpenAI gpt-4o-mini 선택

| 항목 | 내용 |
|---|---|
| **Status (상태)** | ✅ Accepted (2026-05-10) |
| **Context (배경)** | 면접 질문·꼬리 질문·피드백 생성에 LLM 필요. 한국어 면접 특화 품질과 비용·접근성이 기준. 후보: OpenAI / Claude / Gemini / 온디바이스 LLM. |
| **Decision (결정)** | **OpenAI API (`gpt-4o-mini`)** 채택. |
| **Consequence (결과)** | (+) 한국어 면접 질문·피드백 품질 우수, 자기소개서 전문+히스토리를 한 번에 전달, JSON 형식 준수율 높음, 저비용·발급 용이. API 키는 `.env`(`OPENAI_API_KEY`)로만 로드, 30초 타임아웃, 실패 시 시선 지표 기반 최소 리포트로 자동 대체, 원본 영상·오디오는 요청에 미포함. (−) 네트워크 의존(오프라인 불가) → fallback으로 완화. |

**기각 대안**: Gemini(한국어 면접 품질 검증 미흡) / 온디바이스 LLM(모바일 성능 한계, 한국어 품질 불안정)

### ADR-005: 시선 분석 라이브러리로 ML Kit 선택

| 항목 | 내용 |
|---|---|
| **Status (상태)** | ✅ Accepted (2026-05-10) |
| **Context (배경)** | 카메라 프레임에서 얼굴·눈 위치를 실시간 감지해 응시 여부 측정. 온디바이스 처리(개인정보)와 7주 내 Flutter 연동 가능성이 기준. 후보: ML Kit / MediaPipe / 자체 TFLite 모델. |
| **Decision (결정)** | **ML Kit Face Detection (`google_mlkit_face_detection`)** 채택. |
| **Consequence (결과)** | (+) 모델이 앱 내부에 내장 → 원본 영상 서버 미전송으로 개인정보 보호, 오프라인 동작, Flutter 공식 패키지로 양 플랫폼 안정. YUV_420_888 → NV21 변환(row/pixel stride 반영) 후 `InputImage` 생성. 비전 로직이 Data 레이어에 격리돼 교체 용이. (−) MediaPipe 대비 정확도 편차 → 미검출 시 '측정 불가/참고용' 표시로 완화. |

**기각 대안**: MediaPipe(Android/iOS 네이티브 설정 각각 필요 → 7주 일정 리스크) / 자체 TFLite 모델(학습·튜닝 비용 과다)

> **결정 트레이드오프 요약**: 모든 선택의 공통 기준은 **① 1인 개발 생산성 ② 테스트 용이성 ③ 개인정보 보호(원본 영상 미저장)**. 다섯 결정 모두 "코드 생성 의존성 제거"로 빌드 충돌을 피하고 단위 테스트 가능성을 극대화하는 방향으로 수렴합니다.

---

## 문서

### 기획 및 요구사항
| 문서 | 설명 |
|---|---|
| [기능명세서 (요구사항)](md/AI%20기반%20가상%20면접%20코칭%20앱%20v-view_기능명세서_2026-05-10.md) | 기획서 · MVP 기능 요구사항 정의 |
| [WBS / 일정](md/WBS.md) | 8주 작업 분류 체계(WBS) 및 마일스톤 일정 |
| [.planning/](\.planning/) | 비전·요구사항·리스크 기획 문서 모음 |

### 설계 및 아키텍처
| 문서 | 설명 |
|---|---|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | 시스템 아키텍처 설계 |
| [docs/ADR/](docs/ADR/) | 아키텍처 결정 기록(ADR) 5건 |

### 개발 환경 · 빌드 · 배포 · 테스트
| 문서 | 설명 |
|---|---|
| [docs/SETUP.md](docs/SETUP.md) | 개발 환경 설정 + 트러블슈팅 FAQ |
| [docs/DEPLOY.md](docs/DEPLOY.md) | 빌드·서명·배포 가이드 |
| [docs/TESTING.md](docs/TESTING.md) | 단위 테스트·통합 테스트 전략 |

### AI Agent 운용
| 문서 | 설명 |
|---|---|
| [AGENTS.md](AGENTS.md) | AI Agent 워크플로우·Rules·Skills·Commands 통합 지침 |
| [AUTHORING.손정효.md](AUTHORING.손정효.md) | 나만의 AI Agent 부트스트래핑 방법론 |
| [WIKI.md](WIKI.md) | LLM & Vibe Coding Wiki — 암묵지·트러블슈팅·성능 최적화 |
| [CLAUDE.md](CLAUDE.md) | AI 코딩 원칙 (Agent 시스템 프롬프트) |

---

> **저장소**: [github.com/thswjdgy/v-view](https://github.com/thswjdgy/v-view)
