//
//  HomeViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/09.
//

import UIKit
import FSCalendar
import RealmSwift

//MARK: - Home ViewModel

class HomeViewModel: CommonViewModel {
    
    let homeView = HomeView()
    
    var tasks: Results<Diary>! {
        didSet {
            print("Tasks Changed")
        }
    }
    
    var memoTaskList: Results<Diary>!
    var alarmTaskList: Results<Diary>!
    var hospitalTaskList: Results<Diary>!
    var showerTaskList: Results<Diary>!
    var pillTaskList: Results<Diary>!
    var abnormalTaskList: Results<Diary>!
    
    func pushViewController(completion: @escaping () -> Void ) {
        completion()
    }
    
    func fetchData() {
        tasks = UserDiaryRepository.shared.fetch()
    }
    
    func inputDataIntoArray() {
        memoTaskList = UserDiaryRepository.shared.filter(index: 0)
        alarmTaskList = UserDiaryRepository.shared.filter(index: 1)
        hospitalTaskList = UserDiaryRepository.shared.filter(index: 2)
        showerTaskList = UserDiaryRepository.shared.filter(index: 3)
        pillTaskList = UserDiaryRepository.shared.filter(index: 4)
        abnormalTaskList = UserDiaryRepository.shared.filter(index: 5)
    }
    
    func addDeleteSwipeAction(indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let delete = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
            let task = self.tasks[indexPath.row]
            UserDiaryRepository.shared.delete(task)
            self.fetchData()
        }
        
        let image = UIImage(systemName: "trash.fill")
        delete.image = image
        delete.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func checkNumberOfRowsInsection(section: Int) -> Int {
        var index = 0
        
        switch section {
        case 0:
            index = memoTaskList.count
        case 1:
            index = alarmTaskList.count
        case 2:
            index = hospitalTaskList.count
        case 3:
            index = showerTaskList.count
        case 4:
            index = pillTaskList.count
        case 5:
            index = abnormalTaskList.count
        default:
            break
        }
        
        return index
    }
    
    func setHeaderHeight(section: Int) -> CGFloat {
        let height: CGFloat = 66
        var value: CGFloat = 0
        
        switch section {
        case 0:
            if !memoTaskList.isEmpty {
                value = height
            }
        case 1:
            if !alarmTaskList.isEmpty {
                value = height
            }
        case 2:
            if !hospitalTaskList.isEmpty {
                value = height
            }
        case 3:
            if !showerTaskList.isEmpty {
                value = height
            }
        case 4:
            if !pillTaskList.isEmpty {
                value = height
            }
        case 5:
            if !abnormalTaskList.isEmpty {
                value = height
            }
        default:
            break
        }
        
        return value
    }
    
    func setTableViewHeaderView(section: Int) -> UIView {
        let headerView = MemoHeaderView()
//        headerView.backgroundColor = .green
        headerView.headerLabel.text = selectButtonList[section].title
        headerView.circle.backgroundColor = selectButtonList[section].color
        
        return headerView
    }
}
