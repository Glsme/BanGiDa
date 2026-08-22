# BanGiDa 스토리 댓글 기능 기획서

작성일: 2026-08-18
대상 브랜치: `develop`
관련 모듈: `Presentation/Main/Story`, `Domain/UseCase/Story`, `Data/Firebase`

---

## 1. 개요

### 1.1 배경
현재 스토리 기능은 **좋아요(하트)** 만 지원한다. 사용자는 다른 사람의 스토리에 반응할 수 있지만, 텍스트로 소통할 수단이 없다. 반려동물 사진 공유라는 성격상 "귀엽다", "무슨 종이에요?" 같은 대화 욕구가 자연스럽게 발생하므로, 단일 뎁스 댓글을 추가해 스토리 탭의 체류·재방문을 늘린다.

### 1.2 목표
- 스토리마다 댓글을 작성·조회·삭제할 수 있다.
- 피드에서 스크롤을 멈추지 않고 최근 댓글 분위기를 파악할 수 있다.
- 내 스토리에 댓글이 달리면 푸시로 알 수 있다.
- 텍스트 UGC 도입에 따른 App Store 심사 요건(신고·차단)을 충족한다.

### 1.3 범위

**포함 (In scope)**

| 항목 | 내용 |
|---|---|
| 댓글 CRUD | 작성, 목록 조회(페이지네이션), 본인 댓글 삭제 |
| 작성자 배지 | 스토리 작성자가 단 댓글에 `작성자` 배지 표시 |
| 피드 인라인 미리보기 | 카드 하단에 최근 댓글 2개 + "댓글 N개 모두 보기" |
| 댓글 시트 | 바텀시트 전체 목록 + 하단 고정 입력바 |
| 댓글 수 집계 | 스토리 문서 `commentCount` 필드 |
| 신고·차단 | 댓글 신고, 사용자 차단 및 차단 대상 콘텐츠 숨김 |
| 푸시 알림 | Cloud Functions 트리거 → 스토리 작성자에게 FCM 발송, 앱 내 옵트아웃 |

**제외 (Out of scope)**

| 항목 | 사유 |
|---|---|
| 대댓글(2뎁스) | 데이터 모델·UI 복잡도가 크게 오름. v2로 분리 |
| 댓글 좋아요 | 읽기 비용과 정렬 기준(인기순)이 추가됨. v2로 분리 |
| 댓글 수정 | 신고 시점 원문 보존이 어려워짐. 삭제 후 재작성으로 대체 |
| 멘션(@) / 해시태그 | 사용자 검색 인프라가 없음 |
| 딥링크로 특정 스토리 직접 진입 | 피드가 커서 페이지네이션이라 임의 위치 점프 비용이 큼. §7.5 참고 |

### 1.4 확정된 의사결정

| # | 결정 | 내용 |
|---|---|---|
| D1 | 댓글 구조 | 단일 뎁스. 대댓글·댓글 좋아요 없음 |
| D2 | 작성자 표기 | 스토리 작성자가 단 댓글에 `작성자` 배지. 작성 권한 제한은 **없음**(누구나 작성 가능) |
| D3 | 노출 방식 | 피드 인라인 미리보기 + 바텀시트 전체 목록 |
| D4 | 알림 | FCM 푸시 포함 (Cloud Functions 필요). Blaze 요금제는 적용 완료 |
| D5 | 삭제 권한 | 본인 댓글만 삭제 가능. 스토리 작성자도 **타인 댓글은 삭제할 수 없다** |
| D6 | 미리보기 조회 | A안 — 스토리별 `comments` 서브컬렉션 직접 쿼리 (§4.4) |
| D7 | `commentCount` 집계 | A안 — 클라이언트 트랜잭션 + `FieldValue.increment` (§9.1) |
| D8 | 금칙어 필터 | 자체 작성 로컬 사전 기반 전송 전 차단 (§8.3) |
| D9 | 테스트 프레임워크 | Swift Testing (§12) |
| D10 | 가이드 재동의 | `storyAgreementVersion: Int`로 버전 부여해 재동의 수집 (§8.5) |
| D11 | 신고 이력 보존 | 최상위 `reports` 컬렉션에 스냅샷 병행 기록 (§8.6) |

---

## 2. 현황 분석

### 2.1 기존 스토리 데이터 흐름

```
StoryView (SwiftUI)
  └ StoryViewModel  @Injected FetchStoriesUseCase / ToggleStoryLikeUseCase
       └ FetchStoriesUseCaseImpl  (UID 확보 → Repository 위임)
            └ StoryRepositoryImpl (Firestore)
                 images/{storyID}           ← 스토리 문서
                 images/{storyID}/likes/{uid}   ← 좋아요 (문서 존재 = 눌렀음)
                 images/{storyID}/reports/{uid} ← 신고
```

- 페이지네이션: 첫 페이지는 `likeCount desc` 인기 3건, 이후 `createdAt desc` + `documentID desc` 커서 10건씩 (`StoryRepositoryImpl.swift:29-84`)
- 좋아요 토글: Firestore 트랜잭션으로 `likes/{uid}` 문서 생성·삭제 + `likeCount` `FieldValue.increment` (`StoryRepositoryImpl.swift:98-133`)
- 인증: Firebase 익명 로그인. UseCase 진입 시 UID가 없으면 `createUser()` 재시도 후 없으면 `UserError.emptyUID` (`FetchStoriesUseCase.swift:24-31`)

댓글도 **좋아요와 동일한 서브컬렉션 + 카운터 필드 패턴**을 그대로 따르는 것이 학습 비용과 리뷰 비용 면에서 유리하다.

### 2.2 댓글 도입을 막는 제약

댓글은 좋아요와 달리 **스토리 문서 ID를 안정적으로 알아야** 하고(서브컬렉션 페이지네이션), **작성자 UID를 알아야** 한다(배지·알림). 현재 코드는 두 가지를 모두 제공하지 않는다.

| # | 제약 | 근거 위치 | 댓글에 미치는 영향 |
|---|---|---|---|
| C1 | `Story`에 Firestore 문서 ID가 없음. `id`는 매번 새로 만드는 로컬 UUID | `StoryTypes.swift:11` | 댓글 서브컬렉션 경로를 만들 수 없음 |
| C2 | 문서 ID를 `imageURL`에서 역산. `images%2F` 뒤 문자열을 잘라 사용 | `ToggleStoryLikeUseCase.swift:39-49`, `ReportStoryUseCase.swift:33-43` | Storage 경로(`StoryRepositoryImpl.swift:163`)와 Firestore 문서 ID(`:153-156`)가 같다는 **암묵적 계약**에 의존. Storage 경로 규칙이 바뀌면 조용히 깨짐 |
| C3 | `writerUUID`를 읽고 버림 (`guard let _ =`) | `StoryRepositoryImpl.swift:193` | 작성자 배지 판정 불가, 알림 수신자 결정 불가 |
| C4 | 닉네임 단일 출처가 없음. 조회는 UserDefaults, 갱신은 Firestore | `UserRepositoryImpl.swift:48-52`, `:65-67` | 댓글 작성자명 정합성 정책이 필요 |
| C5 | APNs 토큰 위임 메서드 시그니처가 프로토콜과 불일치 | `AppDelegate.swift:93-96` | §7.1 참고 |
| C6 | FCM 토큰을 서버에 저장하지 않음 (`TODO` 주석) | `AppDelegate.swift:118` | 특정 사용자에게 푸시 보낼 수단이 없음 |
| C7 | 테스트 타깃 없음. 앱 타깃 하나뿐 | `Project.swift:30-87` | ATDD→BDD→TDD 플로우를 적용할 곳이 없음 |

> C5 보충: `func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken:)`는 `UIApplicationDelegate`가 요구하는 `func application(_ application: UIApplication, ...)`와 첫 파라미터 레이블이 다르다. 따라서 프로토콜 메서드로 인식되지 않고 **호출되지 않는다**. 현재 푸시가 동작한다면 FirebaseMessaging의 method swizzling(`FirebaseAppDelegateProxyEnabled`를 Info.plist에 두지 않았으므로 기본 활성) 덕분일 가능성이 크다. 푸시를 정식 기능으로 승격하기 전에 교정한다.

