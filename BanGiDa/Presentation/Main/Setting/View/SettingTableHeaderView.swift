//
//  SettingTableHeaderView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2/22/24.
//

import UIKit

import SnapKit

final class SettingTableHeaderView: BaseView {
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
        view.textColor = UIColor.systemTintColor
        view.textAlignment = .left
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(title: String) {
        self.init()
        titleLabel.text = title
    }
    
    override func configureUI() {
        backgroundColor = .clear
        self.addSubview(titleLabel)
    }
    
    override func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
    }
}
