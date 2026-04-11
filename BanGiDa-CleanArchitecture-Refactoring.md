# BanGiDa Clean Architecture 리팩토링 가이드

## 1. 개요

### 1.1 프로젝트 소개
BanGiDa는 반려동물 다이어리 iOS 앱으로, 메모/알림/건강기록 관리 및 "스토리" 사진 공유 기능을 제공한다.

### 1.2 현재 아키텍처 상태
현재 MVVM + 부분적 Clean Architecture 구조를 사용하고 있다.

- **Story 모듈(SwiftUI)**: Clean Architecture를 잘 따르고 있음 (프로토콜 기반 DI, UseCase 분리, async/await)
- **레거시 UIKit 모듈(Home, Write, Search, Alarm, Setting)**: Presentation 계층에서 Realm을 직접 참조하고, 싱글턴 패턴으로 데이터에 접근하며, CommonViewModel 상속 체인에 묶여 있음

### 1.3 핵심 문제점

| # | 문제 | 영향 범위 |
|---|------|-----------|
| 1 | UIKit ViewModel들이 `RealmSwift`를 직접 import하고 `UserDiaryRepository.shared` 싱글턴 호출 | Home, Write, Alarm, Search, Setting VM |
| 2 | `Results<Diary>` (Realm 타입)이 Presentation 계층에 노출 | CommonViewModel 및 모든 서브클래스 |
| 3 | 로컬 다이어리 데이터에 대한 Repository 프로토콜/UseCase 부재 | 전체 로컬 데이터 흐름 |
| 4 | `CommonViewModel` 상속 체인이 모든 ViewModel에 Realm 의존성 강제 | 5개 ViewModel |
| 5 | 바인딩 패턴 3가지 혼용 (Custom Observable, Combine CurrentValueSubject, @Published) | 전체 Presentation |
| 6 | HomeViewModel에서 UITableViewCell 생성, 네비게이션 직접 호출 등 UI 로직 포함 | HomeViewModel |

### 1.4 리팩토링 목표
- 모든 계층 간 의존성을 프로토콜 기반으로 전환
- Presentation 계층에서 Realm/Firebase 등 프레임워크 import 제거
- Story 모듈 수준의 Clean Architecture를 전체 앱에 적용
- Tuist 도입은 이번 리팩토링 범위에서 제외 (아키텍처 안정화 후 별도 진행)

---

## 2. 최종 목표 폴더 구조

```
BanGiDa/
├── Application/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── DI/
│       ├── DIContainer.swift
│       └── Injected.swift
│
├── Domain/                              ← NEW (프레임워크 import 없음)
│   ├── Model/
│   │   ├── DiaryEntry.swift             (순수 struct 도메인 모델)
│   │   ├── DiaryType.swift              (순수 enum)
│   │   ├── AlarmRepeatRule.swift         (순수 enum)
│   │   ├── Story.swift                  (기존 이동)
│   │   └── UserPreferences.swift        (값 객체)
│   ├── Repository/
│   │   ├── DiaryRepository.swift         (protocol)
│   │   ├── ImageRepository.swift         (protocol)
│   │   ├── UserPreferencesRepository.swift (protocol)
│   │   ├── NotificationRepository.swift  (protocol)
│   │   ├── BackupRepository.swift        (protocol)
│   │   ├── UserRepository.swift          (기존 이동)
│   │   └── StoryRepository.swift         (기존 이동)
│   └── UseCase/
│       ├── Diary/    (Fetch, Save, Update, Delete, Search)
│       ├── Alarm/    (SaveAlarm, ScheduleNotification, RemoveNotification, RestoreNotifications)
│       ├── Image/    (Load, Save)
│       ├── Backup/   (Create, Restore, Reset)
│       ├── Story/    (기존 이동: Fetch, Write, ToggleLike, Report)
│       └── User/     (기존 이동: CreateAuth, CheckRegistration, UpdateNickname)
│
├── Data/                                ← NEW
│   ├── Realm/
│   │   ├── RealmDiary.swift             (Diary.swift 이동, 클래스명 유지)
│   │   ├── RealmDiaryRepository.swift   (DiaryRepository 구현체)
│   │   └── RealmDiary+Mapping.swift     (도메인 ↔ Realm 변환)
│   ├── Firebase/
│   │   ├── UserRepositoryImpl.swift     (기존 이동)
│   │   └── StoryRepositoryImpl.swift    (기존 이동)
│   ├── LocalStorage/
│   │   ├── DocumentManager.swift        (기존 이동)
│   │   ├── ImageRepositoryImpl.swift    (DocumentManager 래핑)
│   │   └── UserPreferencesRepositoryImpl.swift (UserDefaults 래핑)
│   ├── Notification/
│   │   └── NotificationRepositoryImpl.swift (CommonViewModel에서 추출)
│   └── Backup/
│       └── BackupRepositoryImpl.swift   (UserDiaryRepository에서 추출)
│
├── Presentation/                        ← Realm import 완전 제거
│   ├── Common/
│   │   ├── Base/ (BaseViewController, BaseView, BaseTableViewCell)
│   │   ├── Style/ (Cells, Views)
│   │   └── Util/ (MainTabViewController, CachedAsyncImage, Category)
│   ├── WalkThrough/
│   ├── Home/
│   │   ├── Model/DiaryDisplayItem.swift ← NEW (Presentation 전용 모델)
│   │   ├── ViewModel/HomeViewModel.swift
│   │   └── View/
│   ├── Write/
│   ├── Search/
│   ├── Alarm/
│   ├── Setting/
│   └── Story/                           (기존 유지, 이미 Clean)
│
├── Core/
│   ├── Errors/ (UserError, WriteStoryError)
│   └── Extensions/ (기존 Extension/ 이동)
│
├── Protocol/ (ReusableProtocol)
└── Resource/ (FontList, Assets)
```

