//
//  SettingTableViewCell.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/13.
//

import UIKit
import SnapKit

class SettingTableViewCell: BaseTableViewCell {
    let label: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func configureUI() {
        self.addSubview(label)
    }
    
    override func setConstraints() {
        label.snp.makeConstraints { make in
            make.centerY.equalTo(self.snp.centerY)
            make.leading.equalTo(self.snp.leading).offset(20)
        }
    }
}
