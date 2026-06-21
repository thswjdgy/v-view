# Gamma 발표자료 콘텐츠 — v-view

> Gamma에 그대로 붙여넣을 슬라이드별 텍스트입니다. (디자인 규칙은 직접 추가)
> 브랜드 컬러: 메인 `#00C9A7`(민트-틸) / 보조 `#FF6B6B`(코랄) / 텍스트 `#131B30` / 배경 `#FAF8FF`
> 모든 수치는 레포 코드·문서 기준 검증 완료. (근거 없는 수치 미포함)

---

## 슬라이드 1 — 타이틀

**v-view**
AI 면접 코치 — 혼자서도, 실전처럼

- 카메라로 시선을 분석하고, AI가 맞춤 질문과 피드백을 주는 모바일 면접 코칭 앱
- 발표자: 손정효
- Flutter · Riverpod · ML Kit · OpenAI gpt-4o-mini

---

## 슬라이드 2 — 비전 제시

**혼자 연습해도, 실제 면접관 앞에 있는 것처럼**

- 면접은 결국 '사람 앞에서' 잘해야 하는데, 연습은 늘 혼자 거울 보고 끝난다
- v-view는 혼자 연습에도 **실전 같은 긴장감 + 객관적 피드백**을 제공
- 3박자 경험: **AI가 질문을 던지고 → 카메라가 시선을 보고 → 끝나면 리포트를 준다**

---

## 슬라이드 3 — 문제 정의

**혼자 면접 준비의 3가지 한계**

- ❌ **실전 같은 긴장감**을 혼자서는 못 만든다
- ❌ 내 **시선이 흔들리는지, 답이 두루뭉술한지** 객관적으로 모른다
- ❌ **나에게 딱 맞는 맞춤 질문**을 받기 어렵다
- → "내가 지금 잘하고 있나?"를 알 수 없는 막막함을 해결

---

## 슬라이드 4 — 프로젝트 계획 (WBS & 기술 스택)

**8주 WBS + 기술 스택**

WBS 마일스톤
- 1~2주: 기획 · 요구사항 · 기능명세서
- 3주: 개발 환경 · 4계층 아키텍처 · ADR
- 4~5주: 핵심 기능(질문 생성·시선 분석) + 단위 테스트
- 6주~: 빌드·배포 파이프라인 · 문서화

기술 스택
- Framework: **Flutter 3.38.9** / State: **Riverpod 2.6.1**
- Vision: **ML Kit Face Detection** / AI: **OpenAI gpt-4o-mini**
- Local DB: **Hive** / Network: **Dio** / Env: **flutter_dotenv**

---

## 슬라이드 5 — 프로젝트 진행 과정 (AI 도구 체인)

**단계별 특화 AI 조합 + 사람 검토 (Human-in-the-Loop)**

- [기획] **Manifest AI** — 앱 컨셉·요구사항 도출
- [디자인] **Google Stitch** — UI 화면 시안
- [개발] **Claude Code** — 코드·테스트·문서 생성
- [검토] **개발자(손정효)** — 전 산출물 직접 검수·의사결정
- GitHub: **56 커밋 / week1~8 브랜치** — 주차별 진행 기록

---

## 슬라이드 6 — 구현 방법 설명

**대화형 개발 + 검증 루프**

- `CLAUDE.md` + `AGENTS.md`로 프로젝트 규칙·레이어를 AI에 주입
- 외과적 수정(Surgical Change): 요청 범위만 정확히 수정
- 핵심 기능 구현
  - AI 질문: 직무·회사·자소서 → gpt-4o-mini가 3/5/7개 생성 + 꼬리질문
  - 시선 분석: ML Kit FaceDetector로 프레임별 응시 여부 판정
  - 리포트: 시선 지표 + AI 피드백 TOP3 + 추이 그래프
- 커밋 조건: `flutter analyze` + `flutter test` 통과

---

## 슬라이드 7 — 앱 구조 설명

**4계층 클린 아키텍처 (단방향 의존)**

- **UI** (`lib/ui/`) → 상태(state)만 참조
- **State** (`lib/state/`) → Riverpod Providers (GazeNotifier · InterviewNotifier · ReportNotifier 등)
- **Domain** (`lib/domain/`) → 순수 Dart 엔티티 (아무것도 import 안 함 → 테스트 용이)
- **Data** (`lib/data/`) → local(Hive) · remote(OpenAI · ML Kit · Firebase)
- 의존성 규칙: `ui → state → domain ← data`

