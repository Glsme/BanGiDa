//
//  SearchViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/13.
//

import UIKit

final class SearchViewModel: CommonViewModel {
    
    var isFiltering: Observable<Bool> = Observable(false)
    var currentIndex: Observable<Int?> = Observable(nil)
    
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
}
