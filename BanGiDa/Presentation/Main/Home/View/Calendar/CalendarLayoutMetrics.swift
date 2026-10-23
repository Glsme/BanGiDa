//
//  CalendarLayoutMetrics.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/10/23.
//

import CoreGraphics

// 캘린더 높이 계산. 기준 높이(monthHeight)는 6주짜리 월 달력이 꽉 차는 높이이고,
// 행 높이는 여기서 나눠 정한다. 주 달력은 한 행, 월 달력은 그 달의 주 수만큼 행을 갖는다.
struct CalendarLayoutMetrics: Equatable {
    static let headerHeight: CGFloat = 66
    static let weekdayHeight: CGFloat = 25
    static let maximumRows = 6

    let monthHeight: CGFloat

    var rowHeight: CGFloat {
        let available = monthHeight - Self.headerHeight - Self.weekdayHeight
        return max(available / CGFloat(Self.maximumRows), 0)
    }

    // progress 0은 주 달력, 1은 rows 행짜리 월 달력이다.
    func height(progress: CGFloat, rows: Int) -> CGFloat {
        Self.headerHeight + Self.weekdayHeight + gridHeight(progress: progress, rows: rows)
    }

    func gridHeight(progress: CGFloat, rows: Int) -> CGFloat {
        let clamped = min(max(progress, 0), 1)
        let extraRows = CGFloat(max(rows - 1, 0)) * clamped
        return rowHeight * (1 + extraRows)
    }

    // 드래그로 주↔월을 끝까지 전환하는 데 필요한 거리.
    func transitionDistance(rows: Int) -> CGFloat {
        max(rowHeight * CGFloat(max(rows - 1, 1)), 1)
    }

    // 전환 중 기준 주가 위쪽에 남아 있도록 월 달력을 위로 미는 거리.
    func gridOffset(progress: CGFloat, focusRow: Int) -> CGFloat {
        let clamped = min(max(progress, 0), 1)
        return -rowHeight * CGFloat(focusRow) * (1 - clamped)
    }
}
