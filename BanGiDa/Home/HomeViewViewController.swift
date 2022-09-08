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
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func configureUI() {
        self.navigationController?.navigationBar.isHidden = true
        mainView.homeTableView.delegate = self
        mainView.homeTableView.dataSource = self
        mainView.homeTableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.reuseIdentifier)
        
        mainView.homeTableView.calendarView.delegate = self
        mainView.homeTableView.calendarView.dataSource = self
        
        mainView.selectCollectionView.delegate = self
        mainView.selectCollectionView.dataSource = self
        mainView.selectCollectionView.register(HomeSelectCollectionViewCell.self, forCellWithReuseIdentifier: HomeSelectCollectionViewCell.reuseIdentifier)
    }
}

extension HomeViewViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Header View"
        return label
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.reuseIdentifier, for: indexPath) as? HomeTableViewCell else { return UITableViewCell() }
        
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
        
        cell.backgroundColor = .lightGray
        
        return cell
    }
    
    
}
