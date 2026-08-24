# Data 계층 Seam 보강 — 관찰 기록

Phase 0 Seam 보강(`DocumentManaging` 프로토콜 추출 + `UserRepositoryImpl`의 `UserDefaults` 주입) 중 관찰한 것을 기록한다.
**프로덕션 로직은 수정하지 않았다.** 구조 변경(프로토콜 채택, 주입 지점 추가)만 했고 동작은 그대로다.

## 이상 동작

| # | 위치(file:line) | 현재 동작 | 왜 의심스러운가 | 고정한 테스트 |
|---|---|---|---|---|
| 1 | `BanGiDa/Data/LocalStorage/DocumentManager.swift:194-200` | `createImagesDirectoryPath()`가 디렉터리 생성 실패를 `catch`에서 `print("image 폴더는 이미 있단다")`로 삼키고 throw하지 않는다. | 이 메서드는 반환값도 없어서 호출부가 성공 여부를 알 방법이 전혀 없다. 실제로 생성이 실패하면 곧이어 실행되는 `ImageRepositoryImpl.saveImageData`의 `data.write(to:)`가 `DocumentError`가 아닌 불투명한 Foundation 에러를 던진다. 즉 "이미지 저장 실패"의 원인이 디렉터리 문제인지 쓰기 권한 문제인지 호출부에서 구분할 수 없다. 또한 catch 메시지가 "이미 있단다"라고 단정하지만, 실제로는 이미 존재하는 경우 `fileExists` 가드에서 걸러지므로 이 catch에 도달했다는 건 다른 실패라는 뜻이다. | `ImageRepositoryImplTests.saveImageDataThrowsOpaqueFoundationErrorWhenImagesDirectoryIsAbsent` |

## 죽은 코드 (Phase 1 모듈 분리에 직접 영향)

전 소스를 검색해 확인한 결과다.

| 대상 | 상태 | Phase 1 관련성 |
|---|---|---|
| `DocumentManager.loadImageFromDocument(fileName:) -> UIImage?` (`DocumentManager.swift:60-70`) | 호출부 0곳 | **`DocumentManager.swift`가 `import UIKit`을 하는 유일한 이유다.** 이 메서드를 지우면 Data 계층에서 UIKit 의존이 사라진다. |
| `DocumentManager.fetchDocumentZipFile()` (`DocumentManager.swift:120-131`) | 호출부 0곳 | — |
| `import RealmSwift` (`DocumentManager.swift:9`) | 파일 안에서 Realm 심볼을 전혀 쓰지 않음 | Data 모듈의 불필요한 Realm 결합 |

이번 작업 범위(구조 변경만)를 벗어나므로 **삭제하지 않았다.** Phase 1에서 `Data` 모듈을 분리할 때 함께 정리하는 것이 자연스럽다.

## Seam이 열린 범위와 열리지 않은 범위

- **열림**: `ImageRepositoryImpl`이 `DocumentManaging`을 주입받게 되어 파일시스템 없이 단위 테스트가 가능해졌다 (`ImageRepositoryImplTests` 7건).
- **부분적으로만 열림**: `ImageRepositoryImpl.saveImageData`는 `documentDirectoryPath()`만 프로토콜을 거치고 실제 쓰기는 `data.write(to:)`로 직접 한다(`ImageRepositoryImpl.swift:21-32`). 스텁이 임시 디렉터리를 돌려주게 하면 테스트는 되지만, 여전히 실제 디스크에 쓴다.
- **열리지 않음 — `BackupRepositoryImpl`**: `documentManager`는 주입 가능해졌으나 `createBackup()`/`restoreFromFile(_:)`이 `try Realm()`을 직접 호출하고, `FileManager.default`의 copy/move/remove와 `Data(contentsOf:)`도 직접 쓴다. 프로토콜 주입만으로는 격리되지 않아 단위 테스트를 만들지 않았다. Realm 주입까지 열려면 별도 작업이 필요하다.
- **열리지 않음 — `UserRepositoryImpl`**: `UserDefaults`는 주입 가능해졌지만 `init(db:userDefaults:)`가 `Firestore` 인스턴스를 요구하고, 이를 얻으려면 `FirebaseApp.configure()`가 선행돼야 한다. 즉 **UserDefaults seam만으로는 이 클래스가 단위 테스트 가능해지지 않았다.** 닉네임 읽기 경로(`readNickname()`)조차 Firestore 없이는 인스턴스를 만들 수 없다. 커버된 것으로 오해하지 않도록 기록해 둔다.

## 프로토콜 표면 결정 근거

`DocumentManaging`에는 `ImageRepositoryImpl`·`BackupRepositoryImpl`이 실제로 호출하는 8개만 넣었다.
`loadImageFromDocument`는 `UIImage`를 반환해 프로토콜에 UIKit을 끌어들이므로, 호출부가 없음을 확인하고 제외했다.
`saveImageDataFromDocument`는 `CachedAsyncImage`(Presentation)만 쓰고 두 저장소는 쓰지 않아 제외했다.

`CachedAsyncImage.swift:69,123`이 `DocumentManager()`를 구체 타입으로 직접 생성하는 것은 이번 범위 밖으로 두었다.
Presentation이 Data 구현체를 직접 참조하는 것은 프로젝트 자체 규칙 위반이지만, Phase 1에서 모듈 경계가 컴파일 에러로 드러낼 때 처리하는 편이 계획 문서의 "빌드 그래프가 안전망" 원칙에 맞는다.
