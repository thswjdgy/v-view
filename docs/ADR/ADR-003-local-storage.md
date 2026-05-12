# ADR-003: 로컬 저장소로 Hive 선택

## 상태
Accepted — 2026-05-10

## 컨텍스트

면접 세션 기록, 리포트, 사용자 입력값을 기기 로컬에 영구 저장해야 한다.
원본 카메라 영상은 저장하지 않는다는 개인정보 보호 원칙이 있다.

후보:
- Hive
- SQLite (sqflite)
- shared_preferences
- Isar

## 결정

**Hive (hive_flutter 1.1.0)를 선택한다.**

## 이유

1. **Flutter 친화적**: Flutter 전용으로 설계, 설정이 단순
2. **빠른 키-값 저장**: 세션 리포트처럼 구조화된 Map을 그대로 저장 가능
3. **암호화 지원**: `HiveAesCipher`로 민감 데이터 암호화 가능 (v2 고려)
4. **경량**: 앱 크기 증가 최소화
5. **코드 생성 불필요**: Map 기반 수동 직렬화로 `hive_generator` 의존성 제거
   (riverpod_generator와 source_gen 버전 충돌 회피)

## 결과

- 4개 Box: `sessions`, `reports`, `history`, `session_input`
- 직렬화는 수동 `_toMap()` / `_fromMap()` 구현
- 원본 카메라 영상은 어떤 Box에도 저장하지 않음

## 대안 검토

| 대안 | 기각 이유 |
|---|---|
| sqflite | 스키마·마이그레이션 관리 부담, 1인 프로젝트 오버헤드 |
| shared_preferences | 단순 키-값만 지원, 리스트·중첩 구조 저장 불편 |
| Isar | hive_generator와 동일한 source_gen 충돌 가능성, 러닝커브 |
