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
    
    override func configureUI() {
        searchView.selectCollectionView.delegate = self
        searchView.selectCollectionView.dataSource = self
        searchView.selectCollectionView.register(SelectButtonCollectionViewCell.self, forCellWithReuseIdentifier: SelectButtonCollectionViewCell.reuseIdentifier)
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.selectButtonList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectButtonCollectionViewCell.reuseIdentifier, for: indexPath) as? SelectButtonCollectionViewCell else { return UICollectionViewCell() }
        
        cell.backgroundColor = .lightGray
        cell.clipsToBounds = true
        cell.layer.cornerRadius = cell.frame.height / 2
        cell.imageView.image = viewModel.selectButtonList[indexPath.item].image
        cell.tintColor = .white
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectButtonCollectionViewCell.reuseIdentifier, for: indexPath) as? SelectButtonCollectionViewCell else { return }
        
        cell.backgroundColor = viewModel.selectButtonList[indexPath.item].color
        collectionView.reloadData()
    }
    
    
}
