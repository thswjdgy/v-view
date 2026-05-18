# v-view 개발 환경 설정 가이드

> 이 문서만 따라하면 **5분 안에** 앱을 실행할 수 있다.

---

## 1. 필요한 도구 버전

| 도구 | 최소 버전 | 버전 확인 명령 |
|---|---|---|
| Flutter SDK | 3.x stable | `flutter --version` |
| Dart | 3.x | `dart --version` |
| JDK | 17 | `java -version` |
| Android SDK | API 21 (Android 5.0) | Android Studio → SDK Manager |
| Git | 2.x | `git --version` |
| Xcode (macOS만) | 15 이상 | `xcode-select --version` |

모든 도구가 설치됐는지 한 번에 확인:

```bash
flutter doctor
```

모든 항목이 `[✓]`이어야 한다. `[!]` 항목이 있으면 아래 FAQ를 먼저 확인할 것.

---

## 2. 저장소 클론

```bash
git clone https://github.com/thswjdguq/v-view.git
cd v-view/v_view
```

---

## 3. 의존성 설치

```bash
flutter pub get
```

성공 시 `Got dependencies!` 메시지가 출력된다.

---

## 4. .env 설정 (API 키)

> **중요**: `.env`는 `.gitignore`에 포함되어 있어 절대 커밋되지 않는다.
> API 키를 코드에 직접 입력하는 방법은 사용하지 않는다.

### 4-1. .env 파일 생성

**macOS / Linux**
```bash
cp .env.example .env
```

**Windows (PowerShell)**
```powershell
Copy-Item .env.example .env
```

### 4-2. .env 파일 내용

`.env.example`의 내용:
```
ANTHROPIC_API_KEY=your_api_key_here
```

`.env`를 열고 `your_api_key_here` 부분을 실제 키로 교체한다:
```
ANTHROPIC_API_KEY=sk-ant-api03-...
```

### 4-3. API 키 발급 방법

