# BanGiDa SwiftUI · Micro Feature · TCA 전환 계획

## 1. 개요

### 1.1 목적
현재 UIKit + MVVM 기반 코드를 SwiftUI + TCA(The Composable Architecture)로 전환하고,
단일 앱 타깃을 Micro Feature Architecture 기반 모듈 구조로 재편한다.

### 1.2 세 개의 독립 축
이번 작업은 서로 독립적인 세 축으로 구성된다. 이 셋을 한 커밋에 섞지 않는 것이 계획 전체의 핵심 전제다.

| 축 | 내용 | 영향 계층 |
|---|---|---|
| A. UI 프레임워크 | UIKit → SwiftUI | Presentation |
| B. 모듈 구조 | 단일 타깃 → Micro Feature | 빌드 그래프 전체 |
| C. 상태 관리 | MVVM(Combine) → TCA | Presentation |

> "리팩터링 모자와 기능 변경 모자를 동시에 쓰면 망한다."
> 세 축을 동시에 진행하면 문제 발생 시 원인을 어느 축에서도 특정할 수 없다.

### 1.3 확정된 결정 사항

| 항목 | 결정 | 근거 |
|---|---|---|
| 배포 타깃 | iOS 16.0 → **17.0 상향** | `@ObservableState`가 네이티브 Observation으로 동작하여 `WithPerceptionTracking` 래핑이 불필요해진다 |
| 모듈 세분화 | **정석 4타깃** (Interface / Implementation / Testing / Example) | 의존성 역전과 피처 독립 실행 확보 |
| 접근 제어자 | 모듈 경계는 `public`이 아니라 **`package`** | 앱 전용이라 외부 소비자가 없다. API 표면을 넓히지 않고 모듈 간 가시성만 얻는다. 전 타깃에 `-package-name BanGiDa`를 건다 |
| 방법론 | Seam + Characterization Test 6단계 루프 | 아래 3장 참조 |
| 전환 순서 | 모듈화 선행 → 화면별 SwiftUI + TCA 동시 전환 | 아래 4장 참조 |

### 1.4 범위 밖
- Realm → SwiftData 등 영속 계층 교체
- Swift 6 언어 모드 전환 (현재 `Tuist.swift`의 `swiftVersion: "5.10"` 유지)
- 기능 추가 및 버그 수정 (특성화 테스트로 캡처만 하고 수정은 별도 작업으로 분리)

---

## 2. 현재 상태 진단

진단 일자 기준 저장소 실측값이다.

| 항목 | 현황 |
|---|---|
| 규모 | Swift 142 파일 / 약 10,300 라인 |
| 빌드 도구 | Tuist 4.201 — 단일 앱 타깃 `BanGiDa` + 테스트 타깃 `BanGiDaTests` |
| Swift 언어 모드 | `Tuist.swift`에 `swiftVersion: "5.10"` |
| 배포 타깃 | iOS 17.0 (`Project.swift`, Phase 0.5에서 상향 완료) |
| 계층 분리 | Domain(UseCase 34개 / Repository 프로토콜 10개) · Data · Presentation · Application |
| DI | Swinject + `@Injected` propertyWrapper (Service Locator) |
| UI | UIKit ViewController 6개 + SwiftUI 화면 5개 (혼재) |
| 테스트 | Swift Testing — Phase 0 완료 후 **139 tests / 33 suites** (착수 시점 49) |

### 2.1 유리한 조건
- Domain 계층이 이미 분리되어 있고 Repository가 전부 프로토콜 기반이다. **Seam이 절반 이상 이미 확보된 상태**이므로 방법론 1단계 비용이 거의 들지 않는다.
- `RealmDiary+Mapping.swift`로 Realm 객체 ↔ 도메인 모델 매핑이 이미 존재한다. TCA State에 Realm 객체가 새어 들어갈 위험이 구조적으로 차단되어 있다.

