// swift-tools-version: 5.10
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
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
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.50.0"),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.10.0"),
    ]
)
