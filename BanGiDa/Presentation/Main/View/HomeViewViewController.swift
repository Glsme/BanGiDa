//
//  HomeViewViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit
import FSCalendar

class HomeViewViewController: BaseViewController {
    
    let mainView = HomeView()
    let viewModel = HomeViewModel()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Realm is located at:", UserDiaryRepository.shared.localRealm.configuration.fileURL!)
        setData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        mainView.homeTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.filterNotification()
    }
    
    override func configureUI() {
        self.navigationController?.navigationBar.isHidden = true
        mainView.homeTableView.delegate = self
        mainView.homeTableView.dataSource = self
        mainView.homeTableView.register(MemoListTableViewCell.self, forCellReuseIdentifier: MemoListTableViewCell.reuseIdentifier)
        
        mainView.homeTableView.calendar.delegate = self
        mainView.homeTableView.calendar.dataSource = self
        
        mainView.selectCollectionView.delegate = self
        mainView.selectCollectionView.dataSource = self
        mainView.selectCollectionView.register(SelectButtonCollectionViewCell.self, forCellWithReuseIdentifier: SelectButtonCollectionViewCell.reuseIdentifier)
        
        mainView.todayButton.addTarget(self, action: #selector(todayButtonClicked), for: .touchUpInside)
        mainView.dateSelectButton.addTarget(self, action: #selector(dateSelectButtonClcicked), for: .touchUpInside)
    }
    
    override func setData() {
        viewModel.fetchData()
        viewModel.inputDataIntoArrayToDate(date: Date())
    }
    
    @objc func todayButtonClicked() {
        mainView.homeTableView.calendar.setCurrentPage(Date(), animated: true)
        mainView.homeTableView.calendar.select(Date(), scrollToDate: true)
    }
    
    @objc func dateSelectButtonClcicked() {
        print(#function)
        mainView.homeTableView.calendar.setCurrentPage(Date(timeIntervalSinceNow: 90000), animated: true)
        
        mainView.homeTableView.calendar.select(Date(timeIntervalSinceNow: 90000), scrollToDate: true)
    }
    
    func pushNavigationController(index: Int) {
        if index == 1 {
            let vc = AlarmViewController()
            vc.navigationItem.title = viewModel.selectButtonList[index].title
            transViewController(ViewController: vc, type: .push)
        } else {
            let vc = WriteViewController()
            vc.navigationItem.title = viewModel.selectButtonList[index].title
            vc.viewModel.currentIndex.value = index
            transViewController(ViewController: vc, type: .push)
        }
    }
}

extension HomeViewViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.setHeaderHeight(section: section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return viewModel.setTableViewHeaderView(section: section)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.checkNumberOfRowsInsection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemoListTableViewCell.reuseIdentifier, for: indexPath) as? MemoListTableViewCell else { return UITableViewCell() }
        
        cell.backgroundColor = .memoBackgroundColor
        viewModel.inputDataInToCell(indexPath: indexPath) { dateText, contentText in
            cell.dateLabel.text = dateText
            cell.contentLabel.text = contentText
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        viewModel.enterEditMemo(ViewController: self, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return viewModel.addDeleteSwipeAction(indexPath: indexPath)
    }
}

extension HomeViewViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("날짜가 선택되었습니다.")
        
        viewModel.tasks = UserDiaryRepository.shared.fetchDate(date: date)
        viewModel.inputDataIntoArrayToDate(date: date)
        print(viewModel.memoTaskList.count, viewModel.alarmTaskList.count, viewModel.hospitalTaskList.count, viewModel.showerTaskList.count, viewModel.pillTaskList.count, viewModel.abnormalTaskList.count)
        mainView.homeTableView.reloadData()
    }
}

extension HomeViewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.selectButtonList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectButtonCollectionViewCell.reuseIdentifier, for: indexPath) as? SelectButtonCollectionViewCell else { return UICollectionViewCell() }
        
        cell.backgroundColor = viewModel.selectButtonList[indexPath.row].color
        cell.clipsToBounds = true
        cell.layer.cornerRadius = cell.frame.height / 2
        cell.imageView.image = viewModel.selectButtonList[indexPath.item].image
        cell.tintColor = .white
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(#function, indexPath.item)
        pushNavigationController(index: indexPath.item)
    }
}
