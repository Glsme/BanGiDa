//
//  WriteView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/13.
//

import UIKit
import SnapKit

class MemoView: BaseView {
    
    let memoView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundColor
        return view
    }()
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "BasicDog")
        view.tintColor = .ultraLightGray
        view.layer.borderColor = UIColor.ultraLightGray.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    let imageButton: UIButton = {
        let view = UIButton()
        view.setTitle("이미지 추가", for: .normal)
        view.setTitleColor(UIColor.unaBlue, for: .normal)
        view.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        return view
    }()
    
    let dateTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "클릭하여 날짜를 선택해주세요"
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        view.textAlignment = .center
        return view
    }()
    
    let dateLabel: UILabel = {
        let view = UILabel()
        view.text = "날짜"
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        view.textColor = .memoDarkGray
        return view
    }()
    
    let textView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .memoBackgroundColor
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        view.layer.cornerRadius = 10
        let spacing: CGFloat = 10
        view.textContainerInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        view.textColor = .lightGray
        return view
    }()
    
    let nameCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 25)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .backgroundColor
        
        return view
    }()
    
    let nameLabel: UILabel = {
        let view = UILabel()
        view.text = "이름"
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        view.textColor = .memoDarkGray
        return view
    }()
    
    let firstLine = LineView()
    let secondLine = LineView()
    let thirdLine = LineView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func configureUI() {
        self.addSubview(memoView)
        [imageView, imageButton, dateTextField, dateLabel, textView, firstLine, secondLine, thirdLine, nameCollectionView, nameLabel].forEach {
            memoView.addSubview($0)
        }
        
        dateTextField.inputView = configureDatePicker()
        dateTextField.inputAccessoryView = configureDateToolbar()
    }
    
    override func setConstraints() {
        memoView.snp.makeConstraints { make in
            make.edges.equalTo(self.safeAreaLayoutGuide)
        }
        
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(self.safeAreaLayoutGuide.snp.width).multipliedBy(0.45)
            make.centerX.equalTo(self)
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(20)
        }
        
        imageButton.snp.makeConstraints { make in
            make.centerX.equalTo(imageView.snp.centerX)
            make.top.equalTo(imageView.snp.bottom).offset(8)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(dateTextField)
            make.leading.equalTo(firstLine.snp.leading).offset(10)
            make.width.equalTo(50)
            make.height.equalTo(dateTextField.snp.height)
        }
        
        dateTextField.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.width.equalTo(textView.snp.width).multipliedBy(0.8)
            make.centerX.equalTo(self.safeAreaLayoutGuide)
            make.top.equalTo(firstLine.snp.bottom).offset(8)
        }
        
        textView.snp.makeConstraints { make in
            make.centerX.equalTo(self.safeAreaLayoutGuide.snp.centerX)
            make.width.equalTo(self.safeAreaLayoutGuide.snp.width).multipliedBy(0.9)
            make.top.equalTo(thirdLine.snp.bottom).offset(20)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        
        firstLine.snp.makeConstraints { make in
            make.top.equalTo(imageButton.snp.bottom).offset(8)
            make.height.equalTo(1)
            make.centerX.equalTo(self.safeAreaLayoutGuide.snp.centerX)
            make.width.equalTo(self.safeAreaLayoutGuide.snp.width).multipliedBy(0.9)
        }
        
        secondLine.snp.makeConstraints { make in
            make.top.equalTo(dateTextField.snp.bottom).offset(8)
            make.height.equalTo(1)
            make.centerX.equalTo(self.safeAreaLayoutGuide.snp.centerX)
            make.width.equalTo(self.safeAreaLayoutGuide.snp.width).multipliedBy(0.9)
        }
        
        thirdLine.snp.makeConstraints { make in
            make.top.equalTo(secondLine.snp.bottom).offset(41)
            make.width.equalTo(secondLine.snp.width)
            make.height.equalTo(1)
            make.centerX.equalTo(self.safeAreaLayoutGuide.snp.centerX)
        }
        
        nameCollectionView.snp.makeConstraints { make in
            make.top.equalTo(secondLine.snp.bottom).offset(8)
            make.height.equalTo(25)
            make.leading.equalTo(nameLabel.snp.trailing).offset(20)
            make.trailing.equalTo(secondLine.snp.trailing)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(nameCollectionView)
            make.leading.equalTo(firstLine.snp.leading).offset(10)
            make.width.equalTo(50)
            make.height.equalTo(nameCollectionView.snp.height)
        }
    }
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd EE"
//        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    func configureDatePicker() -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged)
        
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = Date()
        var components = DateComponents()
        components.calendar = calendar
        
        components.year = 60
        let maxDate = calendar.date(byAdding: components, to: currentDate)!
        
        components.year = -50
        let minDate = calendar.date(byAdding: components, to: currentDate)!
        
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        
        dateTextField.text = formatter.string(from: Date())
        return datePicker
    }
    
    func configureDateToolbar() -> UIToolbar {
        let width = self.bounds.width
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: width, height: 44))
        let cancel = UIBarButtonItem(title: "취소", style: .plain, target: nil, action: #selector(cancelButtonClicked))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let ok = UIBarButtonItem(title: "선택", style: .plain, target: nil, action: #selector(okButtonClicked))
        toolbar.setItems([cancel,flexible, ok], animated: false)
        
        return toolbar
    }
    
    @objc func datePickerValueDidChange(_ datePicker: UIDatePicker) {
        
        dateTextField.text = formatter.string(from: datePicker.date)
    }
    
    @objc func okButtonClicked(_ datePicker: UIDatePicker) {
        dateTextField.endEditing(true)
    }
    
    @objc func cancelButtonClicked() {
        dateTextField.endEditing(true)
    }
}