### 2.2 위험 요소
- ~~**테스트 공백**~~ → **Phase 0에서 해소.** Diary · Alarm · Backup · Preferences 계열에 특성화 테스트를 작성해 49 → 139개가 됐다.
- ~~**미사용 잔재**~~ → **Phase 1에서 정리.** 다만 실측 결과 `Projects/`는 "과거 모듈화 시도의 잔재"가 아니라 **파일이 0개인 빈 디렉터리 껍데기**였다. git에 추적된 적이 없고 gitignore 대상인 `.xcodeproj`·`Derived`만 들어 있었다. 삭제해도 git상 변화가 없었다.
- ~~**정적 접근점**~~ → **Phase 0에서 보강.** `DocumentManaging` 프로토콜을 추출하고 `UserRepositoryImpl`의 `UserDefaults.standard`를 주입으로 바꿨다. 다만 아래 8.4 참조 — Seam이 열리지 않은 범위가 남아 있다.
- **접근 제어자 전환 비용** (신규 발견): 8.4 참조.

---

## 3. 방법론 — Seam + Characterization Test

### 3.1 기본 6단계 루프
1. **Seam 구조 생성** — 코드를 건드리지 않고 외부에서 동작을 바꿀 수 있는 지점을 만든다 (Mock 주입 가능 구조)
2. **Characterization Test 작성** — 현재 동작을 그대로 캡처한다. **버그도 그대로 포함**한다
3. **리팩토링 전 테스트 통과 확인**
4. **리팩토링 수행**
5. **리팩토링 후 테스트 통과 확인** — 실패 시 4단계로 복귀
6. **반복** — 단위별로 1~5 반복

### 3.2 이번 작업을 위한 변형
기본 루프를 그대로 적용하면 세 지점에서 막힌다. 다음과 같이 변형한다.

**(a) Seam 위치를 UseCase 경계로 고정한다**
UIKit → SwiftUI 전환은 View를 통째로 폐기하는 작업이므로 View에 특성화 테스트를 걸면 테스트도 함께 버려진다.
따라서 Seam을 ViewModel **아래**(UseCase / Repository 경계)에 두고, 그 아래를 테스트로 고정한 뒤 위를 갈아끼운다.

**(b) 모듈 분리 단계는 검증 수단이 다르다**
모듈 쪼개기는 동작 변경이 0이므로 특성화 테스트가 아니라 **의존성 그래프가 안전망**이다.

> **초안 정정 (Phase 1 파일럿 실측)**
> 초안은 "Domain 모듈이 UIKit·Realm·Firebase를 import하면 컴파일이 실패하는 것이 검증"이라고 적었다. **이 전제는 틀렸다.** CoreKit에 프로브를 심어 확인한 결과다.
>
> | 시도 | 기대 | 실측 |
> |---|---|---|
> | 의존성 미선언 모듈(DesignSystem) import + 심볼 사용 | 컴파일 실패 | **BUILD SUCCEEDED** |
> | 위 상태 + `enforceExplicitDependencies: true` | 컴파일 실패 | **BUILD SUCCEEDED** |
> | 시스템 프레임워크 `import UIKit` | 컴파일 실패 | **BUILD SUCCEEDED** |
> | `tuist inspect dependencies` | — | **exit 1**, `CoreKit implicitly depends on: DesignSystem` |
>
> 원인은 둘이다. ① 모든 타깃이 같은 `BUILT_PRODUCTS_DIR`에 빌드되고 그 경로가 항상 프레임워크 검색 경로에 있어, 의존성을 선언하지 않아도 first-party 프레임워크가 발견된다. ② 시스템 프레임워크는 어떤 빌드 설정으로도 import를 막을 수 없다.

따라서 이 단계의 게이트는 **`tuist inspect dependencies`** 다 (위반 시 exit 1). 이 명령은 `enforceExplicitDependencies: false`인 현재 설정에서도 정상 동작하므로 `Tuist.swift`는 손대지 않는다.
"Domain은 UIKit을 import하지 않는다" 같은 **시스템 프레임워크 금지 규칙은 도구가 다르다** — SwiftLint 커스텀 룰이 필요하며, 현재 저장소에는 SwiftLint가 없어 도입부터 별도 작업이다.

