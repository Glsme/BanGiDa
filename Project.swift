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
        ],
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release"),
        ]
    ),
    targets: [
        .target(
            name: "BanGiDa",
            destinations: .iOS,
            product: .app,
            bundleId: "com.hsj.bangida",
            deploymentTargets: .iOS("16.0"),
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
                .external(name: "SnapKit"),
                .external(name: "FSCalendar"),
                .external(name: "Zip"),
                .external(name: "AcknowList"),
                .external(name: "IQKeyboardManagerSwift"),
                .external(name: "CropViewController"),
                .external(name: "Swinject"),
                .external(name: "Realm"),
                .external(name: "RealmSwift"),
                .package(product: "FirebaseAnalytics", type: .runtime),
                .package(product: "FirebaseCrashlytics", type: .runtime),
                .package(product: "FirebaseMessaging", type: .runtime),
                .package(product: "FirebaseAuth", type: .runtime),
                .package(product: "FirebaseFirestore", type: .runtime),
                .package(product: "FirebaseStorage", type: .runtime),
                .package(product: "FirebaseRemoteConfig", type: .runtime),
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
            deploymentTargets: .iOS("16.0"),
            infoPlist: .default,
            sources: ["BanGiDaTests/**/*.swift"],
            dependencies: [
                .target(name: "BanGiDa"),
            ]
        ),
    ]
)
