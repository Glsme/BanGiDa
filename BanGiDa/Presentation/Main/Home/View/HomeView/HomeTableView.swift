//
//  HomeTableView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit

import SnapKit

final class HomeTableView: UITableView {
    
    let calendar: CalendarView = {
        let view = CalendarView()
//        view.backgroundColor = .green
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMaxXMaxYCorner, .layerMinXMaxYCorner)
        
        view.layer.shadowColor = UIColor.black.cgColor // 색깔
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSize(width: 0, height: 4) // 위치조정
        view.layer.shadowRadius = 2 // 반경
        view.layer.shadowOpacity = 0.1 // alpha값
        return view
    }()

    private var calendarHeightConstraint: Constraint?
    private var calendarHeight: CGFloat = 0

    //    let calendarView: UIView = {
    //        let view = UIView()
    //        view.backgroundColor = .blue
    //        view.clipsToBounds = true
    //        view.layer.cornerRadius = 20
    //        view.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMaxXMaxYCorner, .layerMinXMaxYCorner)
    //
    //        view.layer.shadowColor = UIColor.black.cgColor // 색깔
    //        view.layer.masksToBounds = false
    //        view.layer.shadowOffset = CGSize(width: 0, height: 4) // 위치조정
    //        view.layer.shadowRadius = 2 // 반경
    //        view.layer.shadowOpacity = 0.1 // alpha값
    //        return view
    //    }()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        configureUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureUI() {
        self.addSubview(calendar)
        tableHeaderView = calendar

        backgroundColor = .backgroundColor
        separatorColor = .systemTintColor
        separatorStyle = .singleLine
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func setConstraints() {
        //        calendarView.snp.makeConstraints { make in
        //            make.height.equalTo(self.safeAreaLayoutGuide).multipliedBy(0.54)
        //            make.width.equalTo(self.safeAreaLayoutGuide)
        //            make.centerX.equalTo(self.safeAreaLayoutGuide.snp.centerX)
        //        }
        
        calendar.snp.makeConstraints { make in
            calendarHeightConstraint = make.height.equalTo(0).constraint
            make.width.equalTo(self.safeAreaLayoutGuide)
            make.centerX.equalTo(self.safeAreaLayoutGuide.snp.centerX)
            make.top.equalTo(self.snp.top)
        }
    }

    // 처음 한 번만 컨테이너 기준 높이를 정한다. 이후 높이는 주/월 전환에 맞춰 FSCalendar가
    // boundingRectWillChange로 조정하고, 행 높이도 처음 크기를 캐시해 쓰므로 여기서 다시 덮어쓰지 않는다.
    func setInitialCalendarHeightIfNeeded(_ height: CGFloat) {
        guard height > 0, calendarHeight == 0 else { return }

        calendarHeight = height
        calendarHeightConstraint?.update(offset: height)
        calendar.frame.size.height = height
        // 테이블 헤더 높이 변경은 tableHeaderView를 다시 대입해야 반영된다.
        tableHeaderView = calendar
    }
}
