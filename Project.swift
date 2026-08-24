import ProjectDescription

let developmentTeam = Environment.developmentTeam.getString(default: "3K4KWAG7KD")

let project = Project(
    name: "BanGiDa",
    options: .options(
        defaultKnownRegions: ["ko"],
        developmentRegion: "ko"
    ),
    packages: [
        .remote(
            url: "https://github.com/firebase/firebase-ios-sdk",
            requirement: .upToNextMajor(from: "11.0.0")
        ),
    ],
    settings: .settings(
        base: [
            "DEVELOPMENT_TEAM": "\(developmentTeam)",
            "MARKETING_VERSION": "2.0.1",
            "CURRENT_PROJECT_VERSION": "1",
            "CODE_SIGN_STYLE": "Automatic",
            "SWIFT_EXPLICITLY_BUILT_MODULES": "NO",
            // package 접근 제어자는 같은 package name으로 컴파일된 모듈 사이에서만 보인다.
            // 프로젝트 전 타깃에 동일하게 걸어 둔다.
            "OTHER_SWIFT_FLAGS": "$(inherited) -package-name BanGiDa",
        ],
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release"),
        ]
    ),
    targets: [
        .target(
            name: "CoreKit",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.hsj.bangida.corekit",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Projects/Core/CoreKit/Sources/**/*.swift"],
            dependencies: []
        ),
        .target(
            name: "Domain",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.hsj.bangida.domain",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Projects/Domain/Sources/**/*.swift"],
            dependencies: []
        ),
        .target(
            name: "Data",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.hsj.bangida.data",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Projects/Data/Sources/**/*.swift"],
            dependencies: [
                .target(name: "Domain"),
                .target(name: "CoreKit"),
                .external(name: "Realm"),
                .external(name: "RealmSwift"),
                .external(name: "Zip"),
                .package(product: "FirebaseAnalytics", type: .runtime),
                .package(product: "FirebaseCrashlytics", type: .runtime),
                .package(product: "FirebaseAuth", type: .runtime),
                .package(product: "FirebaseFirestore", type: .runtime),
                .package(product: "FirebaseStorage", type: .runtime),
                .package(product: "FirebaseRemoteConfig", type: .runtime),
                .package(product: "FirebaseMessaging", type: .runtime),
            ],
            settings: .settings(
                base: [
                    // Firebase의 Obj-C 카테고리가 링크에서 빠지지 않게 한다 (앱 타깃과 동일).
                    "OTHER_LDFLAGS": "$(inherited) -ObjC",
                ]
            )
        ),
        .target(
            name: "DesignSystem",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.hsj.bangida.designsystem",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Projects/Core/DesignSystem/Sources/**/*.swift"],
            dependencies: []
        ),
        .target(
            name: "BanGiDa",
            destinations: .iOS,
            product: .app,
            bundleId: "com.hsj.bangida",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                "ITSAppUsesNonExemptEncryption": false,
                "UIAppFonts": .array([.string("Jalnan.ttf")]),
                "UIApplicationSceneManifest": .dictionary([
                    "UIApplicationSupportsMultipleScenes": false,
                    "UISceneConfigurations": .dictionary([
                        "UIWindowSceneSessionRoleApplication": .array([
                            .dictionary([
                                "UISceneConfigurationName": "Default Configuration",
                                "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate",
                            ]),
                        ]),
                    ]),
                ]),
                "UIBackgroundModes": .array([.string("remote-notification")]),
                "NSPhotoLibraryUsageDescription": "스토리에 사용할 사진을 선택하기 위해 사진 접근이 필요합니다.",
                "UILaunchStoryboardName": "LaunchScreen",
            ]),
            sources: ["BanGiDa/**/*.swift"],
            resources: [
                "BanGiDa/Assets.xcassets",
                "BanGiDa/Resource/**",
                "BanGiDa/Base.lproj/**",
                "BanGiDa/GoogleService-Info.plist",
                "BanGiDa/PrivacyInfo.xcprivacy",
            ],
            entitlements: .file(path: "BanGiDa/BanGiDa.entitlements"),
            dependencies: [
                .target(name: "CoreKit"),
                .target(name: "DesignSystem"),
                .target(name: "Domain"),
                .target(name: "Data"),
                .external(name: "SnapKit"),
                .external(name: "FSCalendar"),
                .external(name: "AcknowList"),
                .external(name: "IQKeyboardManagerSwift"),
                .external(name: "CropViewController"),
                .external(name: "Swinject"),
                // Realm·Zip·Firebase는 Data 모듈이 소유한다.
                // Firebase 산출물이 정적이라 두 타깃이 함께 링크하면 어떤 구성으로도
                // 링크가 성립하지 않는다. 앱 셸은 Firebase를 직접 참조하지 않는다.
            ],
            settings: .settings(
                base: [
                    "OTHER_LDFLAGS": "$(inherited) -ObjC",
                    "TARGETED_DEVICE_FAMILY": "1",
                    // 계절 아이콘은 Asset Catalog에 두고, CFBundleAlternateIcons는 빌드 시 생성시킨다.
                    "ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES": .array([
                        "AppIconWinter",
                        "AppIconAutumn",
                    ]),
                ]
            )
        ),
        .target(
            name: "BanGiDaTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.hsj.bangida.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["BanGiDaTests/**/*.swift"],
            dependencies: [
                .target(name: "BanGiDa"),
                .target(name: "Domain"),
                .target(name: "Data"),
                .target(name: "CoreKit"),
            ]
        ),
    ]
)
