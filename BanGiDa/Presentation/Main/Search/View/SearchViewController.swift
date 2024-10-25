//
//  SearchViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import Combine
import UIKit

final class SearchViewController: BaseViewController {
    
    let searchView = SearchView()
    let viewModel = SearchViewModel()
    var cancelBag = Set<AnyCancellable>()
    
    override func loadView() {
        self.view = searchView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        viewModel.inputDataIntoArray()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.isHidden = true
        
        if !viewModel.isFiltering {
            viewModel.isFiltering = true
            viewModel.currentIndex.value = 0
            collectionView(searchView.selectCollectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
            searchView.selectCollectionView.reloadData()
        }
        
        searchView.filterTableView.reloadData()
    }
    
    override func configureUI() {
        searchView.selectCollectionView.delegate = self
        searchView.selectCollectionView.dataSource = self
        
        searchView.filterTableView.delegate = self
        searchView.filterTableView.dataSource = self
    }
    
    private func bind() {
        viewModel.currentIndex.sink { [weak self] _ in
            guard let self = self else { return }
            self.searchView.filterTableView.reloadData()
        }
        .store(in: &cancelBag)
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Category.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .init())
        }

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SelectButtonCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? SelectButtonCollectionViewCell
        else { return UICollectionViewCell() }
        
        guard let category = Category(rawValue: indexPath.item) else { return cell }
        
        cell.backgroundColor = .lightGray
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = category.color
        cell.selectedBackgroundView = backgroundView
        
        cell.clipsToBounds = true
        cell.layer.cornerRadius = cell.frame.height / 2
        cell.imageView.image = UIImage(systemName: category.image) ?? UIImage()
        cell.tintColor = .white
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(indexPath.item)
        viewModel.isFiltering = true
        viewModel.currentIndex.value = indexPath.item
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let category = Category(rawValue: section) else { return nil }
        
        let headerView = MemoHeaderView()
        headerView.headerLabel.text = category.title
        headerView.circle.backgroundColor = category.color
        