---

## 3. 도메인 모델 설계

### 3.1 DiaryEntry (Realm `Diary`를 대체하는 도메인 모델)

```swift
// Domain/Model/DiaryEntry.swift
struct DiaryEntry: Identifiable {
    let id: String              // Realm ObjectId.stringValue에서 매핑
    var type: DiaryType
    var date: Date
    var registeredDate: Date
    var animalName: String
    var content: String
    var photoFileName: String?
    var alarmTitle: String?
    var repeatRule: AlarmRepeat
}
```

### 3.2 UserPreferences (UserDefaults 값 객체)

```swift
// Domain/Model/UserPreferences.swift
struct UserPreferences {
    var isFirstLaunchCompleted: Bool
    var petName: String?
    var storyAgreement: Bool
}
```

### 3.3 기존 타입 재활용

`DiaryType`과 `AlarmRepeat`은 기존 `Diary.swift`에 정의된 enum을 그대로 사용한다. 다만 `AlarmRepeat`은 현재 `PersistableEnum` (Realm 프로토콜)을 채택하고 있으므로, Phase 9에서 순수 enum과 Realm 확장을 분리할 예정이다.

---

## 4. 새로 필요한 Repository 프로토콜

### 4.1 DiaryRepository

```swift
// Domain/Repository/DiaryRepository.swift
public protocol DiaryRepository {
    func fetchAll() -> [DiaryEntry]
    func fetchByDate(_ date: Date) -> [DiaryEntry]
    func fetchByType(_ type: DiaryType) -> [DiaryEntry]
    func fetchByDateAndType(date: Date, type: DiaryType) -> [DiaryEntry]
    func save(_ entry: DiaryEntry) throws
    func update(_ entry: DiaryEntry) throws
    func delete(_ entry: DiaryEntry) throws
    func deleteAll() throws
    func findByID(_ id: String) -> DiaryEntry?
}
```

### 4.2 ImageRepository

```swift
// Domain/Repository/ImageRepository.swift
public protocol ImageRepository {
    func loadImageData(fileName: String) -> Data?
    func saveImageData(fileName: String, data: Data)
    func removeImage(fileName: String)
}
```

### 4.3 UserPreferencesRepository

```swift
// Domain/Repository/UserPreferencesRepository.swift
public protocol UserPreferencesRepository {
    func load() -> UserPreferences
    func save(_ preferences: UserPreferences)
    func getPetName() -> String?
    func setPetName(_ name: String)
    func isFirstLaunchCompleted() -> Bool
    func setFirstLaunchCompleted()
    func getStoryAgreement() -> Bool
    func setStoryAgreement(_ agreed: Bool)
}
```

### 4.4 NotificationRepository

```swift
// Domain/Repository/NotificationRepository.swift
public protocol NotificationRepository {
    func requestAuthorization() async -> Bool
    func schedule(title: String, body: String, date: Date, index: Int, repeatRule: AlarmRepeat)
    func remove(title: String, body: String, date: Date, index: Int, repeatRule: AlarmRepeat)
    func removeAllDelivered()
}
```

### 4.5 BackupRepository