---

## 3. 사용자 시나리오와 인수 기준

### 3.1 시나리오

1. 사용자가 스토리 탭을 스크롤하다 카드 하단에서 최근 댓글 2개를 본다.
2. "댓글 24개 모두 보기"를 누르면 바텀시트가 올라오고 전체 댓글이 최신순으로 보인다.
3. 하단 입력바에 텍스트를 쓰고 전송하면 목록 맨 위에 내 댓글이 붙고, 카드의 댓글 수가 1 늘어난다.
4. 스토리를 올린 사람이 단 댓글에는 닉네임 옆에 `작성자` 배지가 붙는다.
5. 내가 쓴 댓글을 길게 누르면 삭제할 수 있다. 남의 댓글은 신고·차단만 가능하다.
6. 내 스토리에 댓글이 달리면 푸시가 오고, 설정에서 이 알림을 끌 수 있다.

### 3.2 인수 기준 (ATDD)

| ID | Given | When | Then |
|---|---|---|---|
| AC-01 | 댓글이 3개 이상인 스토리 | 피드를 본다 | 최근 댓글 2개와 "댓글 N개 모두 보기"가 보인다 |
| AC-02 | 댓글이 0개인 스토리 | 피드를 본다 | "첫 댓글을 남겨보세요"가 보인다 |
| AC-03 | 댓글 시트가 열려 있음 | 300자 이내 텍스트를 전송한다 | 목록 최상단에 추가되고 `commentCount`가 1 증가한다 |
| AC-04 | 공백만 입력 | 전송을 시도한다 | 전송 버튼이 비활성이며 요청이 나가지 않는다 |
| AC-05 | 301자 입력 | 전송을 시도한다 | 입력 단계에서 차단되고 잔여 글자 수가 빨간색으로 표시된다 |
| AC-06 | 스토리 작성자 == 댓글 작성자 | 댓글을 본다 | 닉네임 옆에 `작성자` 배지가 보인다 |
| AC-07 | 내가 쓴 댓글 | 길게 누른다 | 삭제 메뉴가 보이고, 삭제 시 `commentCount`가 1 감소한다 |
| AC-08 | 남이 쓴 댓글 | 길게 누른다 | 신고·차단 메뉴만 보이고 삭제는 보이지 않는다 |
| AC-09 | 사용자 B를 차단함 | 피드와 댓글을 본다 | B의 스토리와 댓글이 보이지 않는다 |
| AC-10 | 댓글이 20개 초과 | 시트를 아래로 스크롤한다 | 다음 페이지가 추가로 로드된다 |
| AC-11 | 내 스토리에 타인이 댓글을 달았고 알림 허용 상태 | 앱이 백그라운드 | 푸시가 도착한다 |
| AC-12 | 내 스토리에 내가 댓글을 달았다 | — | 푸시가 도착하지 않는다 |
| AC-13 | 설정에서 댓글 알림을 껐다 | 타인이 댓글을 단다 | 푸시가 도착하지 않는다 |
| AC-14 | 네트워크 오류 | 댓글 전송을 시도한다 | 입력 내용이 유지되고 재시도 안내가 보인다 |

---

## 4. 데이터 모델 설계

### 4.1 Firestore 스키마

```
images/{storyID}
├─ writerUUID        : String
├─ writerNickname    : String
├─ imageURL          : String
├─ text              : String
├─ createdAt         : Timestamp
├─ likeCount         : Int
├─ commentCount      : Int          ← 신규
│
├─ likes/{uid}                       (기존)
├─ reports/{uid}                     (기존)
└─ comments/{commentID}              ← 신규
   ├─ authorUID      : String
   ├─ authorNickname : String
   ├─ text           : String
   ├─ createdAt      : Timestamp
   └─ reports/{reporterUID}          ← 신규 (댓글 신고)
      ├─ createdAt   : Timestamp
      └─ reason      : String?

users/{uid}
├─ nickname, createAt, lastSeenAt    (기존)
├─ fcmToken                   : String     ← 신규
├─ fcmTokenUpdatedAt          : Timestamp  ← 신규
├─ commentNotificationEnabled : Bool       ← 신규 (기본 true)
└─ blocks/{blockedUID}                     ← 신규
   └─ createdAt : Timestamp

reports/{reportID}                         ← 신규 (최상위, 운영 추적용 · §8.6)
├─ targetType, targetPath, storyID, commentID
├─ targetAuthorUID, reporterUID, reason
├─ contentSnapshot
└─ createdAt
```

**마이그레이션**: 기존 스토리 문서에는 `commentCount`가 없다. 파싱 시 `data["commentCount"] as? Int ?? 0`으로 흡수하고, `FieldValue.increment`는 대상 필드가 없거나 숫자가 아니면 지정값으로 세팅되므로(Firestore 공식 동작) **별도 백필 배치는 필요 없다**.

**인덱스**: `comments` 서브컬렉션을 `createdAt desc` 단일 필드로만 정렬하므로 자동 단일 필드 인덱스로 충분하다. 복합 인덱스 추가 불필요.

**삭제 정책**: 단일 뎁스이므로 자식 댓글이 없다. 소프트 삭제(`isDeleted` 플래그)를 둘 이유가 없어 **하드 삭제**로 간다. 단, 삭제된 댓글에 걸린 신고 기록은 서브컬렉션과 함께 사라지므로, 운영상 신고 이력 보존이 필요하면 신고 시점에 별도 최상위 `reports` 컬렉션에 스냅샷을 남기는 방안을 §14에 미결정으로 둔다.

### 4.2 Domain 모델

`Domain/Model/CommentTypes.swift` (신규, 외부 프레임워크 import 없음)

```swift
import Foundation

public struct Comment: Identifiable, Hashable {
    public let id: String              // Firestore documentID
    public let storyID: String
    public let authorUID: String
    public let authorNickname: String
    public let text: String
    public let createdAt: Date
    public let displayTime: String     // "3분 전" 등 표시용 문자열

    public init(
        id: String,
        storyID: String,
        authorUID: String,
        authorNickname: String,
        text: String,
        createdAt: Date,
        displayTime: String
    ) { ... }
}

public struct CommentPage {
    public let comments: [Comment]
    public let nextCursor: CommentCursor?
    public let isEnd: Bool
}

public struct CommentCursor: Hashable, Codable {
    public let createdAt: Date
    public let id: String
}
```

설계 메모
- `Comment`에 `isStoryAuthor` 같은 표시용 플래그를 **넣지 않는다**. 배지 판정은 `story.writerUID == comment.authorUID`로 Presentation에서 계산한다. 도메인 모델이 특정 화면의 표시 규칙을 알 필요가 없고, 같은 댓글을 다른 맥락에서 재사용할 때 플래그가 거짓이 될 수 있기 때문이다.
- `displayTime`은 기존 `Story.time`이 이미 서식화된 문자열을 담는 관례(`StoryTypes.swift:13`, `StoryRepositoryImpl.swift:257-280`)를 따른 것이다. 일관성 우선. 다만 `createdAt` 원본도 함께 보관해 이후 상대시간 갱신이 필요해지면 Presentation에서 재계산할 여지를 남긴다.

### 4.3 `Story` 모델 변경

```swift
public struct Story: Identifiable {
    public let id: String              // ← 변경: Firestore documentID (기존 UUID())
    public let writerUID: String       // ← 신규
    public let imageURL: String
    public let time: String
    public let nickname: String
    public let text: String
    public var isHearted: Bool
    public var heartCount: Int
    public var commentCount: Int       // ← 신규
    public var previewComments: [Comment]  // ← 신규 (최대 2개)
}
```