**(c) 루프의 적용 단위는 "화면 1개"다**
Phase 3에서 화면 하나를 전환할 때마다 1~5단계를 1회 완주한다. 여러 화면을 묶어서 돌리지 않는다.

---

## 4. 전환 순서 선택

### 4.1 대안 비교

| 기준 | A. 모듈화 → 화면별 SwiftUI+TCA 동시 | B. SwiftUI 전면 → TCA → 모듈화 | C. TCA 선행 (UIKit 위에서) |
|---|---|---|---|
| 화면당 작업 횟수 | **1회** | 2회 | 2회 |
| 초기 비용 | 높음 (Tuist 모듈 세팅) | 낮음 | 낮음 |
| 중간 상태 안정성 | 높음 (모듈 경계가 격리) | 중간 | 낮음 |
| 폐기되는 코드 | 적음 | MVVM SwiftUI ViewModel 전량 | UIKit ↔ Store 글루 코드 전량 |
| 중단 가능성 | 언제든 가능 | 가능 | 애매 |

### 4.2 A안 채택 근거
- **왕복 제거**: SwiftUI 전환과 TCA 도입을 화면 단위로 묶으면 화면당 1회로 끝난다.
  B안은 SwiftUI + MVVM을 만든 뒤 다시 Reducer로 옮기므로 같은 화면을 두 번 작업한다.
- **컴파일러 수준의 격리**: 모듈 경계가 먼저 있어야 "이 화면만 TCA, 나머지는 레거시"라는 혼재 상태가
  빌드 그래프로 강제된다. 모듈 없이 혼재하면 전환 진척도가 사람의 기억에 의존한다.
- C안 제외 사유: UIKit + TCA는 `UIHostingController` 또는 수동 store 구독 글루 코드를 요구하는데,
  최종 목적지가 SwiftUI이므로 이 코드는 전량 폐기된다.

---

## 5. 단계별 실행 계획

| Phase | 내용 | 검증 수단 | 상태 |
|---|---|---|---|
| 0 | 안전망 확보 | `xcodebuild test` 통과 | **완료** (49 → 139 tests) |
| 0.5 | 배포 타깃 17 상향 (단독 커밋) | 빌드 + 기존 테스트 전량 | **완료** |
| 1 | 모듈 골격 구성 | `tuist inspect dependencies` (3.2(b) 참조) | 진행 중 — CoreKit·DesignSystem 파일럿 완료 |
| 2 | TCA 기반 마련 | TestStore 동작 확인 | |
| 3 | 화면별 수직 슬라이스 전환 | 화면당 6단계 루프 1회 | |
| 4 | 레거시 정리 | 전량 통과 | |

### Phase 0 — 안전망 확보
가장 덜 화려하지만 이후 모든 단계의 회귀 감지 능력을 결정하는 단계다.

- [x] 검증 명령 확정 및 문서화
- [x] `Diary` 계열 UseCase 특성화 테스트 작성 (Save / Update / Delete / FetchByDate / Search / FindByID)
- [x] `Alarm` 계열 특성화 테스트 작성 (Schedule / Remove / Restore / RequestAuthorization)
- [x] `Backup` 계열 특성화 테스트 작성 (Create / Restore / Reset)
- [x] `Preferences` 계열 특성화 테스트 작성
- [x] Seam 보강 — `DocumentManaging` 프로토콜 추출 + `UserRepositoryImpl`의 `UserDefaults` 주입화. `UserDefaultsKey` enum 자체는 키 목록이라 프로토콜화 대상이 아니었고, 실제 Seam 공백은 `UserDefaults.standard` 직접 참조였다
- [x] 현재 동작을 그대로 캡처했는지 확인 — 의심 동작 11건을 고치지 않고 계열별 `CHARACTERIZATION-NOTES.md`에 기록