```swift
// Domain/Repository/BackupRepository.swift
public protocol BackupRepository {
    func createBackup() throws -> URL
    func restoreFromFile(_ fileURL: URL) throws
}
```

---

## 5. 새로 필요한 UseCase 목록

| UseCase | 의존성 | 설명 |
|---------|--------|------|
| `FetchDiariesByDateUseCase` | DiaryRepository | 날짜별 다이어리 조회 (타입별 그룹핑) |
| `SaveDiaryUseCase` | DiaryRepository, ImageRepository | 새 다이어리 저장 + 이미지 저장 |
| `UpdateDiaryUseCase` | DiaryRepository, ImageRepository | 기존 다이어리 수정 + 이미지 갱신 |
| `DeleteDiaryUseCase` | DiaryRepository, ImageRepository | 다이어리 삭제 + 이미지 삭제 |
| `SearchDiariesUseCase` | DiaryRepository | 타입별 다이어리 검색 |
| `SaveAlarmUseCase` | DiaryRepository, NotificationRepository | 알람 저장 + 알림 스케줄링 |
| `ScheduleNotificationUseCase` | NotificationRepository | 로컬 알림 스케줄링 |
| `RemoveNotificationUseCase` | NotificationRepository | 로컬 알림 제거 |
| `RestoreNotificationsUseCase` | DiaryRepository, NotificationRepository | 알림 복원 (백업 복원 후) |
| `LoadImageUseCase` | ImageRepository | 이미지 데이터 로드 |
| `SaveImageUseCase` | ImageRepository | 이미지 데이터 저장 |
| `CreateBackupUseCase` | BackupRepository | 백업 파일 생성 |
| `RestoreBackupUseCase` | BackupRepository | 백업 파일 복원 |
| `ResetDataUseCase` | DiaryRepository, NotificationRepository, UserPreferencesRepository | 전체 데이터 초기화 |

---

## 6. 단계별 리팩토링 계획

---

### Phase 0: 기반 코드 생성 (비파괴적)

> **목표**: 기존 코드 변경 없이 새 파일만 추가하여 Domain/Data 계층의 스켈레톤을 구축한다.

#### 생성할 파일

