//
//  CalendarDateMath.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/10/23.
//

import Foundation

enum CalendarScope: Equatable {
    case week
    case month
}

// 캘린더 화면에 필요한 날짜 계산을 모은다. 주는 일요일부터 시작하고,
// 페이지는 주 단위면 그 주의 일요일, 월 단위면 그 달의 1일로 나타낸다.
struct CalendarDateMath {
    let calendar: Calendar
    let minimumDate: Date
    let maximumDate: Date

    init(
        calendar: Calendar = CalendarDateMath.makeCalendar(),
        minimumDate: Date? = nil,
        maximumDate: Date? = nil
    ) {
        self.calendar = calendar
        self.minimumDate = minimumDate
            ?? calendar.date(from: DateComponents(year: 1970, month: 1, day: 1))!
        self.maximumDate = maximumDate
            ?? calendar.date(from: DateComponents(year: 2099, month: 12, day: 31))!
    }

    static func makeCalendar(timeZone: TimeZone = .current) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.timeZone = timeZone
        calendar.firstWeekday = 1
        return calendar
    }

    // MARK: - Page

    func pageStart(for date: Date, scope: CalendarScope) -> Date {
        switch scope {
        case .week:
            return weekStart(for: date)
        case .month:
            return monthStart(for: date)
        }
    }

    func page(byAdding offset: Int, to page: Date, scope: CalendarScope) -> Date {
        let component: Calendar.Component = scope == .week ? .weekOfYear : .month
        let moved = calendar.date(byAdding: component, value: offset, to: page) ?? page
        return pageStart(for: moved, scope: scope)
    }

    // 최소·최대 날짜를 포함하는 페이지까지만 넘길 수 있다.
    func canMove(from page: Date, by offset: Int, scope: CalendarScope) -> Bool {
        let target = self.page(byAdding: offset, to: page, scope: scope)
        let first = pageStart(for: minimumDate, scope: scope)
        let last = pageStart(for: maximumDate, scope: scope)
        return target >= first && target <= last
    }

    func clampedPage(for date: Date, scope: CalendarScope) -> Date {
        let clampedDate = min(max(date, minimumDate), maximumDate)
        return pageStart(for: clampedDate, scope: scope)
    }

    // MARK: - Days

    func weekStart(for date: Date) -> Date {
        let day = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: day)
        let diff = (weekday - calendar.firstWeekday + 7) % 7
        return calendar.date(byAdding: .day, value: -diff, to: day) ?? day
    }

    func monthStart(for date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? calendar.startOfDay(for: date)
    }

    func days(inWeekStartingAt weekStart: Date) -> [Date] {
        (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    // 달력 한 장을 주 단위 행으로 돌려준다. 다른 달에 속한 칸은 nil로 비워 둔다.
    func weeks(inMonth month: Date) -> [[Date?]] {
        let start = monthStart(for: month)
        let monthValue = calendar.component(.month, from: start)

        return (0..<numberOfWeeks(inMonth: start)).map { row in
            let rowStart = calendar.date(byAdding: .day, value: row * 7, to: weekStart(for: start)) ?? start
            return days(inWeekStartingAt: rowStart).map { day in
                calendar.component(.month, from: day) == monthValue ? day : nil
            }
        }
    }

    func numberOfWeeks(inMonth month: Date) -> Int {
        let start = monthStart(for: month)
        guard let dayCount = calendar.range(of: .day, in: .month, for: start)?.count else { return 6 }
        let leading = (calendar.component(.weekday, from: start) - calendar.firstWeekday + 7) % 7
        return Int(ceil(Double(leading + dayCount) / 7))
    }

    // 월 달력에서 date가 놓이는 행(0부터).
    func weekRow(of date: Date, inMonth month: Date) -> Int {
        let firstRowStart = weekStart(for: monthStart(for: month))
        let days = calendar.dateComponents([.day], from: firstRowStart, to: weekStart(for: date)).day ?? 0
        return max(days / 7, 0)
    }

    func isSameDay(_ lhs: Date, _ rhs: Date) -> Bool {
        calendar.isDate(lhs, inSameDayAs: rhs)
    }

    func isSameMonth(_ lhs: Date, _ rhs: Date) -> Bool {
        calendar.isDate(lhs, equalTo: rhs, toGranularity: .month)
    }

    func contains(_ date: Date, inPage page: Date, scope: CalendarScope) -> Bool {
        pageStart(for: date, scope: scope) == page
    }

    // 주↔월 전환의 기준이 되는 날짜. 선택한 날이 지금 페이지에 있으면 그 날을,
    // 없으면 페이지의 첫날을 쓴다. 주가 두 달에 걸치면 기준 날짜가 속한 달로 펼친다.
    func focusDate(selected: Date, page: Date, scope: CalendarScope) -> Date {
        contains(selected, inPage: page, scope: scope) ? selected : page
    }

    // 주 페이지 헤더에 보여 줄 달. 주가 두 달에 걸치면 일수가 많은 쪽(가운데 날짜)을 따른다.
    func headerMonth(forPage page: Date, scope: CalendarScope) -> Date {
        switch scope {
        case .week:
            return monthStart(for: calendar.date(byAdding: .day, value: 3, to: page) ?? page)
        case .month:
            return page
        }
    }
}
