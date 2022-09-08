//
//  CalendarView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit
import SnapKit
import FSCalendar

class CalendarView: UIView {
    
    let calendar: FSCalendar = {
        let view = FSCalendar()
        view.scrollDirection = .vertical
        view.locale = Locale(identifier: "ko_KR")
        view.appearance.headerDateFormat = "yyyy년 M월"
        view.appearance.headerTitleColor = .black
        view.appearance.weekdayTextColor = .black
        view.appearance.todayColor = .systemPink
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        setContraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureUI() {
        self.addSubview(calendar)
    }
    
    func setContraints() {
        calendar.snp.makeConstraints { make in
            make.center.bottom.top.equalTo(self)
            make.width.equalTo(self.snp.width).multipliedBy(0.8)
        }
    }
}
