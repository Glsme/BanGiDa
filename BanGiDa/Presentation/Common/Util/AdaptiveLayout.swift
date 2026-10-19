//
//  AdaptiveLayout.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/10/19.
//

import CoreGraphics

// iPhone Duo처럼 접고 펼 때 화면 크기가 바뀌는 기기에서도 같은 비율을 유지하도록,
// 레이아웃 값을 화면(UIScreen)이 아니라 컨테이너 크기에서 계산한다.
enum AdaptiveLayout {
    struct CategoryItemMetrics: Equatable {
        let itemSide: CGFloat
        let spacing: CGFloat
    }

    static let calendarHeightRatio: CGFloat = 0.42
    static let categoryColumns = 6
    static let categoryMinimumSpacing: CGFloat = 10

    static func calendarHeight(containerHeight: CGFloat) -> CGFloat {
        max(containerHeight, 0) * calendarHeightRatio
    }

    // 카테고리 버튼 6개가 컨테이너 폭을 채우도록 배치한다.
    // 폭이 넓어져도 버튼이 컨테이너 높이를 넘지 않게 막고, 남는 폭은 간격으로 나눈다.
    static func categoryItemMetrics(containerSize: CGSize) -> CategoryItemMetrics {
        let width = max(containerSize.width, 0)
        let height = max(containerSize.height, 0)
        let columns = CGFloat(categoryColumns)
        let gaps = columns - 1

        let fittedSide = (width - categoryMinimumSpacing * gaps) / columns
        let itemSide = max(min(fittedSide, height), 0)
        let spacing = max((width - itemSide * columns) / gaps, categoryMinimumSpacing)

        return CategoryItemMetrics(itemSide: itemSide, spacing: spacing)
    }
}
