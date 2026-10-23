//
//  HomeCalendarView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/10/23.
//

import SwiftUI
import UIKit

// FSCalendar를 대신하는 홈 화면 캘린더. 상태와 제스처 처리는 HomeCalendarModel이 맡고,
// 여기서는 헤더·요일·날짜 그리드를 그린다.
struct HomeCalendarView: View {
    @ObservedObject var model: HomeCalendarModel

    var body: some View {
        VStack(spacing: 0) {
            CalendarHeaderView(
                month: model.headerMonth,
                onDateSelectTap: { model.onDateSelectTap() },
                onTodayTap: { model.onTodayTap() }
            )
            .frame(height: CalendarLayoutMetrics.headerHeight)

            CalendarWeekdayRow()
                .frame(height: CalendarLayoutMetrics.weekdayHeight)

            grid
                .frame(height: model.gridHeight, alignment: .top)
                .clipped()

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private var grid: some View {
        if let transition = model.scopeTransition {
            // 주↔월 전환 중에는 기준 주가 위에 붙은 채로 월 달력이 펼쳐지고 접힌다.
            CalendarMonthGrid(weeks: model.dateMath.weeks(inMonth: transition.month), context: dayContext)
                .offset(y: model.metrics.gridOffset(progress: transition.progress, focusRow: transition.focusRow))
                .frame(maxHeight: .infinity, alignment: .top)
        } else {
            pager
        }
    }

    // 이전·현재·다음 페이지를 나란히 두고, 끄는 만큼 옆으로 민다.
    private var pager: some View {
        GeometryReader { proxy in
            let width = proxy.size.width

            HStack(alignment: .top, spacing: 0) {
                ForEach([-1, 0, 1], id: \.self) { offset in
                    page(at: offset)
                        .frame(width: width, alignment: .top)
                }
            }
            .frame(width: width, alignment: .leading)
            .offset(x: -width + model.pageDragOffset)
        }
    }

    @ViewBuilder
    private func page(at offset: Int) -> some View {
        if let page = model.page(at: offset) {
            switch model.scope {
            case .week:
                CalendarWeekRow(days: model.dateMath.days(inWeekStartingAt: page).map { Optional($0) }, context: dayContext)
            case .month:
                CalendarMonthGrid(weeks: model.dateMath.weeks(inMonth: page), context: dayContext)
            }
        } else {
            Color.clear
        }
    }

    private var dayContext: CalendarDayContext {
        CalendarDayContext(
            dateMath: model.dateMath,
            selectedDate: model.selectedDate,
            today: model.today,
            eventsVersion: model.eventsVersion,
            rowHeight: model.metrics.rowHeight,
            hasEvent: { date in model.hasEvent(on: date) },
            onTap: { date in model.tap(date) }
        )
    }
}

// 날짜 칸을 그리는 데 필요한 값. 선택 날짜와 이벤트 버전을 값으로 넘겨 바뀔 때마다 다시 그리게 한다.
struct CalendarDayContext {
    let dateMath: CalendarDateMath
    let selectedDate: Date
    let today: Date
    let eventsVersion: Int
    let rowHeight: CGFloat
    let hasEvent: (Date) -> Bool
    let onTap: (Date) -> Void
}

// MARK: - Header

private struct CalendarHeaderView: View {
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM"
        return formatter
    }()

    let month: Date
    let onDateSelectTap: () -> Void
    let onTodayTap: () -> Void

    var body: some View {
        ZStack {
            Text(Self.formatter.string(from: month))
                .font(.custom("HelveticaNeue-CondensedBold", size: 30))
                .foregroundColor(.systemTintColor)

            HStack(spacing: 0) {
                Button(action: onDateSelectTap) {
                    Image(systemName: "calendar")
                        .foregroundColor(.memoDarkGray)
                        .frame(width: 50, height: 50)
                }
                .accessibilityLabel("날짜 선택")

                Spacer(minLength: 0)

                Button(action: onTodayTap) {
                    Text("Today")
                        .font(.custom("HelveticaNeue-Medium", size: 14))
                        .foregroundColor(.greenblue)
                        .frame(width: 50, height: 20)
                }
            }
            .padding(.horizontal, 20)
            .offset(y: 4)
        }
    }
}

// MARK: - Weekday

private struct CalendarWeekdayRow: View {
    private static let symbols = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Self.symbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.custom("HelveticaNeue-Medium", size: 12))
                    .foregroundColor(Color(uiColor: .lightGray))
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Grid

private struct CalendarMonthGrid: View {
    let weeks: [[Date?]]
    let context: CalendarDayContext

    var body: some View {
        VStack(spacing: 0) {
            ForEach(weeks.indices, id: \.self) { row in
                CalendarWeekRow(days: weeks[row], context: context)
            }
        }
    }
}

private struct CalendarWeekRow: View {
    let days: [Date?]
    let context: CalendarDayContext

    var body: some View {
        HStack(spacing: 0) {
            ForEach(days.indices, id: \.self) { index in
                if let date = days[index] {
                    CalendarDayCell(
                        date: date,
                        day: context.dateMath.calendar.component(.day, from: date),
                        isSelected: context.dateMath.isSameDay(date, context.selectedDate),
                        isToday: context.dateMath.isSameDay(date, context.today),
                        hasEvent: context.hasEvent(date),
                        height: context.rowHeight,
                        onTap: context.onTap
                    )
                } else {
                    Color.clear
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(height: context.rowHeight)
    }
}

private struct CalendarDayCell: View {
    private static let accessibilityFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter
    }()

    let date: Date
    let day: Int
    let isSelected: Bool
    let isToday: Bool
    let hasEvent: Bool
    let height: CGFloat
    let onTap: (Date) -> Void

    var body: some View {
        // 원 아래에 이벤트 점이 들어갈 자리를 남긴다.
        let diameter = max(min(height - 10, 36), 0)

        Button {
            onTap(date)
        } label: {
            VStack(spacing: 2) {
                Text("\(day)")
                    .font(.custom("HelveticaNeue-Light", size: 16))
                    .foregroundColor(titleColor)
                    .frame(width: diameter, height: diameter)
                    .background(Circle().fill(fillColor))

                Circle()
                    .fill(hasEvent ? eventColor : Color.clear)
                    .frame(width: 5, height: 5)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Self.accessibilityFormatter.string(from: date))
        .accessibilityValue(hasEvent ? "기록 있음" : "")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var fillColor: Color {
        if isSelected { return .pastelYellow }
        if isToday { return .greenblue }
        return .clear
    }

    private var titleColor: Color {
        isSelected || isToday ? .white : .systemTintColor
    }

    private var eventColor: Color {
        isSelected ? .greenblue : .darkPink
    }
}
