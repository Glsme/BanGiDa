//
//  SearchView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/13.
//

import UIKit
import SnapKit

final class SearchView: BaseView {
    let headerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var selectCollectionView: SelectButtonCollectionView = {
        let view = SelectButtonCollectionView(frame: .zero, collectionViewLayout: selectCollectionViewLayout())
        view.register(SelectButtonCollectionViewCell.self, forCellWithReuseIdentifier: SelectButtonCollectionViewCell.reuseIdentifier)
        return view
    }()
    
    let filterTableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.register(MemoListTableViewCell.self, forCellReuseIdentifier: MemoListTableViewCell.reuseIdentifier)
        view.register(AlarmListTableViewCell.self, forCellReuseIdentifier: AlarmListTableViewCell.reuseIdentifier)
        view.rowHeight = 100
        view.backgroundColor = .backgroundColor
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func configureUI() {
        headerView.addSubview(selectCollectionView)
        [headerView, filterTableView].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(60)
        }
        
        selectCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide)
            make.trailing.bottom.equalTo(headerView)
            make.width.equalTo(self).multipliedBy(0.95)
            make.centerX.equalTo(self)
        }
        
        filterTableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.bottom.leading.trailing.equalTo(self.safeAreaLayoutGuide)
        }
    }
    
    func selectCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 10
        let width = (UIScreen.main.bounds.width * 0.95) - (spacing * 5)
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: width / 6, height: width / 6)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = 0
//        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        
        return layout
    }
}
