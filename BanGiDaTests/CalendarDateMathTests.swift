import CoreGraphics
import Foundation
import Testing

@testable import BanGiDa

struct CalendarDateMathTests {
    private let math = CalendarDateMath(
        calendar: CalendarDateMath.makeCalendar(timeZone: TimeZone(identifier: "Asia/Seoul")!)
    )

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        math.calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    @Test func weekStartsOnSunday() {
        // 2026.10.23은 금요일이다.
        #expect(math.weekStart(for: date(2026, 10, 23)) == date(2026, 10, 18))
        #expect(math.weekStart(for: date(2026, 10, 18)) == date(2026, 10, 18))
    }

    @Test func pageStartFollowsScope() {
        #expect(math.pageStart(for: date(2026, 10, 23), scope: .week) == date(2026, 10, 18))
        #expect(math.pageStart(for: date(2026, 10, 23), scope: .month) == date(2026, 10, 1))
    }

    @Test func movingPagesCrossesMonthAndYear() {
        #expect(math.page(byAdding: 1, to: date(2026, 10, 25), scope: .week) == date(2026, 11, 1))
        #expect(math.page(byAdding: -1, to: date(2026, 1, 1), scope: .month) == date(2025, 12, 1))
    }

    @Test func numberOfWeeksAdaptsToMonth() {
        #expect(math.numberOfWeeks(inMonth: date(2026, 2, 1)) == 4)
        #expect(math.numberOfWeeks(inMonth: date(2026, 10, 1)) == 5)
        #expect(math.numberOfWeeks(inMonth: date(2026, 8, 1)) == 6)
    }

    @Test func monthGridLeavesOtherMonthDaysEmpty() {
        let weeks = math.weeks(inMonth: date(2026, 10, 1))

        #expect(weeks.count == 5)
        #expect(weeks.allSatisfy { $0.count == 7 })
        // 10월 1일은 목요일이므로 첫 행의 일~수는 비어 있다.
        #expect(weeks[0].prefix(4).allSatisfy { $0 == nil })
        #expect(weeks[0][4] == date(2026, 10, 1))
        #expect(weeks[4][6] == date(2026, 10, 31))
        #expect(weeks.flatMap { $0 }.compactMap { $0 }.count == 31)
    }

    @Test func weekRowLocatesDateInMonthGrid() {
        #expect(math.weekRow(of: date(2026, 10, 1), inMonth: date(2026, 10, 1)) == 0)
        #expect(math.weekRow(of: date(2026, 10, 23), inMonth: date(2026, 10, 1)) == 3)
        #expect(math.weekRow(of: date(2026, 10, 31), inMonth: date(2026, 10, 1)) == 4)
    }

    @Test func pagingStopsAtMinimumAndMaximumDates() {
        let firstWeek = math.pageStart(for: date(1970, 1, 1), scope: .week)
        let lastMonth = math.pageStart(for: date(2099, 12, 31), scope: .month)

        #expect(!math.canMove(from: firstWeek, by: -1, scope: .week))
        #expect(math.canMove(from: firstWeek, by: 1, scope: .week))
        #expect(!math.canMove(from: lastMonth, by: 1, scope: .month))
        #expect(math.canMove(from: lastMonth, by: -1, scope: .month))
    }

    @Test func focusDateUsesSelectionOnlyWhenVisible() {
        let selected = date(2026, 10, 23)

        #expect(math.focusDate(selected: selected, page: date(2026, 10, 18), scope: .week) == selected)
        #expect(math.focusDate(selected: selected, page: date(2026, 11, 1), scope: .week) == date(2026, 11, 1))
        #expect(math.focusDate(selected: selected, page: date(2026, 9, 1), scope: .month) == date(2026, 9, 1))
    }

    @Test func weekHeaderFollowsMajorityMonth() {
        // 9.27~10.3 주는 9월이 4일이라 9월로 보인다.
        #expect(math.headerMonth(forPage: date(2026, 9, 27), scope: .week) == date(2026, 9, 1))
        #expect(math.headerMonth(forPage: date(2026, 10, 25), scope: .week) == date(2026, 10, 1))
    }
}

struct CalendarLayoutMetricsTests {
    private let metrics = CalendarLayoutMetrics(monthHeight: 367)

    @Test func sixRowMonthFillsBaseHeight() {
        #expect(abs(metrics.height(progress: 1, rows: 6) - 367) < 0.001)
    }

    @Test func weekHeightKeepsSingleRow() {
        let expected = CalendarLayoutMetrics.headerHeight + CalendarLayoutMetrics.weekdayHeight + metrics.rowHeight

        #expect(abs(metrics.height(progress: 0, rows: 5) - expected) < 0.001)
        #expect(abs(metrics.height(progress: -1, rows: 5) - expected) < 0.001)
    }

    @Test func transitionInterpolatesRows() {
        let half = metrics.height(progress: 0.5, rows: 5)
        let week = metrics.height(progress: 0, rows: 5)

        #expect(abs(half - (week + metrics.rowHeight * 2)) < 0.001)
    }

    @Test func gridOffsetKeepsFocusRowOnTopWhileCollapsed() {
        #expect(abs(metrics.gridOffset(progress: 0, focusRow: 3) + metrics.rowHeight * 3) < 0.001)
        #expect(metrics.gridOffset(progress: 1, focusRow: 3) == 0)
    }
}

@MainActor
struct HomeCalendarModelTests {
    private let math = CalendarDateMath(
        calendar: CalendarDateMath.makeCalendar(timeZone: TimeZone(identifier: "Asia/Seoul")!)
    )

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        math.calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    private func makeModel() -> HomeCalendarModel {
        let model = HomeCalendarModel(dateMath: math, today: date(2026, 10, 23))
        model.setMonthHeight(367)
        return model
    }

    @Test func startsOnWeekOfToday() {
        let model = makeModel()

        #expect(model.scope == .week)
        #expect(model.currentPage == date(2026, 10, 18))
        #expect(model.selectedDate == date(2026, 10, 23))
    }

    @Test func programmaticSelectMovesPageWithoutNotifying() {
        let model = makeModel()
        var notified = false
        model.onSelect = { _ in notified = true }

        model.select(date(2026, 12, 25))

        #expect(model.currentPage == date(2026, 12, 20))
        #expect(!notified)
    }

    @Test func tapNotifiesSelection() {
        let model = makeModel()
        var selected: Date?
        model.onSelect = { selected = $0 }

        model.tap(date(2026, 10, 20))

        #expect(selected == date(2026, 10, 20))
        #expect(model.currentPage == date(2026, 10, 18))
    }

    @Test func scopeDragFollowsTranslation() {
        let model = makeModel()
        let weekHeight = model.height

        #expect(model.beginScopeTransition())
        // 10월은 5주이므로 4행만큼 끌면 월 달력이 다 펼쳐진다.
        model.updateScopeTransition(translation: model.metrics.rowHeight * 2)

        #expect(model.scopeTransition?.focusRow == 3)
        #expect(abs((model.scopeTransition?.progress ?? 0) - 0.5) < 0.001)
        #expect(abs(model.height - (weekHeight + model.metrics.rowHeight * 2)) < 0.001)
    }

    @Test func eventLookupIsCachedUntilReload() {
        let model = makeModel()
        var lookups = 0
        model.eventCount = { _ in
            lookups += 1
            return 1
        }

        #expect(model.hasEvent(on: date(2026, 10, 23)))
        #expect(model.hasEvent(on: date(2026, 10, 23)))
        #expect(lookups == 1)

        model.reloadEvents()
        _ = model.hasEvent(on: date(2026, 10, 23))
        #expect(lookups == 2)
    }
}