---

## 슬라이드 8 — 아키텍처 다이어그램

**레이어 다이어그램**

```
┌──────────────────────────────┐
│  UI Layer (lib/ui/)          │  화면·위젯
└──────────────┬───────────────┘
               │ watch/read (Riverpod)
┌──────────────▼───────────────┐
│  State Layer (lib/state/)    │  Notifier 6종
└──────────────┬───────────────┘
               │ call
┌──────────────▼───────────────┐
│  Domain Layer (lib/domain/)  │  순수 Dart 엔티티
└──────┬───────────────┬───────┘
       │               │
┌──────▼─────┐  ┌──────▼────────┐
│ data/local │  │ data/remote   │
│ Hive       │  │ OpenAI·ML Kit │
│            │  │ ·Firebase     │
└────────────┘  └───────────────┘
```

- 원본 카메라 영상·오디오는 어디에도 저장하지 않음 (개인정보 보호)

---

## 슬라이드 9 — 개발 환경 설정

**5분 셋업 (docs/SETUP.md)**

- 요구: Flutter 3.38.9 · JDK 17 · Android SDK(compileSdk 36 / minSdk 24)
- 절차
  1. `git clone` → `cd v-view/v_view`
  2. `flutter pub get`
  3. `.env` 생성 후 `OPENAI_API_KEY=` 입력 (코드 하드코딩 금지)
  4. `flutter run`
- `flutter doctor`로 환경 점검, 시선 분석은 실기기 권장

---

## 슬라이드 10 — 빌드와 배포 과정

**빌드 → 서명 → 배포 파이프라인**

```
코드 푸시 → [게이트] flutter analyze + flutter test
   → 빌드 (APK / AAB / IPA)
   → 서명 (key.properties + v-view-release.jks)
   → 배포 (Firebase App Distribution)
```

- 빌드: `flutter build apk --release` / `appbundle --release`
- CI Secrets로 `.env` 주입 (키 미커밋)
- 현재 상태: **빌드·서명 파이프라인 준비 완료 / 배포는 예정 단계**

---

## 슬라이드 11 — 구현 시행착오 사례 (개발자 관점)

**대표 트러블슈팅 (WIKI.md 기록)**

- **카메라 프레임 포맷 충돌**: 안드로이드 YUV_420_888 → ML Kit은 NV21만 지원
  → row stride / pixel stride를 직접 반영해 변환 (`camera_frame_converter.dart`)
- **버튼 렌더링 7개 화면 동시 크래시**: `border width:0 + borderRadius` 충돌
  → 한 곳 수정 후 grep으로 동일 패턴 전수 검색 → 일괄 수정
- **세션 상태 잔류**: Riverpod 전역 상태에 이전 면접 데이터 남음
  → 진입점에서 reset 일괄 호출 + 화면 진입 시 동기 초기화
- 모든 사례를 '증상 → 원인 → 해결 → 교훈' 포맷으로 누적

---

## 슬라이드 12 — 성능 최적화 노력

**Performance Optimization**

- **UI Flash 방지**: 질문 화면 진입 시 첫 프레임 전에 이전 질문 동기 초기화
- **무한 루프 차단**: 꼬리질문 생성 깊이 최대 2단계로 제한
- **불필요 API 호출 억제**: 상태 흐름 제어로 재진입 시 중복 생성 방지
- **빌드 효율**: 변경 파일만 타겟 분석, 병렬 도구 호출로 왕복 최소화

---

## 슬라이드 13 — 코드 품질 관리

**Quality Management**

- 매 수정마다 `flutter analyze` — 에러·경고 0건 유지 (info 수준 deprecation만 잔존, STT v2 미사용 영역)
- 외과적 수정 원칙: 변경 줄이 요청에서 직접 추적 가능
- 레이어 경계 위반 검토 (AI 생성물의 Domain/Data 위치 오류를 사람이 교정)
- ADR로 기술 결정 근거 문서화 (5건)

---

## 슬라이드 14 — 테스트 결과

**단위 테스트 45개 — 전체 통과**

