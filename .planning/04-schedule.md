# 6주 일정 (Week 10~15)

## 전체 일정 개요

| 주차 | 목표 | 핵심 산출물 | 검증 |
|---|---|---|---|
| Week 10 | 기획·일정 수립 | `.planning/*` 5개 문서 | 본인 리뷰 |
| Week 11 | 설계·환경 구축 | `docs/architecture.md`, 빌드 가능 상태 | "Hello World" 실행 |
| Week 12 | 핵심 기능 1 + **중간 발표** | 동작하는 프로토타입 (질문 생성·시선 분석) | 데모 가능 |
| Week 13 | 핵심 기능 2 + 테스트 | 주요 기능 완성, 테스트 통과 | `flutter test` |
| Week 14 | 마감·배포·문서 | 배포 산출물, 최종 문서 | 배포 링크 또는 빌드 |
| Week 15 | **최종 발표·평가** | 발표 슬라이드, 회고 | 평가 |

---

## Week 10 — 기획·일정 수립 ✅

**목표**: AI Agent와 함께 기획 문서 완비

| 작업 | 상태 |
|---|---|
| 비전·목표 (`00-vision.md`) | ✅ |
| 요구사항 MoSCoW (`01-requirements.md`) | ✅ |
| WBS 3단계 (`02-wbs.md`) | ✅ |
| 6주 일정 (`04-schedule.md`) | ✅ |
| 리스크 목록 (`05-risks.md`) | ✅ |
| ADR 작성 시작 | ✅ |

---

## Week 11 — 설계·환경 구축 ✅

**목표**: `git clone` → 한 줄 명령으로 실행 가능

| 작업 | 상태 |
|---|---|
| GitHub 저장소 생성 | ✅ |
| Flutter 프로젝트 스캐폴드 | ✅ |
| 레이어 아키텍처 확정 | ✅ |
| `docs/architecture.md` (레이어 구조) | ✅ |
| `docs/setup.md` (zero→run) | ✅ |
| ADR-001~004 완성 | ✅ |
| Hello World 빌드 성공 | ✅ |

---

## Week 12 — 핵심 기능 1 + 중간 발표 ✅

**목표**: 동작하는 프로토타입으로 중간 발표

| 작업 | 상태 |
|---|---|
| 도메인 엔티티 5개 정의 | ✅ |
| 데이터 레이어 (Hive, ClaudeApi, GazeAnalyzer) | ✅ |
| State 레이어 5개 Notifier | ✅ |
| UI 스캐폴드 (6개 화면) | ✅ |
| 카메라 + GazeAnalyzer 파이프라인 연결 | ✅ |
| CameraFrameConverter 구현 | ✅ |

---

## Week 13 — 핵심 기능 2 + 테스트 🔄

**목표**: 주요 기능 완성 + 단위 테스트 25개 통과

| 작업 | 상태 |
|---|---|
| 스켈레톤 로딩 UI | ✅ |
| GazeTrendChart (최근 5회 추이) | ✅ |
| SessionConfirmScreen (개인정보 안내) | ✅ |
| 히스토리 전체 삭제 버튼 | ✅ |
| Dio 오프라인·타임아웃 오류 처리 | ✅ |
| fallback 개선 포인트 TOP3 | ✅ |
| 단위 테스트 25개 통과 | ✅ |
| `flutter analyze` 이슈 0 | ✅ |
| OpenAI gpt-4o-mini 실 연동 테스트 | ⬜ |

---

## Week 14 — 마감·배포·문서 ⬜

**목표**: 배포 산출물 + 최종 문서 완비

| 작업 | 예정 |
|---|---|
| `key.properties` + 키스토어 생성 | ⬜ |
| Android APK 릴리즈 빌드 | ⬜ |
| Firebase App Distribution 배포 | ⬜ |
| `docs/DEPLOY.md` 최종 확인 | ⬜ |
| `pubspec.yaml` 버전 (`1.0.0+1`) 최종 확인 | ✅ |

---

## Week 15 — 최종 발표·평가 ⬜

**목표**: 완성된 프로젝트 발표

| 작업 | 예정 |
|---|---|
| 발표 슬라이드 (Marp) | ✅ |
| Q&A 예상 질문 답변 준비 | ✅ |
| AUTHORING.손정협.md 라이브 시연 준비 | ⬜ |
| 실기기 데모 준비 | ⬜ |

---

## 리스크 & 완충 시간

- **Week 13 여유**: OpenAI gpt-4o-mini 실 연동 실패 시 fallback으로 커버
- **Week 14 여유**: APK 빌드 실패 시 시뮬레이터 데모로 대체
- **완충**: 각 주 금요일은 미완 작업 마무리용
