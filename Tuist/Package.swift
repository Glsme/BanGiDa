// swift-tools-version: 5.10
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    // Xcode 27 의 iOS 27 SDK libc++ 는 realm-core 14.x 가 번들한 s2geometry 를 컴파일하지 못한다
    // (`std::is_pod` 특수화 거부, `s2polyline.cc` 의 `SearchState` 비교자 불일치 — realm-core#8101).
    // realm-core 20.1.5 는 두 곳을 모두 고쳤으므로 realm-swift 를 20.x 로 올려 해결한다.
    productTypes: [:]
)
#endif

let package = Package(
    name: "BanGiDa",
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.0.0"),
        .package(url: "https://github.com/WenchaoD/FSCalendar", from: "2.0.0"),
        .package(url: "https://github.com/marmelroy/Zip.git", from: "2.0.0"),
        .package(url: "https://github.com/vtourraine/AcknowList.git", from: "3.0.0"),
        .package(url: "https://github.com/hackiftekhar/IQKeyboardManager.git", from: "6.5.0"),
        .package(url: "https://github.com/TimOliver/TOCropViewController.git", from: "2.0.0"),
        .package(url: "https://github.com/realm/realm-swift.git", from: "20.0.5"),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.10.0"),
    ]
)
