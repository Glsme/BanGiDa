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
    
    let selectButtonList = [
        SelectButtonModel(imageString: "note.text", r: 133, g: 204, b: 204, alpha: 1),
        SelectButtonModel(imageString: "alarm", r: 252, g: 200, b: 141, alpha: 1),
        SelectButtonModel(imageString: "cross.case", r: 169, g: 223, b: 225, alpha: 1),
        SelectButtonModel(imageString: "drop", r: 250, g: 227, b: 175, alpha: 1),
        SelectButtonModel(imageString: "pills", r: 168, g: 215, b: 177, alpha: 1),
        SelectButtonModel(imageString: "bandage", r: 228, g: 167, b: 180, alpha: 1)
    ]
    
    @objc func todayButtonClicked(calendar: FSCalendar) {
        calendar.setCurrentPage(Date(), animated: true)
    }
    
    func pushViewController(completion: @escaping () -> Void ) {
        completion()
    }
}
