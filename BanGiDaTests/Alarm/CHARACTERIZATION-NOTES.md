# Alarm UseCase 특성화 테스트 — 이상 동작 보고

Phase 0 안전망 작업 중 발견한 의심스러운 현재 동작을 기록한다. **프로덕션 코드는 수정하지 않았고**, 아래 동작은 모두 테스트로 고정(characterize)만 했다.

| # | 위치(file:line) | 현재 동작 | 왜 의심스러운가 | 고정한 테스트 |
|---|---|---|---|---|
| 1 | `BanGiDa/Domain/UseCase/Alarm/RestoreNotificationsUseCase.swift:26` | `SaveAlarmUseCase`(`SaveAlarmUseCase.swift:38`)와 `UpdateAlarmUseCase`(`UpdateAlarmUseCase.swift:27`)는 `date > Date() \|\| repeatRule != .none`을 예약 조건으로 쓰지만, `RestoreNotificationsUseCase`는 `alarm.date > Date()`만 본다(`repeatRule` 무시). | **최우선 항목.** 과거 날짜에 걸린 반복 알람(예: `date`가 어제, `repeatRule`이 `.daily`)은 저장/수정 시점에는 정상적으로 알림이 예약되지만, 앱을 재시작해 `RestoreNotificationsUseCase.execute()`가 대기 알림을 복원할 때는 이 조건에 걸려 재등록되지 않는다. 즉 사용자가 알아채지 못하는 사이 반복 알람이 영구히 사라진다. | `RestoreNotificationsUseCaseTests.dropsRepeatingAlarmWithPastDateOnRestoreEvenThoughRepeatRuleIsNotNone` (대조군: `SaveAlarmUseCaseTests.schedulesWhenDateIsInPastButRepeatRuleIsNotNone`, `UpdateAlarmUseCaseTests.schedulesWhenDateIsInPastButRepeatRuleIsNotNone`) |
| 2 | `BanGiDa/Domain/UseCase/Alarm/UpdateAlarmUseCase.swift:24-25` | `diaryRepository.update(entry)`가 throw하면 함수가 즉시 종료되어 이어지는 `notificationRepository.remove(identifier:)`와 `schedule(...)` 호출이 전혀 일어나지 않는다. | 저장소 갱신이 실패했으니 알림도 그대로 두는 편이 안전해 보이지만, 실제로는 **"기존에 걸려 있던 알림이 그대로 살아남는다"**는 의미다. 호출부가 실패를 사용자에게 알리고 재시도를 유도한다면 문제가 적지만, 만약 UI가 "수정 완료"로 오인하고 넘어가면 화면상의 알람 정보와 실제로 울리는 알림 내용(구 데이터)이 어긋난 채로 남는다. | `UpdateAlarmUseCaseTests.doesNotRemoveOrScheduleWhenUpdateThrows` |
| 3 | `BanGiDa/Domain/UseCase/Alarm/RemoveNotificationUseCase.swift:22-28`, `ScheduleNotificationUseCase.swift:22-28` | 두 UseCase 모두 오버로드 2개가 서로 완전히 독립적인 저장소 메서드에 위임하며, 한쪽 호출이 다른 쪽 저장소 메서드를 건드리지 않는다. | 버그는 아니지만, 이름이 같은 메서드가 파라미터 시그니처만 다른 오버로드 구조라 TCA 전환 시 Action/Reducer 설계에서 실수로 잘못된 오버로드를 호출하기 쉬운 지점이라 기록해 둔다. | `ScheduleNotificationUseCaseTests.byIdentifierOverloadDoesNotCallByIndexOverload` / `byIndexOverloadDoesNotCallByIdentifierOverload`, `RemoveNotificationUseCaseTests`의 대응 테스트 |

## Seam 문제 (테스트 대상 UseCase가 `Date()`를 직접 호출)

`SaveAlarmUseCase`, `UpdateAlarmUseCase`, `RestoreNotificationsUseCase` 모두 시간 소스를 주입받지 않고 `Date()`를 직접 호출한다(각각 `SaveAlarmUseCase.swift:28,38`, `UpdateAlarmUseCase.swift:27`, `RestoreNotificationsUseCase.swift:26`). 그 결과:

- 테스트에서 "지금 이 순간"과 "1초 전/후" 같은 경계값을 결정적으로 검증할 방법이 없다. 이번 특성화 테스트는 `Date().addingTimeInterval(3600)`(명백한 미래) / `Date().addingTimeInterval(-3600)`(명백한 과거)만 사용했고, `date == Date()`에 가까운 경계값은 의도적으로 검증하지 않았다.
- TCA 전환 시 `Date`를 `@Dependency`로 주입 가능한 형태로 바꾸면 이 Seam이 해소되고, 회귀 테스트에서 경계값(예: 정확히 현재 시각과 같은 알람)도 결정적으로 검증할 수 있게 된다. 설계 논의가 필요한 지점으로 남겨둔다.

## 참고

- `RestoreNotificationsUseCase.execute()`가 가장 먼저 호출하는 `notificationRepository.removeAllPending()`(`RestoreNotificationsUseCase.swift:24`)은 `NotificationRepository` 계약상 앱이 등록한 모든 대기 중 알림을 지운다. 다이어리에 알람으로 등록되지 않은 다른 경로로 걸린 로컬 알림이 있다면(현재 코드베이스에는 없어 보이지만) 그 알림도 함께 사라진다는 뜻이라 기록해 둔다.
- `SaveAlarmUseCase`는 `schedule`에 넘기는 `identifier`로 로컬에서 조립한 `entry.id`가 아니라 `diaryRepository.save`가 돌려준 `savedEntry.id`를 쓴다(`SaveAlarmUseCase.swift:40`). 두 값이 항상 같다면 문제가 되지 않지만, 저장소가 id를 재발급하는 구현으로 바뀌면 이 경로에 의존하는 코드가 있다는 점을 팀이 인지하고 있어야 한다. 버그는 아니라 위 표에는 올리지 않았고, `SaveAlarmUseCaseTests.usesRepositoryReturnedIDAsScheduleIdentifierRatherThanLocallyGeneratedID`로 고정만 해두었다. 덧붙여 이 경로는 **비대칭**이다 — `identifier`만 저장소 반환값(`savedEntry.id`)을 따르고, `date`·`repeatRule`은 저장소 반환 entry가 아니라 `execute`의 인자를 그대로 쓴다(`SaveAlarmUseCase.swift:43-44`). 저장소가 값을 보정하는 구현으로 바뀌면 알림과 저장 데이터가 어긋날 수 있는 지점이라 `schedulesWithArgumentDateAndRepeatRuleRatherThanRepositoryReturnedEntryValues`로 함께 고정했다. 반환값 출처는 `returnsRepositorySaveResultRatherThanLocallyBuiltEntry`가 고정한다.
- `SaveAlarmUseCase`의 `schedule` title은 인자로 받은 `alarmTitle`(필수, non-optional)을 그대로 쓰고(`SaveAlarmUseCase.swift:41`), `UpdateAlarmUseCase`와 `RestoreNotificationsUseCase`는 `alarmTitle ?? animalName`으로 대체 로직이 있다(`UpdateAlarmUseCase.swift:30`, `RestoreNotificationsUseCase.swift:29`). Save 경로는 애초에 `alarmTitle`이 optional이 아니라서 대체가 필요 없지만, 세 UseCase의 title 결정 로직이 완전히 같지 않다는 점은 TCA 전환 시 공통 로직으로 묶을지 판단할 때 참고할 필요가 있다.