`id`를 문서 ID로 바꾸면 `StoryView`의 `ForEach(..., id: \.element.id)`(`StoryView.swift:22`), `loadMoreIfNeeded(currentStoryID:)`(`StoryViewModel.swift:41`), `stories.firstIndex(where:)`(`StoryViewModel.swift:72`)가 그대로 동작하며, 오히려 서버 식별자 기준이 되어 중복 판정이 정확해진다. 현재 중복 제거에 쓰는 `loadedImageURLs`(`StoryViewModel.swift:22`)도 `loadedStoryIDs`로 바꾸는 편이 의미상 맞다.

### 4.4 인라인 미리보기 조회 전략 (확정: A안)

피드 한 페이지(10건)를 불러올 때 각 스토리의 최근 댓글 2개를 어떻게 채울지는 읽기 비용과 정합성의 교환이다.

| 안 | 방식 | 페이지당 문서 읽기 | 정합성 | 구현량 |
|---|---|---|---|---|
| **A** | 피드 로드 후 스토리별 `comments` `limit(2)` 병렬 쿼리 | 10(스토리) + 10(좋아요) + 20(댓글) = **40** | 항상 최신 | 낮음. 기존 `fetchLikedIDs`(`StoryRepositoryImpl.swift:223-246`)의 `withThrowingTaskGroup` 패턴을 그대로 재사용 |
| **B** | 스토리 문서에 `recentComments` 배열(최대 2개)을 비정규화 | 10 + 10 = **20** | 삭제·신고 시 배열 재계산 필요. Cloud Functions 없이는 어긋나기 쉬움 | 중간. 쓰기 경로마다 동기화 코드 필요 |

**채택: A안 (D6).** 근거 두 가지.
1. 현재 코드가 이미 좋아요에서 같은 N+1 병렬 패턴을 쓰고 있어 구조가 일관되고, 리뷰어가 새로 이해할 개념이 없다.
2. B는 "댓글 삭제 → 배열 갱신 누락 → 유령 댓글 표시" 같은 정합성 버그를 만들기 쉬운데, 이 버그는 사용자 눈에 바로 보이면서 재현이 어렵다.

읽기량이 실제 비용 문제로 관측되는 시점(예: 스토리 탭 DAU가 유의미하게 늘어 Firestore 읽기가 무료 할당량을 상시 초과할 때)에 B로 전환한다. 전환 시에도 Domain 인터페이스(`fetchStories`가 `previewComments`를 채워 돌려준다)는 그대로라 Presentation은 손대지 않아도 된다.

---

## 5. 아키텍처 설계

### 5.1 계층별 신규·변경 파일

```
Domain/                                       (외부 프레임워크 import 금지)
├─ Model/
│  ├─ CommentTypes.swift              ← 신규  Comment, CommentPage, CommentCursor
│  └─ StoryTypes.swift                ← 변경  id/writerUID/commentCount/previewComments
├─ Repository/
│  ├─ CommentRepository.swift         ← 신규  protocol
│  ├─ StoryRepository.swift           ← 변경  imageID → storyID 파라미터명
│  └─ UserRepository.swift            ← 변경  FCM 토큰, 차단 API 추가
└─ UseCase/
   ├─ Comment/
   │  ├─ FetchCommentsUseCase.swift   ← 신규
   │  ├─ WriteCommentUseCase.swift    ← 신규
   │  ├─ DeleteCommentUseCase.swift   ← 신규
   │  └─ ReportCommentUseCase.swift   ← 신규
   ├─ User/
   │  ├─ BlockUserUseCase.swift       ← 신규
   │  └─ UpdateFCMTokenUseCase.swift  ← 신규
   └─ Story/
      ├─ FetchStoriesUseCase.swift    ← 변경  CommentRepository 조합
      ├─ ToggleStoryLikeUseCase.swift ← 변경  cacheKey 파싱 제거
      └─ ReportStoryUseCase.swift     ← 변경  cacheKey 파싱 제거

Core/Errors/
└─ CommentError.swift                 ← 신규

Data/Firebase/
├─ CommentRepositoryImpl.swift        ← 신규
├─ StoryRepositoryImpl.swift          ← 변경  documentID/writerUUID/commentCount 매핑
└─ UserRepositoryImpl.swift           ← 변경  fcmToken, blocks

Presentation/Main/Story/
├─ Comment/
│  ├─ View/
│  │  ├─ CommentSheetView.swift              ← 신규
│  │  └─ SubViews/
│  │     ├─ CommentRow.swift                 ← 신규
│  │     ├─ CommentInputBar.swift            ← 신규
│  │     └─ CommentPreviewView.swift         ← 신규 (피드 인라인)
│  └─ ViewModel/
│     └─ CommentViewModel.swift              ← 신규
├─ View/SubViews/StoryRow.swift              ← 변경  미리보기 + 댓글 버튼
├─ ViewModel/StoryViewModel.swift            ← 변경  commentCount 동기화
└─ ReportSheet/View/ReportSheetView.swift    ← 변경  대상 일반화 (스토리/댓글)

Application/
├─ DIContainer.swift                  ← 변경  CommentRepository + UseCase 6개 등록
└─ AppDelegate.swift                  ← 변경  APNs 시그니처 교정, 토큰 저장, 푸시 탭 라우팅
```

### 5.2 Repository 프로토콜

```swift
// Domain/Repository/CommentRepository.swift
public protocol CommentRepository {
    func fetchComments(storyID: String, after cursor: CommentCursor?, limit: Int) async throws -> CommentPage
    func fetchPreviewComments(storyIDs: [String], limit: Int) async throws -> [String: [Comment]]
    func writeComment(storyID: String, text: String, authorUID: String, authorNickname: String) async throws -> Comment
    func deleteComment(storyID: String, commentID: String) async throws
    func reportComment(storyID: String, commentID: String, uid: String, reason: String) async throws
}
```

**`StoryRepository`에 합치지 않고 분리하는 이유**: `StoryRepository`는 이미 조회·작성·좋아요·신고 4개 책임을 갖고 있고, 여기에 5개를 더하면 프로토콜 하나가 9개 메서드가 된다. Mock 구현 부담도 함께 커져 UseCase 단위 테스트에서 쓰지 않는 메서드까지 매번 stub해야 한다.

**미리보기 조합 위치**: `StoryRepositoryImpl`이 `CommentRepository`를 주입받게 하면 Data 계층 내부에 의존이 생긴다. 대신 **`FetchStoriesUseCase`가 두 Repository를 모두 주입받아 조합**한다. Repository 간 의존이 없어지고, 조합 규칙(미리보기 몇 개, 차단 사용자 필터링)이 도메인 규칙으로 한곳에 모인다.

```swift
public final class FetchStoriesUseCaseImpl: FetchStoriesUseCase {
    private let storyRepository: StoryRepository
    private let commentRepository: CommentRepository
    private let userRepository: UserRepository

    public func execute(after cursor: StoryCursor?) async throws -> StoryPage {
        if userRepository.loadUID()?.isEmpty ?? true {
            try await userRepository.createUser()
        }
        guard let uid = userRepository.loadUID() else { throw UserError.emptyUID }

        let page = try await storyRepository.fetchStories(after: cursor, uid: uid)
        let blockedUIDs = try await userRepository.fetchBlockedUIDs()

        let visible = page.stories.filter { !blockedUIDs.contains($0.writerUID) }
        let previews = try await commentRepository.fetchPreviewComments(
            storyIDs: visible.map(\.id),
            limit: 2
        )

        let merged = visible.map { story -> Story in
            var story = story
            story.previewComments = (previews[story.id] ?? [])
                .filter { !blockedUIDs.contains($0.authorUID) }
            return story
        }
        return StoryPage(stories: merged, nextCursor: page.nextCursor, isEnd: page.isEnd)
    }
}
```

> 주의: 차단 필터로 스토리가 걸러지면 페이지당 실제 표시 건수가 10보다 작아진다. `isEnd` 판정은 **필터 이전 원본 개수** 기준을 유지해야 무한 스크롤이 조기 종료되지 않는다. 위 코드는 `page.isEnd`를 그대로 전달해 이 조건을 지킨다.

