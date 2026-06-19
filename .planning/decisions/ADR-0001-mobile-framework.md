# ADR-0001: 모바일 프레임워크 선택 — Flutter

| 항목 | 내용 |
|------|------|
| **날짜** | 2026-05-10 |
| **상태** | 확정 (Accepted) |
| **작성자** | 손정협 |

---

## 배경 (Context)

v-view는 카메라 기반 시선 분석과 OpenAI gpt-4o-mini 질문 생성을 핵심으로 하는 모바일 면접 코칭 앱이다. 7주 안에 Android/iOS 양쪽에서 동작하는 MVP를 완성해야 한다.

---

## 결정 (Decision)

**Flutter 선택**

---

## 대안 (Alternatives)

| 플랫폼 | 장점 | 제외 이유 |
|--------|------|-----------|
| React Native | JS/TS 생태계, 익숙함 | ML Kit 연동 패키지가 커뮤니티 유지보수 버전이라 불안정 |
| Android (Kotlin) | 풀 네이티브, 도구 성숙 | iOS 미지원 → 타겟 사용자 절반 누락 |
| iOS (Swift) | Apple 생태계 깊이 | macOS 개발 환경 필수, Android 미지원 |
| Kotlin Multiplatform | 코어 공유 | 복잡도 높음, 7주 일정에 부적합 |

---

## 결과 (Consequences)

**긍정적**
- 코드 한 벌로 Android/iOS 동시 지원
- `google_mlkit_face_detection` 공식 패키지로 시선 분석 구현 가능
- Firebase App Distribution으로 발표용 배포 가능

**리스크 및 대응**
- Dart 언어 학습 필요 → Claude Code로 코드 생성 후 직접 읽고 이해하는 방식으로 보완
- ML Kit 기기별 정확도 편차 → '측정 불가/참고용' UI로 대응

---

## 60초 말하기

> "Flutter를 선택했습니다. 7주 안에 Android/iOS를 동시에 커버해야 했기 때문입니다. React Native와 Android(Kotlin)도 검토했지만, React Native는 ML Kit 연동이 불안정하고 Android는 iOS를 포기해야 해서 Flutter가 유일한 선택이었습니다."

> AI Agent(Claude Code) 초안 생성 / 손정협 직접 검토 확인
