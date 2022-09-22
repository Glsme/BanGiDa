//
//  SearchViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/13.
//

import UIKit

class SearchViewModel: CommonViewModel {
    
    var isFiltering: Observable<Bool> = Observable(false)
    var currentIndex: Observable<Int?> = Observable(nil)
    
    func setSelectedTableViewHeaderView() -> UIView {
        let headerView = MemoHeaderView()
        
        guard let index = currentIndex.value else { return UIView() }
        headerView.headerLabel.text = selectButtonList[index].title
        headerView.circle.backgroundColor = selectButtonList[index].color
        
        return headerView
    }
    
    func setnumberOfSections() -> Int {
        if currentIndex.value == nil {
            return 0
        } else {
            return 1
        }
    }
    
    func inputDataInToCell(indexPath: IndexPath, completionHandler: @escaping (String, String, String) -> () ) {
        var dateText = ""
        var contentText = ""
        var alarmTitle = ""
        
        guard let index = currentIndex.value else { return }
        
        switch index {
        case 0:
            dateText = dateFormatter.string(from: memoTaskList[indexPath.row].date)
            contentText = memoTaskList[indexPath.row].content
        case 1:
            dateText = dateFormatter.string(from: alarmTaskList[indexPath.row].date)
            alarmTitle = alarmTaskList[indexPath.row].alarmTitle ?? "알람"
        case 2:
            dateText = dateFormatter.string(from: growthTaskList[indexPath.row].date)
            contentText = growthTaskList[indexPath.row].content
        case 3:
            dateText = dateFormatter.string(from: showerTaskList[indexPath.row].date)
            contentText = showerTaskList[indexPath.row].content
        case 4:
            dateText = dateFormatter.string(from: hospitalTaskList[indexPath.row].date)
            contentText = hospitalTaskList[indexPath.row].content
        case 5:
            dateText = dateFormatter.string(from: abnormalTaskList[indexPath.row].date)
            contentText = abnormalTaskList[indexPath.row].content
        default:
            break
        }
        
        completionHandler(dateText, contentText, alarmTitle)
    }
    
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
