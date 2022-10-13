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
    
    func inputDataInToCell(indexPath: IndexPath, completionHandler: @escaping (String, String, String, UIImage) -> () ) {
        var dateText = ""
        var contentText = ""
        var alarmTitle = ""
        var image = UIImage()
        
        guard let index = currentIndex.value else { return }
        
        switch index {
        case 0:
            dateText = dateFormatter.string(from: memoTaskList[indexPath.row].date)
            contentText = memoTaskList[indexPath.row].content
            image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(memoTaskList[indexPath.row].objectId).jpg") ?? UIImage(named: "BasicDog")!
        case 1:
            dateText = dateFormatter.string(from: alarmTaskList[indexPath.row].date)
            alarmTitle = alarmTaskList[indexPath.row].alarmTitle ?? "알람"
        case 2:
            dateText = dateFormatter.string(from: growthTaskList[indexPath.row].date)
            contentText = growthTaskList[indexPath.row].content
            image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(growthTaskList[indexPath.row].objectId).jpg") ?? UIImage(named: "BasicDog")!
        case 3:
            dateText = dateFormatter.string(from: showerTaskList[indexPath.row].date)
            contentText = showerTaskList[indexPath.row].content
            image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(showerTaskList[indexPath.row].objectId).jpg") ?? UIImage(named: "BasicDog")!
        case 4:
            dateText = dateFormatter.string(from: hospitalTaskList[indexPath.row].date)
            contentText = hospitalTaskList[indexPath.row].content
            image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(hospitalTaskList[indexPath.row].objectId).jpg") ?? UIImage(named: "BasicDog")!
        case 5:
            dateText = dateFormatter.string(from: abnormalTaskList[indexPath.row].date)
            contentText = abnormalTaskList[indexPath.row].content
            image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(abnormalTaskList[indexPath.row].objectId).jpg") ?? UIImage(named: "BasicDog")!
        default:
            break
        }
        
        completionHandler(dateText, contentText, alarmTitle, image)
    }
    
    func enterEditMemo<T: UIViewController>(ViewController vc: T, indexPath: IndexPath) {
        let writeVC = WriteViewController()
        
        if let index = currentIndex.value {
            switch index {
            case 0:
                writeVC.memoView.textView.text = memoTaskList[indexPath.row].content
                writeVC.memoView.dateTextField.text = dateFormatter.string(from: memoTaskList[indexPath.row].date)
                writeVC.memoView.imageView.image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(memoTaskList[indexPath.row].objectId).jpg")
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
                writeVC.memoView.textView.text = growthTaskList[indexPath.row].content
                writeVC.memoView.dateTextField.text = dateFormatter.string(from: growthTaskList[indexPath.row].date)
                writeVC.memoView.imageView.image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(growthTaskList[indexPath.row].objectId).jpg")
                UserDiaryRepository.shared.primaryKey = growthTaskList[indexPath.row].objectId
            case 3:
                writeVC.memoView.textView.text = showerTaskList[indexPath.row].content
                writeVC.memoView.dateTextField.text = dateFormatter.string(from: showerTaskList[indexPath.row].date)
                writeVC.memoView.imageView.image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(showerTaskList[indexPath.row].objectId).jpg")
                UserDiaryRepository.shared.primaryKey = showerTaskList[indexPath.row].objectId
            case 4:
                writeVC.memoView.textView.text = hospitalTaskList[indexPath.row].content
                writeVC.memoView.dateTextField.text = dateFormatter.string(from: hospitalTaskList[indexPath.row].date)
                writeVC.memoView.imageView.image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(hospitalTaskList[indexPath.row].objectId).jpg")
                UserDiaryRepository.shared.primaryKey = hospitalTaskList[indexPath.row].objectId
            case 5:
                writeVC.memoView.textView.text = abnormalTaskList[indexPath.row].content
                writeVC.memoView.dateTextField.text = dateFormatter.string(from: abnormalTaskList[indexPath.row].date)
                writeVC.memoView.imageView.image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(abnormalTaskList[indexPath.row].objectId).jpg")
                UserDiaryRepository.shared.primaryKey = abnormalTaskList[indexPath.row].objectId
            default:
                break
            }
            
            if writeVC.memoView.imageView.image == UIImage(named: "BasicDog") || writeVC.memoView.imageView.image == nil {
    //            print("image is Empty")
                writeVC.memoView.imageButton.setTitle("이미지 추가", for: .normal)
            } else {
                writeVC.memoView.imageButton.setTitle("이미지 편집", for: .normal)
            }
            
//            print("index:: \(index)")
//            writeVC.navigationItem.title = selectButtonList[index].title
            writeVC.viewModel.currentIndex.value = index
            
            vc.transViewController(ViewController: writeVC, type: .push)
        }
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
        
        if currentIndex.value == 1 {
            guard let alarmCell = tableView.dequeueReusableCell(withIdentifier: AlarmListTableViewCell.reuseIdentifier, for: indexPath) as? AlarmListTableViewCell else { return UITableViewCell() }
            
            alarmCell.configureCell(date: dateText, content: alarmTitle, alarmBackgroundColor: .memoBackgroundColor)
            
            return alarmCell
        } else {
            guard let memoCell = tableView.dequeueReusableCell(withIdentifier: MemoListTableViewCell.reuseIdentifier, for: indexPath) as? MemoListTableViewCell else { return UITableViewCell() }
            
            memoCell.configureCell(image: image, date: dateText, content: contentText, memoBackgroundColor: .memoBackgroundColor)
            
            return memoCell
        }
    }
}
