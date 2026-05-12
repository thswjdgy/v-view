# 개발 환경 설정 가이드

---

## 사전 요구사항

| 도구 | 최소 버전 | 확인 명령 |
|---|---|---|
| Flutter SDK | 3.38.x | `flutter --version` |
| Dart | 3.10.x | `dart --version` |
| Android Studio | Hedgehog 이상 | — |
| Android SDK | API 21 이상 | — |
| Git | 2.x | `git --version` |

---

## 1. 저장소 클론

```bash
git clone https://github.com/thswjdguq/v-view.git
cd v-view/v_view
```

---

## 2. Flutter SDK 설치 (미설치 시)

### Windows
```powershell
# winget으로 설치
winget install Google.Flutter

# 또는 공식 사이트에서 ZIP 다운로드
# https://flutter.dev/docs/get-started/install/windows
```

### 환경 변수 확인
```powershell
flutter doctor
```
모든 항목이 ✓ 표시되어야 한다.

---

## 3. 의존성 설치

```bash
cd v-view/v_view
flutter pub get
```

---

## 4. 환경 변수 설정

```bash
# .env.example을 복사
cp .env.example .env
```

`.env` 파일을 열고 API 키 입력:
```
ANTHROPIC_API_KEY=sk-ant-api03-xxxxxxxxxxxx
```

> **주의**: `.env`는 `.gitignore`에 포함되어 있어 커밋되지 않는다.
> API 키는 절대 코드에 직접 입력하지 않는다.

Claude API 키 발급: https://console.anthropic.com/

---

## 5. Android 설정

### 5.1 AndroidManifest.xml 권한 추가

`v_view/android/app/src/main/AndroidManifest.xml`에 아래 추가:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```

### 5.2 ML Kit 설정

`v_view/android/app/build.gradle.kts` 확인:
```kotlin
android {
    compileSdk = 34
    defaultConfig {
        minSdk = 21  // ML Kit 최소 요구사항
    }
}
```

---

## 6. iOS 설정 (macOS 필요)

### 6.1 Info.plist 권한 추가

`v_view/ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>시선 분석을 위해 카메라가 필요합니다. 원본 영상은 저장되지 않습니다.</string>
```

### 6.2 CocoaPods 설치

```bash
cd v_view/ios
pod install
```

---

## 7. 실행

### Android 에뮬레이터 / 실기기

```bash
# 연결된 디바이스 확인
flutter devices

# 실행
flutter run

# 특정 디바이스 지정
flutter run -d <device-id>
```

### 디버그 / 릴리즈 모드

```bash
flutter run --debug    # 기본값, 핫 리로드 지원
flutter run --profile  # 성능 분석
flutter run --release  # 릴리즈 빌드
```

---

## 8. IDE 설정 (VS Code 권장)

필수 확장:
- Flutter (Dart Code)
- Dart (Dart Code)
- Flutter Riverpod Snippets

설정 파일 (`.vscode/settings.json`):
```json
{
  "editor.formatOnSave": true,
  "dart.flutterSdkPath": "C:/flutter",
  "[dart]": {
    "editor.defaultFormatter": "Dart-Code.dart-code"
  }
}
```

---

## 9. 트러블슈팅

| 증상 | 해결책 |
|---|---|
| `flutter pub get` 실패 | `flutter clean` 후 재시도 |
| ML Kit 빌드 오류 | `minSdk = 21` 확인 |
| `.env` 로드 실패 | `pubspec.yaml`의 `assets:` 섹션에 `.env` 포함 확인 |
| 카메라 미표시 | 실기기 사용 (에뮬레이터 카메라 지원 제한) |
| API 호출 실패 | `.env`의 API 키, 네트워크 연결 확인 |
