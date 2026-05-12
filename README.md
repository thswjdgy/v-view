# v-view — AI 기반 가상 면접 코칭 앱

> 카메라로 시선을 분석하고, Claude AI가 맞춤 질문과 피드백을 제공하는 모바일 면접 코칭 앱

[![Flutter](https://img.shields.io/badge/Flutter-3.38-blue)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.6-purple)](https://riverpod.dev)
[![Claude API](https://img.shields.io/badge/Claude-API-orange)](https://anthropic.com)

---

## 목차

- [프로젝트 개요](#프로젝트-개요)
- [주요 기능](#주요-기능)
- [기술 스택](#기술-스택)
- [아키텍처](#아키텍처)
- [빠른 시작](#빠른-시작)
- [폴더 구조](#폴더-구조)
- [문서](#문서)

---

## 프로젝트 개요

면접 준비생이 혼자서도 실전과 같은 환경에서 연습할 수 있도록:
- **AI 맞춤 질문** — 직종·회사·자기소개서 기반으로 Claude API가 생성
- **실시간 시선 분석** — ML Kit으로 카메라 응시 여부를 측정
- **세션 피드백 리포트** — 시선 지표 + Q&A 요약 + 개선 포인트 TOP3
- **로컬 히스토리** — Hive로 기기에 안전하게 저장, 원본 영상 저장 없음

---

## 주요 기능

| # | 기능 | MVP 범위 |
|---|---|---|
| 1 | AI 맞춤 질문 생성 | 기본 질문 3개 + 꼬리 질문 |
| 2 | 실시간 시선 분석 | 응시율, 분산 횟수/시간 |
| 3 | 세션 피드백 리포트 | 시선 지표 + AI 피드백 |
| 4 | 면접 기록 관리 | 로컬 저장, 목록/상세 조회 |
| 5 | 세션 설정 | 면접 유형 선택, 정보 입력 |
| 6 | 권한·오류 처리 | 카메라 권한, 네트워크 오류 |

> v2 범위(미구현): STT 발화 분석, 표정/감정 분석

---

## 기술 스택

| 분류 | 기술 | 선택 이유 |
|---|---|---|
| Framework | Flutter 3.38 | Android/iOS 단일 코드베이스 |
| State | Riverpod 2.6 | 컴파일 타임 안전성, 테스트 용이 |
| Vision | ML Kit Face Detection | 온디바이스 처리, 개인정보 보호 |
| AI | Claude API (claude-opus-4-7) | 자연스러운 한국어 면접 질문 생성 |
| Local DB | Hive | Flutter 친화적, 빠른 키-값 저장 |
| Network | Dio | 인터셉터, 타임아웃 설정 용이 |
| Env | flutter_dotenv | API 키 코드 분리 |
| Chart | fl_chart | 시선 추이 시각화 |

→ 상세 결정 근거: [docs/ADR/](docs/ADR/)

---

## 아키텍처

```
┌─────────────────────────────────────┐
│              UI Layer               │
│  session_setup │ interview │ report  │
│  gaze          │ history   │ common  │
└────────────────┬────────────────────┘
                 │ watch/read
┌────────────────▼────────────────────┐
│           State Layer               │
│        Riverpod Providers           │
└────────────────┬────────────────────┘
                 │ call
┌────────────────▼────────────────────┐
│          Domain Layer               │
│   Entities (SessionInput, Gaze…)    │
└───────────┬──────────┬──────────────┘
            │          │
┌───────────▼──┐  ┌────▼──────────────┐
│ data/local   │  │  data/remote      │
│ Hive         │  │  Claude API       │
│ (sessions,   │  │  ML Kit Gaze      │
│  reports,    │  │                   │
│  history)    │  │                   │
└──────────────┘  └───────────────────┘
```

→ 상세: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

---

## 빠른 시작

```bash
# 1. 저장소 클론
git clone https://github.com/thswjdguq/v-view.git
cd v-view/v_view

# 2. 의존성 설치
flutter pub get

# 3. 환경 변수 설정
cp .env.example .env
# .env에 ANTHROPIC_API_KEY 입력

# 4. 실행
flutter run
```

→ 상세 환경 설정: [docs/SETUP.md](docs/SETUP.md)

---

## 폴더 구조

```
v-view/
├── v_view/                  # Flutter 앱
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app.dart
│   │   ├── ui/              # 화면·위젯
│   │   ├── state/           # Riverpod providers
│   │   ├── domain/          # 엔티티
│   │   └── data/
│   │       ├── local/       # Hive datasources
│   │       └── remote/      # Claude API, ML Kit
│   └── pubspec.yaml
├── docs/
│   ├── ARCHITECTURE.md
│   ├── SETUP.md
│   ├── DEPLOY.md
│   ├── TESTING.md
│   └── ADR/                 # 아키텍처 결정 기록
├── md/                      # 기획 문서
│   ├── 기능명세서.md
│   ├── WBS.md
│   └── CLAUDE.md
├── AGENTS.md                # AI Agent 지침
└── README.md
```

---

## 문서

| 문서 | 설명 |
|---|---|
| [기능명세서](md/AI%20기반%20가상%20면접%20코칭%20앱%20v-view_기능명세서_2026-05-10.md) | 전체 요구사항 |
| [WBS](md/WBS.md) | 작업 분류 및 일정 |
| [ARCHITECTURE](docs/ARCHITECTURE.md) | 시스템 설계 |
| [ADR](docs/ADR/) | 아키텍처 결정 기록 |
| [SETUP](docs/SETUP.md) | 개발 환경 설정 |
| [DEPLOY](docs/DEPLOY.md) | 빌드·배포 가이드 |
| [TESTING](docs/TESTING.md) | 테스트 전략 |
| [CLAUDE.md](md/CLAUDE.md) | AI Agent 코딩 원칙 |
| [AGENTS.md](AGENTS.md) | AI Agent 작업 지침 |
