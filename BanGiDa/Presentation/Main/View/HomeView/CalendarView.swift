//
//  CalendarView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit
import FSCalendar

class CalendarView: FSCalendar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        setContraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureUI() {
        scrollDirection = .vertical
        locale = Locale(identifier: "ko_KR")
        appearance.headerDateFormat = "yyyy.MM"
        appearance.eventDefaultColor = .darkPink
        appearance.eventSelectionColor = .greenblue
        appearance.headerTitleColor = .systemTintColor
        appearance.weekdayTextColor = .lightGray
        backgroundColor = .backgroundColor
        appearance.headerTitleFont = UIFont(name: "HelveticaNeue-CondensedBold", size: 30)
        appearance.weekdayFont = UIFont(name: "HelveticaNeue-Medium", size: 12)
        appearance.titleFont = UIFont(name: "HelveticaNeue-Light", size: 16)
        appearance.titleDefaultColor = .systemTintColor
        appearance.selectionColor = .pastelYellow
        appearance.todayColor = .greenblue
        headerHeight = 66
        
        calendarWeekdayView.weekdayLabels[0].text = "Sun"
        calendarWeekdayView.weekdayLabels[1].text = "Mon"
        calendarWeekdayView.weekdayLabels[2].text = "Tue"
        calendarWeekdayView.weekdayLabels[3].text = "Wen"
        calendarWeekdayView.weekdayLabels[4].text = "Thu"
        calendarWeekdayView.weekdayLabels[5].text = "Fri"
        calendarWeekdayView.weekdayLabels[6].text = "Sat"
        
        placeholderType = .none
        
    }
    
    func setContraints() {
        
    }
}
