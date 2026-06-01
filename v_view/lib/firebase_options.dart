// firebase_options.dart — helpflow-760d1 Firebase 프로젝트 설정
// ⚠️ 이 파일은 .gitignore에 등록하세요. 민감한 API 키를 포함합니다.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          '이 플랫폼은 Firebase를 지원하지 않습니다: $defaultTargetPlatform',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyANaD8ojGu4mEEEAU9GEK9Mx_5EbBpYgMM',
    appId: '1:702947365573:web:5acc5e57fe28b2c5bc56ac',
    messagingSenderId: '702947365573',
    projectId: 'helpflow-760d1',
    authDomain: 'helpflow-760d1.firebaseapp.com',
    storageBucket: 'helpflow-760d1.firebasestorage.app',
    measurementId: 'G-PBZNMBM7YB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC_TiXqZ7VjW6RQXlyi-z6mP8SC8Xfwfaw',
    appId: '1:702947365573:android:3ec95f1f49f72e94bc56ac',
    messagingSenderId: '702947365573',
    projectId: 'helpflow-760d1',
    storageBucket: 'helpflow-760d1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC_TiXqZ7VjW6RQXlyi-z6mP8SC8Xfwfaw',
    appId: '1:702947365573:android:3ec95f1f49f72e94bc56ac',
    messagingSenderId: '702947365573',
    projectId: 'helpflow-760d1',
    storageBucket: 'helpflow-760d1.firebasestorage.app',
  );
}
