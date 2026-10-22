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
        view.textColor = .systemTintColor
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
    
    override func prepareForReuse() {
        image.isHidden = false
        versionLabel.text = ""
        accessoryView = nil
        selectionStyle = .default
    }
    
    override func configureUI() {
        backgroundColor = .memoBackgroundColor
        
        // contentView는 테이블의 safe area만큼 안쪽에 놓이므로 세로 바 아래로 글자가 들어가지 않는다.
        [label, image, versionLabel].forEach {
            contentView.addSubview($0)
        }
    }

    override func setConstraints() {
        label.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.snp.centerY)
            make.leading.equalTo(contentView.snp.leading).offset(20)
        }

        image.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.snp.centerY)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
        }

        versionLabel.snp.makeConstraints { make in
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
            make.centerY.equalTo(contentView.snp.centerY)
        }
    }
}