### 5.3 UseCase

```swift
public protocol WriteCommentUseCase {
    func execute(storyID: String, text: String) async throws -> Comment
}

public final class WriteCommentUseCaseImpl: WriteCommentUseCase {
    public func execute(storyID: String, text: String) async throws -> Comment {
        // 기존 WriteStoryUseCase(:24-31)와 동일한 UID 확보 절차
        if userRepository.loadUID()?.isEmpty ?? true {
            try await userRepository.createUser()
        }
        guard let uid = userRepository.loadUID() else { throw UserError.emptyUID }
        guard let nickname = userRepository.readNickname() else { throw UserError.emptyNickname }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw CommentError.emptyText }
        guard trimmed.count <= CommentPolicy.maxLength else { throw CommentError.textTooLong }

        return try await commentRepository.writeComment(
            storyID: storyID,
            text: trimmed,
            authorUID: uid,
            authorNickname: nickname
        )
    }
}
```

```swift
// Core/Errors/CommentError.swift
public enum CommentError: Error {
    case emptyText
    case textTooLong
    case notAuthor          // 본인 댓글이 아닌데 삭제 시도
    case rateLimited        // 연속 전송 쿨다운
}

public enum CommentPolicy {
    public static let maxLength = 300
    public static let previewCount = 2
    public static let pageSize = 20
    public static let writeCooldown: TimeInterval = 3
}
```

입력 검증을 View가 아닌 UseCase에 두는 이유는 "댓글은 300자 이내여야 한다"가 화면 사정이 아니라 도메인 규칙이기 때문이다. View는 같은 정책 상수를 참조해 **입력 단계에서 미리 막고**(AC-05), UseCase는 최종 방어선 역할을 한다.

### 5.4 DI 등록

`DIContainer.registerDependencies()`에 추가한다 (기존 패턴 그대로).

```swift
// MARK: - Repositories
container.register(CommentRepository.self) { _ in
    CommentRepositoryImpl()
}
.inObjectScope(.container)

// MARK: - Comment UseCases
container.register(FetchCommentsUseCase.self) { resolver in
    FetchCommentsUseCaseImpl(
        commentRepository: resolver.force(CommentRepository.self),
        userRepository: resolver.force(UserRepository.self)
    )
}
// WriteComment / DeleteComment / ReportComment / BlockUser / UpdateFCMToken 동일 형태
```

`FetchStoriesUseCase` 등록은 `commentRepository` 인자가 추가되도록 수정한다.

---

## 6. UI/UX 설계

### 6.1 피드 인라인 미리보기

`StoryRow`의 `writingView` 아래에 붙인다.

```
┌──────────────────────────────┐
│                              │
│          [스토리 사진]        │
│                              │
├──────────────────────────────┤
│ ♥ 12    💬 24        2시간 전 │
│                              │
│ 산책러버 오늘 산책 다녀왔어요!   │
│ ────────────────────────────  │
│ 산책러버 [작성자] 날씨가 좋았어요 │
│ 고양이집사 너무 귀엽네요        │
│ 댓글 24개 모두 보기          › │
└──────────────────────────────┘
```

- 하트 옆에 말풍선 아이콘(`bubble.left`) + 댓글 수. 탭하면 시트를 연다.
- 미리보기 각 줄은 **1줄 말줄임**. 닉네임은 Bold, 본문은 Regular — 기존 `writingView`(`StoryRow.swift:147-157`)의 `Text` 연결 방식을 재사용한다.
- 댓글 0개: 구분선과 미리보기 대신 `첫 댓글을 남겨보세요` 회색 한 줄. 탭하면 시트가 입력바 포커스 상태로 열린다. (AC-02)
- 댓글 1~2개: "모두 보기" 줄은 감춘다. 미리보기가 곧 전체이므로 중복이다.

### 6.2 댓글 시트

```swift
.sheet(isPresented: $isCommentSheetPresented) {
    CommentSheetView(storyID: storyID, storyWriterUID: writerUID)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
}
```

- `presentationDetents`는 iOS 16.0+ API이고 배포 타깃이 iOS 16.0(`Project.swift:36`)이므로 그대로 쓸 수 있다. 기존 `ReportSheetView`(`ReportSheetView.swift:83`)가 이미 같은 API를 쓰고 있어 패턴이 일관된다.
- 구성: 상단 헤더(`댓글 24` + 닫기) / 중앙 목록(`LazyVStack` + `ScrollView`) / 하단 고정 입력바.
- 무한 스크롤은 `StoryViewModel.loadMoreIfNeeded(currentStoryID:)`(`StoryViewModel.swift:41-45`)와 동일하게 마지막 항목의 `onAppear`로 트리거한다. (AC-10)
- 정렬은 `createdAt desc` (최신순). 피드 페이지네이션과 방향이 같아 커서 로직을 그대로 옮길 수 있다.

**입력바**

```swift
TextField("댓글을 입력해 주세요", text: $text, axis: .vertical)
    .lineLimit(1...4)
```

`axis:` 파라미터를 가진 `TextField`는 iOS 16.0+에서 사용할 수 있다. 300자에 근접하면 잔여 글자 수를 표시하고, 초과 입력은 `onChange`에서 잘라낸다. 전송 버튼은 `trimmed.isEmpty || isSending`일 때 비활성 — 기존 `WriteStoryViewModel.isShareEnabled`(`WriteStoryViewModel.swift:20-24`)와 같은 방식이다.

**키보드 회피**: `IQKeyboardManager`가 전역 활성(`AppDelegate.swift:22`)이지만 SwiftUI 시트 내부에서는 개입이 제한적이다. 시트가 키보드에 가려지는지, 입력바가 키보드 위에 정확히 붙는지는 **시뮬레이터·실기기 양쪽에서 확인해야 할 항목**으로 둔다(§12 검증 목록).

### 6.3 작성자 배지

```swift
// CommentViewModel
func isStoryAuthor(_ comment: Comment) -> Bool {
    comment.authorUID == storyWriterUID
}
```

배지는 닉네임 바로 뒤 캡슐. 색상은 앱 톤(`Color.greenblue`, `StoryView.swift:63`)을 따르고 폰트는 `HelveticaNeue-Bold` 10pt. 배지 자체는 장식이므로 VoiceOver에서는 닉네임과 합쳐 `"산책러버, 작성자"`로 읽히도록 `accessibilityLabel`을 묶는다.

### 6.4 컨텍스트 메뉴

| 대상 | 메뉴 |
|---|---|
| 내 댓글 (`authorUID == 내 UID`) | 삭제 |
| 남의 댓글 | 신고, 차단 |

`.contextMenu`로 구현한다. 삭제는 `confirmationDialog`로 한 번 확인한다(되돌릴 수 없는 동작). (AC-07, AC-08)

### 6.5 상태별 화면

| 상태 | 표시 |
|---|---|
| 최초 로딩 | 시트 중앙 `ProgressView` |
| 빈 목록 | "아직 댓글이 없어요. 첫 댓글을 남겨보세요" |
| 추가 로딩 | 목록 하단 `ProgressView` |
| 끝 도달 | 별도 문구 없음 (피드와 달리 짧은 목록이 흔함) |
| 전송 중 | 입력바 비활성 + 전송 버튼 자리 `ProgressView` |
| 전송 실패 | 토스트/알럿 + **입력 텍스트 유지** (AC-14) |

### 6.6 낙관적 업데이트 여부

기존 좋아요는 서버 성공 후 로컬을 갱신하는 보수적 방식이다(`StoryViewModel.swift:69-80`). 댓글도 **같은 방식**을 권장한다. 근거: 실패 시 롤백해야 할 상태가 목록 삽입·카운터·스크롤 위치 세 가지로 좋아요보다 많고, 댓글 전송은 사용자가 대기를 자연스럽게 받아들이는 동작이다. 다만 전송 왕복이 체감상 길어지면(대략 1초 이상) 낙관적 삽입 + 실패 시 해당 행만 붉게 표시하는 방식으로 바꾸는 것도 선택지다.

