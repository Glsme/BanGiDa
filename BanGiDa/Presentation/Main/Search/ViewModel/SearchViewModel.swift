//
//  SearchViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/13.
//

import Foundation

final class SearchViewModel: CommonViewModel {
    
    var isFiltering: Observable<Bool> = Observable(false)
    var currentIndex: Observable<Int?> = Observable(nil)
    
    func checkNumberOfRowsInsection(section: Int) -> Int {
        if let index = currentIndex.value {
            switch index {
            case 0:
                return memoTaskList.count
            case 1:
                return alarmTaskList.count
            case 2:
                return growthTaskList.count
            case 3:
                return showerTaskList.count
            case 4:
                return hospitalTaskList.count
            case 5:
                return abnormalTaskList.count
            default:
                return 0
            }
        } else {
            return 0
        }
    }
}
