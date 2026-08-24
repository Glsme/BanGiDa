# Diary UseCase 특성화 테스트 — 이상 동작 보고

Phase 0 안전망 작업 중 발견한 의심스러운 현재 동작을 기록한다. **프로덕션 코드는 수정하지 않았고**, 아래 동작은 모두 테스트로 고정(characterize)만 했다.

| # | 위치(file:line) | 현재 동작 | 왜 의심스러운가 | 고정한 테스트 |
|---|---|---|---|---|
| 1 | `BanGiDa/Domain/UseCase/Diary/SaveDiaryUseCase.swift:40-44` | `imageRepository.saveImageData`가 성공한 뒤 `diaryRepository.save`가 throw하면, 이미 디스크에 쓰인 이미지 파일을 정리(cleanup)하지 않고 그대로 종료한다. | 저장이 실패했는데도 이미지 파일만 남아 고아 파일(orphan file)이 쌓인다. 사용자가 같은 entry를 재시도하면 `"\(id).jpg"`는 새 UUID로 생성되므로 기존 고아 파일은 영영 참조되지 않고 디스크 용량만 잠식한다. | `SaveDiaryUseCaseTests.leavesOrphanedImageFileWhenSaveThrowsAfterImageWasSaved` |
| 2 | `BanGiDa/Domain/UseCase/Diary/UpdateDiaryUseCase.swift:23-33` | `photoData`가 `nil`이면 `saveImageData`를 호출하지 않고 전달받은 `entry`를 그대로 `update`하므로, 기존 `photoFileName`이 그대로 유지된다. | 이 UseCase의 시그니처(`photoData: Data?`)만 보면 "사진을 nil로 넘기면 사진이 제거된다"고 오해하기 쉽지만, 실제로는 **사진을 제거할 방법이 이 UseCase에 없다**. 사진 삭제가 필요한 호출부가 있다면 별도 경로가 있는지, 혹은 이 자체가 누락된 기능인지 확인이 필요하다. | `UpdateDiaryUseCaseTests.preservesExistingPhotoFileNameWhenPhotoDataIsNil` |
| 3 | `BanGiDa/Domain/UseCase/Diary/DeleteDiaryUseCase.swift:23-28` | `photoFileName`이 있으면 `removeImage`를 먼저 호출하고 그 다음 `delete`를 호출한다. `removeImage`는 성공(non-throwing)했는데 이어지는 `delete`가 throw하면, 이미지 파일은 이미 삭제된 채 엔트리는 저장소에 그대로 남는다. | 삭제 실패 시 "이미지는 사라졌는데 일기 엔트리는 남아있는" 불일치 상태가 된다. 사용자 화면에는 엔트리가 계속 보이지만 그 안의 사진은 이미 사라진 상태로 노출될 수 있다. | `DeleteDiaryUseCaseTests.leavesEntryPersistedWhenDeleteThrowsAfterImageWasRemoved` |
| 4 | `BanGiDa/Domain/UseCase/Diary/UpdateDiaryUseCase.swift:24-29` | `saveImageData`가 성공한 뒤 `diaryRepository.update`가 throw하면, 이미 디스크에 쓰인 이미지 파일을 정리하지 않는다. | 1번과 같은 고아 파일 문제가 수정 경로에도 그대로 있다. 수정은 저장보다 자주 일어나므로 누적 속도가 더 빠를 수 있다. | `UpdateDiaryUseCaseTests.leavesOrphanedImageFileWhenUpdateThrowsAfterImageWasSaved` |
| 5 | `BanGiDa/Domain/UseCase/Diary/FetchDiariesByDateUseCase.swift:24` | 조회 대상 타입을 `DiaryType.allCases`가 아니라 `[DiaryType.memo, .alarm, .hospital, .shower, .pill, .abnormal]` 리터럴로 하드코딩해 순회한다. | 지금은 리터럴이 전체 케이스와 우연히 일치하지만, `DiaryType`에 케이스를 추가하면 컴파일은 통과하는데 그 타입만 조회에서 조용히 누락된다. 컴파일러가 잡아주지 않는 종류의 누락이다. | `FetchDiariesByDateUseCaseTests.queriesHardcodedSixDiaryTypesInFixedOrderForGivenDate` (리터럴 고정) + `hardcodedTypeListCurrentlyCoversEveryDiaryTypeCase` (케이스 추가 감시) |

## 참고
- 1·3·4번은 모두 "두 저장소(diary/image)에 걸친 작업이 원자적(atomic)이지 않다"는 공통 패턴이다. TCA 전환 시 이 경계를 하나의 트랜잭션으로 묶을지 여부를 설계 단계에서 논의할 필요가 있다.
- `FetchDiariesByDateUseCase.execute(date:)`는 빈 배열인 타입을 결과 딕셔너리 키에서 아예 제외한다(`if !entries.isEmpty`). 버그는 아니지만 호출부가 `result[.memo] ?? []` 없이 `result[.memo]!`처럼 강제 언래핑하면 깨질 수 있는 지점이라 함께 적어둔다.
