//
//  MemoListTableViewCell.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/14.
//

import UIKit

class MemoListTableViewCell: BaseTableViewCell {
    let memoImageView: UIImageView = {
        let view = UIImageView()
//        view.backgroundColor = .darkGray
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        return view
    }()
    
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
        view.numberOfLines = 2
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        view.textColor = .systemTintColor
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
//        memoImageView.snp.makeConstraints { make in
//            make.centerY.equalTo(self.snp.centerY)
//            make.trailing.equalTo(self).offset(-10)
//            make.top.equalTo(self).offset(10)
//            make.bottom.equalTo(self).offset(-10)
//            make.width.equalTo(memoImageView.snp.height)
//        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(self).offset(10)
            make.leading.equalTo(self).offset(10)
            make.height.equalTo(20)
            make.trailing.equalTo(self.snp.trailing).offset(-20)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(dateLabel)
            make.top.equalTo(dateLabel.snp.bottom).offset(5)
            make.bottom.equalTo(self.snp.bottom).offset(-10)
        }
        
    }
}
