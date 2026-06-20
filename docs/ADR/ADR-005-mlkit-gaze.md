# ADR-005: 시선 분석 라이브러리로 ML Kit 선택

## 상태
Accepted — 2026-05-10

## 컨텍스트

v-view의 핵심 기능은 면접 중 카메라 프레임에서 사용자의 얼굴·눈 위치를
실시간으로 감지해 화면 응시 여부를 측정하는 것이다.
온디바이스 처리(개인정보 보호)와 7주 일정 내 Flutter 연동 가능성이 선택 기준이었다.

후보:
- ML Kit Face Detection (`google_mlkit_face_detection`)
- MediaPipe (Google)
- 자체 비전 모델 (TensorFlow Lite 직접 통합)

## 결정

**ML Kit Face Detection (`google_mlkit_face_detection` 0.11)을 선택한다.**

## 이유

1. **온디바이스 처리**: 분석 모델이 앱 내부에 내장 → 원본 카메라 영상을 서버로 전송하지 않아 개인정보 보호 원칙 충족
2. **Flutter 공식 지원**: pub.dev 공식 패키지로 Android/iOS 양쪽 안정적 동작
3. **오프라인 동작**: 인터넷 연결 없이도 시선 분석 가능
4. **연동 단순성**: 7주 일정 내 추가 네이티브 설정 부담이 작음
5. **교체 용이성**: Data 레이어(`data/remote/gaze/`)에 격리되어 향후 교체 시 영향 최소

## 결과

- `lib/data/remote/gaze/gaze_analyzer.dart` 에서 ML Kit `FaceDetector` 사용
- 안드로이드 카메라의 YUV_420_888 → NV21 변환 후 `InputImage` 생성
  (`lib/data/remote/gaze/camera_frame_converter.dart`, row stride/pixel stride 반영)
- 응시율 공식: `(응시 프레임 수 / 전체 측정 프레임 수) × 100`
- 시선 분산 카운트: **연속 1초 이상** 유지 시 1회 (흔들림 노이즈 제외)
- 얼굴 미검출·측정 품질 저하 시 `'측정 불가/참고용'` 표시
- 원본 카메라 영상·오디오는 로컬·서버 어디에도 저장하지 않음

## 대안 검토

| 대안 | 장점 | 기각 이유 |
|---|---|---|
| **MediaPipe** | 시선 추정 정확도 높음 | Flutter 연동 시 Android/iOS 네이티브 설정을 각각 구성해야 해 7주 일정 리스크가 큼 |
| 자체 비전 모델 (TFLite) | 완전한 제어·커스터마이징 | 모델 학습·튜닝 비용 과다, 1인·7주 일정에 비현실적 |

> 향후 정확도 개선이 필요하면 ML Kit → MediaPipe 교체가 가능하며,
> 비전 로직이 Data 레이어에 격리되어 있어 `data/remote/gaze/`만 교체하면 된다.
>
> AI Agent(Claude Code) 초안 생성 / 손정협 직접 검토 확인
