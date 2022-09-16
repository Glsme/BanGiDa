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
        
        print("Realm is located at:", UserMemoRepository.shared.localRealm.configuration.fileURL!)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        viewModel.fetchData()
        mainView.homeTableView.reloadData()
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
        viewModel.inputDataIntoArray()
    }
    
    @objc func todayButtonClicked() {
        mainView.homeTableView.calendar.setCurrentPage(Date(), animated: true)
    }
    
    @objc func dateSelectButtonClcicked() {
        print(#function)
    }
    
    func pushNavigationController(index: Int) {
        let vc = WriteViewController()
        vc.navigationItem.title = viewModel.selectButtonList[index].title
        vc.viewModel.currentIndex.value = index
        transViewController(ViewController: vc, type: .push)
    }
}

extension HomeViewViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.font = UIFont(name: FontList.jalnan.rawValue, size: 20)
        label.text = "헤더뷰"
        return label
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemoListTableViewCell.reuseIdentifier, for: indexPath) as? MemoListTableViewCell else { return UITableViewCell() }
        
        cell.backgroundColor = .bananaYellow
        cell.dateLabel.text = dateFormatter.string(from: viewModel.tasks[indexPath.row].date)
        cell.contentLabel.text = viewModel.tasks[indexPath.row].content
        
        return cell
    }
}

extension HomeViewViewController: FSCalendarDelegate, FSCalendarDataSource {
    
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
