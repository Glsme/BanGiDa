//
//  HomeViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/09.
//

import UIKit
import FSCalendar

//MARK: - Home ViewModel

class HomeViewModel {
    
    let selectButtonImageList = [
        UIImage(systemName: "highlighter"),
        UIImage(systemName: "alarm.fill"),
        UIImage(systemName: "cross.case.fill"),
        UIImage(systemName: "drop.fill"),
        UIImage(systemName: "pills.fill"),
        UIImage(systemName: "stethoscope")
    ]
    
    @objc func todayButtonClicked(calendar: FSCalendar) {
        calendar.setCurrentPage(Date(), animated: true)
    }
    
    func pushViewController(completion: @escaping () -> Void ) {
        completion()
    }
}