검증 명령:
```bash
tuist generate --no-open
# 개발 머신 함정 우회: Realm 모듈맵 잔재가 읽기 전용으로 남으면
# Copy Module Map 스크립트 페이즈가 cp: Permission denied 로 실패한다
rm -f "$HOME/Library/Developer/Xcode/DerivedData/BanGiDa-*/Build/Products/Debug-iphonesimulator/Realm.framework/Modules/module.modulemap"
xcodebuild test -workspace BanGiDa.xcworkspace -scheme BanGiDa \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

> **초안 정정**: 초안은 `iPhone 16`을 적었으나 현재 개발 머신에는 iPhone 16용 최신 런타임(OS 26.2)이 없어 `OS:latest` 매칭에 실패한다. 설치된 최신 런타임을 쓰는 `iPhone 17`로 대체한다.
> 시뮬레이터가 `Application failed preflight checks` / `Busy`로 간헐 실패하는 경우가 있다. 코드와 무관하며 `xcrun simctl shutdown all` 후 재시도하면 통과한다.

### Phase 0.5 — 배포 타깃 상향 (16.0 → 17.0)
**반드시 단독 커밋으로 처리한다.** 모듈화나 TCA 커밋에 섞으면 이후 문제 발생 시
iOS 17 상향 때문인지 리팩토링 때문인지 구분할 수 없다.

- [ ] ~~선행: Firebase Analytics에서 실사용자 OS 버전 분포 확인~~ — **확인 없이 상향하기로 결정.** 릴리스 전에 iOS 16 비중을 확인할 것을 권고로 남긴다
- [x] `Project.swift`의 `deploymentTargets: .iOS("16.0")` → `.iOS("17.0")` (앱·테스트 두 타깃)
- [x] 빌드 경고 확인 및 정리 — 상향이 유발한 `onChange(of:perform:)` deprecation 5건 정리. 남은 경고는 `extraneous whitespace` 2건이며 Swift 6 언어 모드 항목이라 8.5에 따라 미룬다
- [x] 기존 테스트 전량 통과 확인 (139 tests)

> **관찰**: 저장소의 `#available(iOS 10.0/15.0)` 분기 3곳은 이번 상향이 아니라 **상향 이전 16.0 시절부터 이미 죽은 분기**였다. 컴파일러가 이런 분기에 경고를 내지 않으므로(실측 확인) 드러나지 않았을 뿐이다. 상향 커밋과 원인이 다르므로 분리해서 다룬다.

### Phase 1 — 모듈 골격 구성 (동작 변경 0)

- [x] `Projects/` 잔재 디렉터리 정리 (파일 0개의 빈 껍데기였음, 2.2 참조)
- [x] **`Core(CoreKit, DesignSystem)` 파일럿** — 6파일 최소 규모로 모듈 분리 절차와 `package` 전환을 먼저 검증
- [x] `Domain` 모듈 분리 (58파일. 실제 `package` 전환은 최상위 50 + 멤버 71개였다)
- [x] `Data` 모듈 분리 (20파일, 최상위 17 + 멤버 60개). Firebase 링크 문제는 8.6 참조
- [ ] ~~Story 피처로 4타깃 템플릿 구성~~ — **Phase 2 이후로 미룸.** 8.7 참조
- [ ] ~~나머지 6개 피처에 확산~~ — 동일
- [x] 의존성 방향 검증 수단 확정 — `tuist inspect dependencies` (3.2(b) 참조)
- [x] ~~SwiftLint 도입~~ → **아키텍처 테스트로 대체.** SwiftLint가 미설치라 팀 전체에 새 도구를 강제하게 되어, 소스를 직접 훑는 `BanGiDaTests/Architecture/ArchitectureBoundaryTests.swift`로 같은 목적을 달성했다. 전량 테스트에 포함되므로 별도 명령이 필요 없다
- [ ] `tuist cache` 세팅 — **보류.** 목적이 "타깃 30개 이상 환경 대응"인데 현재 5개다. 타깃이 실제로 늘어난 뒤에 한다

