# v-view 시스템 아키텍처

---

## 전체 구조

```
┌──────────────────────────────────────────────────────────┐
│                     Flutter App                          │
│                                                          │
│  ┌─────────────────────────────────────────────────┐    │
│  │                   UI Layer                      │    │
│  │  SessionSetup │ Interview │ Gaze │ Report        │    │
│  │  History      │ Common                          │    │
│  └───────────────────┬─────────────────────────────┘    │
│                      │ watch / read(notifier)            │
│  ┌───────────────────▼─────────────────────────────┐    │
│  │              State Layer (Riverpod)              │    │
│  │  SessionInputNotifier │ InterviewNotifier        │    │
│  │  GazeNotifier         │ ReportNotifier           │    │
│  │  HistoryNotifier                                 │    │
│  └────────┬──────────────────────┬──────────────────┘    │
│           │                      │                       │
│  ┌────────▼──────────┐  ┌────────▼──────────────────┐   │
│  │  Domain Layer     │  │  Domain Layer              │   │
│  │  (Entities)       │  │  (Entities)                │   │
│  │  SessionInput     │  │  GazeMetrics               │   │
│  │  InterviewQuestion│  │  SessionReport             │   │
│  │  QuestionAnswer   │  │  SessionHistoryItem        │   │
│  └────────┬──────────┘  └────────┬──────────────────┘   │
│           │                      │                       │
│  ┌────────▼──────────┐  ┌────────▼──────────────────┐   │
│  │  data/local       │  │  data/remote               │   │
│  │  HiveService      │  │  ClaudeApiService          │   │
│  │  - sessions box   │  │  - generateQuestions()     │   │
│  │  - reports box    │  │  - generateFollowUp()      │   │
│  │  - history box    │  │  - generateFeedback()      │   │
│  │  - input box      │  │                            │   │
│  │                   │  │  GazeAnalyzer              │   │
│  │                   │  │  - analyze(InputImage)     │   │
│  │                   │  │  - computeMetrics()        │   │
│  └───────────────────┘  └────────────────────────────┘   │
│                                  │                       │
└──────────────────────────────────┼───────────────────────┘
                                   │
               ┌───────────────────┼─────────────────┐
               │                   │                 │
         ┌─────▼──────┐    ┌───────▼──────┐   ┌─────▼─────┐
         │ Hive DB    │    │ Claude API   │   │ ML Kit    │
         │ (기기 로컬) │    │ (Anthropic)  │   │ (온디바이스)│
         └────────────┘    └──────────────┘   └───────────┘
```

---

## 레이어 책임

### UI Layer (`lib/ui/`)
- 화면 렌더링 및 사용자 인터랙션
- Riverpod `ref.watch()` / `ref.read()` 만 사용
- 비즈니스 로직 없음

### State Layer (`lib/state/`)
- Riverpod `StateNotifierProvider` 기반
- UI ↔ Domain/Data 연결
- 비동기 상태, 에러 상태 관리
- 각 기능별 독립 Notifier

### Domain Layer (`lib/domain/`)
- 순수 Dart 클래스 (Flutter 의존성 없음)
- 엔티티, 값 객체, 열거형
- 비즈니스 규칙의 단일 진실 출처

### Data Layer (`lib/data/`)
- `local/`: Hive를 통한 로컬 영속성
- `remote/`: Claude API (Dio), ML Kit Face Detection

---

## 데이터 흐름 — 면접 세션 전체

```
사용자 입력
    │
    ▼
SessionSetupScreen
    │  notifier.start(input)
    ▼
InterviewNotifier
    │  claudeApi.generateQuestions()
    ▼
ClaudeApiService ──→ Anthropic API
    │  List<InterviewQuestion>
    ▼
InterviewScreen (질문 표시)
    │  동시에
    ▼
GazeNotifier ──→ GazeAnalyzer ──→ ML Kit
    │  (카메라 프레임마다 분석)
    │
    │  (답변 완료)
    ▼
InterviewNotifier.nextQuestion()
    │  claudeApi.generateFollowUp()
    ▼
ClaudeApiService ──→ Anthropic API
    │
    │  (세션 종료)
    ▼
ReportNotifier.generate()
    │  claudeApi.generateFeedback()
    ▼
ClaudeApiService ──→ Anthropic API
    │  List<ImprovementPoint>
    ▼
ReportLocalDatasource.save()  +  HistoryLocalDatasource.save()
    │
    ▼
ReportScreen (리포트 표시)
```

---

## 시선 분석 알고리즘

```
카메라 프레임 수신
    │
    ▼
FaceDetector.processImage()
    │
    ├── 얼굴 미검출 → GazeFrame(faceDetected: false)
    │
    └── 얼굴 검출
            │
            ▼
        headEulerAngleY.abs() < 15° AND headEulerAngleZ.abs() < 15°?
            │
            ├── YES → isGazing: true
            └── NO  → isGazing: false

세션 종료 시 GazeMetrics 계산
    │
    ├── 응시율 = (isGazing == true인 프레임 수 / 전체 프레임 수) × 100
    │
    ├── 분산 횟수: isGazing == false 구간이 1000ms 이상 연속 시 +1
    │
    ├── 분산 총 시간: 위 구간들의 합산(초)
    │
    └── 측정 품질:
            얼굴 검출률 < 30% → unavailable
            얼굴 검출률 < 60% → reference
            그 이상           → normal
```

---

## 로컬 저장 구조 (Hive)

| Box | Key | Value | 보관 항목 |
|---|---|---|---|
| sessions | `last_input` | Map | 마지막 세션 입력값 |
| reports | sessionId (UUID) | Map | 세션 리포트 전체 |
| history | sessionId (UUID) | Map | 히스토리 목록 메타데이터 |
| session_input | `last_input` | Map | 재사용 입력값 |

**저장하지 않는 것**: 원본 카메라 영상, 오디오

---

## 오류 처리 전략

| 상황 | 처리 |
|---|---|
| Claude API 질문 생성 실패 | 에러 메시지 표시 + 재시도 버튼 |
| Claude API 피드백 생성 실패 | 최소 리포트(시선 지표만) 자동 대체 |
| 카메라 권한 거부 | CameraPermissionScreen으로 안내 |
| 앱 백그라운드 전환 | 타이머 일시정지 (WidgetsBindingObserver) |
| 네트워크 타임아웃 | Dio 30초 타임아웃, ErrorDisplay 위젯 |

---

## 확장 포인트 (v2)

| v2 기능 | 예상 추가 위치 |
|---|---|
| STT 발화 분석 | data/remote/stt/, state/stt/ |
| 표정/감정 분석 | data/remote/gaze/ (GazeAnalyzer 확장) |
| 리포트 공유 | ui/report/widgets/ + 공유 라이브러리 |