---

## 7. 알림 설계 (FCM)

### 7.1 선행 교정

```swift
// AppDelegate.swift — 현재 (프로토콜과 시그니처 불일치, 호출되지 않음)
func application(application: UIApplication,
                 didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
}

// 교정
func application(_ application: UIApplication,
                 didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
}
```

또한 이 메서드는 `UNUserNotificationCenterDelegate` extension이 아니라 `AppDelegate` 본체(또는 `UIApplicationDelegate` 관련 extension)에 두는 것이 맞다. 등록 실패 경로(`didFailToRegisterForRemoteNotificationsWithError`)도 함께 추가해 Crashlytics에 남긴다.

### 7.2 FCM 토큰 저장 흐름

```
Messaging.didReceiveRegistrationToken(fcmToken)
        │
        ├─ Auth UID 있음 → UpdateFCMTokenUseCase.execute(token)
        │                    → users/{uid}.fcmToken = token
        │                                .fcmTokenUpdatedAt = serverTimestamp
        │
        └─ Auth UID 없음 → UserDefaults에 pendingFCMToken 보관
                             → 익명 로그인 완료 시점에 flush
```

`UserRepository`에 추가:

```swift
func updateFCMToken(_ token: String) async throws
func fetchBlockedUIDs() async throws -> Set<String>
func block(uid: String) async throws
func unblock(uid: String) async throws
```

토큰은 앱 실행마다 그리고 갱신될 때마다 콜백이 오므로(`AppDelegate.swift:118-119` 주석에 이미 기술됨), 값이 이전과 같으면 쓰기를 건너뛰어 불필요한 Firestore 쓰기를 줄인다.

### 7.3 Cloud Functions

댓글 문서 생성 트리거로 스토리 작성자에게 발송한다. **클라이언트에서 직접 FCM을 보내는 방식은 서버 키를 앱에 넣어야 하므로 채택하지 않는다.**

```javascript
// functions/index.js (Node.js, Firebase Functions v2)
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

exports.onStoryCommentCreated = onDocumentCreated(
  "images/{storyID}/comments/{commentID}",
  async (event) => {
    const comment = event.data?.data();
    if (!comment) return;

    const { storyID } = event.params;
    const storySnap = await db.doc(`images/${storyID}`).get();
    const writerUID = storySnap.get("writerUUID");

    if (!writerUID) return;
    if (writerUID === comment.authorUID) return;            // AC-12: 자기 글 자기 댓글

    const [userSnap, blockedSnap] = await Promise.all([
      db.doc(`users/${writerUID}`).get(),
      db.doc(`users/${writerUID}/blocks/${comment.authorUID}`).get(),
    ]);

    if (blockedSnap.exists) return;                          // 차단한 상대의 댓글
    if (userSnap.get("commentNotificationEnabled") === false) return;  // AC-13

    const token = userSnap.get("fcmToken");
    if (!token) return;

    const body = comment.text.length > 40
      ? `${comment.text.slice(0, 40)}…`
      : comment.text;

    try {
      await admin.messaging().send({
        token,
        notification: { title: "새 댓글이 달렸어요", body: `${comment.authorNickname}: ${body}` },
        data: { type: "story_comment", storyID },
      });
    } catch (error) {
      // 무효 토큰이면 정리
      if (
        error.code === "messaging/registration-token-not-registered" ||
        error.code === "messaging/invalid-registration-token"
      ) {
        await db.doc(`users/${writerUID}`).update({
          fcmToken: admin.firestore.FieldValue.delete(),
        });
      } else {
        throw error;
      }
    }
  }
);
```

`commentCount` 집계를 이 Function에서 함께 처리할지는 §9의 보안 규칙 트레이드오프와 묶여 있다.

**요금제**: Cloud Functions 배포에 필요한 Blaze(종량제) 요금제는 **이미 적용되어 있다**. 따라서 배포를 막는 요금제 제약은 없다.

다만 Blaze는 종량제이므로 호출량에 비례해 비용이 발생한다. 댓글 알림 Function은 댓글 작성 1건당 1회 실행되고 내부에서 Firestore 문서를 3건 읽으므로(스토리·수신자·차단 여부), 예상 비용은 대략 `일일 댓글 수 x (호출 1 + 읽기 3)` 규모다. 무료 할당량(월 200만 호출, 일 5만 읽기) 안에서는 실질 비용이 0에 가깝지만, 스토리 사용량이 늘면 Firebase 콘솔에서 **예산 알림(budget alert)** 을 걸어두는 편이 안전하다.

### 7.4 옵트아웃

설정 화면에 "댓글 알림" 토글을 추가하고 `users/{uid}.commentNotificationEnabled`에 반영한다. 기본값 `true`. 필드가 없는 기존 사용자는 Function에서 `=== false` 비교로 처리하므로 자동으로 켜진 상태가 된다.

### 7.5 푸시 탭 처리

현재 `userNotificationCenter(_:didReceive:)`는 `print`만 한다(`AppDelegate.swift:103-105`).

1차 범위: **스토리 탭으로 이동**까지만 구현한다. `data.storyID`는 payload에 실어 보내되 사용하지 않는다.

특정 스토리로 스크롤하는 딥링크를 1차에서 제외하는 이유는, 피드가 인기 3건 + `createdAt desc` 커서 페이지네이션 구조(`StoryRepositoryImpl.swift:29-84`)라 임의 스토리가 몇 번째 페이지에 있는지 알 수 없고, 해당 스토리에 도달하려면 페이지를 순차로 다 불러와야 하기 때문이다. 제대로 하려면 "단일 스토리 상세 화면"을 새로 만들어 `images/{storyID}` 문서 하나만 읽어 띄우는 편이 낫고, 이는 별도 과제 규모다.

---

## 8. 정책 및 안전장치

### 8.1 App Store 심사 요건

App Review Guidelines 1.2(User-Generated Content)는 UGC를 다루는 앱에 다음을 요구한다.

| 요건 | 현재 (스토리) | 댓글 도입 후 필요 |
|---|---|---|
| 불쾌한 콘텐츠 필터링 방법 | 없음 | 금칙어 필터 (권장) |
| 신고 메커니즘 | 있음 (`ReportSheetView`) | 댓글 신고 추가 (**필수**) |
| 신고 콘텐츠의 시의적절한 제거 | 안내 문구만 있음 (`StoryGuideOverlay`의 24시간 문구) | 운영 프로세스 유지 |
| 사용자 차단 기능 | **없음** | 차단 추가 (**필수**) |
| 개발자 연락처 게시 | 앱스토어 페이지 | 유지 |

사진만 있을 때보다 **텍스트 댓글이 붙으면 심사 기준이 실질적으로 엄격해진다**. 특히 차단 기능 부재는 1.2 위반으로 반려 사유가 되므로, M3(§11)에 반드시 포함한다.

### 8.2 차단

- 저장: `users/{uid}/blocks/{blockedUID}`
- 적용: 클라이언트 필터링. 차단 목록을 앱 시작 시 한 번 읽어 메모리에 캐시하고, 피드 조합(§5.2)과 댓글 목록 양쪽에서 제외한다. (AC-09)
- 서버 측 강제는 하지 않는다. 차단은 "내 눈에 보이지 않게" 하는 기능이지 상대의 쓰기를 막는 기능이 아니며, Firestore 규칙으로 상대의 쓰기를 막으려면 규칙에서 차단 문서를 읽어야 해 규칙 평가 비용이 늘어난다.
- 진입점: 댓글 컨텍스트 메뉴, 스토리 신고 시트. 해제는 설정 화면의 "차단 목록".

### 8.3 금칙어 필터

**자체 작성 로컬 사전 기반 필터를 도입한다 (D8).** 앱 번들에 단어 목록을 넣고 전송 전에 검사해, 걸리면 전송을 막고 안내한다.

