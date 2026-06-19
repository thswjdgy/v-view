# ADR-0003: 백엔드/비전 라이브러리 선택 — ML Kit + OpenAI gpt-4o-mini

| 항목 | 내용 |
|------|------|
| **날짜** | 2026-05-10 |
| **상태** | 확정 (Accepted) |
| **작성자** | 손정협 |

---

## 배경 (Context)

v-view는 두 가지 외부 기술이 필요하다.

1. **시선 분석**: 카메라 프레임에서 눈 위치를 실시간으로 감지
2. **AI 질문 생성 + 피드백**: 면접 유형/직종/자기소개서 기반 맞춤 질문 생성

---

## 결정 (Decision)

- 시선 분석: **ML Kit** (`google_mlkit_face_detection`)
- AI 질문/피드백: **OpenAI gpt-4o-mini** (OpenAI)
- 별도 서버 없음 — 로컬 저장은 **Hive**

---

## 대안 (Alternatives)

### 시선 분석

| 라이브러리 | 장점 | 제외 이유 |
|-----------|------|-----------|
| **ML Kit** | pub.dev 공식 패키지, 온디바이스 처리 | 선택 |
| MediaPipe | 정확도 높음 | Flutter 연동 시 Android/iOS 네이티브 설정 각각 필요 → 7주 일정 리스크 |

### AI 질문/피드백

| 서비스 | 장점 | 제외 이유 |
|--------|------|-----------|
| **OpenAI gpt-4o-mini** | 한국어 품질 우수, 구조화 응답 | 선택 |
| OpenAI GPT | 생태계 넓음 | Claude 대비 한국어 면접 특화 프롬프트 품질 낮음 |
| 자체 서버 | 완전한 제어 | 7주 안에 서버 구축 + 앱 개발 동시 진행 불가 |

---

## 결과 (Consequences)

**긍정적**
- ML Kit: 분석 모델이 앱 안에 내장 → 인터넷 없이도 시선 분석 가능, 원본 영상 서버 전송 없음
- OpenAI gpt-4o-mini: 별도 서버 없이 REST 호출만으로 AI 기능 구현
- Hive: Flutter 전용 경량 로컬 DB, 설정 단순

**리스크 및 대응**
- ML Kit 정확도 편차 → 얼굴 미검출 시 '측정 불가/참고용' 표시
- OpenAI gpt-4o-mini 비용 → 세션당 호출 횟수 제한으로 관리
- 향후 ML Kit → MediaPipe 교체 필요 시 Data 레이어(`data/remote/gaze/`)만 교체하면 됨

---

## 60초 말하기

> "시선 분석은 ML Kit, AI 질문 생성은 OpenAI gpt-4o-mini를 선택했습니다. ML Kit은 분석 모델이 앱 안에 내장되어 원본 영상을 서버로 보내지 않아 개인정보 정책을 충족하고, OpenAI gpt-4o-mini는 별도 서버 없이 REST 호출만으로 한국어 면접 질문 생성이 가능하기 때문입니다. MediaPipe는 정확도가 높지만 Flutter 연동 복잡도가 높아 7주 일정에 리스크가 컸습니다."

> AI Agent(Claude Code) 초안 생성 / 손정협 직접 검토 확인
