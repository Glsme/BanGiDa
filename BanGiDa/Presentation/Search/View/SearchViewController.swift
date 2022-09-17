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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchView.filterTableView.reloadData()
    }
    
    override func configureUI() {
        searchView.selectCollectionView.delegate = self
        searchView.selectCollectionView.dataSource = self
        searchView.selectCollectionView.register(SelectButtonCollectionViewCell.self, forCellWithReuseIdentifier: SelectButtonCollectionViewCell.reuseIdentifier)
        
        searchView.filterTableView.delegate = self
        searchView.filterTableView.dataSource = self
        searchView.filterTableView.register(MemoListTableViewCell.self, forCellReuseIdentifier: MemoListTableViewCell.reuseIdentifier)
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
        print(indexPath.item)
        viewModel.isFiltering.value = true
        viewModel.currentIndex.value = indexPath.item
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.setSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        viewModel.setTableViewHeaderView(section: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemoListTableViewCell.reuseIdentifier, for: indexPath) as? MemoListTableViewCell else { return UITableViewCell() }
        
        cell.backgroundColor = .bananaYellow
        
        return cell
    }
    
    
}