| 테스트 파일 | 케이스 |
|---|---|
| gaze_analyzer_test | 10 |
| interview_notifier_test | 20 |
| report_notifier_test | 7 |
| session_input_notifier_test | 7 |
| widget_test | 1 |
| **합계** | **45 (All passed)** |

- 핵심 검증: 시선 분산 **연속 1초 기준**, 응시율 공식, 상태 전환, AI 실패 시 fallback
- 통합 테스트(integration_test): E2E 앱 시작·인증 화면 시나리오 추가 완료

---

## 슬라이드 15 — ADR 요약 (질의응답 준비)

**주요 기술 결정 5건 (docs/ADR/)**

| ADR | 결정 | 기각 대안 |
|---|---|---|
| 001 | Flutter | React Native / 네이티브 분리 |
| 002 | Riverpod | Provider / BLoC / GetX |
| 003 | Hive | SQLite / shared_preferences / Isar |
| 004 | OpenAI gpt-4o-mini | Gemini / 온디바이스 LLM |
| 005 | ML Kit | MediaPipe / 자체 TFLite 모델 |

- 각 ADR: Context · Decision · Status · Consequence + 대안 기각 이유
- 예) 시선 분석은 ML Kit — 온디바이스로 개인정보 보호, MediaPipe는 네이티브 설정 부담으로 제외

---

## 슬라이드 16 — GitHub 설치 가이드

**저장소 & 문서**

- Repo: github.com/thswjdgy/v-view
- README: Setup Guide · Build & Deployment · Testing · Architecture · ADR
- 설치: `git clone` → `flutter pub get` → `.env` 설정 → `flutter run`
- 문서 인덱스: `docs/SETUP.md` · `DEPLOY.md` · `TESTING.md` · `ARCHITECTURE.md` · `docs/ADR/`

---

## 슬라이드 17 — 시연 데모 (앱 형태 & 기능)

**30초 라이브 데모 — 화면 구성**

- 홈: 주간 목표 · AI 모의면접 CTA · 최근 기록
- 세션 설정: 면접 유형 · 직무 · 자소서(최대 1000자) · 질문 수/타이머
- 질문 생성: V-Bot 로딩 → AI 맞춤 질문 리스트
- 면접: 카메라 + 질문 + 타이머 + 시선 추적
- 리포트: 총점 + 시선 지표 바 + AI 피드백 카드

---

## 슬라이드 18 — 사용자 시나리오 기반 시연

**30초 시연 순서 (매끄럽게)**

1. (0~7초) 홈 → "면접 연습 시작하기" → 자소서 입력
2. (7~15초) "다음" → **V-Bot 질문 생성 로딩** → 질문 리스트 등장
3. (15~25초) 면접 화면: 카메라 + 질문 + 타이머 (시선 배지)
4. (25~30초) 리포트: 총점 + 시선 지표 + 개선점

---

## 슬라이드 19 — 임팩트 있는 데모 장면

**2개 핵심 컷 강조**

- 🤖 **"질문 생성 로딩 → 맞춤 질문 등장"** — 자소서가 진짜 분석되는 순간
- 📊 **"리포트 총점 + 시선 지표 바"** — 객관적 피드백이 한눈에
- 메시지: "자소서를 넣으면 AI가 질문을 만들고, 시선을 추적하고, 끝나면 점수로 돌려준다"

---

## 슬라이드 20 — 마무리 및 향후 발전 방향

**정리 & 로드맵**

- v-view = 혼자서도 실전처럼 + 객관적 피드백 (AI 질문 · 시선 분석 · 리포트)
- 개발 방식: 분야별 특화 AI(Manifest AI · Google Stitch · Claude Code) + 사람 검토
- 향후 (v2)
  - Firebase App Distribution 실배포
  - 음성(STT) · 표정/감정 분석 확장
- 감사합니다.

---

## ⚠️ 발표 사실관계 가드 (슬라이드에 넣으면 안 되는 것)

- 응시율 "72%" 등 구체 측정 수치 (실측 기록 없음)
- "FaceDetector 1,028회 / 에러 0건" (근거 없음)
- "통합 테스트 45개 전부 통과" 등 과장 표현 금지 (통합 테스트는 E2E 기본 시나리오 수준)
- "flutter analyze 0건 클린" (info 6건 존재 → '에러·경고 0'으로)
- "Firebase 배포 완료" (파이프라인 준비/예정 단계)