**Domain/Model/**
| 파일 | 설명 |
|------|------|
| `DiaryEntry.swift` | 순수 struct 도메인 모델 |
| `UserPreferences.swift` | UserDefaults 값 객체 |

**Domain/Repository/** (프로토콜만)
| 파일 | 설명 |
|------|------|
| `DiaryRepository.swift` | 로컬 다이어리 CRUD 인터페이스 |
| `ImageRepository.swift` | 이미지 파일 관리 인터페이스 |
| `UserPreferencesRepository.swift` | 사용자 설정 관리 인터페이스 |
| `NotificationRepository.swift` | 로컬 알림 관리 인터페이스 |
| `BackupRepository.swift` | 백업/복원 인터페이스 |

**Data 구현체**
| 파일 | 설명 |
|------|------|
| `Data/Realm/RealmDiary+Mapping.swift` | `Diary.toDomain()`, `Diary.fromDomain()` 변환 로직 |
| `Data/LocalStorage/ImageRepositoryImpl.swift` | DocumentManager를 래핑하여 ImageRepository 구현 |
| `Data/LocalStorage/UserPreferencesRepositoryImpl.swift` | UserDefaults를 래핑하여 UserPreferencesRepository 구현 |
| `Data/Notification/NotificationRepositoryImpl.swift` | CommonViewModel의 알림 로직을 추출하여 NotificationRepository 구현 |

#### 수정할 파일
없음. 모든 코드는 순수 추가이며, 기존 동작에 영향 없음.

#### 검증
- `Cmd+B` 빌드 성공
- 기존 모든 기능 정상 동작

---

### Phase 1: DiaryRepository 구현 + UseCase 생성

> **목표**: Repository 구현체와 UseCase를 생성하고, DI Container에 등록한다.

#### 생성할 파일

| 파일 | 설명 |
|------|------|
| `Data/Realm/RealmDiaryRepository.swift` | DiaryRepository 프로토콜의 Realm 구현체 |
| `Domain/UseCase/Diary/FetchDiariesByDateUseCase.swift` | 날짜별 다이어리 조회 |
| `Domain/UseCase/Diary/SaveDiaryUseCase.swift` | 다이어리 저장 |
| `Domain/UseCase/Diary/UpdateDiaryUseCase.swift` | 다이어리 수정 |
| `Domain/UseCase/Diary/DeleteDiaryUseCase.swift` | 다이어리 삭제 |
| `Domain/UseCase/Diary/SearchDiariesUseCase.swift` | 타입별 검색 |
| `Domain/UseCase/Image/LoadImageUseCase.swift` | 이미지 로드 |
| `Domain/UseCase/Image/SaveImageUseCase.swift` | 이미지 저장 |
| `Domain/UseCase/Alarm/SaveAlarmUseCase.swift` | 알람 저장 + 알림 스케줄링 |
| `Domain/UseCase/Alarm/ScheduleNotificationUseCase.swift` | 알림 스케줄링 |
| `Domain/UseCase/Alarm/RemoveNotificationUseCase.swift` | 알림 제거 |

#### 수정할 파일

| 파일 | 변경 내용 |
|------|-----------|
| `Application/DIContainer.swift` | DiaryRepository, ImageRepository, UserPreferencesRepository, NotificationRepository 등록 + 모든 새 UseCase 등록 |

#### 핵심 설계
RealmDiaryRepository는 내부에 Realm 인스턴스를 보유하며, `Results<Diary>`를 `[DiaryEntry]` 배열로 변환하여 반환한다. Realm 타입이 외부로 절대 노출되지 않는다.

#### 검증
- `Cmd+B` 빌드 성공
- DI Container resolve 정상 동작

---

### Phase 2: WriteViewModel + AlarmViewModel 마이그레이션

> **목표**: 가장 단순한 ViewModel부터 시작하여 Realm 직접 의존성을 제거한다.

#### WriteViewModel 변경 사항

| Before | After |
|--------|-------|
| `import RealmSwift` | 제거 |
| `var primaryKey: ObjectId?` | `var editingEntryID: String?` |
| `Diary(type:date:...)` 직접 생성 | `@Injected SaveDiaryUseCase` 호출 |
| `UserDiaryRepository.shared.write(task)` | `saveDiaryUseCase.execute(...)` |
| `UserDiaryRepository.shared.update(...)` | `@Injected UpdateDiaryUseCase` 호출 |
| `UserDiaryRepository.shared.documentManager.saveImageDataFromDocument(...)` | `@Injected SaveImageUseCase` 호출 |
| `UserDefaults.standard.string(forKey: UserDefaultsKey.name.rawValue)` | `@Injected UserPreferencesRepository` |

#### AlarmViewModel 변경 사항

| Before | After |
|--------|-------|
| `class AlarmViewModel: CommonViewModel` | `class AlarmViewModel` (독립 클래스) |
| `import RealmSwift` | 제거 |
| `var primaryKey: ObjectId?` | `var editingEntryID: String?` |
| `UserDiaryRepository.shared.write(task)` | `@Injected SaveAlarmUseCase` |
| `sendNotification(...)` | `@Injected ScheduleNotificationUseCase` |
| `Results<Diary>` 프로퍼티 | `[DiaryEntry]` 배열 |

#### 수정할 파일
- `Presentation/Main/Write/ViewModel/WriteViewModel.swift`
- `Presentation/Main/Alarm/ViewModel/AlarmViewModel.swift`

#### 검증
- Write 화면: 메모 생성, 수정, 이미지 첨부 정상 동작
- Alarm 화면: 알람 생성, 반복 설정, 알림 수신 정상 동작

---

### Phase 3: WalkThroughViewModel 마이그레이션

> **목표**: 초기 실행 플로우의 Realm 직접 참조를 제거한다.

#### 변경 사항

| Before | After |
|--------|-------|
| `class WalkthroughViewModel: CommonViewModel` | `class WalkthroughViewModel` (독립 클래스) |
| `UserDiaryRepository.shared.write(task)` | `@Injected SaveDiaryUseCase` |
| `UserDefaults.standard.string(forKey:)` | `@Injected UserPreferencesRepository` |
| `Diary(...)` 직접 생성 | UseCase를 통한 저장 |

#### 수정할 파일
- `Presentation/WalkTrough/ViewModel/WalkThroughViewModel.swift`

#### 검증
- 초기 실행 워크스루 플로우 (닉네임 설정, 첫 다이어리 생성) 정상 동작

---

### Phase 4: HomeViewModel 마이그레이션 (가장 복잡)

> **목표**: 가장 복잡한 ViewModel을 4개 서브스텝으로 분할하여 안전하게 리팩토링한다.

#### Step 4a — Presentation 모델 생성

```swift
// Presentation/Home/Model/DiaryDisplayItem.swift
struct DiaryDisplayItem {
    let id: String
    let dateText: String
    let content: String
    let alarmTitle: String?
    let imageData: Data?
    let type: DiaryType
}
```

ViewModel은 `DiaryEntry` → `DiaryDisplayItem`으로 변환하여 View에 전달한다.

#### Step 4b — ViewModel에서 UI 로직 제거

| 제거할 메서드 | 이동 위치 | 이유 |
|--------------|-----------|------|
| `cellForRowAt(tableView:indexPath:)` | HomeViewViewController | UITableViewCell 생성은 VC의 역할 |
| `enterEditMemo(ViewController:indexPath:)` | HomeViewViewController (delegate/closure) | 네비게이션은 VC의 역할 |
| `showDatePickerAlert()` | HomeViewViewController | UIAlertController 생성은 VC의 역할 |

#### Step 4c — Realm 의존성 제거

| Before | After |
|--------|-------|
| `class HomeViewModel: CommonViewModel` | `class HomeViewModel` (독립 클래스) |
| `Results<Diary>` 프로퍼티 6개 | `[DiaryEntry]` 배열 |
| `UserDiaryRepository.shared.filter(index:)` | `@Injected FetchDiariesByDateUseCase` |
| `UserDiaryRepository.shared.documentManager.loadImageFromDocument(...)` | `@Injected LoadImageUseCase` |

#### Step 4d — HomeViewViewController 정리

- `UserDiaryRepository.shared.fetchDate(date:)` 호출 제거
- 모든 데이터 접근을 ViewModel 경유로 변경
- `import RealmSwift` 제거

#### 수정할 파일
- `Presentation/Main/Home/ViewModel/HomeViewModel.swift` (대규모 리팩토링)
- `Presentation/Main/Home/View/HomeViewViewController.swift` (상당한 변경)

#### 검증
- 홈 화면 캘린더 날짜 선택 → 메모 목록 정상 표시
- 메모 탭 → 수정 화면 이동 정상
- 스와이프 삭제 정상
- 카테고리별 필터링 정상

---

### Phase 5: SearchViewModel 마이그레이션

> **목표**: 검색/필터 화면의 Realm 직접 참조를 제거한다.

#### 변경 사항

| Before | After |
|--------|-------|
| `class SearchViewModel: CommonViewModel` | `class SearchViewModel` (독립 클래스) |
| `Results<Diary>` 프로퍼티 | `[DiaryEntry]` 배열 |
| `UserDiaryRepository.shared.filter(index:)` | `@Injected SearchDiariesUseCase` |

#### SearchViewController 변경 사항

| Before | After |
|--------|-------|
| `UserDiaryRepository.shared.delete(task)` | ViewModel의 delete 메서드 호출 |
| `UserDiaryRepository.shared.documentManager.loadImageFromDocument(...)` | ViewModel 경유 이미지 로드 |

#### 수정할 파일
- `Presentation/Main/Search/ViewModel/SearchViewModel.swift`
- `Presentation/Main/Search/View/SearchViewController.swift`

#### 검증
- 카테고리별 검색/필터 정상 동작
- 스와이프 삭제 정상 동작

---

### Phase 6: SettingViewModel + 백업/복원 마이그레이션

> **목표**: 설정 화면과 백업/복원 기능의 데이터 계층 의존성을 제거한다.

#### 생성할 파일

| 파일 | 설명 |
|------|------|
| `Domain/UseCase/Backup/CreateBackupUseCase.swift` | 백업 파일 생성 |
| `Domain/UseCase/Backup/RestoreBackupUseCase.swift` | 백업 파일 복원 |
| `Domain/UseCase/Backup/ResetDataUseCase.swift` | 전체 데이터 초기화 |
| `Domain/UseCase/Alarm/RestoreNotificationsUseCase.swift` | 알림 복원 |
| `Data/Backup/BackupRepositoryImpl.swift` | BackupRepository 구현체 |

#### SettingViewModel 변경 사항

| Before | After |
|--------|-------|
| `class SettingViewModel: CommonViewModel` | `class SettingViewModel` (독립 클래스) |
| `UserDiaryRepository.shared.deleteAll()` | `@Injected ResetDataUseCase` |
| `inputDataIntoArray()` (부모 메서드) | `@Injected SearchDiariesUseCase` |
| 알림 복원 로직 | `@Injected RestoreNotificationsUseCase` |

#### SettingViewController 변경 사항

| Before | After |
|--------|-------|
| `private let repository = UserDiaryRepository.shared` | 제거 (ViewModel 경유) |
| `repository.saveEncodedDataToDocument()` | `@Injected CreateBackupUseCase` (ViewModel 경유) |
| `repository.restoreRealmForBackupFile()` | `@Injected RestoreBackupUseCase` (ViewModel 경유) |
| `repository.documentManager.saveImageDataFromDocument(...)` | `@Injected SaveImageUseCase` (ViewModel 경유) |

#### 수정할 파일
- `Presentation/Main/Setting/ViewModel/SettingViewModel.swift`
- `Presentation/Main/Setting/View/SettingViewController.swift`
- `Application/DIContainer.swift` (백업 UseCase 등록)

#### 검증
- 설정 화면 정상 표시
- 백업 생성 → zip 파일 정상 생성
- 백업 복원 → 데이터 정상 복원 + 알림 복원
- 데이터 초기화 정상 동작

---

### Phase 7: CommonViewModel + Observable 삭제

> **목표**: 모든 ViewModel 마이그레이션 완료 후, 레거시 기반 클래스를 삭제한다.

#### 전제조건
Phase 2~6 모두 완료 (모든 ViewModel이 CommonViewModel 상속을 제거한 상태)

#### 삭제할 파일

| 파일 | 이유 |
|------|------|
| `Presentation/Common/ViewModel/CommonViewModel.swift` | 모든 서브클래스가 독립 클래스로 전환 완료 |
| `Application/Utility/Observable.swift` | Custom Observable은 Combine @Published로 대체 |

#### 검증
```bash
# 프로젝트 전체에서 참조 0건 확인
grep -r "CommonViewModel" BanGiDa/ --include="*.swift"   # → 0건
grep -r "Observable<" BanGiDa/ --include="*.swift"        # → 0건
```

---

### Phase 8: 바인딩 패턴 통일

> **목표**: 모든 UIKit ViewModel의 바인딩 패턴을 Combine `@Published`로 통일한다.

#### 변환 규칙

| Before (CurrentValueSubject) | After (@Published) |
|------------------------------|-------------------|
| `let currentIndex = CurrentValueSubject<Int, Never>(0)` | `@Published var currentIndex: Int = 0` |
| `viewModel.currentIndex.value` | `viewModel.currentIndex` |
| `viewModel.currentIndex.value = 5` | `viewModel.currentIndex = 5` |
| `viewModel.currentIndex.sink { }` | `viewModel.$currentIndex.sink { }` |

#### 대상 ViewModel

| ViewModel | 현재 패턴 | 변환 대상 프로퍼티 |
|-----------|----------|-------------------|
| WriteViewModel | `CurrentValueSubject` | `currentIndex`, `dateText`, `diaryContent` |
| AlarmViewModel | `CurrentValueSubject` | `dateText`, `diaryContent` |
| SearchViewModel | `CurrentValueSubject` | `currentIndex` |

#### 수정할 파일
- 리팩토링된 모든 ViewModel
- 대응하는 모든 ViewController (sink 구독 코드 업데이트)

#### 검증
- 모든 화면에서 데이터 바인딩 정상 동작
- 메모리 누수 없음 (cancellables 정상 해제)

---

### Phase 9: 폴더 구조 재배치

> **목표**: 최종 폴더 구조에 맞게 기존 파일들을 이동한다.

#### 이동할 파일

| 현재 위치 | 이동 위치 |
|-----------|-----------|
| `UseCase/Interfactors/UserRepository.swift` | `Domain/Repository/UserRepository.swift` |
| `UseCase/Interfactors/StoryRepository.swift` | `Domain/Repository/StoryRepository.swift` |
| `UseCase/Story/*` | `Domain/UseCase/Story/` |
| `UseCase/User/*` | `Domain/UseCase/User/` |
| `DataBase/Story/StoryRepositoryImpl.swift` | `Data/Firebase/StoryRepositoryImpl.swift` |
| `DataBase/User/UserRepositoryImpl.swift` | `Data/Firebase/UserRepositoryImpl.swift` |
| `DataBase/DocumentManager.swift` | `Data/LocalStorage/DocumentManager.swift` |
| `DataBase/UserDefaultsKey.swift` | `Data/LocalStorage/UserDefaultsKey.swift` |
| `DataBase/Realm/Diary.swift` | `Data/Realm/RealmDiary.swift` (파일명만 변경) |
| `Presentation/Main/Story/Model/Story.swift` | `Domain/Model/Story.swift` |
| `Extension/*` | `Core/Extensions/` |

#### 주의사항
- **Xcode 프로젝트 Navigator에서 이동**하거나, `.pbxproj` 파일을 함께 업데이트해야 함
- **Realm 클래스명(`Diary`)은 절대 변경하지 않음** — 기존 사용자 DB 마이그레이션 이슈 방지
- Swift는 단일 타겟 내에서 import 경로가 없으므로, 파일 이동 자체는 코드 변경 없이 가능

#### 검증
- `Cmd+B` 빌드 성공
- 전체 기능 정상 동작

---

### Phase 10: 레거시 코드 삭제

> **목표**: 이전된 모든 기존 코드를 완전히 삭제한다.

#### 전제조건
```bash
# UserDiaryRepository.shared 참조 0건 확인
grep -r "UserDiaryRepository" BanGiDa/ --include="*.swift"   # → 0건
```

#### 삭제할 파일/폴더

| 대상 | 이유 |
|------|------|
| `DataBase/UserDiaryRepository.swift` | RealmDiaryRepository로 대체 |
| `DataBase/` 폴더 전체 | 모든 내용이 `Data/`로 이동 완료 |
| `UseCase/` 폴더 전체 | 모든 내용이 `Domain/UseCase/`로 이동 완료 |

#### 검증
- `Cmd+B` 빌드 성공
- 전체 기능 회귀 테스트
```bash
# 레거시 참조 0건 확인
grep -r "DataBase/" BanGiDa/ --include="*.swift"       # → 0건
grep -r "Interfactors" BanGiDa/ --include="*.swift"     # → 0건
```

---

## 7. Phase 의존성 관계도

```
Phase 0 (기반 코드 생성)
  │
  ▼
Phase 1 (Repository + UseCase + DI 등록)
  │
  ├──► Phase 2 (Write + Alarm VM) ──┐
  ├──► Phase 3 (WalkThrough VM)  ───┤
  ├──► Phase 4 (Home VM)         ───┤   ※ Phase 2~6은 병렬 가능
  ├──► Phase 5 (Search VM)       ───┤      권장 순서: 2→3→4→5→6
  └──► Phase 6 (Setting VM)     ───┘
                                    │
                                    ▼
                          Phase 7 (CommonViewModel 삭제)
                                    │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
              Phase 8          Phase 9          Phase 10
           (바인딩 통일)    (폴더 재배치)    (레거시 삭제)
```

---

## 8. 리스크 및 대응 전략

| # | 리스크 | 심각도 | 대응 전략 |
|---|--------|--------|-----------|
| 1 | HomeViewModel UI 로직 분리 시 기존 동작 깨짐 | 🔴 높음 | Phase 4를 4개 서브스텝(4a~4d)으로 분할, 각 스텝마다 빌드+수동 테스트 |
| 2 | `Results<Diary>` → `[DiaryEntry]` 전환 시 라이브 업데이트 손실 | 🟡 중간 | 현재 코드가 수동 `reloadData()` 사용 중이므로 동작 동일. 추후 Combine Publisher 확장 가능 |
| 3 | Realm `Diary` 클래스명 변경 시 기존 DB 마이그레이션 필요 | 🔴 높음 | **클래스명 절대 변경하지 않음**, 파일명만 변경 |
| 4 | 알림 identifier 포맷 변경 시 기존 알림 orphan | 🟡 중간 | NotificationRepositoryImpl에서 기존과 동일한 identifier 생성 로직 유지 + 레거시 identifier 호환 |
| 5 | SettingVC 백업/복원 플로우 복잡도 | 🟡 중간 | BackupRepositoryImpl로 캡슐화, 리팩토링 전 수동 테스트로 현재 동작 기록 |
| 6 | `@Injected` fatalError 가능성 | 🟢 낮음 | 모든 등록을 앱 시작 시 완료, Phase별로 DI 등록 누락 확인 |
| 7 | Xcode 프로젝트 파일 이동 시 참조 깨짐 | 🟡 중간 | Xcode Navigator에서 이동하거나, 스크립트로 `.pbxproj` 업데이트 |

---

## 9. 검증 체크리스트

### 매 Phase 완료 후

- [ ] `Cmd+B` 빌드 성공
- [ ] 해당 Phase에서 수정한 화면의 전체 플로우 수동 테스트
- [ ] 수정한 파일에서 `import RealmSwift` grep → 0건
- [ ] 수정한 파일에서 `UserDiaryRepository.shared` grep → 0건

### Phase 7 완료 후

- [ ] `CommonViewModel` 참조 프로젝트 전체 0건
- [ ] `Observable<` 참조 프로젝트 전체 0건

### Phase 10 완료 후 (최종 검증)

- [ ] `DataBase/` 폴더 참조 0건
- [ ] `UseCase/Interfactors` 참조 0건
- [ ] `import RealmSwift` 가 `Data/` 폴더 내부에만 존재
- [ ] `import FirebaseAuth`, `import FirebaseFirestore` 등이 `Data/` 폴더 내부에만 존재
- [ ] 전체 화면 회귀 테스트:
  - [ ] 워크스루 (첫 실행)
  - [ ] 홈 (캘린더, 메모 목록, 카테고리 필터)
  - [ ] 메모 작성/수정/삭제
  - [ ] 알람 생성/수정/반복 설정
  - [ ] 검색/필터
  - [ ] 스토리 (조회, 작성, 좋아요, 신고)
  - [ ] 설정 (프로필, 백업, 복원, 초기화)

---

## 10. 참조할 기존 패턴 (Story 모듈)

Story 모듈은 이미 Clean Architecture를 따르고 있으므로 **모든 리팩토링의 레퍼런스**로 사용한다.

| 패턴 | 참조 파일 | 핵심 포인트 |
|------|-----------|-------------|
| ViewModel | `Presentation/Main/Story/ViewModel/StoryViewModel.swift` | `@MainActor`, `@Published`, `@Injected`, `async/await` |
| UseCase | `UseCase/Story/FetchStoriesUseCase.swift` | 프로토콜 + Impl 분리, init 주입 |
| Repository Protocol | `UseCase/Interfactors/StoryRepository.swift` | 순수 프로토콜, `async throws` |
| Repository Impl | `DataBase/Story/StoryRepositoryImpl.swift` | Firebase 직접 접근, 도메인 모델 반환 |
| DI 등록 | `Application/DIContainer.swift` | Swinject container scope, resolver 패턴 |

---

## 11. 주요 수정 대상 파일 요약

| 파일 | 변경 규모 | Phase | 비고 |
|------|-----------|-------|------|
| `Application/DIContainer.swift` | 매 Phase마다 등록 추가 | 1~6 | 누적 변경 |
| `Presentation/Common/ViewModel/CommonViewModel.swift` | 삭제 | 7 | 전제: 모든 VM 마이그레이션 완료 |
| `Application/Utility/Observable.swift` | 삭제 | 7 | @Published로 대체 |
| `Presentation/Main/Home/ViewModel/HomeViewModel.swift` | 대규모 리팩토링 | 4 | 4개 서브스텝 |
| `Presentation/Main/Home/View/HomeViewViewController.swift` | 상당한 변경 | 4 | UI 로직 수용 |
| `Presentation/Main/Write/ViewModel/WriteViewModel.swift` | 중간 리팩토링 | 2 | Realm 제거 |
| `Presentation/Main/Alarm/ViewModel/AlarmViewModel.swift` | 중간 리팩토링 | 2 | CommonVM 상속 제거 |
| `Presentation/WalkTrough/ViewModel/WalkThroughViewModel.swift` | 소규모 리팩토링 | 3 | CommonVM 상속 제거 |
| `Presentation/Main/Search/ViewModel/SearchViewModel.swift` | 소규모 리팩토링 | 5 | CommonVM 상속 제거 |
| `Presentation/Main/Search/View/SearchViewController.swift` | 소규모 변경 | 5 | 직접 repository 호출 제거 |
| `Presentation/Main/Setting/ViewModel/SettingViewModel.swift` | 중간 리팩토링 | 6 | 백업/복원 UseCase 적용 |
| `Presentation/Main/Setting/View/SettingViewController.swift` | 중간 리팩토링 | 6 | repository 직접 참조 제거 |
| `DataBase/UserDiaryRepository.swift` | 삭제 | 10 | RealmDiaryRepository로 대체 |

---

## 12. 기술 스택 참고

| 분류 | 기술 | 비고 |
|------|------|------|
| UI | UIKit + SwiftUI | Story 탭만 SwiftUI |
| 로컬 DB | RealmSwift | Diary 모델, schemaVersion 1 |
| 서버 | Firebase (Auth, Firestore, Storage, Crashlytics, Analytics, FCM) | Story 기능 |
| 레이아웃 | SnapKit | UIKit 화면 |
| DI | Swinject + @Injected 프로퍼티 래퍼 | 커스텀 래퍼 |
| 반응형 | Combine (@Published, CurrentValueSubject) + Custom Observable | Phase 8에서 통일 |
| 기타 | FSCalendar, CropViewController, IQKeyboardManager, Zip, AcknowList | |
