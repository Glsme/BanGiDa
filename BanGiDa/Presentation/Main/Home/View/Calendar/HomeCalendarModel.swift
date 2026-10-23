//
//  HomeCalendarModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/10/23.
//

import Combine
import SwiftUI

// 홈 화면 캘린더의 상태. UIKit 화면(HomeViewViewController)과 SwiftUI 캘린더(HomeCalendarView)가
// 함께 쓰며, FSCalendar의 select/setCurrentPage/reloadData 역할을 대신한다.
// 좌우 페이지 넘김과 주↔월 전환 드래그는 테이블 스크롤과 함께 조율해야 해서 화면 쪽 제스처가
// 이 모델의 drag 메서드를 부르고, 캘린더 뷰는 그 상태를 그리기만 한다.
@MainActor
final class HomeCalendarModel: ObservableObject {
    struct HeightChange: Equatable {
        let height: CGFloat
        let animated: Bool
    }

    // 주↔월 전환 중 상태. 기준 날짜가 속한 달을 그려 두고 progress만큼 펼친다.
    struct ScopeTransition: Equatable {
        let month: Date
        let focusDate: Date
        let focusRow: Int
        let rows: Int
        let startProgress: CGFloat
        var progress: CGFloat
    }

    static let settleDuration: TimeInterval = 0.25

    let dateMath: CalendarDateMath
    let heightDidChange = PassthroughSubject<HeightChange, Never>()

    @Published private(set) var selectedDate: Date
    @Published private(set) var currentPage: Date
    @Published private(set) var scope: CalendarScope = .week
    @Published private(set) var metrics = CalendarLayoutMetrics(monthHeight: 0)
    @Published private(set) var pageDragOffset: CGFloat = 0
    @Published private(set) var scopeTransition: ScopeTransition?
    // 이벤트 표시를 다시 그리게 하는 값. reloadEvents()마다 바뀐다.
    @Published private(set) var eventsVersion = 0

    // 기록이 있는 날짜에 점을 찍는다. 날짜마다 저장소를 조회하므로 결과를 캐시한다.
    var eventCount: (Date) -> Int = { _ in 0 } {
        didSet { reloadEvents() }
    }
    var onSelect: (Date) -> Void = { _ in }
    var onTodayTap: () -> Void = {}
    var onDateSelectTap: () -> Void = {}

    private var eventCache: [Date: Bool] = [:]
    private var isSettling = false
    private var lastPublishedHeight: CGFloat = 0

    init(dateMath: CalendarDateMath = CalendarDateMath(), today: Date = Date()) {
        self.dateMath = dateMath
        self.selectedDate = dateMath.calendar.startOfDay(for: today)
        self.currentPage = dateMath.clampedPage(for: today, scope: .week)
    }

    var today: Date {
        dateMath.calendar.startOfDay(for: Date())
    }

    // MARK: - Height

    var height: CGFloat {
        metrics.height(progress: progress, rows: rows)
    }

    var gridHeight: CGFloat {
        metrics.gridHeight(progress: progress, rows: rows)
    }

    private var progress: CGFloat {
        if let scopeTransition {
            return scopeTransition.progress
        }
        return scope == .month ? 1 : 0
    }

    private var rows: Int {
        if let scopeTransition {
            return scopeTransition.rows
        }
        return scope == .month ? dateMath.numberOfWeeks(inMonth: currentPage) : 1
    }

    func setMonthHeight(_ monthHeight: CGFloat) {
        guard monthHeight > 0, metrics.monthHeight != monthHeight else { return }
        metrics = CalendarLayoutMetrics(monthHeight: monthHeight)
        publishHeight(animated: false)
    }

    private func publishHeight(animated: Bool) {
        let currentHeight = self.height
        guard currentHeight > 0, currentHeight != lastPublishedHeight else { return }
        lastPublishedHeight = currentHeight
        heightDidChange.send(HeightChange(height: currentHeight, animated: animated))
    }

    // MARK: - Selection & Paging

    // 사용자가 날짜를 누른 경우. 화면에 알린다.
    func tap(_ date: Date) {
        guard scopeTransition == nil else { return }
        select(date, scrollToDate: false)
        onSelect(selectedDate)
    }

    // 코드에서 날짜를 고르는 경우. FSCalendar의 select(_:scrollToDate:)처럼 onSelect를 부르지 않는다.
    func select(_ date: Date, scrollToDate: Bool = true) {
        let day = dateMath.calendar.startOfDay(for: date)
        selectedDate = day
        if scrollToDate {
            setCurrentPage(day)
        }
    }

