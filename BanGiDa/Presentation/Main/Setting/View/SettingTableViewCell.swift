//
//  SettingTableViewCell.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/13.
//

import UIKit
import SnapKit

final class SettingTableViewCell: BaseTableViewCell {
    let label: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        return view
    }()
    
    let image: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "chevron.right")
        view.tintColor = .systemTintColor
        return view
    }()
    
    let versionLabel: UILabel = {
        let view = UILabel()
        view.text = ""
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
        [label, image, versionLabel].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        label.snp.makeConstraints { make in
            make.centerY.equalTo(self.snp.centerY)
            make.leading.equalTo(self.snp.leading).offset(20)
        }
        
        image.snp.makeConstraints { make in
            make.centerY.equalTo(self.snp.centerY)
            make.trailing.equalTo(self.snp.trailing).offset(-20)
        }
        
        versionLabel.snp.makeConstraints { make in
            make.trailing.equalTo(self.snp.trailing).offset(-20)
            make.centerY.equalTo(self.snp.centerY)
        }
    }
}
