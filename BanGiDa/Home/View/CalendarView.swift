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
        appearance.headerDateFormat = "yyyy년 M월"
        appearance.headerTitleColor = .black
        appearance.weekdayTextColor = .black
    }
    
    func setContraints() {
        
    }
}
