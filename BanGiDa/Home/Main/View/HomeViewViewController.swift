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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func configureUI() {
        self.navigationController?.navigationBar.isHidden = true
        mainView.homeTableView.delegate = self
        mainView.homeTableView.dataSource = self
        mainView.homeTableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.reuseIdentifier)
        
        mainView.homeTableView.calendar.delegate = self
        mainView.homeTableView.calendar.dataSource = self
        
        mainView.selectCollectionView.delegate = self
        mainView.selectCollectionView.dataSource = self
        mainView.selectCollectionView.register(HomeSelectCollectionViewCell.self, forCellWithReuseIdentifier: HomeSelectCollectionViewCell.reuseIdentifier)
        
        mainView.todayButton.addTarget(self, action: #selector(todayButtonClicked), for: .touchUpInside)
    }
    
    @objc func todayButtonClicked() {
        viewModel.todayButtonClicked(calendar: mainView.homeTableView.calendar)
    }
    
    @objc func pushNavigationController() {
        self.transViewController(ViewController: WriteViewController(), type: .push)
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
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.reuseIdentifier, for: indexPath) as? HomeTableViewCell else { return UITableViewCell() }
        
        cell.backgroundColor = .bananaYellow
        
        return cell
    }
}

extension HomeViewViewController: FSCalendarDelegate, FSCalendarDataSource {
    
}

extension HomeViewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeSelectCollectionViewCell.reuseIdentifier, for: indexPath) as? HomeSelectCollectionViewCell else { return UICollectionViewCell() }
        
        cell.selectButton.setImage(viewModel.selectButtonList[indexPath.row].image, for: .normal)
        cell.selectButton.tintColor = .white
        cell.backgroundColor = viewModel.selectButtonList[indexPath.row].color
        cell.clipsToBounds = true
        cell.layer.cornerRadius = cell.frame.height / 2
        cell.selectButton.addTarget(self, action: #selector(pushNavigationController), for: .touchUpInside)
        
        return cell
    }
}