> **파일럿 순서 변경**: 초안은 Story 피처를 파일럿으로 삼았으나, 실제로는 `Core`를 먼저 했다.
> 모든 피처가 `Domain`에 의존하므로 하위 계층이 먼저 서야 피처 타깃이 의존할 대상이 생기기 때문이다.
> "같은 실수를 7번 고치지 않는다"는 파일럿의 원래 취지는 그대로 유지된다 — 6파일 규모에서 `package` 전환과
> 의존성 게이트를 먼저 검증했다.

> **Story를 파일럿으로 고른 이유**: 이미 SwiftUI이고 Comment · ReportSheet · WriteStory 하위 화면까지
> 포함하므로 중첩 피처 구조까지 한 번에 검증된다.
> **7개를 동시에 만들지 않는 이유**: 4타깃 구성은 Interface가 Implementation을 몰라야 하는
> 의존 방향 설정에서 실수가 나는데, 동시에 만들면 같은 실수를 7번 고치게 된다.

### Phase 2 — TCA 기반 마련

- [ ] `swift-composable-architecture` 의존성 추가 (`Tuist/Package.swift`)
- [ ] DI 전략 적용: **신규 전환 피처만 `@Dependency`, 레거시는 Swinject 유지, Phase 4에서 Swinject 제거**
- [ ] Reducer / State / Action 작성 컨벤션 확정
- [ ] `TestStore` 기반 테스트 작성 패턴 확립 (파일럿 피처 기준)

> **DI 병존 전략 근거**: TCA의 `TestStore`는 `@Dependency`와 맞물려 동작하므로 최종적으로는
> `swift-dependencies` 이관이 자연스럽다. 다만 전면 교체는 변경 폭이 크므로,
> 전환된 피처부터 점진 이관하고 마지막에 Swinject를 제거한다.

### Phase 3 — 화면별 수직 슬라이스 전환
화면 하나당 3장의 6단계 루프를 1회 완주한다. 상세 순서는 6장 참조.

### Phase 4 — 레거시 정리

- [ ] `AppDelegate` / `SceneDelegate` → SwiftUI App lifecycle 전환
- [ ] Swinject 및 `@Injected` 제거
- [ ] SnapKit / IQKeyboardManagerSwift 등 UIKit 전용 의존성 제거
- [ ] `Tuist/Package.swift` 의존성 목록 정리

---

## 6. 화면별 전환 순서

이미 SwiftUI인 화면부터 진행하면 **UI 프레임워크 축을 제외하고 TCA 축만** 검증할 수 있다.
변수를 하나씩 통제하기 위한 순서다.

| 순서 | 화면 | 현재 UI | ViewModel 규모 | 비고 |
|---|---|---|---|---|
| 1 | ReportSheet | SwiftUI | 48줄 | **파일럿** — 최소 규모 |
| 2 | BlockedUsers | SwiftUI | 61줄 | |
| 3 | WriteStory | SwiftUI | 47줄 (View 321줄) | |
| 4 | Comment | SwiftUI | 180줄 | SwiftUI 화면 중 최고 복잡도 |
| 5 | Story | SwiftUI | 121줄 | 리스트 / 페이징 |
| 6 | Alarm | UIKit | 105줄 | UIKit 전환 첫 대상 |
| 7 | Search | UIKit | 98줄 | |
| 8 | Write | UIKit | 91줄 (MemoView 230줄) | |
| 9 | Home | UIKit | VC 388줄 | **최고 난도 — FSCalendar 의존** |
| 10 | Setting | 혼재 | 133줄 (VC 341줄) | 일부 SwiftUI 이미 적용됨 |
| 11 | WalkThrough | UIKit | 53줄 | |
| 12 | MainTab | 혼재 | — | TabView + TCA 라우팅 |

Home을 9번째로 배치한 이유는 FSCalendar 대응 방침(8.2 참조)이 그 이전 단계의 경험을 필요로 하기 때문이다.

---

## 7. 목표 모듈 구조

