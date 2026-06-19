# WIKI.md — LLM & Vibe Coding Wiki

> **v-view** 프로젝트를 AI Agent(Claude Code)와 함께 개발하며 축적한 **암묵지 관리(Knowledge Management)** 문서입니다.
> LLM 컨텍스트 한계 극복, AI 생성 코드의 품질 관리·성능 최적화(Performance Optimization),
> 그리고 협업 중 발생한 시행착오(Troubleshooting)를 재현 가능한 형태로 집대성합니다.
>
> 이 **LLM Wiki**는 "한 번 겪은 문제는 두 번 디버깅하지 않는다"는 원칙으로 운영됩니다.

---

## 목차

1. [LLM 컨텍스트 관리 및 토큰 절약 암묵지](#1-llm-컨텍스트-관리-및-토큰-절약-암묵지)
2. [AI 생성 코드 품질 관리 및 성능 최적화 노하우](#2-ai-생성-코드-품질-관리-및-성능-최적화-노하우)
3. [AI 협업 시행착오(Troubleshooting) 기록 체계](#3-ai-협업-시행착오troubleshooting-기록-체계)
4. [프롬프트 엔지니어링 치트시트](#4-프롬프트-엔지니어링-치트시트)

---

## 1. LLM 컨텍스트 관리 및 토큰 절약 암묵지

LLM은 컨텍스트 윈도우가 유한하고, 대화가 길어질수록 ① 비용 증가 ② 초반 지시 망각 ③ 응답 지연이 발생합니다.
이를 극복하기 위해 적용한 **암묵지(Knowledge Management) 기법**입니다.

### 1.1 "규칙은 대화가 아니라 파일에 쓴다" — 영속 컨텍스트 분리

LLM은 대화 맥락을 잊지만, 파일은 매 세션 자동으로 다시 읽힙니다.
따라서 반복 지시는 대화로 하지 않고 **컨트롤 파일**에 영구 기록했습니다.

| 파일 | 역할 | 효과 |
|---|---|---|
| `CLAUDE.md` | 코딩 원칙·금지 규칙 (시스템 프롬프트화) | 매 세션 "FilledButton 쓰지 마" 재설명 불필요 |
| `AGENTS.md` | Agent·Skill·Command 운용 지침 | 워크플로우 일관성 유지 |
| `WIKI.md` (이 문서) | 시행착오·트러블슈팅 누적 | 동일 버그 재디버깅 방지 |

> **핵심 암묵지**: 같은 지시를 두 번 타이핑하고 있다면, 그건 파일에 박제할 시점이라는 신호다.

### 1.2 컨텍스트 압축(Compaction)을 전제로 한 작업 단위 설계

긴 세션은 자동 요약(compaction)으로 초반 디테일이 압축됩니다. 이를 역이용해:

- **작업을 "검증 가능한 완료 기준"이 있는 단위로 쪼갬** → 압축돼도 다음 세션이 이어받기 쉬움
- 중요한 결정·제약은 대화에만 남기지 않고 즉시 파일(`CLAUDE.md`)에 반영
- "절대 건드리면 안 되는 파일" 같은 안전 제약은 압축에 휩쓸리지 않도록 **파일에 고정**

### 1.3 토큰 절약 — "전체"가 아니라 "필요한 부분"만 읽기

| ❌ 토큰 낭비 패턴 | ✅ 절약 패턴 | 절감 효과 |
|---|---|---|
| `flutter analyze` (전체 프로젝트) | `flutter analyze lib/특정파일.dart` | 분석 범위·출력 토큰 대폭 감소 |
| 파일 전체 재출력 후 수정 | `Edit` 도구로 변경 라인만 치환 | 출력 토큰 최소화 |
| 파일 전체 읽기 | `offset`/`limit`으로 해당 구간만 Read | 입력 토큰 절감 |
| 키워드 위치를 추측해 여러 번 Read | `Grep`으로 라인 핀포인트 후 Read | 왕복 횟수 감소 |
| 매번 코드베이스 재탐색 | `Explore Subagent`에 위임 (별도 컨텍스트) | 메인 컨텍스트 오염 방지 |

### 1.4 병렬 도구 호출로 왕복(Round-trip) 최소화

서로 의존하지 않는 작업은 **한 번의 응답에 묶어 병렬 실행**했습니다.
왕복 횟수가 곧 토큰·시간 비용이기 때문입니다.

```
[1회 응답에 동시 실행]
Read(home_screen.dart) + Read(provider.dart) + Grep("reset") + flutter analyze
→ 4번의 개별 왕복(4× 컨텍스트 재로딩)을 1번으로 압축
```

### 1.5 서브에이전트로 컨텍스트 격리(Context Isolation)

"이 데이터가 어디에 저장되나?" 같은 광범위 탐색은 **Explore Subagent**에 위임했습니다.
탐색 과정의 수많은 파일 내용이 메인 대화 컨텍스트를 오염시키지 않고,
**결과 요약만** 돌려받아 핵심 컨텍스트를 깨끗하게 유지했습니다.

---

## 2. AI 생성 코드 품질 관리 및 성능 최적화 노하우

AI가 생성한 코드는 "동작하는 것처럼 보이지만 미묘하게 틀린" 경우가 많습니다.
이를 잡아내기 위한 **품질 관리(Linting·Refactoring)** 및 **성능 최적화(Performance Optimization)** 노하우입니다.

### 2.1 Lint-as-Guardrail — IDE 진단을 즉시 피드백 루프로

`Edit` 직후 IDE Diagnostics 훅이 자동 실행되어, **빌드 전에** 오류를 잡습니다.

```
Edit 실행 → IDE 진단 훅 자동 트리거 → lint 경고/에러 즉시 반환
→ 같은 응답 턴 안에서 수정 → 사용자에게 깨진 코드 노출 0
```

**실제 사례**: import 추가 후 "Unused import" 경고가 즉시 떠서,
해당 import를 실제 사용하는 코드까지 같은 턴에 완성 → orphan 코드 잔류 방지.

### 2.2 "한 곳에서 터진 버그는 다른 곳에도 있다" — 패턴 일괄 검출

AI는 같은 잘못된 패턴을 여러 파일에 복제하는 경향이 있습니다.
하나를 고치면 **반드시 `Grep`으로 동일 패턴을 전수 검사**했습니다.

**실제 사례 — Flutter 렌더링 버그 7개 파일 일괄 수정**
```
증상: "A hairline border ... can only be drawn when BorderRadius is zero"
원인: border width를 0으로 만들면서 borderRadius를 함께 줌 (Duolingo 3D 버튼)

❌ 잘못된 패턴
border: Border(bottom: BorderSide(width: _pressed ? 0 : 4))  // width:0 + radius → assertion

✅ 수정 패턴
border: _pressed ? null : Border(bottom: BorderSide(width: 4))  // border 자체를 제거

조치: Grep("width: _pressed ? 0")으로 7개 파일 전수 검출 → 일괄 수정
```

### 2.3 Refactoring 원칙 — "외과적 수정(Surgical Change)"

AI에게 자유를 주면 요청하지 않은 부분까지 "개선"하다 회귀 버그를 만듭니다.
이를 막기 위한 리팩터링 가드레일:

- **변경된 모든 줄은 요청에서 직접 추적 가능해야 함** (추적 불가 변경 = 금지)
- 인접한 "개선할 것 같은" 코드는 건드리지 않고 **언급만**
- 파일 전체 재작성 금지 → 변경 라인만 `Edit`
- 초기화 로직처럼 흩어지기 쉬운 코드는 **한 함수로 집결**시켜 단일 책임화

**실제 사례 — 세션 초기화 로직 단일화**
```dart
// 각 화면에 흩어질 뻔한 reset 호출을 _startNewSession() 한 곳으로 집결
void _startNewSession() {
  ref.read(sessionInputProvider.notifier).reset();  // 자소서·직무
  ref.read(interviewProvider.notifier).reset();      // 질문·답변
  ref.read(gazeProvider.notifier).reset();           // 시선 데이터
  Navigator.push(...);
}
```

### 2.4 성능 최적화(Performance Optimization) 노하우

| 영역 | 문제 | 최적화 기법 |
|---|---|---|
| **상태 잔류** | Riverpod 전역 상태로 이전 세션 데이터가 남아 오작동 | 진입점 reset + 화면 진입 시 동기 reset **이중 방어** |
| **UI Flash** | 이전 질문이 첫 프레임에 잠깐 노출 | `initState`에서 `addPostFrameCallback` **이전에** 동기 reset |
| **불필요 API 호출** | 같은 화면 재진입마다 질문 재생성 | `idle + empty` 상태를 loading으로 처리해 흐름 제어 |
| **무한 생성 루프** | 꼬리질문이 끝없이 생성 | `_followUpDepth()` 재귀 카운팅으로 최대 2단계 제한 |
| **빌드 토큰** | 매번 full analyze | 변경 파일만 타겟 분석 |
| **앱 시작 비용** | 메인 스레드 과부하 (Skipped frames) | 무거운 초기화를 프레임 콜백으로 분산 |

**실제 사례 — UI Flash 방지 타이밍 제어**
```dart
@override
void initState() {
  super.initState();
  ref.read(interviewProvider.notifier).reset();   // ① 동기: 첫 build 전에 비움
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(interviewProvider.notifier).start(input);  // ② 비동기: API는 프레임 후
  });
}
// 결과: 이전 질문이 단 한 프레임도 노출되지 않음
```

### 2.5 AI 생성물 검증 — "스크린샷으로 눈으로 확인"

코드가 컴파일된다 ≠ 의도대로 보인다. UI는 **반드시 실제 렌더링을 시각 검증**했습니다.

```
adb shell screencap → adb pull → 이미지 직접 확인(Read)
→ 레이아웃·색상·텍스트 육안 검수 → 문제 시 수정·재검증
```

> **성능 최적화 팁**: 탭 좌표는 추측하지 말고 `adb shell uiautomator dump`로
> 정확한 `bounds`를 추출. (에뮬레이터 1080×2400, 화면 표시 540px → ÷2 스케일 차이로 오탭 방지)

---

## 3. AI 협업 시행착오(Troubleshooting) 기록 체계

동일 문제를 반복 디버깅하지 않기 위한 **시행착오 누적 로그**입니다.
각 항목은 `증상 → 원인 → 해결 → 교훈` 표준 포맷으로 기록합니다.

### TS-001. Flutter border assertion (UI 렌더링 크래시)
- **증상**: `A hairline border can only be drawn when BorderRadius is zero or null`
- **원인**: `BorderSide(width: 0)` + `borderRadius` 동시 사용 (AI가 7개 파일에 복제)
- **해결**: pressed 시 `border: null` 처리 + `Grep`으로 전수 일괄 수정
- **교훈**: AI의 복제 패턴은 한 곳을 고친 뒤 반드시 전역 검색한다.

### TS-002. Riverpod 전역 상태 잔류 (세션 데이터 오염)
- **증상**: 새 면접인데 이전 자소서·질문·답변이 그대로 남음
- **원인**: 전역 Provider가 이전 세션 상태를 보존, reset 미호출
- **해결**: 각 Notifier에 `reset()` 추가 → `_startNewSession()`에서 일괄 호출 (이중 방어)
- **교훈**: 전역 상태는 "시작 시 초기화"를 진입점에서 명시적으로 보장한다.

### TS-003. AI 질문 캐시 (이전 세션 질문 재노출)
- **증상**: 새 자소서를 넣어도 이전 질문이 나옴
- **원인**: `if (questions.isEmpty)` 가드로 기존 질문 재사용
- **해결**: 화면 진입 시 무조건 reset 후 재생성, `idle+empty`를 loading으로 처리
- **교훈**: 캐시 가드는 "언제 무효화할지"를 함께 설계해야 한다.

### TS-004. 꼬리질문 무한 생성 (성능·UX 저하)
- **증상**: 꼬리질문이 끝없이 생성됨
- **원인**: 생성 조건에 깊이 제한 없음
- **해결**: `_followUpDepth()` 재귀 카운팅으로 최대 2단계 제한 + AI가 `needsFollowUp` 판단
- **교훈**: LLM 재귀 호출에는 반드시 종료 조건(depth/횟수)을 건다.

### TS-005. 로그인 후 화면 미전환 (네비게이션 버그)
- **증상**: 로그인 성공해도 화면이 안 바뀜
- **원인**: `app.dart`의 `home:` 변경은 이미 `push`된 LoginScreen에 영향 없음
- **해결**: LoginScreen에 `ref.listen` 추가 → 성공 시 `pushAndRemoveUntil`
- **교훈**: 선언적 라우팅과 명령형 네비게이션을 섞을 때 전환 트리거 위치를 확인한다.

### TS-006. 로그인 시 네트워크 오류 (환경 문제 / 앱 무관)
- **증상**: 로그인·회원가입 시 "네트워크 연결을 확인해주세요"
- **원인**: **에뮬레이터 DNS 미설정** (앱 버그 아님). `firebase.google.com` 해석 실패
- **해결**: `emulator -avd Pixel_8 -dns-server 8.8.8.8`로 재시작 → DNS 정상화
- **교훈**: "네트워크 오류"는 앱부터 의심하지 말고 **DNS·권한·환경**을 먼저 분리 진단한다.
  (에뮬레이터 `ping` 100% 손실은 QEMU의 ICMP 미라우팅, HTTPS는 정상 — 오판 주의)

### TS-007. Gradle `flutter.compileSdkVersion` VSCode 빨간불 (오탐)
- **증상**: `build.gradle.kts` 1행에 빨간 줄, "phased action failed"
- **원인**: VSCode가 Flutter Gradle 플러그인 확장 프로퍼티를 해석 못 하는 **오탐**. 실제 빌드는 성공
- **해결**: `compileSdk = 36`, `ndkVersion = "..."` 등 명시값으로 치환
- **교훈**: IDE 경고와 실제 빌드 결과를 분리 검증한다. (`flutter build apk`로 사실 확인)

### TS-008. git push 거부 (대용량 파일)
- **증상**: 173MB mp4 때문에 push rejected (>100MB 제한)
- **원인**: 시연 영상이 커밋에 포함됨
- **해결**: `git rm --cached` + `.gitignore`에 `*.mp4` 추가 + `--amend`
- **교훈**: 미디어·빌드 산출물은 처음부터 `.gitignore`에 등록한다.

### TS-009. 네이밍과 실제 구현 불일치 (혼동 위험)
- **증상**: `ClaudeApiService` 클래스가 실제로는 OpenAI(`api.openai.com`, `gpt-4o-mini`)를 호출
- **원인**: 초기 Claude → OpenAI 전환 시 클래스명 미변경
- **해결**: 문서(README/ADR)는 **실제 구현(OpenAI)** 기준으로 통일해 Q&A 모순 방지
- **교훈**: 문서와 코드가 충돌하면 "코드가 진실". 발표 전 정합성을 맞춘다.

### 시행착오 기록 표준 포맷
> 새 문제 발생 시 아래 템플릿으로 이 섹션에 누적:
> ```
> ### TS-XXX. 한 줄 제목 (영역)
> - 증상 / 원인 / 해결 / 교훈
> ```

---

## 4. 프롬프트 엔지니어링 치트시트

실전에서 효과를 본 프롬프트 기법 모음입니다.

| 기법 | 설명 | 효과 |
|---|---|---|
| **진단 먼저(Diagnose-First)** | "고쳐줘" 대신 "어디에 저장되는지 전부 찾아줘" | 잘못된 파일 수정 → 반복 작업 방지 |
| **검증 가능한 완료 기준** | "되게 해줘"(✕) → "1초 미만이면 카운트 안 되는 테스트 통과"(○) | 독립 반복 실행 가능 |
| **금지 목록 명시** | "X 파일 건드리지 마"를 프롬프트·파일에 고정 | 회귀 버그 차단 |
| **출력 형식 강제** | LLM API에 "JSON만 반환, 마크다운 금지" 시스템 프롬프트 | 파싱 실패율 감소 |
| **종료 조건 명시** | 재귀/반복 작업에 depth·횟수 상한 지정 | 무한 루프 방지 |
| **diff로 보여줘** | 수정 결과를 diff 형태로 요청 | 변경 추적·리뷰 용이 |
| **역할 부여** | "너는 시니어 풀스택 개발자야" | 답변 깊이·전문성 향상 |

### LLM API 호출 자체의 프롬프트 (앱 내부)
```dart
// 출력 형식을 강제해 JSON 파싱 안정성 확보
static const _jsonSystem =
    '반드시 유효한 JSON만 반환하세요. 설명이나 마크다운 코드블록을 포함하지 마세요.';

// 꼬리질문: LLM이 필요 여부를 스스로 판단하게 위임 (항상 생성 금지)
// 필요: {"needsFollowUp":true,"text":"...","intent":"..."}
// 불필요: {"needsFollowUp":false}
```

---

## 5. AI가 자주 틀리는 코드 패턴과 검토 노하우

AI는 "기능적으로 동작하는" 코드를 만들지만, 프레임워크 관례나 아키텍처 일관성은
사람이 검토(Review)해야 합니다. 실제로 반복 발견된 패턴을 박제합니다.

### 5.1 Riverpod StateNotifier — 상태 직접 변이(mutation) 금지

```dart
// ❌ AI가 자주 쓰는 잘못된 패턴 (state를 직접 mutation → rebuild 안 됨)
state.someList.add(item);

// ✅ 올바른 패턴 (새 객체로 교체해야 rebuild 트리거)
state = state.copyWith(someList: [...state.someList, item]);
```
**왜**: Riverpod는 state 객체 **참조 자체가 바뀌어야** 위젯 rebuild가 발생한다.

### 5.2 Hive — "권장 방식(TypeAdapter 자동생성)"을 그대로 따르지 않기

AI는 Hive 사용 시 `@HiveType`/`@HiveField`/`build_runner`를 권유합니다.
v-view는 **수동 Map 직렬화**를 선택했습니다.

```dart
// AI 추천 — build_runner 설정 시간 + source_gen 버전 충돌 리스크
@HiveType(typeId: 0)
class SessionReport extends HiveObject { ... }

// v-view 선택 — 설정 없이 즉시 동작
box.put(id, {'gazeRate': metrics.gazeRate, ...});
```
**학습**: 도구의 "권장 방식"이 항상 최적은 아니다. 일정·학습 목표에 맞게 직접 선택한다.

### 5.3 아키텍처 일관성은 사람이 검토 — 실제 발견 사례

"동작한다 ≠ 올바르다." AI 생성물에서 실제로 잡아낸 레이어 위반:
- `GazeAnalyzer.computeMetrics()`가 Data 레이어에 있던 것 → Domain으로 이동
- `GazeFrame` 클래스가 Data 파일에 정의 → Domain 엔티티로 분리
- `gazeAnalyzerProvider`가 Data 객체를 반환하며 State 파일에 위치 → 책임 재배치

**교훈**: 기능 검증과 별개로 **레이어 경계 위반**은 매 생성물마다 사람이 확인한다.

---

## 6. LLM의 구조적 한계와 대응 (Knowledge Management)

| LLM(AI)의 한계 | 대응 방법 (암묵지) |
|---|---|
| 실기기 동작 보장 불가 | 에뮬레이터 → 실기기 순서로 검증, 스크린샷 육안 확인 |
| 카메라/센서 연동 오류 빈번 | 기기별 권한·해상도를 직접 점검 |
| API 비용 감각 없음 | 세션당 호출 횟수·꼬리질문 depth 상한을 직접 설계 |
| 개인정보 정책 판단 불가 | "원본 영상 저장 금지"를 CLAUDE.md에 명시적 규칙화 |
| 이미 구현된 코드 모름 → 중복 생성 | 작업 전 "이 기능 이미 있는지 확인해줘" 습관화 |
| 한국 법규/용어 부정확 | 법률·정책 문구는 사람이 직접 검토 |

### Claude Code(개발 도구) 특화 활용 기법

- **CLAUDE.md 자동 로드**: 루트 `CLAUDE.md`는 매 세션 자동으로 컨텍스트에 포함 →
  프로젝트 규칙·레이어 구조·금지사항을 한 번만 적어두면 반복 설명 불필요
- **병렬 파일 읽기**: "이 3개 파일을 보고 아키텍처 일관성을 검토해줘" → 동시 읽기·비교
- **메모리 시스템**: 대화 간 기억 유지 → "커밋은 요청할 때만" 같은 지시가 세션 넘어 유지
- **오류 메시지 통째 붙여넣기**: 파일명·줄번호·스택을 모두 참조해 정확히 수정

---

> **운영 원칙**: 이 LLM Wiki는 살아있는 문서다. 새로운 시행착오(Troubleshooting)와
> 성능 최적화(Performance Optimization) 경험은 그때그때 누적해 **암묵지를 형식지로 전환**한다.
>
> 관련 문서: [AGENTS.md](AGENTS.md) · [CLAUDE.md](CLAUDE.md) · [README.md](README.md)
> 작성·통합: 손정협 (구 `LLM-WIKI.md` 통합본)
