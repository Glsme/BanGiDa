//
//  AlarmListTableViewCell.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/23.
//

import UIKit

class AlarmListTableViewCell: BaseTableViewCell {
    let dateLabel: UILabel = {
        let view = UILabel()
//        view.backgroundColor = .lightGray
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
        view.textColor = .memoDarkGray
        return view
    }()
    
    let contentLabel: UILabel = {
        let view = UILabel()
//        view.backgroundColor = .darkGray
        view.numberOfLines = 3
        view.textAlignment = .left
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        view.textColor = .systemTintColor
        view.numberOfLines = 1
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func configureUI() {
        [dateLabel, contentLabel].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(self).offset(10)
            make.leading.equalTo(self).offset(20)
            make.height.equalTo(20)
            make.trailing.equalTo(self.snp.trailing).offset(-20)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(dateLabel)
            make.top.equalTo(dateLabel.snp.bottom)
            make.bottom.lessThanOrEqualTo(self.snp.bottom).offset(-15)
        }
    }
}
