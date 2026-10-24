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
        let view = SelectButtonCollectionView()
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
            make.top.bottom.equalTo(headerView)
            make.width.equalTo(headerView).multipliedBy(0.95)
            make.centerX.equalTo(headerView)
        }
        
        filterTableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            // safe area 밖(iPhone Duo 측면 바·하단)에서도 스크롤되도록 프레임은 끝까지 늘리고,
            // 셀은 테이블이 safe area 안으로 들여 놓는다.
            make.bottom.leading.trailing.equalToSuperview()
        }
    }
}