```
Projects/
├─ App/                        # BanGiDa 앱 타깃
├─ Features/
│  ├─ Story/
│  │  ├─ StoryInterface/       # Reducer 타입, State/Action 공개 API
│  │  ├─ Story/                # Reducer 구현 + SwiftUI View
│  │  ├─ StoryTesting/         # Mock / Preview 더미 구현
│  │  └─ StoryExample/         # 피처 단독 실행 앱
│  ├─ Home/                    # 이하 동일 4타깃 구성
│  ├─ Write/
│  ├─ Search/
│  ├─ Alarm/
│  ├─ Setting/
│  └─ WalkThrough/
├─ Domain/                     # UseCase 34개, Repository 프로토콜
├─ Data/                       # Realm · Firebase · LocalStorage 구현체
└─ Core/
   ├─ DesignSystem/            # 완료 (Phase 1 파일럿)
   └─ CoreKit/                 # 완료 (Phase 1 파일럿)
```

**예상 타깃 수**: 피처 7개 × 4타깃 = 28, 여기에 Domain · Data · Core 2종 · App을 더해 **총 35개 안팎**.

**매니페스트 구성**: 현재는 루트 `Project.swift` 하나에 타깃을 나열하고 `sources`로 위 디렉터리를 가리킨다.
모듈별 `Project.swift` + `Workspace.swift`로 쪼개는 것은 매니페스트만 바뀌는 작업이라 소스 배치를 먼저 잡고
타깃 수가 늘어난 뒤에 판단한다.

의존성 규칙:
- `Domain`은 어떤 외부 프레임워크도 import하지 않는다 (UIKit / SwiftUI / Realm / Firebase 금지)
  — 다만 이 규칙은 **컴파일러가 강제하지 못한다.** 3.2(b) 참조
- `FeatureInterface`는 `FeatureImplementation`을 참조하지 않는다
- 피처 간 참조는 반드시 `Interface` 타깃을 경유한다
- `App`만이 전체 구현 타깃을 조립한다
- 위 규칙의 실제 게이트는 `tuist inspect dependencies` 다

---

## 8. 리스크와 대응

### 8.1 Realm × TCA
TCA `State`는 Equatable한 값 타입을 전제하나 Realm 객체는 스레드에 confined되어 있다.
**State에 Realm 객체를 직접 담지 않는다.** `RealmDiary+Mapping.swift`의 도메인 모델 매핑을 반드시 경유한다.

### 8.2 FSCalendar (Home 화면)
FSCalendar는 UIKit 전용이며, iOS 17에도 이를 대체할 SwiftUI 네이티브 캘린더 컴포넌트는 없다
(`MultiDatePicker`는 이벤트 표시 dot, 주/월 전환을 제공하지 않아 대체재가 되지 못한다).

선택지:
| 방안 | 장점 | 단점 |
|---|---|---|
| `UIViewRepresentable` 래핑 유지 | 변경 최소, 기능 동일 | UIKit 의존이 영구히 남음 |
| 자체 캘린더 구현 | UIKit 완전 탈피 | 구현·검증 비용이 크고 회귀 위험 |
| 대체 라이브러리 도입 | 중간 비용 | 신규 의존성 학습·검증 필요 |

Home 전환 착수 시점에 결정한다. 그 전까지는 미결로 둔다.

### 8.3 접근 제어자 전환 비용 (초안 누락)
초안은 모듈 분리 비용을 타깃 생성과 의존 방향 설정으로만 봤다. 실제 최대 비용은 **접근 제어자**다.
단일 타깃에서는 모든 심볼이 `internal`로 서로 보이지만, 타깃을 쪼개는 순간 경계를 넘는 모든 심볼에 제어자를 붙여야 한다.

| 대상 | 전체 타입 | 이미 공개 | 전환 필요 |
|---|---|---|---|
| Domain | 95 | 45 | 50 |
| Data | 21 | 5 | 16 |

타입 선언만이 아니다. Domain에만 `func`/`var`/`init`/`case` 선언이 203개 있고, 특히
**`public`/`package` struct의 멤버와이즈 이니셜라이저는 여전히 `internal`이라 자동 공개되지 않는다.**
`DiaryEntry(...)`처럼 다른 모듈에서 생성하는 타입은 이니셜라이저를 손으로 써 줘야 한다.

