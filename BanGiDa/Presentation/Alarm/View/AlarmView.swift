//
//  AlarmView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/19.
//

import UIKit
import SnapKit

class AlarmView: BaseView {
    
    let dateLabel: UILabel = {
        let view = UILabel()
        view.text = "알람이 울릴 시간을 선택해주세요"
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
        view.textColor = .lightGray
        view.backgroundColor = .greenblue
        return view
    }()
    
    let dateTextField: UITextField = {
        let view = UITextField()
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
//        view.backgroundColor = .bananaYellow
        view.textAlignment = .center
        view.placeholder = "날짜를 선택해주세요."
        return view
    }()
    
    let firstLine = LineView()
    let secondLine = LineView()
    
    let titleTextField: UITextField = {
        let view = UITextField()
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
//        view.backgroundColor = .bananaYellow
        view.textAlignment = .center
        view.placeholder = "제목을 입력해주세요."
        return view
    }()
    
//    let memoLabel: UILabel = {
//        let view = UILabel()
//        view.text = "알람 메모를 입력해주세요"
//        view.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
//        view.textColor = .lightGray
////        view.backgroundColor = .unaBlue
//        return view
//    }()
    
    let memoTextView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .memoBackgroundColor
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        view.layer.cornerRadius = 10
        let spacing: CGFloat = 10
        view.textContainerInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        view.textColor = .lightGray
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func configureUI() {
        [dateLabel, dateTextField, firstLine, titleTextField, secondLine ,memoTextView].forEach {
            self.addSubview($0)
        }
        
        dateTextField.inputView = configureDatePicker()
        dateTextField.inputAccessoryView = configureDateToolbar()
    }
    
    override func setConstraints() {
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(15)
            make.leading.equalTo(self.safeAreaLayoutGuide.snp.leading).offset(10)
        }
        
        dateTextField.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(15)
            make.centerX.equalTo(self.safeAreaLayoutGuide.snp.centerX)
            make.width.equalTo(firstLine.snp.width)
        }
        
        firstLine.snp.makeConstraints { make in
            make.width.equalTo(self.safeAreaLayoutGuide.snp.width).multipliedBy(0.9)
            make.top.equalTo(dateTextField.snp.bottom).offset(15)
            make.centerX.equalTo(dateTextField.snp.centerX)
            make.height.equalTo(1)
        }
        
//        memoLabel.snp.makeConstraints { make in
//            make.leading.equalTo(dateLabel.snp.leading)
//            make.top.equalTo(line.snp.bottom).offset(15)
//        }
        
        titleTextField.snp.makeConstraints { make in
            make.width.equalTo(firstLine.snp.width)
            make.top.equalTo(firstLine.snp.bottom).offset(15)
            make.centerX.equalTo(self.safeAreaLayoutGuide.snp.centerX)
        }
        
        secondLine.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(15)
            make.width.equalTo(titleTextField.snp.width)
            make.centerX.equalTo(self.safeAreaLayoutGuide.snp.centerX)
            make.height.equalTo(1)
        }
        
        memoTextView.snp.makeConstraints { make in
            make.width.equalTo(secondLine.snp.width)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-10)
            make.top.equalTo(secondLine.snp.bottom).offset(15)
            make.centerX.equalTo(self.safeAreaLayoutGuide.snp.centerX)
        }
    }
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd EE hh:mm a"
//        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    func configureDatePicker() -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
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
