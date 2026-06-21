# v-view 바이브 코딩 TODO

> AI Agent(Claude Code)와 함께 진행하는 작업 목록  
> 기준: 기능명세서 MVP 6개 기능  
> 업데이트: 2026-05-13

---

## 전체 진행 현황

| 세션 | 주제 | 상태 |
|---|---|---|
| Week 1 | 오리엔테이션 | ✅ 완료 |
| Week 2 | 기획 & 일정 수립 | ✅ 완료 |
| Week 3 | 설계 & 환경 구축 | ✅ 완료 |
| Week 4 | 구현 1 + **중간 발표** | ✅ 완료 |
| Week 5 | 구현 2 (테스트/디버깅) | ✅ 완료 |
| Week 6 | 마감 & 배포 | ✅ 완료 |
| Week 7 | **최종 발표·평가** | ⬜ 예정 |

---

## 완료된 작업 ✅

### 기획 / 문서
- [x] 기능명세서 작성 (MVP 6개 기능 + v2 2개)
- [x] WBS 작성 (작업 분류 및 일정)
- [x] CLAUDE.md 작성 (AI Agent 코딩 원칙)

### 환경 구축
- [x] GitHub 저장소 생성 (`thswjdgy/v-view`)
- [x] Flutter 프로젝트 스캐폴드 생성 (`v_view/`)
- [x] pubspec.yaml 의존성 구성 (Riverpod, Hive, Dio, ML Kit, fl_chart 등)
- [x] `.env` / `.env.example` API 키 관리 구조
- [x] `flutter analyze` 이슈 없음 확인

### 아키텍처 / 레이어
- [x] 레이어 구조 확정 (ui / state / domain / data)
- [x] 기능별 폴더 구조 생성 (6개 기능 기준)
- [x] 도메인 엔티티 정의
  - [x] `SessionInput`, `InterviewType`
  - [x] `InterviewQuestion`, `QuestionAnswer`
  - [x] `GazeMetrics`, `GazeQuality`
  - [x] `SessionReport`, `ImprovementPoint`
  - [x] `SessionHistoryItem`

### 데이터 레이어
- [x] `HiveService` 초기화 (4개 Box)
- [x] `SessionInputLocalDatasource` (재사용 입력값)
- [x] `ReportLocalDatasource` (리포트 저장/로드)
- [x] `HistoryLocalDatasource` (목록 저장/삭제)
- [x] `ClaudeApiService` (질문생성/꼬리질문/피드백)
- [x] `GazeAnalyzer` (ML Kit, 시선 판별 로직)

### State 레이어
- [x] `SessionInputNotifier` (입력값 상태 + 로컬 저장)
- [x] `InterviewNotifier` (질문 진행, 타이머, 꼬리질문)
- [x] `GazeNotifier` (프레임 수집, 지표 계산)
- [x] `ReportNotifier` (리포트 생성, AI 실패 fallback)
- [x] `HistoryNotifier` (히스토리 목록, 삭제)

### UI 스캐폴드 (화면 뼈대)
- [x] `SessionSetupScreen` (면접 유형 선택, 입력 폼)
- [x] `InterviewScreen` (질문 카드, 타이머, 답변 입력)
- [x] `ReportScreen` (리포트 화면)
- [x] `HistoryListScreen` / `HistoryDetailScreen`
- [x] `CameraPermissionScreen` (권한 요청)
- [x] `ErrorDisplay` (에러 공통 위젯)

### 평가 문서
- [x] `README.md` (프로젝트 전체 개요)
- [x] `AGENTS.md` (AI Agent 작업 지침)
- [x] `docs/ARCHITECTURE.md` (시스템 구조)
- [x] `docs/ADR/` (Flutter, Riverpod, Hive, OpenAI gpt-4o-mini 선택 근거 4개)
- [x] `docs/SETUP.md` (개발 환경 설정)
- [x] `docs/DEPLOY.md` (빌드·배포 가이드)
- [x] `docs/TESTING.md` (테스트 전략)
- [x] `AUTHORING.손정효.md` (AI Agent 부트스트래핑 방법론)
- [x] `.planning/decisions/ADR-0001~0003` (발표용 ADR 3종 — 60초 말하기 포함)
- [x] `LLM-WIKI.md` (Claude Code 바이브 코딩 암묵지 — 보너스 +1)

---

## 남은 작업 🔄

### 기능 1 — AI 맞춤 질문 생성 (Week 4~5)

- [x] **1.1** OpenAI API 실제 연동 테스트 (실 API 키로 질문 생성 확인) → 에뮬레이터 실기기 테스트 완료. 자기소개서에 "Spring Boot/JPA" 입력 시 "Spring Boot를 사용한 프로젝트 경험에 대해 구체적으로 설명해 주시겠습니까?"라는 맥락 기반 질문 생성 확인
- [x] **1.2** 질문 생성 로딩 UI 개선 (Shimmer 또는 스켈레톤)
- [x] **1.3** 질문 생성 실패 시 재시도 흐름 E2E 확인
- [x] **1.4** 꼬리 질문 생성 흐름 실기기 테스트 → "꼬리 질문" 배지와 함께 답변 내용(데이터베이스 미언급)을 분석한 후속 질문 "어떤 데이터베이스를 사용했고, 그 선택의 이유는 무엇인가요?" 생성 확인

