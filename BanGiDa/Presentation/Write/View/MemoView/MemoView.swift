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
        return view
    }()
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .bananaYellow
        view.layer.cornerRadius = 10
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let imageButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "photo"), for: .normal)
        view.tintColor = .black
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 25
        return view
    }()
    
    let dateTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "클릭하여 날짜를 선택해주세요"
        view.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        view.textAlignment = .center
//        view.layer.borderWidth = 3
//        view.layer.borderColor = UIColor.bananaYellow.cgColor
//        view.layer.cornerRadius = 5
//        view.backgroundColor = .black
        return view
    }()
    
    let textView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .bananaYellow
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        view.layer.cornerRadius = 10
        let spacing: CGFloat = 10
        view.textContainerInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        view.textColor = .lightGray
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func configureUI() {
        self.addSubview(memoView)
        [imageView, imageButton, dateTextField, textView].forEach {
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
            make.width.height.equalTo(self.safeAreaLayoutGuide.snp.width).multipliedBy(0.6)
            make.centerX.equalTo(self)
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(20)
        }
        
        imageButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.bottom.equalTo(imageView.snp.bottom).offset(-10)
            make.trailing.equalTo(imageView.snp.trailing).offset(-10)
        }
        
        dateTextField.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(textView.snp.width)
            make.centerX.equalTo(self.safeAreaLayoutGuide)
            make.top.equalTo(imageView.snp.bottom).offset(20)
        }
        
        textView.snp.makeConstraints { make in
            make.centerX.equalTo(self.safeAreaLayoutGuide.snp.centerX)
            make.width.equalTo(self.safeAreaLayoutGuide.snp.width).multipliedBy(0.9)
            make.top.equalTo(dateTextField.snp.bottom).offset(20)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
    }
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일 EEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    func configureDatePicker() -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged)
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