테스트도 영향을 받는다. 31개 파일이 `@testable import BanGiDa` 하나로 모든 계층에 접근 중이라,
Domain·Data가 분리되면 각 모듈을 따로 import해야 한다.

`public` 대신 `package`를 택한 이유는 1.3 참조.

### 8.4 Seam이 열리지 않은 범위 (Phase 0 실측)
Phase 0의 Seam 보강으로 `ImageRepositoryImpl`은 단위 테스트가 가능해졌으나, 다음은 **열리지 않았다.**

- `BackupRepositoryImpl` — `documentManager`는 주입 가능해졌지만 `createBackup()`/`restoreFromFile(_:)`이 `try Realm()`을 직접 호출하고 `FileManager.default`도 직접 쓴다. Realm 주입까지 열려면 별도 작업이 필요하다.
- `UserRepositoryImpl` — `UserDefaults`는 주입 가능해졌지만 `init`이 `Firestore` 인스턴스를 요구하고, 이는 `FirebaseApp.configure()`를 선행 요구한다. **UserDefaults seam만으로는 이 클래스가 테스트 가능해지지 않았다.**

커버된 것으로 오해하지 않도록 명시한다. 상세는 `BanGiDaTests/Data/CHARACTERIZATION-NOTES.md`.

### 8.6 Firebase는 한 타깃만 링크할 수 있다 (Phase 1 실측)
Data를 별도 타깃으로 떼면 앱과 Data가 Firebase를 이중 링크하게 되는데, **어떤 구성으로도 링크가 성립하지 않는다.**

| 구성 | 결과 |
|---|---|
| 앱·Data 양쪽에 선언 | duplicate symbol 9,234개 |
| Data에만 선언 | `_OBJC_CLASS_$_FIRFirestore` 등 Obj-C 심볼 undefined |
| `productTypes`로 동적 강제 | `FirebaseFirestore` 자체 링크 실패 (Swift 오버레이가 `FirebaseFirestoreInternal` 바이너리를 못 찾음) |

덧붙여 Firebase는 `Project.swift`의 `packages:`로 **Xcode 네이티브 SPM** 통합이라
`Tuist/Package.swift`의 `PackageSettings.productTypes` 관할 밖이다. 이 사실을 모르면 동적 강제 시도 자체가 무효다.

**해결**: Firebase를 만지는 타깃을 Data 하나로 모은다. `AppDelegate`가 들고 있던
`FirebaseApp.configure()`·`Messaging` 대리자·`MessagingDelegate` 채택을 Data의 `FirebaseBootstrap`으로 옮겼다.
부수 효과로 앱 셸의 import에서 Firebase·Realm·Zip이 모두 사라져 프로젝트 자체 규칙에도 부합하게 됐다.

**남은 위험**: 이 이관은 이번 작업에서 유일하게 테스트로 보호되지 않은 동작 변경이다.
`UpdateFCMTokenUseCase`는 테스트 4건이 덮지만 "APNs 토큰 등록 → FCM 토큰 수신 → UseCase 호출" 배선은 단위 테스트가 없다.
실기기 푸시 수신 확인이 필요하다.

### 8.7 피처 모듈화는 DI 전환보다 뒤에 와야 한다 (Phase 1 실측)
초안은 Phase 1에서 Story 4타깃을 만들고 Phase 2에서 TCA를 도입하는 순서였다. **이 순서는 성립하지 않는다.**

레거시 화면은 `@Injected` propertyWrapper로 의존을 얻는데, 이것이 `AppDIContainer.shared`를 직접 참조하고
`AppDIContainer`는 `import Data`로 모든 구현체를 등록한다. 즉 피처를 모듈로 떼면

```
Story 피처 → @Injected → AppDIContainer → Data
```

가 되어 피처가 Data에 전이 의존한다. 마이크로 피처 구조가 막으려는 바로 그 역전이다.

