# ADR-004: AI 백엔드로 OpenAI gpt-4o-mini 선택

## 상태
Accepted — 2026-05-10

## 컨텍스트

면접 질문 생성, 꼬리 질문 생성, 피드백 리포트 생성에 LLM이 필요하다.
한국어 면접 특화 품질, 비용, API 접근성이 선택 기준이었다.

후보:
- OpenAI API (gpt-4o-mini)
- Claude API (Anthropic)
- Google Gemini
- 온디바이스 LLM (llama.cpp 등)

## 결정

**OpenAI API (gpt-4o-mini)를 선택한다.**

## 이유

1. **한국어 품질**: 자연스러운 한국어 면접 질문·피드백 생성 품질 우수
2. **긴 컨텍스트**: 자기소개서 전문 + 면접 히스토리를 한 번에 전달 가능
3. **지시사항 준수**: JSON 형식 응답 지시 시 형식 이탈률 낮음
4. **저비용**: gpt-4o-mini는 경량·저비용으로 다회 호출(질문·꼬리질문·피드백)에 적합
5. **개발 접근성**: 개인 개발자 API 키 발급 용이

## 결과

- API 키는 `.env`에서만 로드 (`OPENAI_API_KEY`)
- 모든 요청에 30초 타임아웃 설정
- 실패 시 최소 리포트(시선 지표만) 자동 대체
- 원본 카메라 영상·오디오는 API 요청에 포함하지 않음
- 응답 파싱: JSON 추출 후 도메인 객체 변환
- 호출 엔드포인트: `https://api.openai.com/v1/chat/completions`

## 대안 검토

| 대안 | 기각 이유 |
|---|---|
| Claude API (Anthropic) | 유사 품질이나 gpt-4o-mini 대비 단가가 높아 다회 호출 비용 부담 |
| Gemini | 한국어 면접 질문 품질 검증 미흡 |
| 온디바이스 LLM | 모바일 기기 성능 한계, 한국어 모델 품질 불안정 |

> 참고: 코드의 서비스 클래스명은 초기 설계 흔적으로 `ClaudeApiService`이나,
> 실제 구현은 OpenAI gpt-4o-mini를 호출한다. (네이밍과 구현 불일치는 WIKI.md TS-009 참고)
