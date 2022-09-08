//
//  HomeTableView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit
import SnapKit

class HomeTableView: UITableView {
    
    let calendarView = CalendarView()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        configureUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureUI() {
        self.tableHeaderView = calendarView
        self.tableHeaderView?.frame.size.height = UIScreen.main.bounds.height * 0.35
    }
    
    func setConstraints() {
        
    }
}