우회하려면 `Injected`를 CoreKit으로 올리고 리졸버를 추상화해야 하는데, `AppDelegate`가 `@Injected` 저장 프로퍼티를
갖고 있어 `didFinishLaunching`보다 먼저 해석이 일어난다. 리졸버 주입을 늦추면 기동이 깨지고, 지연 해석으로 바꾸면
Service Locator 전반의 타이밍이 바뀌는데 이 배선에는 테스트가 없다.

게다가 지금 Story를 MVVM+Swinject 상태로 4타깃화해도 Phase 3에서 TCA로 다시 쓴다 — §4.2가 피하려던 왕복이다.

**결론**: 피처 모듈화를 Phase 3으로 옮긴다. 화면을 TCA로 전환할 때 그 피처의 4타깃을 함께 만들면
Interface에 담을 실체(State/Action)가 생기고, `@Dependency`가 Swinject 의존도 끊어준다.

### 8.5 Swift 6 동시성
현재 Swift 5.10 모드다. 모듈을 분리하면 모듈 간 `Sendable` 경계가 드러나 에러가 대량 발생할 수 있다.
**모듈화와 Swift 6 언어 모드 전환을 동시에 진행하지 않는다.** 이 또한 "모자 두 개" 사례에 해당한다.
Swift 6 전환은 Phase 4 이후 별도 작업으로 분리한다.

---

## 9. 미결 사항

| # | 항목 | 결정 시점 | 비고 |
|---|---|---|---|
| 1 | ~~실사용자 iOS 버전 분포~~ | ~~Phase 0.5 착수 전~~ | **종결** — 확인 없이 17.0 상향. 릴리스 전 iOS 16 비중 확인은 권고로 남음 |
| 2 | FSCalendar 대응 방안 | Phase 3 / Home 전환 시 | 8.2 참조 |
| 3 | Swinject 완전 제거 시점 | Phase 4 | 전 피처 전환 완료 후 |
| 4 | Swift 6 언어 모드 전환 | Phase 4 이후 별도 작업 | 8.5 참조 |
| 5 | 모듈 product 타입 (`.framework` vs `.staticFramework`) | Domain·Data 분리 시 | 파일럿은 `.framework`로 갔다. 타깃 35개 규모에서는 동적 프레임워크 로딩 비용이 누적되므로 재검토가 필요하다 |
| 6 | DesignSystem 에셋 이전 | 피처 모듈 확산 시 | 색상 에셋이 앱 번들에 있어 `Color("BackgroundColor")`가 `Bundle.main`으로 해석되는 데 의존한다. 지금은 동작하지만 에셋을 DesignSystem으로 옮기면 `bundle:` 인자가 필요해진다 |
| 7 | 특성화로 고정한 의심 동작 11건의 처리 시점 | Phase 3 화면별 전환 시 | 계열별 `CHARACTERIZATION-NOTES.md`. 계획 원칙상 전환과 섞지 말고 별도 작업으로 뺀다 |

---

## 10. 참고 자료

- 마틴 파울러, 『리팩터링 2판』
- 마이클 페더스, 『레거시 코드 활용 전략』
- [iOS 앱 리팩토링 전략 및 회고](https://glsman-111co.tistory.com/33) — 본 계획의 3장 방법론 출처
- [TCA — Observation Backport](https://github.com/pointfreeco/swift-composable-architecture/blob/main/Sources/ComposableArchitecture/Documentation.docc/Articles/ObservationBackport.md) — iOS 17 미만에서 `WithPerceptionTracking`이 요구되는 근거
- [TCA — Migrating to 1.7](https://github.com/pointfreeco/swift-composable-architecture/blob/main/Sources/ComposableArchitecture/Documentation.docc/Articles/MigrationGuides/MigratingTo1.7.md) — `@ObservableState` 마이그레이션 가이드
- [BanGiDa Clean Architecture 리팩토링 가이드](./BanGiDa-CleanArchitecture-Refactoring.md) — 선행 리팩토링 문서