공개 사전을 그대로 들여오지 않는 이유는, 대개 다른 서비스 맥락에 맞춰져 있어 오탐이 많고(반려동물 커뮤니티에서 문제되지 않는 단어까지 걸림), 출처별 라이선스 확인 부담이 생기기 때문이다. 서비스 성격에 맞는 최소 목록으로 시작해 신고 누적 결과를 보고 넓히는 편이 낫다.

서버 필터(Cloud Functions에서 검사 후 삭제)를 1차에 두지 않는 이유는 이미 저장된 뒤 지우는 형태라 짧게라도 노출되기 때문이다. 우회 시도가 관측되면 로컬 필터를 유지한 채 서버 검사를 2차로 덧붙인다.

**구성**

| 항목 | 내용 |
|---|---|
| 저장 위치 | `BanGiDa/Resource/profanity-ko.txt` (줄바꿈 구분, 앱 번들 리소스) |
| 로딩 | 최초 사용 시 1회 로드 후 `Set<String>` 캐시 |
| 검사 시점 | 전송 버튼 탭 시. 입력 중에는 검사하지 않는다 (타이핑 도중 경고는 방해가 크다) |
| 정규화 | 소문자화 + 공백·특수문자 제거 후 부분 문자열 포함 검사 |
| 위반 시 | 전송 차단 + `CommentError.containsProhibitedWord` + "사용할 수 없는 표현이 포함되어 있어요" 안내. 어떤 단어가 걸렸는지는 **표시하지 않는다** (우회 학습을 돕게 된다) |
| 계층 | `Domain`의 `ProfanityFilter` 프로토콜 + `Data`의 번들 로딩 구현체. UseCase가 주입받아 검사 |

`CommentError`에 케이스를 추가한다.

```swift
public enum CommentError: Error {
    case emptyText
    case textTooLong
    case notAuthor
    case rateLimited
    case containsProhibitedWord   // D8
}
```

### 8.4 입력 제약

| 항목 | 값 | 근거 |
|---|---|---|
| 최대 길이 | 300자 | 단일 뎁스 댓글 UI에서 4줄 이내로 읽히는 상한 |
| 최소 길이 | trim 후 1자 | 공백 도배 방지 (AC-04) |
| 줄바꿈 | 허용, 연속 3줄 이상은 1줄로 축약 | 세로 도배 방지 |
| 연속 전송 쿨다운 | 3초 | 스팸 완화 |

### 8.5 가이드 문구 갱신

`StoryGuideOverlay`(`StoryGuideOverlay.swift:28-34`)의 이용 안내에 댓글 관련 항목을 추가한다.

```
• 댓글에서 서로를 존중해 주세요. 비방·욕설은 제재될 수 있습니다.
• 신고된 댓글은 운영자가 검토 후 삭제될 수 있습니다.
```

**이미 동의한 사용자에게도 다시 받는다 (D10).** 현재 동의 여부는 `UserDefaultsKey.storyAgreement` 불리언 하나(`UserDefaultsKey.swift:13`)라, 버전 개념을 도입한다.

```swift
enum UserDefaultsKey: String {
    case first = "first"
    case name = "name"
    case storyAgreement = "storyAgreement"              // 레거시 (마이그레이션용으로 유지)
    case storyAgreementVersion = "storyAgreementVersion" // 신규 Int
}

enum StoryGuidePolicy {
    static let currentVersion = 2   // 1: 사진 정책만, 2: 댓글 정책 포함
}
```

- 표시 조건: `storyAgreementVersion < StoryGuidePolicy.currentVersion`
- 마이그레이션: 버전 키가 없고 레거시 `storyAgreement == true`이면 버전 1로 간주한다. 즉 기존 동의자는 버전 2 안내를 **한 번** 더 보게 된다.
- `StoryView`의 `@AppStorage(UserDefaultsKey.storyAgreement.rawValue) private var hasAgreedToStoryGuide`(`StoryView.swift:16`)를 버전 비교 방식으로 교체한다.

재동의를 받는 쪽을 택한 이유는 댓글이 **새로운 종류의 UGC**이기 때문이다. 사진 정책에만 동의한 사용자에게 댓글 관련 제재 조항을 고지 없이 적용하면 근거가 약하고, 심사 대응 시에도 "댓글 정책을 언제 어떻게 고지했는가"에 답할 수 있어야 한다.

### 8.6 신고 이력 보존

**최상위 `reports` 컬렉션에 스냅샷을 병행 기록한다 (D11).**

댓글은 하드 삭제(§4.1)이고 신고 기록은 댓글 문서의 서브컬렉션에 있으므로, 신고당한 사용자가 스스로 댓글을 지우면 **신고 이력이 함께 사라진다**. 악용하면 신고를 무력화할 수 있고, 반복 위반자를 추적할 근거도 남지 않는다.

```
reports/{reportID}                      ← 신규 (최상위)
├─ targetType      : String    "story" | "comment"
├─ targetPath      : String    "images/{storyID}/comments/{commentID}"
├─ storyID         : String
├─ commentID       : String?
├─ targetAuthorUID : String    신고 대상 작성자
├─ reporterUID     : String
├─ reason          : String?
├─ contentSnapshot : String    신고 시점의 원문 (댓글 300자 상한이라 부담 없음)
└─ createdAt       : Timestamp
```

- 신고 시 서브컬렉션(중복 신고 방지용, `reports/{reporterUID}` 문서 존재 여부로 판정)과 최상위 컬렉션(운영 추적용)에 **모두** 쓴다.
- 최상위 문서는 대상이 삭제돼도 남으므로 `targetAuthorUID`로 반복 위반자를 집계할 수 있다.
- 클라이언트는 자기가 쓴 신고만 생성할 수 있고 읽기는 막는다(§9). 운영자는 콘솔에서 본다.
- 스토리 신고도 같은 컬렉션을 쓰도록 통일해, 운영자가 한 곳만 보면 되게 한다.

---

## 9. Firestore 보안 규칙 초안

