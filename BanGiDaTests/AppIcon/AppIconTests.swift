//
//  AppIconTests.swift
//  BanGiDaTests
//
//  Created by Seokjune Hong on 2026/08/10.
//

import Testing

@testable import BanGiDa

struct AppIconTests {

    @Test("기본 아이콘은 primary이므로 alternateIconName이 nil이다")
    func defaultIconHasNoAlternateName() {
        #expect(AppIcon.default.alternateIconName == nil)
    }

    @Test("계절 아이콘의 alternateIconName은 Asset Catalog 이름과 같다")
    func seasonalIconsUseAssetName() {
        #expect(AppIcon.winter.alternateIconName == "AppIconWinter")
        #expect(AppIcon.autumn.alternateIconName == "AppIconAutumn")
    }

    @Test("원격에서 알 수 없는 값이 오면 기본 아이콘으로 흡수한다")
    func unknownRemoteValueFallsBackToDefault() {
        #expect(AppIcon(remoteValue: "AppIconSpring") == .default)
        #expect(AppIcon(remoteValue: "") == .default)
        #expect(AppIcon(remoteValue: "appiconwinter") == .default)
    }

    @Test("시스템이 돌려준 alternateIconName을 그대로 해석한다")
    func parsesSystemAlternateIconName() {
        #expect(AppIcon(alternateIconName: nil) == .default)
        #expect(AppIcon(alternateIconName: "AppIconWinter") == .winter)
        #expect(AppIcon(alternateIconName: "AppIconAutumn") == .autumn)
    }
}
