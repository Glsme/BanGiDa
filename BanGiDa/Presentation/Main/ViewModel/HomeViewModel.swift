//
//  HomeViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/09.
//

import UIKit
import FSCalendar

//MARK: - Home ViewModel

class HomeViewModel: CommonViewModel {
    
    @objc func todayButtonClicked(calendar: FSCalendar) {
        calendar.setCurrentPage(Date(), animated: true)
    }
    
    func pushViewController(completion: @escaping () -> Void ) {
        completion()
    }
}
