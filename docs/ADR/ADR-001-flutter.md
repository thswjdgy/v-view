# ADR-001: 크로스플랫폼 프레임워크로 Flutter 선택

## 상태
Accepted — 2026-05-10

## 컨텍스트

v-view는 Android와 iOS 모두를 타겟으로 하는 모바일 앱이다.
개발 리소스가 1인이므로 두 플랫폼을 단일 코드베이스로 개발할 수 있는 크로스플랫폼 프레임워크가 필요했다.

후보:
- Flutter (Dart)
- React Native (JavaScript/TypeScript)
- Native Android + iOS 별도 개발

## 결정

**Flutter를 선택한다.**

## 이유

1. **ML Kit 통합**: `google_mlkit_face_detection` 플러그인이 Flutter에서 안정적으로 지원됨
2. **카메라 플러그인**: `camera` 패키지의 성숙도와 문서화 수준이 우수
3. **성능**: Dart AOT 컴파일로 시선 분석 같은 실시간 처리에 적합
4. **UI 일관성**: 자체 렌더링 엔진으로 Android/iOS 동일한 화면 보장
5. **생태계**: Riverpod, Hive 등 필요한 라이브러리가 모두 Flutter 우선 지원

## 결과

- Dart 언어 학습이 필요하나, AI Agent(Claude Code)가 코드 생성을 지원
- 네이티브 기능(카메라, 권한) 사용 시 플랫폼별 설정 필요 (AndroidManifest, Info.plist)
- iOS 빌드는 macOS 환경 필요 (CI/CD에서 고려)

## 대안 검토

| 대안 | 기각 이유 |
|---|---|
| React Native | ML Kit Flutter 플러그인 대비 불안정, JS Bridge 오버헤드 |
| Native (Android + iOS) | 1인 개발에서 두 코드베이스 유지 비용 과다 |
