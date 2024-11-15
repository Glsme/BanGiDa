# 🐶 반기다: 반려동물 기록 다이어리

![bangida_preview](https://user-images.githubusercontent.com/88874280/207097533-477e217a-defc-44f4-a658-ee9d81552504.png)

### 동물들의 생활 기록 및 추억을 기록하기 위한 앱입니다. 

- Realm을 사용하여 메모를 기록하고 저장할 수 있습니다.
- 카테고리별로 선택하여 메모할 수 있습니다.
- Notification을 사용하여 원하는 시간에 알람 설정이 가능합니다.
- 카테고리 필터를 적용하여 최근 기록들을 살펴볼 수 있습니다.
- Realm data를 json형식으로 변환하여 원하는 데이터를 백업 및 복구할 수 있습니다.

[‎앱스토어 링크](https://apps.apple.com/kr/app/BangiDaApp/id6443524869)
</br><br/>
</br><br/>

## 🛠️ 사용 기술 및 라이브러리

- `Swift`, `MVVM`, `UIKit`, `APNs`, `MessageUI`, `StoreKit`
- `Realm`, `SnapKit`, `FirebaseAnalytics`, `FirebaseCrashlytics`, `FCM`, `FSCalendar`, `Zip`,
    
    `IQKeybordManagerSwift`, `TOCropViewController`
</br><br/>
</br><br/>

## 🗓️ 개발 기간

- 개발 기간: 2022년 9월 6일 ~ 2022년 9월 29일 (약 3주, 이후 지속적인 업데이트 진행 중)
- 세부 개발 기간

| 진행사항 | 진행기간 | 세부 내용 |
| --- | --- | --- |
| 기획 및 디자인 초안 | 2022.09.01 ~ 2022.09.09 | 디자인 초안 제작 (Figma), 주요 기능 기획, 공수 산정 계획, 기획 발표 |
| UI 제작 | 2022.09.10 ~ 2022.09.13 | 3개의 탭(홈, 검색, 설정) UI 제작, 메모 작성 UI 제작 |
| Realm 도입 및 데이터 저장 기능 | 2022.09.14 ~ 2022.09.18 | 메모 또는 알람 작성 시 Realm으로 저장 기능 추가, Realm 데이터 읽기 기능 추가 |
| 검색 UI 내 필터 기능 | 2022.09.19 ~ 2022.09.21 | 카테고리 클릭 시 필터 기능 추가, 필터된 데이터 핸들링, 필터된 메모 클릭 시 메모 수정 기능 추가 |
| 버그 수정, QA 및 앱 심사 준비 | 2022.09.22 ~ 2022.09.29 | 버그 수정, 앱 mock-up, 앱 QA, 개인정보 처리방침 준비, 앱 심사 제출 |

</br><br/>
</br><br/>

## ✏️ 구현해야 할 기술

- MVVM 패턴 이해 및 적용
- Code base로 UI 작성
- Realm 데이터 CRUD 및 백업•복구 방법
- Notification을 사용하여 사용자 알람 설정
- FCM을 사용하여 사용자에게 push 알림
- FSCalendar를 사용하여 사용자에게 정보 표시 및 수정•삭제 기능 구현
</br><br/>
</br><br/>

## 💡 Trouble Shooting

- 메모 작성 화면에서 스와이프로 pop 모션을 실행하다 돌아가면 네비게이션바가 사라지는 현상 발생
    
    → TabBarController, NavigationController를 모두 사용할 때 push - pop 시 현상 발생 확인. 
    
    → FSCalendar 내부 reloadData 시점 문제 reloadData 시점을 DispatchQueue로 조절하여 해결
    

```swift
DispatchQueue.main.async { [weak self] in
    guard let self = self else { return }
    self.mainView.homeTableView.calendar.reloadData()
    self.mainView.homeTableView.reloadData()
}
```
</br><br/>
- TableView의 데이터 업데이트에 따른 분기처리로 코드의 양이 많아지고 Index out of range 에러 발생
    
    → 섹션의 개수를 상수로 주고, 업데이트 시 셀의 개수만 핸들링하도록 변경
    

```swift
func setHeaderHeight(section: Int) -> CGFloat {
    let height: CGFloat = 66
    var value: CGFloat = 0

    switch section {
    case 0: value = !memoTaskList.isEmpty ? height : value
    case 1: value = !alarmTaskList.isEmpty ? height : value
    case 2: value = !growthTaskList.isEmpty ? height : value
    case 3: value = !showerTaskList.isEmpty ? height : value
    case 4: value = !hospitalTaskList.isEmpty ? height : value
    case 5: value = !abnormalTaskList.isEmpty ? height : value
    default:
        break
    }

    return value
}
```

```swift
let homeTableView: HomeTableView = {
    let view = HomeTableView(frame: .zero, style: .insetGrouped)
    view.contentInset = .zero
    view.contentInsetAdjustmentBehavior = .never
    return view
}()
```
</br><br/>
- 기존 백업/복구 기능 중 복구 작업 시 복구 후 필연적으로 앱이 종료됨
    
    → 백업 시 Data를 JSON 형식으로 저장하고 복구할 때 JSON 형식에서 Data로 Decoding 으로 해결
    

<img src="https://user-images.githubusercontent.com/88874280/207098187-e0e0d175-a916-4b4e-bb72-0b9c1eb698a1.png"  width="400" height="180"/>

</br><br/>
</br><br/>

## 🤔 회고

- ViewModel의 규칙 중 UIKit을 import하면 안 된다는 규칙을 모르고 ViewController의 로직을 모두 ViewModel로 옮겼다. (현재 리팩토링 진행 중)
- 메모리릭에 대응하면서 메모리릭을 신경 쓰며 개발할 수 있는 능력을 키웠다.
- 공수 산정을 하고 직접 개발을 하며 공수 산정의 중요성을 깨닫는 계기가 되었고, 총 일정에 맞춰 개발 일정을 계획하는 능력을 키웠다.
- Observable class를 사용하여 양방향 Binding을 적용하였지만, 장점을 제대로 적용시켜 사용하지 못하고 있다는 것을 깨달았다. 추후 양방향 Binding의 장점을 좀 더 적극적으로 사용해서 코드를 리팩토링해보면 좋을 것 같다.
- 현재 Notification을 활용한 알람 기능에서 로컬 알림 개수에 관한 제한이 없는데 만약 64개가 넘어갈 경우 앱이 동작하지 않는다는 것을 알게 되었다. 이와 관련하여 리팩토링 시 개수를 제한하는 코드를 작성해야겠다고 생각했다.
- 프로젝트 내에서 `String`, 또는 `Int`값들을 raw하게 모두 직접 넣어줬다. 하지만 추후 유지•보수 시 비용이 많이 발생하는 것을 느꼈다. 따라서 raw값들을 쉽게 관리해야 하는 필요성을 인지하였고, 이후 새싹 스터디 프로젝트에서 raw값을 열거형으로 관리하는 방식을 구조 설계에 반영했다.
</br><br/>
</br><br/>

## 출시 정보

### v1.1.5

- 2024.11.06 업데이트
- 메모가 저장되지 않고 최신 메모로 변경되는 버그 수정

### v1.1.4

- 2024.06.23 업데이트
- PrivacyInfo 대응
- Firebase Logging 방식 변경

### v1.1.3

- 2024.03.28 업데이트
- 설정 화면 리팩토링

### v1.1.2

- 2023.11.30 업데이트
- 메모 저장 시 DB에 저장되지 않는 현상 관련 Firebase 로그 추가

### v1.1.1

- 2023.10.12 업데이트
- 코드 전체 리팩토링
    - UIKit 분리
    - Observable 객체 -> Combine 변경 및 적용
    - 레거시 코드 삭제

### v1.1.0

- 2023.03.17 업데이트
- Profile 기능 추가
    - Profile 관련 Workthrough 추가
    - 설정 화면 Profile 추가 및 변경 기능 추가

### v1.0.7

- 2023.02.19 업데이트
- 일부 Class 내 final 키워드 추가
- Home 화면 내 UIKit 분리

### v1.0.6

- 2022.12.12 업데이트
- 불필요한 코드 제거 및 개선

### v1.0.5

- 2022.11.12 업데이트
- 앱 성능 향상을 위한 코드 개선 작업
- 불필요한 코드 제거

### v1.0.4

- 2022.11.01 업데이트
- 설정 화면 Diffable CollectionView로 변경
- 설정 화면 기능별 로직 분류

### v1.0.3

- 2022.10.16 업데이트
- FCM 기능 수정
- 불필요한 코드 제거 및 개선

### v1.0.2

- 2022.10.15 업데이트
- 앱 처음 시동 시 쉽게 사용할 수 있는 도움말 메모 추가
- Firebase 추가 (Analytics, Crashlytics, FCM)
- 불필요한 코드 제거 및 개선

### v1.0.1

- 2022.10.10 업데이트
- 메모 작성 화면 진입 시 캘린더에 클릭된 날짜로 자동 변경
- 검색 화면 내 메모 삭제시 메모가 보이지 않는 현상 수정
- 불필요한 코드 제거 및 개선

### v1.0

- 2022.09.29 출시
</br><br/>
