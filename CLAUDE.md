# BanGiDa - 반려동물 기록 다이어리

## 프로젝트 개요
반려동물 생활 기록 및 추억 다이어리 iOS 앱. Realm 기반 메모 CRUD, 카테고리 필터, 알람, 백업/복구 지원.

## 기술 스택
- Swift, UIKit (레거시) + SwiftUI (Story 모듈)
- MVVM + Clean Architecture
- Realm, SnapKit, Firebase (Analytics/Crashlytics/FCM), FSCalendar, Zip
- DI: DIContainer + @Injected propertyWrapper

## 아키텍처 (Clean Architecture)
```
Domain/   → 순수 Swift (Model, Repository protocol, UseCase)
Data/     → Realm, Firebase, LocalStorage, Notification 구현체
Presentation/ → ViewModel + View (UIKit/SwiftUI)
Application/  → AppDelegate, SceneDelegate, DI
```
- Domain 계층은 외부 프레임워크 import 금지
- Story 모듈은 Clean Architecture 적용 완료, UIKit 레거시 모듈 리팩토링 진행 중

## Git 브랜치
- `main`: 출시 버전
- `develop`: 기본 브랜치 (PR 대상)
- `feature/clean-architecture-refactoring`: 현재 작업 브랜치

## 빌드
```bash
open BanGiDa.xcworkspace  # xcworkspace로 열기
```

## 주요 규칙
- Presentation 계층에서 Realm/Firebase 직접 import 금지
- Repository는 반드시 프로토콜 기반, DIContainer를 통해 주입
- 바인딩은 Combine 기반으로 통일 (레거시 Custom Observable 점진적 제거)