현재 레포에는 규칙 파일이 없다(콘솔에서 직접 관리하는 것으로 보인다). **`firestore.rules`를 레포에 추가해 코드와 함께 버전 관리할 것을 제안한다** — 규칙 변경은 데이터 안전에 직결되는데 현재는 변경 이력이 남지 않는다.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /images/{storyID} {
      allow read: if request.auth != null;

      // 카운터 필드만 변경 허용
      allow update: if request.auth != null
        && request.resource.data.diff(resource.data).affectedKeys()
             .hasOnly(['likeCount', 'commentCount']);

      match /likes/{uid} {
        allow read: if request.auth != null;
        allow write: if request.auth != null && uid == request.auth.uid;
      }

      match /comments/{commentID} {
        allow read: if request.auth != null;

        allow create: if request.auth != null
          && request.resource.data.authorUID == request.auth.uid
          && request.resource.data.text is string
          && request.resource.data.text.size() > 0
          && request.resource.data.text.size() <= 300
          && request.resource.data.authorNickname is string
          && request.resource.data.createdAt == request.time;

        // D5: 본인 댓글만 삭제. 스토리 작성자에게 권한을 주려면
        // 여기서 상위 스토리 문서를 get()으로 읽어야 해 규칙 평가 비용이 늘어난다.
        allow delete: if request.auth != null
          && resource.data.authorUID == request.auth.uid;

        allow update: if false;   // 수정 미지원

        match /reports/{reporterUID} {
          allow create: if request.auth != null && reporterUID == request.auth.uid;
          allow read, update, delete: if false;
        }
      }

      match /reports/{reporterUID} {
        allow create: if request.auth != null && reporterUID == request.auth.uid;
        allow read, update, delete: if false;
      }
    }

    match /users/{uid} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == uid;

      match /blocks/{blockedUID} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }
    }

    // D11: 운영 추적용 신고 스냅샷. 생성만 허용하고 조회는 콘솔로만.
    match /reports/{reportID} {
      allow create: if request.auth != null
        && request.resource.data.reporterUID == request.auth.uid
        && request.resource.data.createdAt == request.time;
      allow read, update, delete: if false;
    }
  }
}
```

### 9.1 `commentCount` 집계 방식 (확정: A안)

| 안 | 방식 | 장점 | 단점 |
|---|---|---|---|
| **A** | 클라이언트 트랜잭션 + `FieldValue.increment` (좋아요와 동일) | 즉시 반영, 추가 인프라 없음, 기존 코드 패턴 재사용 | 규칙으로 "1씩만" 강제 불가. increment sentinel은 규칙에서 값 검증이 안 되므로 조작된 클라이언트가 임의 값을 넣을 수 있음 |
| **B** | Cloud Functions `onDocumentCreated`/`onDocumentDeleted`에서 집계, 클라이언트 update 차단 | 조작 불가, 알림 Function과 같은 위치 | 반영이 수백 ms~수 초 지연. 낙관적 로컬 갱신 필요 |

**채택: A안 (D7).** 좋아요가 이미 A 방식이라 같은 취약점을 이미 안고 있고, 댓글만 B로 가면 두 카운터의 신뢰 수준이 달라져 오히려 혼란스럽다. 어뷰징이 실제로 관측되면 **좋아요와 댓글을 함께** B로 옮기는 편이 일관된다. D4로 어차피 Functions를 도입하므로 전환 비용은 크지 않다.

---

## 10. 선행 리팩토링 (M0)

댓글 구현 전에 §2.2의 제약을 해소한다. 이 단계는 **기능 변화가 없는 리팩토링**이므로 별도 PR로 분리해 리뷰 범위를 좁힌다.

| # | 작업 | 대상 |
|---|---|---|
| R1 | `Story.id`를 Firestore documentID(String)로 변경, `writerUID` 추가 | `StoryTypes.swift` |
| R2 | `parseStory`에서 `document.documentID`, `writerUUID`, `commentCount` 매핑 | `StoryRepositoryImpl.swift:189-221` |
| R3 | `cacheKey(for:)` URL 파싱 제거, `execute(storyID:)`로 시그니처 변경 | `ToggleStoryLikeUseCase.swift:39-49`, `ReportStoryUseCase.swift:33-43` |
| R4 | 호출부 수정 (`imageURL` → `storyID`) | `StoryViewModel.swift:64-85`, `StoryRow.swift:91`, `ReportSheetView.swift:19-21`, `ReportViewModel.swift:14` |
| R5 | `loadedImageURLs` → `loadedStoryIDs` | `StoryViewModel.swift:22, 100` |
| R6 | `Story.mock` 갱신 | `Presentation/Main/Story/Model/Story.swift` |
| R7 | APNs 위임 메서드 시그니처 교정 + 실패 콜백 추가 | `AppDelegate.swift:93-96` |
| R8 | 단위 테스트 타깃 추가 | `Project.swift` |

R3/R4는 인터페이스가 바뀌므로 컴파일러가 누락된 호출부를 잡아준다. R1의 `id` 타입 변경(`UUID` → `String`)도 마찬가지다.

> `Story.commentCount`는 M1(댓글 작성 시 카운터가 필요해지는 시점), `Story.previewComments`는 M2(`Comment` 타입이 존재하는 시점)에 추가한다. M0에서는 `Comment` 타입이 아직 없으므로 §4.3의 최종 형태를 한 번에 만들 수 없다.

### R8 참고: 테스트 타깃

```swift
.target(
    name: "BanGiDaTests",
    destinations: .iOS,
    product: .unitTests,
    bundleId: "com.hsj.bangida.tests",
    deploymentTargets: .iOS("16.0"),
    infoPlist: .default,
    sources: ["BanGiDaTests/**/*.swift"],
    dependencies: [.target(name: "BanGiDa")]
)
```

---

## 11. 구현 마일스톤

| 단계 | 내용 | 산출물 | 검증 | 상태 |
|---|---|---|---|---|
| **M0** | 선행 리팩토링 (§10) | storyID·writerUID 노출, APNs 시그니처 교정, 테스트 타깃 | 빌드 + 테스트 2건 | ✅ `57ff4d2` |
| **M1** | 댓글 조회·작성 | `CommentTypes`, `CommentRepository(+Impl)`, `Fetch`/`WriteCommentUseCase`, `CommentSheetView`, `CommentViewModel`, `RelativeTimeFormatter` 추출, DI 등록 | 테스트 9건 + AC-03·04·05·10·14 | ✅ `0628c2e` |
| **M2** | 인라인 미리보기 + 카운터 | `fetchPreviewComments`, `FetchStoriesUseCase` 조합, `CommentPreviewView`, `StoryRow` 변경 | 테스트 12건 + AC-01·02·06 | ✅ `a00bb45` |
| **M3-1** | 삭제·신고·차단 | `Delete`/`ReportCommentUseCase`, `Block`/`UnblockUserUseCase`, `ReportTarget`, 컨텍스트 메뉴, 최상위 `reports` 스냅샷 | 테스트 19건 + AC-07·08·09 | ✅ `f69a25b` |
| **M3-2** | 정책·보안 규칙 | `ProfanityFilter`(+번들 구현체·사전), `storyAgreementVersion` 재동의, `firestore.rules` | 테스트 26건 | ✅ `0ae72db` |
| **M3-3** | 차단 목록·해제 UI | `BlockedUser`, `FetchBlockedUsersUseCase`, `BlockedUsersView`, 설정 화면 연결 | 테스트 + 수동 확인 | 진행 중 |
| **M4** | 푸시 알림 | `UpdateFCMTokenUseCase`, FCM 토큰 저장, Cloud Functions, 설정 토글 | AC-11·12·13 (실기기 필수) | 대기 |

M1~M2는 서로 의존한다. M3는 원래 한 단계였으나 범위가 M1보다 커져 세 단계로 분할했다 — 한 번에 맡기면 일부가 조용히 누락될 위험이 있었다. M3-3(차단 해제 UI)은 착수 시점에는 계획에 없었고, M3-1 구현 중 "차단은 되는데 해제할 방법이 없다"는 것이 드러나 추가됐다.

### 11.1 실제 진행에서 배운 것

- **서브에이전트는 빌드 검증을 하지 못한다** (§12.2 함정 3). 코드 작성과 `swiftc -parse`까지만 맡기고 빌드·테스트·커밋은 호출자가 맡는 분업이 자리 잡았다.
- **`swiftc -parse`를 통과해도 컴파일은 실패할 수 있다.** 타입 해석과 모듈 스코프는 검사되지 않아, M1에서 `Comment` 이름 충돌(Swift Testing에도 동명 타입이 있다)과 `import Foundation` 누락이 뒤늦게 드러났다. 이후 마일스톤 지시서에 이 두 항목을 누적해 넣자 재발하지 않았다.
- **빌드 실패의 다수는 코드가 아니라 환경 문제였다.** 시뮬레이터 런타임 불일치와 Realm 모듈맵 권한 문제가 그것이다(§12.2 함정 1·2).

---

## 12. 테스트 전략

ATDD로 §3.2 인수 기준을 고정하고 → BDD로 ViewModel·UseCase 행동을 명세하고 → TDD로 세부 구현을 검증하는 순서를 따른다.

| 계층 | 대상 | 방법 |
|---|---|---|
| UseCase | 입력 검증(빈 문자열·300자 초과), UID 부재 시 재시도, 차단 필터링, `isEnd` 보존 | Mock Repository. 모든 Repository가 프로토콜 기반이라 별도 도구 없이 가능 |
| ViewModel | 페이지네이션 누적, 전송 중 상태, 실패 시 입력 보존, 작성자 배지 판정 | Mock UseCase + `@MainActor` 테스트 |
| Repository | Firestore 쿼리·트랜잭션 | **Firebase Local Emulator Suite**. 실제 프로젝트 데이터를 건드리지 않고 규칙까지 함께 검증 가능 |
| 보안 규칙 | §9 규칙 | `@firebase/rules-unit-testing` (에뮬레이터) |
| 수동 확인 | 키보드 회피, 시트 detent 전환, 푸시 수신 | 실기기. 특히 §6.2의 IQKeyboardManager 상호작용 |

**테스트 프레임워크: Swift Testing (D9).** 신규 타깃이라 기존 XCTest 자산에 묶이지 않고, `@Test`·`#expect` 기반이라 이 프로젝트의 UseCase처럼 전부 `async throws`인 코드를 표현하기 간결하다. `#expect(throws: CommentError.textTooLong)` 형태로 오류 검증도 한 줄로 끝난다.

