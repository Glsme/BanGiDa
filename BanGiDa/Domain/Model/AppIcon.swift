//
//  AppIcon.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/08/10.
//

import Foundation

/// 앱 아이콘 종류.
///
/// `rawValue`는 Asset Catalog의 아이콘 세트 이름이자 Remote Config가 내려주는 값이다.
/// 새 아이콘을 추가하려면 Asset Catalog에 같은 이름의 `.appiconset`을 만들고
/// `Project.swift`의 `ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES`에도 등록해야 한다.
enum AppIcon: String, CaseIterable {
    case `default` = "AppIconDefault"
    case winter = "AppIconWinter"
    case autumn = "AppIconAutumn"

    /// 기본 아이콘은 alternate가 아니라 primary이므로 nil로 표현한다.
    var alternateIconName: String? {
        self == .default ? nil : rawValue
    }

    /// `UIApplication.alternateIconName`이 돌려주는 값을 그대로 받는다.
    init(alternateIconName: String?) {
        guard let alternateIconName else {
            self = .default
            return
        }

        self.init(remoteValue: alternateIconName)
    }

    /// 원격에서 받은 임의의 문자열을 해석한다.
    /// 오타나 아직 배포되지 않은 아이콘 이름이 내려와도 앱이 깨지지 않도록 기본 아이콘으로 흡수한다.
    init(remoteValue: String) {
        self = AppIcon(rawValue: remoteValue) ?? .default
    }
}
