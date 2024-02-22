//
//  SettingView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/13.
//

import UIKit
import SnapKit

final class SettingView: BaseView {
    let settingCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: .init())
        return view
    }()
    
    let settingTableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.reuseIdentifier)
        view.backgroundColor = .clear
        return view
    }()
    
    let profileView = ProfileView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func configureUI() {
        [settingTableView, profileView].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        profileView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.27)
        }
        
        settingTableView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.top.equalTo(profileView.snp.bottom)
        }
    }
}