        return headerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.currentIndex.value == nil ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.checkNumberOfRowsInsection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        
        if let index = viewModel.currentIndex.value, Category(rawValue: index) == .alarm {
            guard let alarmCell = tableView.dequeueReusableCell(withIdentifier: AlarmListTableViewCell.reuseIdentifier, for: indexPath) as? AlarmListTableViewCell else { return UITableViewCell() }
            alarmCell.configureCell(date: dateText, content: alarmTitle, alarmBackgroundColor: .memoBackgroundColor)
            
            return alarmCell
        } else {
            guard let memoCell = tableView.dequeueReusableCell(withIdentifier: MemoListTableViewCell.reuseIdentifier, for: indexPath) as? MemoListTableViewCell else { return UITableViewCell() }
            memoCell.configureCell(image: image, date: dateText, content: contentText, memoBackgroundColor: .memoBackgroundColor)
            
            return memoCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        enterEditMemo(ViewController: self, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: nil) { [weak self] action, view, completionHandler in
            guard let self = self else { return }
            
            var task = Diary(type: nil, date: Date(), regDate: Date(), animalName: "", content: "", photo: nil, alarmTitle: nil)
            
            if let index = self.viewModel.currentIndex.value {
                let category = Category(rawValue: index)
                switch category {
                case .memo:
                    task = self.viewModel.memoTaskList[indexPath.row]
                case .alarm:
                    self.viewModel.removeNotification(title: self.viewModel.alarmTaskList[indexPath.row].alarmTitle ?? "",
                                                      body: self.viewModel.alarmTaskList[indexPath.row].content,
                                                      date: self.viewModel.alarmTaskList[indexPath.row].date,
                                                      index: indexPath.row)
                    task = self.viewModel.alarmTaskList[indexPath.row]
                case .growth:
                    task = self.viewModel.growthTaskList[indexPath.row]
                case .shower:
                    task = self.viewModel.showerTaskList[indexPath.row]
                case .hospital:
                    task = self.viewModel.hospitalTaskList[indexPath.row]
                case .abnormal:
                    task = self.viewModel.abnormalTaskList[indexPath.row]
                default:
                    break
                }
                
                UserDiaryRepository.shared.delete(task)
                self.viewModel.inputDataIntoArray()
                self.searchView.filterTableView.reloadData()
            }            
        }
        
        let image = UIImage(systemName: "trash.fill")
        delete.image = image
        delete.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

extension SearchViewController {
    private func inputDataInToCell(indexPath: IndexPath, completionHandler: @escaping (String, String, String, UIImage) -> () ) {
        var dateText = ""
        var contentText = ""
        var alarmTitle = ""
        var image = UIImage()
        
        guard let index = viewModel.currentIndex.value else { return }
        let category = Category(rawValue: index)
        
        switch category {
        case .memo:
            dateText = dateFormatter.string(from: viewModel.memoTaskList[indexPath.row].date)
            contentText = viewModel.memoTaskList[indexPath.row].content
            image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(viewModel.memoTaskList[indexPath.row].objectId).jpg") ?? UIImage(named: "BasicDog")!
        case .alarm:
            dateText = dateFormatter.string(from: viewModel.alarmTaskList[indexPath.row].date)
            alarmTitle = viewModel.alarmTaskList[indexPath.row].alarmTitle ?? "알람"
        case .growth:
            dateText = dateFormatter.string(from: viewModel.growthTaskList[indexPath.row].date)
            contentText = viewModel.growthTaskList[indexPath.row].content
            image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(viewModel.growthTaskList[indexPath.row].objectId).jpg") ?? UIImage(named: "BasicDog")!
        case .shower:
            dateText = dateFormatter.string(from: viewModel.showerTaskList[indexPath.row].date)
            contentText = viewModel.showerTaskList[indexPath.row].content
            image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(viewModel.showerTaskList[indexPath.row].objectId).jpg") ?? UIImage(named: "BasicDog")!
        case .hospital:
            dateText = dateFormatter.string(from: viewModel.hospitalTaskList[indexPath.row].date)
            contentText = viewModel.hospitalTaskList[indexPath.row].content
            image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(viewModel.hospitalTaskList[indexPath.row].objectId).jpg") ?? UIImage(named: "BasicDog")!
        case .abnormal:
            dateText = dateFormatter.string(from: viewModel.abnormalTaskList[indexPath.row].date)
            contentText = viewModel.abnormalTaskList[indexPath.row].content
            image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(viewModel.abnormalTaskList[indexPath.row].objectId).jpg") ?? UIImage(named: "BasicDog")!
        default:
            break
        }
        
        completionHandler(dateText, contentText, alarmTitle, image)
    }
    
    private func enterEditMemo<T: UIViewController>(ViewController vc: T, indexPath: IndexPath) {
        let writeVC = WriteViewController()
        
        if let index = viewModel.currentIndex.value {
            let category = Category(rawValue: index)
            
            switch category {
            case .memo:
                writeVC.memoView.textView.text = viewModel.memoTaskList[indexPath.row].content
                writeVC.memoView.dateTextField.text = dateFormatter.string(from: viewModel.memoTaskList[indexPath.row].date)
                writeVC.memoView.imageView.image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(viewModel.memoTaskList[indexPath.row].objectId).jpg")
                UserDiaryRepository.shared.primaryKey = viewModel.memoTaskList[indexPath.row].objectId
            case .alarm:
                let alarmVC = AlarmViewController()
                alarmVC.navigationItem.title = category?.title
                alarmVC.alarmView.dateTextField.text = viewModel.dateAndTimeFormatter.string(from: viewModel.alarmTaskList[indexPath.row].date)
                alarmVC.alarmView.memoTextView.text = viewModel.alarmTaskList[indexPath.row].content
                alarmVC.alarmView.titleTextField.text = viewModel.alarmTaskList[indexPath.row].alarmTitle
                UserDiaryRepository.shared.primaryKey = viewModel.alarmTaskList[indexPath.row].objectId
                vc.transViewController(ViewController: alarmVC, type: .push)
                return
            case .growth:
                writeVC.memoView.textView.text = viewModel.growthTaskList[indexPath.row].content
                writeVC.memoView.dateTextField.text = dateFormatter.string(from: viewModel.growthTaskList[indexPath.row].date)
                writeVC.memoView.imageView.image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(viewModel.growthTaskList[indexPath.row].objectId).jpg")
                UserDiaryRepository.shared.primaryKey = viewModel.growthTaskList[indexPath.row].objectId
            case .shower:
                writeVC.memoView.textView.text = viewModel.showerTaskList[indexPath.row].content
                writeVC.memoView.dateTextField.text = dateFormatter.string(from: viewModel.showerTaskList[indexPath.row].date)
                writeVC.memoView.imageView.image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(viewModel.showerTaskList[indexPath.row].objectId).jpg")
                UserDiaryRepository.shared.primaryKey = viewModel.showerTaskList[indexPath.row].objectId
            case .hospital:
                writeVC.memoView.textView.text = viewModel.hospitalTaskList[indexPath.row].content
                writeVC.memoView.dateTextField.text = dateFormatter.string(from: viewModel.hospitalTaskList[indexPath.row].date)
                writeVC.memoView.imageView.image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(viewModel.hospitalTaskList[indexPath.row].objectId).jpg")
                UserDiaryRepository.shared.primaryKey = viewModel.hospitalTaskList[indexPath.row].objectId
            case .abnormal:
                writeVC.memoView.textView.text = viewModel.abnormalTaskList[indexPath.row].content
                writeVC.memoView.dateTextField.text = dateFormatter.string(from: viewModel.abnormalTaskList[indexPath.row].date)
                writeVC.memoView.imageView.image = UserDiaryRepository.shared.documentManager.loadImageFromDocument(fileName: "\(viewModel.abnormalTaskList[indexPath.row].objectId).jpg")
                UserDiaryRepository.shared.primaryKey = viewModel.abnormalTaskList[indexPath.row].objectId
            default:
                break
            }
            
            if writeVC.memoView.imageView.image == UIImage(named: "BasicDog") || writeVC.memoView.imageView.image == nil {
    //            print("image is Empty")
                writeVC.memoView.imageButton.setTitle("이미지 추가", for: .normal)
            } else {
                writeVC.memoView.imageButton.setTitle("이미지 편집", for: .normal)
            }
            
            writeVC.viewModel.currentIndex.value = index
            
            vc.transViewController(ViewController: writeVC, type: .push)
        }
    }
}