    func setCurrentPage(_ date: Date) {
        guard scopeTransition == nil else { return }
        let page = dateMath.clampedPage(for: date, scope: scope)
        guard page != currentPage else { return }
        currentPage = page
        publishHeight(animated: true)
    }

    func page(at offset: Int) -> Date? {
        guard dateMath.canMove(from: currentPage, by: offset, scope: scope) else { return nil }
        return dateMath.page(byAdding: offset, to: currentPage, scope: scope)
    }

    func movePage(by offset: Int) {
        guard let page = page(at: offset) else { return }
        currentPage = page
        publishHeight(animated: true)
    }

    var headerMonth: Date {
        if let scopeTransition {
            return scopeTransition.month
        }
        return dateMath.headerMonth(forPage: currentPage, scope: scope)
    }

    // MARK: - Page Drag

    func updatePageDrag(translation: CGFloat) {
        guard !isSettling, scopeTransition == nil else { return }
        // 넘길 페이지가 없으면 끌리는 거리를 줄여 끝에 닿았음을 보여 준다.
        let isBlocked = (translation > 0 && page(at: -1) == nil) || (translation < 0 && page(at: 1) == nil)
        pageDragOffset = isBlocked ? translation / 3 : translation
    }

    func endPageDrag(translation: CGFloat, velocity: CGFloat, width: CGFloat) {
        guard !isSettling, scopeTransition == nil, width > 0 else { return }

        let projected = translation + velocity * 0.2
        var direction = 0
        if translation < -width / 3 || projected < -width / 2, page(at: 1) != nil {
            direction = 1
        } else if translation > width / 3 || projected > width / 2, page(at: -1) != nil {
            direction = -1
        }

        isSettling = true
        withAnimation(.easeOut(duration: Self.settleDuration)) {
            pageDragOffset = -CGFloat(direction) * width
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.settleDuration) { [weak self] in
            guard let self else { return }
            // 옆 페이지가 가운데로 온 뒤 같은 자리에서 페이지를 바꿔 끼우므로 화면이 튀지 않는다.
            self.withoutAnimation {
                if direction != 0 {
                    self.movePage(by: direction)
                }
                self.pageDragOffset = 0
            }
            self.isSettling = false
        }
    }

    // MARK: - Scope Drag

    @discardableResult
    func beginScopeTransition() -> Bool {
        guard !isSettling, scopeTransition == nil, metrics.rowHeight > 0 else { return false }

        let focusDate = dateMath.focusDate(selected: selectedDate, page: currentPage, scope: scope)
        let month = dateMath.monthStart(for: focusDate)
        let startProgress: CGFloat = scope == .month ? 1 : 0
        scopeTransition = ScopeTransition(
            month: month,
            focusDate: focusDate,
            focusRow: dateMath.weekRow(of: focusDate, inMonth: month),
            rows: dateMath.numberOfWeeks(inMonth: month),
            startProgress: startProgress,
            progress: startProgress
        )
        pageDragOffset = 0
        return true
    }

    // translation은 아래로 끌수록 커진다. 아래로 끌면 월 달력으로 펼쳐진다.
    func updateScopeTransition(translation: CGFloat) {
        guard !isSettling, var transition = scopeTransition else { return }
        let distance = metrics.transitionDistance(rows: transition.rows)
        transition.progress = min(max(transition.startProgress + translation / distance, 0), 1)
        scopeTransition = transition
        publishHeight(animated: false)
    }

    func endScopeTransition(velocity: CGFloat) {
        guard !isSettling, let transition = scopeTransition else { return }

        let distance = metrics.transitionDistance(rows: transition.rows)
        let projected = transition.progress + velocity * 0.2 / distance
        let target: CalendarScope = projected > 0.5 ? .month : .week

        isSettling = true
        withAnimation(.easeOut(duration: Self.settleDuration)) {
            scopeTransition?.progress = target == .month ? 1 : 0
        }
        publishHeight(animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + Self.settleDuration) { [weak self] in
            guard let self else { return }
            self.withoutAnimation {
                self.scope = target
                self.currentPage = self.dateMath.clampedPage(for: transition.focusDate, scope: target)
                self.scopeTransition = nil
            }
            self.isSettling = false
            self.publishHeight(animated: false)
        }
    }

    // MARK: - Events

    func hasEvent(on date: Date) -> Bool {
        let day = dateMath.calendar.startOfDay(for: date)
        if let cached = eventCache[day] {
            return cached
        }
        let hasEvent = eventCount(day) > 0
        eventCache[day] = hasEvent
        return hasEvent
    }

    func reloadEvents() {
        eventCache.removeAll()
        eventsVersion += 1
    }

    // MARK: - Private

    private func withoutAnimation(_ body: () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction, body)
    }
}