전제 확인 완료: 로컬 툴체인은 Xcode 26.2 / Swift 6.2.3으로 Swift Testing 요구 조건(Xcode 16 이상)을 충족한다. 두 프레임워크는 한 타깃 안에 공존할 수 있어 이후 전환·혼용에 제약은 없다.

### 12.1 단계별 최소 검증 명령

```bash
# 생성 (Project.swift 변경 시)
tuist generate --no-open

# 사용 가능한 destination 확인 — 아래 "함정 1" 참고. 이름을 추측하지 마라
xcodebuild build -workspace BanGiDa.xcworkspace -scheme BanGiDa \
  -destination 'platform=iOS Simulator,name=__INVALID__' 2>&1 \
  | sed -n '/Available destinations/,/Ineligible destinations/p'

# 테스트 타깃만 실행 — 전체 빌드보다 가볍다
# UDID로 지정해 이름 모호성을 없앤다 (iPhone 17 Pro, iOS 26.2 예시)
xcodebuild test \
  -workspace BanGiDa.xcworkspace \
  -scheme BanGiDa \
  -destination 'platform=iOS Simulator,id=7185DA6C-23CC-481F-8C1D-DCBD425EC252' \
  -only-testing:BanGiDaTests

# Firestore 에뮬레이터 (규칙 + Repository 통합)
firebase emulators:start --only firestore
```

### 12.2 검증 시 걸린 함정 (M0에서 실제로 겪음)

**함정 1 — 시뮬레이터 런타임 불일치.** Xcode 26.2에서는 iOS 17.5·18.1·18.3.1 런타임 시뮬레이터가 전부 *ineligible*로 분류된다. 기기 목록(`xcrun simctl list devices available`)에는 iPhone 16이 버젓이 보이지만 빌드에 지정하면 다음으로 실패한다.

```
xcodebuild: error: Unable to find a device matching the provided destination specifier
```

eligible한 것은 **OS 26.2 런타임**뿐이다(iPhone 16e, 17, 17 Pro, 17 Pro Max, Air). `simctl`의 available 목록과 xcodebuild의 eligible 목록이 다르다는 점에 주의한다. 위 명령처럼 일부러 잘못된 이름을 넣어 Available 섹션을 확인하는 편이 빠르다.

**함정 2 — `Executed 0 tests`는 실패가 아니다.** Swift Testing으로 작성한 테스트는 XCTest 카운터에 잡히지 않는다. 로그에 다음이 나와도 정상이다.

```
Test Suite 'All tests' passed
	 Executed 0 tests, with 0 failures (0 unexpected)
◇ Test run started.
✔ Test run with 2 tests in 1 suite passed
```

판정은 `Executed N tests`가 아니라 **`✔ Test run with N tests ... passed`** 줄로 해야 한다. 로그를 `tail`로 자르면 이 줄을 놓치기 쉬우므로 `grep -E "Test run with|✘|BUILD (SUCCEEDED|FAILED)"`로 뽑는다.

**함정 3 — codex 서브에이전트는 빌드 검증을 할 수 없다.** Codex 샌드박스는 CoreSimulatorService 접근과 외부 패키지 네트워크가 차단되어 `xcodebuild`와 `xcrun simctl`이 모두 실패한다. 서브에이전트에는 코드 작성과 `xcrun swiftc -parse` 구문 검사까지만 맡기고, 빌드·테스트는 호출자 세션에서 수행한다.

---

## 13. 리스크와 트레이드오프

| # | 리스크 | 영향 | 완화 |
|---|---|---|---|
| K1 | App Store 1.2 위반으로 반려 | 출시 지연 | 차단 기능을 M3에 **필수**로 포함. 심사 노트에 신고·차단 경로 명시 |
| K2 | Firestore 읽기 비용 증가 (§4.4 A안: 페이지당 40 reads) | 비용 | B안 전환 경로를 인터페이스 수준에서 미리 확보 |
| K3 | `commentCount` 정합성 이탈 (§9.1 A안) | 표시 오류 | 주기적 재집계 스크립트, 필요 시 B안 전환 |
| K4 | Functions 호출량 증가에 따른 종량 비용 | 비용 | Blaze는 이미 적용됨. 무료 할당량 초과 시점을 대비해 Firebase 콘솔 예산 알림 설정 (§7.3) |
| K5 | 닉네임 변경 시 과거 댓글의 이름이 옛 값으로 남음 | 사용자 혼란 | 스토리 문서도 이미 작성 시점 닉네임을 비정규화하고 있어(`StoryRepositoryImpl.swift:179`) 동작이 일관됨. "댓글은 작성 시점 닉네임으로 표시된다"를 정책으로 명시 |
| K6 | 댓글 삭제 시 신고 이력 소실 | 운영 추적 곤란 | 해소됨 — 최상위 `reports` 컬렉션에 스냅샷 병행 기록 (D11, §8.6) |
| K7 | R1의 `Story.id` 타입 변경이 예상 밖 호출부를 건드림 | 회귀 | 컴파일 에러로 전부 드러남. M0을 별도 PR로 분리 |

---

## 14. 결정 이력

착수 전 미결정으로 두었던 항목은 모두 확정되었다. 결정 내용은 §1.4 의사결정 표(D1~D11)가 단일 진실 원천이며, 아래는 어떤 선택지 중에서 무엇을 골랐는지에 대한 추적용 기록이다.

| # | 항목 | 결정 | 반영 |
|---|---|---|---|
| Q1 | 스토리 작성자의 타인 댓글 삭제 권한 | 불가 — 본인 댓글만 | D5, §9 |
| Q2 | 미리보기 조회 전략 | A — 서브컬렉션 직접 쿼리 | D6, §4.4 |
| Q3 | `commentCount` 집계 | A — 클라이언트 increment | D7, §9.1 |
| Q4 | 금칙어 사전 | 자체 작성 로컬 사전 | D8, §8.3 |
| Q5 | 테스트 프레임워크 | Swift Testing | D9, §12 |
| Q6 | 가이드 문구 재동의 | `storyAgreementVersion`으로 재동의 수집 | D10, §8.5 |
| Q7 | 신고 이력 보존 | 최상위 `reports` 스냅샷 병행 | D11, §8.6 |
| Q8 | Blaze 요금제 | 이미 적용 완료 | D4, §7.3 |

**남은 확인 사항 없음.** Xcode 툴체인 버전(Swift Testing 요구, §12)은 Xcode 26.2 / Swift 6.2.3으로 확인 완료.

---

## 부록: 참고 자료

- Apple, *App Review Guidelines* — 1.2 User-Generated Content (신고·차단·필터링 요건)
- Apple, *Human Interface Guidelines* — Sheets (detent 사용 기준)
- Apple Developer Documentation — `presentationDetents(_:)`, `TextField(_:text:axis:)` (모두 iOS 16.0+)
- Apple Developer Documentation — `UIApplicationDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`
- Firebase Documentation — Cloud Firestore: 서브컬렉션 데이터 모델링, `FieldValue.increment`, 트랜잭션
- Firebase Documentation — Cloud Firestore Security Rules: `diff().affectedKeys()`
- Firebase Documentation — Cloud Messaging: 등록 토큰 관리, 무효 토큰 처리
- Firebase Documentation — Local Emulator Suite, `@firebase/rules-unit-testing`
- 프로젝트 내부: `BanGiDa-CleanArchitecture-Refactoring.md` (계층 구조 및 명명 규칙)
