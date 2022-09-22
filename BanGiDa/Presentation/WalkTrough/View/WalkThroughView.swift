//
//  WalkThroughView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/22.
//

import UIKit
import SnapKit

class WalkThroughView: BaseView {
    let dogImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "ColorDog")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let userTextView: UIView = {
        let view = UIView()
        view.backgroundColor = .memoBackgroundColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    let textLabel: UILabel = {
        let view = UILabel()
        view.text = "키우고 계신 반려동물의 이름을 등록해주세요."
        view.textAlignment = .center
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        return view
    }()
    
    let userTextField: UITextField = {
        let view = UITextField()
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        view.placeholder = "반려 동물 이름"
        view.backgroundColor = .backgroundColor
        view.textAlignment = .center
        view.layer.cornerRadius = 10
        return view
    }()
    
    let userSaveButton: UIButton = {
        let view = UIButton()
        view.setTitle("저장", for: .normal)
        view.setTitleColor(.systemTintColor, for: .normal)
//        view.backgroundColor = .backgroundColor
        view.layer.cornerRadius = 5
        view.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func configureUI() {
        [dogImageView, userTextView].forEach {
            self.addSubview($0)
        }
        
        [textLabel, userTextField, userSaveButton].forEach {
            self.userTextView.addSubview($0)
        }
    }
    
    override func setConstraints() {
        userTextView.snp.makeConstraints { make in
            make.center.equalTo(self.safeAreaLayoutGuide.snp.center)
            make.width.equalTo(self.safeAreaLayoutGuide.snp.width).multipliedBy(0.8)
            make.height.equalTo(self.safeAreaLayoutGuide.snp.height).multipliedBy(0.25)
        }
        
        dogImageView.snp.makeConstraints { make in
            make.centerX.equalTo(self.safeAreaLayoutGuide.snp.centerX)
            make.width.height.equalTo(self.safeAreaLayoutGuide.snp.height).multipliedBy(0.15)
            make.bottom.equalTo(userTextView.snp.top)
        }
        
        userTextField.snp.makeConstraints { make in
            make.centerX.equalTo(userTextView.snp.centerX)
            make.centerY.equalTo(userTextView.snp.centerY).multipliedBy(1.1)
            make.width.equalTo(userTextView.snp.width).multipliedBy(0.8)
            make.height.equalTo(30)
        }
        
        textLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self.safeAreaLayoutGuide.snp.centerX)
            make.bottom.equalTo(userTextField.snp.top).offset(-20)
            make.width.equalTo(userTextField.snp.width)
        }
        
        userSaveButton.snp.makeConstraints { make in
            make.centerX.equalTo(self.safeAreaLayoutGuide.snp.centerX)
            make.top.equalTo(userTextField.snp.bottom).offset(20)
            make.width.equalTo(50)
            make.height.equalTo(25)
        }
    }
}
