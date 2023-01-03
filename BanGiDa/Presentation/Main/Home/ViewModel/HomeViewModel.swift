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
    
    func checkNumberOfRowsInsection(section: Int) -> Int {
        var index = 0
        let category = Category(rawValue: section)
        
        switch category {
        case .memo:
            index = memoTaskList.count
        case .alarm:
            index = alarmTaskList.count
        case .growth:
            index = growthTaskList.count
        case .shower:
            index = showerTaskList.count
        case .hospital:
            index = hospitalTaskList.count
        case .abnormal:
            index = abnormalTaskList.count
        default:
            break
        }
        
        return index
    }
    
    func setHeaderHeight(section: Int) -> CGFloat {
        let height: CGFloat = 66
        var value: CGFloat = 0
        let category = Category(rawValue: section)
        
        switch category {
        case .memo: value = !memoTaskList.isEmpty ? height : value
        case .alarm: value = !alarmTaskList.isEmpty ? height : value
        case .growth: value = !growthTaskList.isEmpty ? height : value
        case .shower: value = !showerTaskList.isEmpty ? height : value
        case .hospital: value = !hospitalTaskList.isEmpty ? height : value
        case .abnormal: value = !abnormalTaskList.isEmpty ? height : value
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
        let category = Category(rawValue: indexPath.section)
        
        switch category {
        case .memo:
            dateText = dateAndTimeFormatter.string(from: memoTaskList[indexPath.row].regDate)
            contentText = memoTaskList[indexPath.row].content
            image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(memoTaskList[indexPath.row].objectId).jpg") ?? UIImage(named: "BasicDog")!
        case .alarm:
            dateText = dateAndTimeFormatter.string(from: alarmTaskList[indexPath.row].regDate)
            alarmTitle = alarmTaskList[indexPath.row].alarmTitle ?? "알람"
            contentText = alarmTaskList[indexPath.row].content
        case .growth:
            dateText = dateAndTimeFormatter.string(from: growthTaskList[indexPath.row].regDate)
            contentText = growthTaskList[indexPath.row].content
            image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(growthTaskList[indexPath.row].objectId).jpg") ?? UIImage(named: "BasicDog")!
        case .shower:
            dateText = dateAndTimeFormatter.string(from: showerTaskList[indexPath.row].regDate)
            contentText = showerTaskList[indexPath.row].content
            image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(showerTaskList[indexPath.row].objectId).jpg") ?? UIImage(named: "BasicDog")!
        case .hospital:
            dateText = dateAndTimeFormatter.string(from: hospitalTaskList[indexPath.row].regDate)
            contentText = hospitalTaskList[indexPath.row].content
            image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(hospitalTaskList[indexPath.row].objectId).jpg") ?? UIImage(named: "BasicDog")!
        case .abnormal:
            dateText = dateAndTimeFormatter.string(from: abnormalTaskList[indexPath.row].regDate)
            contentText = abnormalTaskList[indexPath.row].content
            image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(abnormalTaskList[indexPath.row].objectId).jpg") ?? UIImage(named: "BasicDog")!
        default:
            break
        }
        
        completionHandler(dateText, contentText, alarmTitle, image)
    }
    
    func enterEditMemo<T: UIViewController>(ViewController vc: T, indexPath: IndexPath) {
        let writeVC = WriteViewController()
        let category = Category(rawValue: indexPath.section)
        
        switch category {
        case .memo:
            writeVC.memoView.textView.text = memoTaskList[indexPath.row].content
            writeVC.memoView.dateTextField.text = dateFormatter.string(from: memoTaskList[indexPath.row].date)
            writeVC.memoView.imageView.image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(memoTaskList[indexPath.row].objectId).jpg")
            UserDiaryRepository.shared.primaryKey = memoTaskList[indexPath.row].objectId
        case .alarm:
            let alarmVC = AlarmViewController()
            alarmVC.navigationItem.title = selectButtonList[indexPath.section].title
            alarmVC.alarmView.dateTextField.text = dateAndTimeFormatter.string(from: alarmTaskList[indexPath.row].date)
            alarmVC.alarmView.memoTextView.text = alarmTaskList[indexPath.row].content
            alarmVC.alarmView.titleTextField.text = alarmTaskList[indexPath.row].alarmTitle
            UserDiaryRepository.shared.primaryKey = alarmTaskList[indexPath.row].objectId
            vc.transViewController(ViewController: alarmVC, type: .push)
            return
        case .growth:
            writeVC.memoView.textView.text = growthTaskList[indexPath.row].content
            writeVC.memoView.dateTextField.text = dateFormatter.string(from: growthTaskList[indexPath.row].date)
            writeVC.memoView.imageView.image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(growthTaskList[indexPath.row].objectId).jpg")
            UserDiaryRepository.shared.primaryKey = growthTaskList[indexPath.row].objectId
        case .shower:
            writeVC.memoView.textView.text = showerTaskList[indexPath.row].content
            writeVC.memoView.dateTextField.text = dateFormatter.string(from: showerTaskList[indexPath.row].date)
            writeVC.memoView.imageView.image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(showerTaskList[indexPath.row].objectId).jpg")
            UserDiaryRepository.shared.primaryKey = showerTaskList[indexPath.row].objectId
        case .hospital:
            writeVC.memoView.textView.text = hospitalTaskList[indexPath.row].content
            writeVC.memoView.dateTextField.text = dateFormatter.string(from: hospitalTaskList[indexPath.row].date)
            writeVC.memoView.imageView.image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(hospitalTaskList[indexPath.row].objectId).jpg")
            UserDiaryRepository.shared.primaryKey = hospitalTaskList[indexPath.row].objectId
        case .abnormal:
            writeVC.memoView.textView.text = abnormalTaskList[indexPath.row].content
            writeVC.memoView.dateTextField.text = dateFormatter.string(from: abnormalTaskList[indexPath.row].date)
            writeVC.memoView.imageView.image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(abnormalTaskList[indexPath.row].objectId).jpg")
            UserDiaryRepository.shared.primaryKey = abnormalTaskList[indexPath.row].objectId
        default:
            break
        }
        
        if writeVC.memoView.imageView.image == UIImage(named: "BasicDog") || writeVC.memoView.imageView.image == nil {
            writeVC.memoView.imageButton.setTitle("이미지 추가", for: .normal)
        } else {
            writeVC.memoView.imageButton.setTitle("이미지 편집", for: .normal)
        }
        
        writeVC.viewModel.currentIndex.value = indexPath.section
        
        vc.transViewController(ViewController: writeVC, type: .push)
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
                        
            self.homeView.homeTableView.calendar.setCurrentPage(self.currentDate.value, animated: true)
            self.homeView.homeTableView.calendar.select(self.currentDate.value, scrollToDate: true)
        }
        
        alert.addAction(ok)
        
        alert.view.addSubview(datePicker)
        alert.view.addConstraint(height)
        
        return alert
    }
    
    @objc func selectDate(_ datePicker: UIDatePicker) {
        //        date = datePicker.date
    }
    
    func cellForRowAt(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        var dateText = ""
        var contentText = ""
        var alarmTitle = ""
        var image = UIImage()
        
        inputDataInToCell(indexPath: indexPath) { selectedDateText, selectedContentText, selectedAlarmTitle, selectedImage in
            dateText = selectedDateText
            contentText = selectedContentText
            alarmTitle = selectedAlarmTitle
            image = selectedImage
        }
        
        let category = Category(rawValue: indexPath.section)
        
        if category == .alarm {
            guard let alarmCell = tableView.dequeueReusableCell(withIdentifier: AlarmListTableViewCell.reuseIdentifier, for: indexPath) as? AlarmListTableViewCell else { return UITableViewCell() }
            
            alarmCell.configureCell(date: dateText, content: alarmTitle, alarmBackgroundColor: .memoBackgroundColor)
            
            return alarmCell
        } else {
            guard let memoCell = tableView.dequeueReusableCell(withIdentifier: MemoListTableViewCell.reuseIdentifier, for: indexPath) as? MemoListTableViewCell else { return UITableViewCell() }
            
            memoCell.configureCell(image: image, date: dateText, content: contentText, memoBackgroundColor: .memoBackgroundColor)
            
            return memoCell
        }
    }
    
    func cellForItemAt(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectButtonCollectionViewCell.reuseIdentifier, for: indexPath) as? SelectButtonCollectionViewCell else { return UICollectionViewCell() }
        
        cell.configureCell(bgColor: selectButtonList[indexPath.row].color, image: selectButtonList[indexPath.item].image)
        
        return cell
    }
}
