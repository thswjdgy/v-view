# AGENTS.md — v-view AI Agent 작업 지침

> 이 파일은 Claude Code 등 AI Agent가 v-view 저장소에서 작업할 때
> 자동으로 읽어야 하는 컨텍스트 및 행동 원칙입니다.
> 코딩 원칙 상세: [md/CLAUDE.md](md/CLAUDE.md)

---

## 프로젝트 한 줄 요약

Flutter 기반 AI 가상 면접 코칭 앱.
Claude API로 면접 질문을 생성하고, ML Kit으로 시선을 분석하여 피드백 리포트를 제공한다.

---

## 저장소 구조

```
v-view/
├── v_view/          ← Flutter 앱 (주요 작업 공간)
├── docs/            ← 설계·운영 문서
├── md/              ← 기획 문서 (읽기 전용, 수정 금지)
├── AGENTS.md        ← 이 파일
└── README.md
```

**작업 시 기본 디렉토리:** `v_view/`

---

## 기술 스택 & 버전 (고정)

| 라이브러리 | 버전 | 역할 |
|---|---|---|
| flutter_riverpod | 2.6.1 | 상태 관리 |
| hive_flutter | 1.1.0 | 로컬 DB |
| dio | 5.9.2 | HTTP 클라이언트 |
| flutter_dotenv | 5.2.1 | 환경 변수 |
| camera | 0.11.4 | 카메라 스트림 |
| google_mlkit_face_detection | 0.11.1 | 시선 분석 |
| fl_chart | 0.70.2 | 차트 |
| permission_handler | 11.4.0 | 권한 |

> 버전 변경 시 반드시 이 테이블도 업데이트할 것.

---

## 레이어 규칙

```
ui/ → state/ → domain/ ← data/
```

- `ui/`는 `state/`만 참조한다. `data/`를 직접 참조하지 않는다.
- `state/`는 `domain/`과 `data/`를 참조할 수 있다.
- `domain/`은 어떤 레이어도 import하지 않는다 (순수 Dart).
- `data/`는 `domain/`만 참조한다.

---

## 핵심 비즈니스 규칙 (코드 변경 시 반드시 준수)

1. **시선 분산 카운트**: 분산 상태 연속 1초(1000ms) 이상일 때만 1회
   - 구현 위치: `v_view/lib/data/remote/gaze/gaze_analyzer.dart`
   - `_distractionThresholdMs = 1000`

2. **응시율 공식**: `(응시 프레임 수 / 전체 측정 프레임 수) × 100`
   - 측정 품질이 낮으면 `GazeQuality.reference` 또는 `unavailable`로 표시

3. **API 키 관리**: `.env` 파일 사용, 코드 하드코딩 절대 금지
   - 키 참조: `dotenv.env['ANTHROPIC_API_KEY']`

4. **원본 영상 저장 금지**: `GazeAnalyzer`는 프레임을 처리 후 즉시 버린다

5. **AI 실패 시 최소 리포트**: Claude API 실패 → `_fallbackImprovements()` 호출
   - 구현 위치: `v_view/lib/state/report/report_provider.dart`

---

## 기능별 파일 맵

| 기능 | UI | State | Domain | Data |
|---|---|---|---|---|
| 세션 설정 | ui/session_setup/ | state/session_setup/ | domain/session_setup/ | data/local/session/ |
| 면접 진행 | ui/interview/ | state/interview/ | domain/interview/ | data/remote/ai/ |
| 시선 분석 | ui/gaze/ | state/gaze/ | domain/gaze/ | data/remote/gaze/ |
| 피드백 리포트 | ui/report/ | state/report/ | domain/report/ | data/local/report/ |
| 히스토리 | ui/history/ | state/history/ | domain/history/ | data/local/history/ |
| 공통 | ui/common/ | — | — | data/local/hive_service.dart |

---

## 작업 패턴

### 새 기능 추가 시 순서
1. `domain/`에 엔티티·모델 추가
2. `data/`에 datasource 구현
3. `state/`에 Provider 추가
4. `ui/`에 화면·위젯 추가
5. `flutter analyze` 통과 확인

### 버그 수정 시
- 영향받는 레이어의 파일만 수정
- 수정 후 `flutter analyze` 실행
- 시선 분산 로직 수정 시 반드시 1초 기준 유지

### 금지 사항
- `md/` 폴더 파일 수정 금지 (기획 문서, 읽기 전용)
- v2 기능(STT, 표정 분석) 먼저 구현 금지
- `data/remote/` 에서 영상·오디오 파일 저장 금지

---

## 환경 확인 명령어

```bash
# 의존성 설치
flutter pub get

# 분석
flutter analyze

# 테스트
flutter test

# Android 빌드 (릴리즈)
flutter build apk --release
```

---

## Claude API 연동 포인트

| 호출 | 파일 | 메서드 |
|---|---|---|
| 기본 질문 생성 | data/remote/ai/claude_api_service.dart | generateQuestions() |
| 꼬리 질문 생성 | 동일 | generateFollowUp() |
| 피드백 생성 | 동일 | generateFeedback() |

모델: `claude-opus-4-7` (변경 시 AGENTS.md, claude_api_service.dart 동시 수정)