### 기능 2 — 실시간 시선 분석 (Week 4~5)

- [x] **2.1** 카메라 권한 요청 → 승인/거부 분기 실기기 테스트 → 에뮬레이터에서 "Allow v_view to take pictures and record video?" 권한 다이얼로그 표시 확인, "While using the app" 승인 후 카메라 프리뷰 및 얼굴 감지 상태 배너("얼굴 미감지") 정상 동작 확인
- [x] **2.2** `CameraController` 연결 — `InterviewScreen`에 카메라 프리뷰 추가
- [x] **2.3** 카메라 프레임 → `GazeAnalyzer.analyze()` 파이프라인 연결
- [x] **2.4** `GazeNotifier.processFrame()` 실시간 호출 (면접 중 매 프레임)
- [x] **2.5** 시선 분산 1초 기준 단위 테스트 작성 및 통과

### 기능 3 — 피드백 리포트 (Week 5)

- [x] **3.1** `GazeMetricsCard` 파이차트 실 데이터 연결 확인
- [x] **3.2** 히스토리 최근 5회 추이 그래프 (`LineChart`, fl_chart)
- [x] **3.3** 개선 포인트 TOP3 — 근거 지표 연결 로직 검증
- [x] **3.4** 측정 불가/참고용 배너 표시 조건 확인
- [x] **3.5** AI 피드백 실패 시 fallback 리포트 표시 확인

### 기능 4 — 면접 기록 관리 (Week 5)

- [x] **4.1** 세션 종료 후 히스토리 목록에 자동 추가 확인
- [x] **4.2** 히스토리 상세 → 리포트 재열람 흐름 테스트
- [x] **4.3** 단일 세션 삭제 — 삭제 불가 복구 안내 다이얼로그 확인
- [x] **4.4** 전체 삭제 기능 추가 (HistoryListScreen 상단 버튼)

### 기능 5 — 세션 설정 (Week 4)

- [x] **5.1** 이전 입력값 자동 불러오기 확인 (재사용)
- [x] **5.2** 입력값 미리보기/확인 화면 추가 (`ConfirmScreen`)
- [x] **5.3** 글자 수 제한 및 안내 문구 추가 (자기소개서 최대 500자 등)

### 기능 6 — 권한·오류 처리 (Week 5~6)

- [x] **6.1** 카메라 권한 영구 거부 시 설정 이동 흐름 테스트
- [x] **6.2** 오프라인 상태 감지 및 안내 (Dio Interceptor 또는 connectivity_plus)
- [x] **6.3** Dio 타임아웃 30초 경과 시 에러 메시지 표시 확인
- [x] **6.4** 앱 백그라운드 전환 → 타이머 정지 → 포어그라운드 복귀 → 재개 흐름 확인
- [x] **6.5** 세션 전 개인정보 처리 안내 다이얼로그 추가

---

## 테스트 TODO (Week 5~6)

- [x] `gaze_analyzer_test.dart` — 시선 분산 1초 미만 카운트 안됨
- [x] `gaze_analyzer_test.dart` — 응시율 계산 공식 검증
- [x] `session_input_notifier_test.dart` — isValid 조건 테스트
- [x] `report_notifier_test.dart` — AI 실패 시 fallback 리포트 생성
- [x] `flutter test` 전체 통과 확인 (45/45)
- [x] `interview_notifier_test.dart` — 상태 전환·타이머·API Fake 연동 20개

---

## 배포 TODO (Week 6)

- [x] `key.properties.example` + 릴리즈 서명 설정 (`app/build.gradle.kts`)
- [x] `key.properties` 실제 키스토어 생성 및 연결 (`android/app/v-view-release.jks`)
- [x] Android APK 릴리즈 빌드 확인 (`flutter build apk --release`) → 80MB APK 생성
- [ ] Firebase App Distribution 테스트 배포
- [x] `pubspec.yaml` 버전 번호 최종 확인 (`1.0.0+1`)

---

## 발표 준비 TODO (Week 7)

- [x] 발표 슬라이드 (Marp) 작성
  - 프로젝트 소개 (What / Why)
  - 기술 스택 선택 이유 (ADR 기반)
  - 아키텍처 다이어그램 설명
  - 시연 영상 또는 실기기 데모
  - AI Agent 활용 방식 (AUTHORING.손정효.md)
- [x] Q&A 예상 질문 답변 준비
  - "시선 분산 1초 기준을 왜 정했나?"
  - "Riverpod를 선택한 이유는?"
  - "AI 실패 시 어떻게 처리하나?"
  - "레이어 구조에서 ui가 data를 직접 참조하지 않는 이유?"
  - "Hive와 SQLite 차이는?"
- [x] AUTHORING.손정효.md 기반 라이브 부트스트래핑 시연 준비 (보너스 +2) — §10 시연 스크립트 완성

---

## 우선순위 요약

```
지금 당장 (Week 4):
  1. 카메라 + GazeAnalyzer 실기기 연결 (기능 2)
  2. OpenAI gpt-4o-mini 실 연동 테스트 (기능 1)
  3. 세션 입력 → 면접 → 리포트 E2E 흐름 확인

Week 5:
  4. 시선 분석 단위 테스트
  5. 히스토리/삭제 흐름
  6. 에러 처리 완성

Week 6:
  7. 배포 빌드
  8. 발표 슬라이드
```
