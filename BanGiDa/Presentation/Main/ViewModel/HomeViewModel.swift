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
    
    func fetchData() {
        inputDataIntoArrayToDate(date: Date())
        homeView.homeTableView.reloadData()
    }
    
    func addDeleteSwipeAction(indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let delete = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
            var task = Diary(type: nil, date: Date(), regDate: Date(), animalName: "", content: "", photo: nil, alarmTitle: nil)
            
            switch indexPath.section {
            case 0:
                task = self.memoTaskList[indexPath.row]
            case 1:
                task = self.alarmTaskList[indexPath.row]
            case 2:
                task = self.hospitalTaskList[indexPath.row]
            case 3:
                task = self.showerTaskList[indexPath.row]
            case 4:
                task = self.pillTaskList[indexPath.row]
            case 5:
                task = self.abnormalTaskList[indexPath.row]
            default:
                break
            }
            
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
    
    func inputDataInToCell(indexPath: IndexPath, completionHandler: @escaping (String, String, String, UIImage) -> () ) {
        var dateText = ""
        var contentText = ""
        var alarmTitle = ""
        var image: UIImage = UIImage()
        
        switch indexPath.section {
        case 0:
            dateText = dateFormatter.string(from: memoTaskList[indexPath.row].date)
            contentText = memoTaskList[indexPath.row].content
            image = loadImageFromDocument(fileName: "\(memoTaskList[indexPath.row].objectId).jpg") ?? UIImage(named: "BasicDog")!
        case 1:
            dateText = dateFormatter.string(from: alarmTaskList[indexPath.row].date)
            alarmTitle = alarmTaskList[indexPath.row].alarmTitle ?? "알람"
            contentText = alarmTaskList[indexPath.row].content
        case 2:
            dateText = dateFormatter.string(from: hospitalTaskList[indexPath.row].date)
            contentText = hospitalTaskList[indexPath.row].content
            image = loadImageFromDocument(fileName: "\(memoTaskList[indexPath.row].objectId).jpg") ?? UIImage(named: "BasicDog")!
        case 3:
            dateText = dateFormatter.string(from: showerTaskList[indexPath.row].date)
            contentText = showerTaskList[indexPath.row].content
            image = loadImageFromDocument(fileName: "\(memoTaskList[indexPath.row].objectId).jpg") ?? UIImage(named: "BasicDog")!
        case 4:
            dateText = dateFormatter.string(from: pillTaskList[indexPath.row].date)
            contentText = pillTaskList[indexPath.row].content
            image = loadImageFromDocument(fileName: "\(memoTaskList[indexPath.row].objectId).jpg") ?? UIImage(named: "BasicDog")!
        case 5:
            dateText = dateFormatter.string(from: abnormalTaskList[indexPath.row].date)
            contentText = abnormalTaskList[indexPath.row].content
            image = loadImageFromDocument(fileName: "\(memoTaskList[indexPath.row].objectId).jpg") ?? UIImage(named: "BasicDog")!
        default:
            break
        }
        
        completionHandler(dateText, contentText, alarmTitle, image)
    }
    
    func enterEditMemo<T: UIViewController>(ViewController vc: T, indexPath: IndexPath) {
        let writeVC = WriteViewController()
        
        switch indexPath.section {
        case 0:
            writeVC.memoView.textView.text = memoTaskList[indexPath.row].content
            writeVC.memoView.dateTextField.text = dateFormatter.string(from: memoTaskList[indexPath.row].date)
            writeVC.memoView.imageView.image = loadImageFromDocument(fileName: "\(memoTaskList[indexPath.row].objectId).jpg")
            UserDiaryRepository.shared.primaryKey = memoTaskList[indexPath.row].objectId
        case 1:
            let alarmVC = AlarmViewController()
            alarmVC.navigationItem.title = selectButtonList[indexPath.section].title
            alarmVC.alarmView.dateTextField.text = dateAndTimeFormatter.string(from: alarmTaskList[indexPath.row].date)
            alarmVC.alarmView.memoTextView.text = alarmTaskList[indexPath.row].content
            alarmVC.alarmView.titleTextField.text = alarmTaskList[indexPath.row].alarmTitle
            UserDiaryRepository.shared.primaryKey = alarmTaskList[indexPath.row].objectId
            vc.transViewController(ViewController: alarmVC, type: .push)
            return
        case 2:
            writeVC.memoView.textView.text = hospitalTaskList[indexPath.row].content
            writeVC.memoView.dateTextField.text = dateFormatter.string(from: hospitalTaskList[indexPath.row].date)
            writeVC.memoView.imageView.image = loadImageFromDocument(fileName: "\(memoTaskList[indexPath.row].objectId).jpg")
            UserDiaryRepository.shared.primaryKey = hospitalTaskList[indexPath.row].objectId
        case 3:
            writeVC.memoView.textView.text = showerTaskList[indexPath.row].content
            writeVC.memoView.dateTextField.text = dateFormatter.string(from: showerTaskList[indexPath.row].date)
            writeVC.memoView.imageView.image = loadImageFromDocument(fileName: "\(memoTaskList[indexPath.row].objectId).jpg")
            UserDiaryRepository.shared.primaryKey = showerTaskList[indexPath.row].objectId
        case 4:
            writeVC.memoView.textView.text = pillTaskList[indexPath.row].content
            writeVC.memoView.dateTextField.text = dateFormatter.string(from: pillTaskList[indexPath.row].date)
            writeVC.memoView.imageView.image = loadImageFromDocument(fileName: "\(memoTaskList[indexPath.row].objectId).jpg")
            UserDiaryRepository.shared.primaryKey = pillTaskList[indexPath.row].objectId
        case 5:
            writeVC.memoView.textView.text = abnormalTaskList[indexPath.row].content
            writeVC.memoView.dateTextField.text = dateFormatter.string(from: abnormalTaskList[indexPath.row].date)
            writeVC.memoView.imageView.image = loadImageFromDocument(fileName: "\(memoTaskList[indexPath.row].objectId).jpg")
            UserDiaryRepository.shared.primaryKey = abnormalTaskList[indexPath.row].objectId
        default:
            break
        }
        
        writeVC.navigationItem.title = selectButtonList[indexPath.section].title
        writeVC.viewModel.currentIndex.value = indexPath.section
        
        vc.transViewController(ViewController: writeVC, type: .push)
    }
    
    func loadImageFromDocument(fileName: String) -> UIImage? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        } else {
            return UIImage(named: "BasicDog")
        }
    }
    
    func filterNotification() {
        if !alarmPrivacy.value {
            requsetAuthorization()
        }
    }
    
    func showDatePickerAlert() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.addTarget(self, action: #selector(selectDate(_ :)), for: .touchUpInside)
        
        let height : NSLayoutConstraint = NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.1, constant: 300)
        
        let ok = UIAlertAction(title: "선택 완료", style: .cancel) { action in
            
            self.currentDateString.value = self.dateFormatter.string(from: datePicker.date)
            self.currentDate.value = self.dateFormatter.date(from: self.currentDateString.value) ?? Date()
            
            print("\(self.currentDate.value) ====== \(datePicker.date)" , "@@@@@")

            self.homeView.homeTableView.calendar.setCurrentPage(self.currentDate.value, animated: true)
            self.homeView.homeTableView.calendar.select(self.currentDate.value, scrollToDate: true)
            
//            self.calendar(self.mainView.homeTableView.calendar, didSelect: Date(timeInterval: -86400, since: self.viewModel.currentDate.value), at: .current)
//
//            self.mainView.homeTableView.calendar.setCurrentPage(self.viewModel.currentDate.value, animated: true)
//            self.mainView.homeTableView.calendar.select(Date(timeInterval: 86400, since: self.viewModel.currentDate.value), scrollToDate: true)
        }
        
        alert.addAction(ok)
        
        alert.view.addSubview(datePicker)
        alert.view.addConstraint(height)
        
        return alert
    }
    
    @objc func selectDate(_ datePicker: UIDatePicker) {
//        date = datePicker.date
    }
}
