//
//  SearchViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit

class SearchViewController: BaseViewController {
    
    let searchView = SearchView()
    let viewModel = SearchViewModel()
    
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
//        print("searchView", #function)

        navigationController?.navigationBar.isHidden = true
        
        if !viewModel.isFiltering.value {
            viewModel.isFiltering.value = true
            viewModel.currentIndex.value = 0
            collectionView(searchView.selectCollectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
            searchView.selectCollectionView.reloadData()
        }
        
        searchView.filterTableView.reloadData()
    }
    
    override func configureUI() {
        searchView.selectCollectionView.delegate = self
        searchView.selectCollectionView.dataSource = self
        searchView.selectCollectionView.register(SelectButtonCollectionViewCell.self, forCellWithReuseIdentifier: SelectButtonCollectionViewCell.reuseIdentifier)
        
        searchView.filterTableView.delegate = self
        searchView.filterTableView.dataSource = self
        searchView.filterTableView.register(MemoListTableViewCell.self, forCellReuseIdentifier: MemoListTableViewCell.reuseIdentifier)
        searchView.filterTableView.register(AlarmListTableViewCell.self, forCellReuseIdentifier: AlarmListTableViewCell.reuseIdentifier)
    }
    
    func bind() {
        viewModel.currentIndex.bind { [weak self] index in
            guard let self = self else { return }
            self.searchView.filterTableView.reloadData()
        }
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.selectButtonList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectButtonCollectionViewCell.reuseIdentifier, for: indexPath) as? SelectButtonCollectionViewCell else { return UICollectionViewCell() }
        
        
        cell.backgroundColor = .lightGray
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = viewModel.selectButtonList[indexPath.item].color
        cell.selectedBackgroundView = backgroundView
        
        cell.clipsToBounds = true
        cell.layer.cornerRadius = cell.frame.height / 2
        cell.imageView.image = viewModel.selectButtonList[indexPath.item].image
        cell.tintColor = .white
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(indexPath.item)
        viewModel.isFiltering.value = true
        viewModel.currentIndex.value = indexPath.item
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        viewModel.setSelectedTableViewHeaderView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.setnumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.checkNumberOfRowsInsection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var dateText = ""
        var contentText = ""
        var alarmTitle = ""
        var image = UIImage()
        
        viewModel.inputDataInToCell(indexPath: indexPath) { selectedDateText, selectedContentText, selectedAlarmTitle, selectedImage in
            dateText = selectedDateText
            contentText = selectedContentText
            alarmTitle = selectedAlarmTitle
            image = selectedImage
        }
        
        if self.viewModel.currentIndex.value == 1 {
            guard let alarmCell = tableView.dequeueReusableCell(withIdentifier: AlarmListTableViewCell.reuseIdentifier, for: indexPath) as? AlarmListTableViewCell else { return UITableViewCell() }
            
            alarmCell.dateLabel.text = dateText
            alarmCell.contentLabel.text = alarmTitle
//            alarmCell.memoImageView.backgroundColor = .memoBackgroundColor
//            alarmCell.memoImageView.image = nil
            alarmCell.backgroundColor = .memoBackgroundColor
            
            return alarmCell
        } else {
            guard let memoCell = tableView.dequeueReusableCell(withIdentifier: MemoListTableViewCell.reuseIdentifier, for: indexPath) as? MemoListTableViewCell else { return UITableViewCell() }
            
            memoCell.backgroundColor = .memoBackgroundColor
            memoCell.dateLabel.text = dateText
            memoCell.contentLabel.text = contentText
            memoCell.memoImageView.image = image
            
            return memoCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.enterEditMemo(ViewController: self, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: nil) { [weak self] action, view, completionHandler in
            guard let self = self else { return }
            
            var task = Diary(type: nil, date: Date(), regDate: Date(), animalName: "", content: "", photo: nil, alarmTitle: nil)
            
            if let index = self.viewModel.currentIndex.value {
                switch index {
                case 0:
                    task = self.viewModel.memoTaskList[indexPath.row]
                case 1:
                    self.viewModel.removeNotification(title: self.viewModel.alarmTaskList[indexPath.row].alarmTitle ?? "",
                                                      body: self.viewModel.alarmTaskList[indexPath.row].content,
                                                      date: self.viewModel.alarmTaskList[indexPath.row].date,
                                                      index: indexPath.row)
                    task = self.viewModel.alarmTaskList[indexPath.row]
                case 2:
                    task = self.viewModel.growthTaskList[indexPath.row]
                case 3:
                    task = self.viewModel.showerTaskList[indexPath.row]
                case 4:
                    task = self.viewModel.hospitalTaskList[indexPath.row]
                case 5:
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
