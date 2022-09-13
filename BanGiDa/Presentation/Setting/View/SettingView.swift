//
//  SettingView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/13.
//

import UIKit
import SnapKit

class SettingView: BaseView {
    
    let settingTableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func configureUI() {
        self.addSubview(settingTableView)
    }
    
    override func setConstraints() {
        settingTableView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
}