1. [console.anthropic.com](https://console.anthropic.com/) 접속
2. 로그인 → **API Keys** 메뉴
3. **Create Key** → 키 복사
4. `.env`에 붙여넣기

---

## 5. 앱 실행

### 연결된 디바이스 확인

```bash
flutter devices
```

### 실행

```bash
# 기본 실행 (디버그 모드, 핫 리로드 지원)
flutter run

# 디바이스가 여러 개일 때 지정
flutter run -d <device-id>
```

**플랫폼별 실행 방법:**

| 플랫폼 | 방법 |
|---|---|
| Android 에뮬레이터 | Android Studio에서 AVD 실행 후 `flutter run` |
| Android 실기기 | USB 연결 + USB 디버깅 활성화 후 `flutter run` |
| iOS 시뮬레이터 (macOS만) | `open -a Simulator` 후 `flutter run` |
| iOS 실기기 (macOS만) | Xcode에서 서명 설정 후 `flutter run` |

> **카메라 기능**: 에뮬레이터/시뮬레이터에서는 카메라가 제한된다.
> 시선 분석을 테스트하려면 실기기를 사용할 것.

---

## 6. 자주 발생하는 오류 FAQ

---

### FAQ 1 — Android SDK 경로를 찾을 수 없다

**오류 메시지**
```
Android SDK not found. Define location with an ANDROID_SDK_ROOT environment variable.
```

**원인**: `flutter doctor`가 Android SDK 위치를 인식하지 못함

**해결**

**Windows (PowerShell)**
```powershell
# 환경 변수 설정 (Android Studio 기본 경로)
[System.Environment]::SetEnvironmentVariable(
  "ANDROID_SDK_ROOT",
  "$env:LOCALAPPDATA\Android\Sdk",
  "User"
)
# 터미널 재시작 후 확인
flutter doctor --android-licenses
```

**macOS / Linux**
```bash
# .zshrc 또는 .bashrc에 추가
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk   # macOS
export ANDROID_SDK_ROOT=$HOME/Android/Sdk            # Linux
export PATH=$PATH:$ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/platform-tools

source ~/.zshrc   # 적용
flutter doctor --android-licenses
```

---

### FAQ 2 — iOS 시뮬레이터가 뜨지 않는다 (macOS)

**오류 메시지**
```
No supported devices found with name or id matching 'iPhone'.
```

**원인**: Xcode 설치 또는 시뮬레이터 런타임 누락

**해결**
```bash
# Xcode Command Line Tools 설치
xcode-select --install

# 시뮬레이터 직접 실행
open -a Simulator

# 런타임이 없으면 Xcode → Settings → Platforms에서 iOS 런타임 추가

# 이후 실행
flutter run
```

---

### FAQ 3 — 카메라 권한 오류로 앱이 멈춘다

**증상**: 앱 실행 후 카메라 화면에서 검은 화면 또는 즉시 종료

**Android 해결**

`android/app/src/main/AndroidManifest.xml`에 아래 두 줄이 있는지 확인:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```

없으면 `<manifest>` 태그 바로 아래에 추가한다.

**iOS 해결**

`ios/Runner/Info.plist`에 아래가 있는지 확인:
```xml
<key>NSCameraUsageDescription</key>
<string>시선 분석을 위해 카메라가 필요합니다. 원본 영상은 저장되지 않습니다.</string>
```

없으면 `<dict>` 태그 안에 추가한다.

**공통**: 이미 권한을 거부했다면 기기 설정 → 앱 → v-view → 카메라 권한 허용

---

### FAQ 4 — API 키 누락으로 질문이 생성되지 않는다

**오류 메시지** (디버그 콘솔)
```
DioException: 401 Unauthorized
또는
flutter_dotenv: ANTHROPIC_API_KEY is not set
```

**체크리스트** (순서대로 확인)

1. `v_view/` 안에 `.env` 파일이 존재하는지 확인
   ```bash
   # macOS/Linux
   ls -a v_view/ | grep .env
   # Windows
   Get-ChildItem -Hidden v_view\ | Where-Object Name -like ".env*"
   ```

2. `.env` 파일 안에 키가 올바르게 입력됐는지 확인 (앞뒤 공백·따옴표 없어야 함)
   ```
   ANTHROPIC_API_KEY=sk-ant-api03-...   ← 올바름
   ANTHROPIC_API_KEY="sk-ant-api03-..." ← 잘못됨 (따옴표 제거)
   ANTHROPIC_API_KEY= sk-ant-...        ← 잘못됨 (앞 공백 제거)
   ```

3. `pubspec.yaml`의 `flutter.assets`에 `.env`가 포함됐는지 확인
   ```yaml
   flutter:
     assets:
       - .env
   ```

4. 위 3가지 모두 정상이면 `flutter clean && flutter pub get && flutter run`

---

### FAQ 5 — 빌드 실패 (Build failed)

**증상 A — Gradle 빌드 실패 (Android)**
```
FAILURE: Build failed with an exception.
Execution failed for task ':app:compileDebugKotlin'.
```

**해결**
```bash
cd android
./gradlew clean        # macOS/Linux
gradlew.bat clean      # Windows
cd ..
flutter run
```

그래도 실패하면:
```bash
flutter clean
flutter pub get
flutter run
```

**증상 B — CocoaPods 오류 (iOS / macOS)**
```
[!] CocoaPods could not find compatible versions for pod "GoogleMLKit/FaceDetection"
```

**해결**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter run
```

**증상 C — minSdkVersion 오류 (Android)**
```
uses-sdk:minSdkVersion 16 cannot be smaller than version 21 declared in library
```

**해결**: `android/app/build.gradle` (또는 `build.gradle.kts`)에서 확인:
```kotlin
defaultConfig {
    minSdk = 21   // 이 값이 21 이상이어야 함
}
```
