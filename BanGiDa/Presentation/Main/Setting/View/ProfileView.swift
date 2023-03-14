//
//  ProfileView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2023/03/14.
//

import UIKit

import SnapKit

final class ProfileView: UICollectionViewCell {
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "BasicDog")
        view.tintColor = .ultraLightGray
        view.layer.borderColor = UIColor.ultraLightGray.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 5
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        view.textColor = .systemTintColor
        view.text = UserDefaults.standard.string(forKey: UserDefaultsKey.name.rawValue) ?? ""
        view.textAlignment = .left
        return view
    }()
    
    lazy var imageButton: UIButton = {
        let view = UIButton()
        view.setTitle("프로필 이미지 변경", for: .normal)
        view.setTitleColor(UIColor.unaBlue, for: .normal)
        view.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        [imageView, nameLabel, imageButton].forEach {
            self.addSubview($0)
        }
    }
    
    func setConstraints() {
        imageView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(8)
            make.top.equalTo(safeAreaLayoutGuide.snp.top).inset(8)
            make.leading.equalToSuperview().inset(16)
            make.width.equalTo(imageView.snp.height)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.top).offset(16)
            make.leading.equalTo(imageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview()
        }
        
        imageButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(8)
            make.leading.equalTo(nameLabel.snp.leading)
        }
    }
}
