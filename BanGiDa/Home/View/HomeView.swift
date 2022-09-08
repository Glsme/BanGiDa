//
//  HomeView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit
import SnapKit

class HomeView: BaseView {
    
    let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    let homeTableView: HomeTableView = {
        let view = HomeTableView(frame: .zero, style: .insetGrouped)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func configureUI() {
        [headerView, homeTableView].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(60)
        }
        
        homeTableView.snp.makeConstraints { make in
            make.bottom.trailing.leading.equalTo(self.safeAreaLayoutGuide)
            make.top.equalTo(headerView.snp.bottom)
        }
    }
}
