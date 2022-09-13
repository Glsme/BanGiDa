//
//  HomeTableView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit
import SnapKit

class HomeTableView: UITableView {
    
    let calendar: CalendarView = {
        let view = CalendarView()
        return view
    }()
    
    let calendarView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
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
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        configureUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureUI() {
        calendarView.addSubview(calendar)
        self.tableHeaderView = calendarView
        
        self.tableHeaderView?.frame.size.height = UIScreen.main.bounds.height * 0.42
        backgroundColor = .white
    }
    
    func setConstraints() {
        calendarView.snp.makeConstraints { make in
            make.height.equalTo(self.safeAreaLayoutGuide).multipliedBy(0.54)
            make.width.equalTo(self.safeAreaLayoutGuide)
            make.centerX.equalTo(self.safeAreaLayoutGuide.snp.centerX)
        }
        
        calendar.snp.makeConstraints { make in
            make.height.equalTo(calendarView).multipliedBy(0.95)
            make.width.equalTo(self.safeAreaLayoutGuide).multipliedBy(0.97)
            make.centerX.equalTo(calendarView.snp.centerX)
            make.top.equalTo(calendarView.snp.top)
        }
    }
}