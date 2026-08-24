//
//  AlarmView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/19.
//

import UIKit

import SnapKit
import DesignSystem

/// AlarmViewController에 사용되는 View입니다.
/**
 # OverView
 - AlarmViewController 내 View로 사용
 
 ## Font Style:
 - HelveticaNeue-Medium, 12
 - HelveticaNeue-Medium, 16
 */
final class AlarmView: BaseView {
    
    let dateLabel: UILabel = {
        let view = UILabel()
        view.text = "알람이 울릴 시간을 선택해주세요"
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
        view.textColor = .lightGray
        return view
    }()
    
    let dateTextField: UITextField = {
        let view = UITextField()
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        view.textAlignment = .center
        view.placeholder = "날짜를 선택해주세요."
        return view
    }()
    
    let firstLine = LineView()
    let secondLine = LineView()
    let thridLine = LineView()
    
    private let repeatPicker = UIPickerView()
    private let repeatPickerTextField = UITextField()
    private let repeatOptions: [(title: String, rule: AlarmRepeat)] = [
        ("반복 안함", .none),
        ("매일", .daily),
        ("매주", .weekly),
        ("매월", .monthly),
        ("매년", .yearly)
    ]
    
    private(set) var selectedRepeatRule: AlarmRepeat = .none
    
    let repeatButton: UIButton = {
        let view = UIButton()
        view.setTitle("반복 안함", for: .normal)
        view.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        view.setTitleColor(.black, for: .normal)
        view.backgroundColor = UIColor(r: 252, g: 200, b: 141)
        view.layer.cornerRadius = 10
        view.setTitleColor(UIColor(r: 255, g: 255, b: 255), for: .normal)
        
        return view
    }()
    
    let titleTextField: UITextField = {
        let view = UITextField()
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        view.textAlignment = .center
        view.placeholder = "제목을 입력해주세요."
        return view
    }()
    
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
    
    override func configureUI() {
        [
            dateLabel,
            dateTextField,
            firstLine,
            repeatButton,
            thridLine,
            titleTextField,
            secondLine ,
            memoTextView,
            repeatPickerTextField
        ].forEach {
            self.addSubview($0)
        }
        
        dateTextField.inputView = configureDatePicker()
        dateTextField.inputAccessoryView = configureDateToolbar()
        
        repeatButton.addTarget(self, action: #selector(repeatButtonTapped), for: .touchUpInside)
        configureRepeatPicker()
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
        
        repeatButton.snp.makeConstraints { make in
            make.width.equalTo(firstLine.snp.width).inset(16)
            make.top.equalTo(firstLine.snp.bottom).offset(15)
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(44)
        }
        
        secondLine.snp.makeConstraints { make in
            make.top.equalTo(repeatButton.snp.bottom).offset(15)
            make.width.equalTo(firstLine.snp.width)
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(1)
        }
        
        titleTextField.snp.makeConstraints { make in
            make.width.equalTo(secondLine.snp.width)
            make.top.equalTo(secondLine.snp.bottom).offset(15)
            make.centerX.equalTo(safeAreaLayoutGuide)
        }
        
        thridLine.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(15)
            make.width.equalTo(firstLine)
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(1)
        }
        
        memoTextView.snp.makeConstraints { make in
            make.width.equalTo(thridLine.snp.width)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-10)
            make.top.equalTo(thridLine.snp.bottom).offset(15)
            make.centerX.equalTo(safeAreaLayoutGuide)
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
    
    private func configureRepeatPicker() {
        repeatPicker.delegate = self
        repeatPicker.dataSource = self
        repeatPickerTextField.isHidden = true
        repeatPickerTextField.inputView = repeatPicker
        repeatPickerTextField.inputAccessoryView = configureRepeatToolbar()
        repeatPicker.selectRow(0, inComponent: 0, animated: false)
    }
    
    private func configureRepeatToolbar() -> UIToolbar {
        let width = self.bounds.width
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: width, height: 44))
        let cancel = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(repeatPickerCancelTapped))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let ok = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(repeatPickerDoneTapped))
        toolbar.setItems([cancel, flexible, ok], animated: false)
        
        return toolbar
    }
    
    @objc private func repeatButtonTapped() {
        syncPickerSelection()
        repeatPickerTextField.becomeFirstResponder()
    }
    
    private func syncPickerSelection() {
        if let currentTitle = repeatButton.title(for: .normal),
           let index = repeatOptions.firstIndex(where: { $0.title == currentTitle }) {
            repeatPicker.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    @objc private func repeatPickerDoneTapped() {
        let selectedRow = repeatPicker.selectedRow(inComponent: 0)
        let selection = repeatOptions[selectedRow]
        repeatButton.setTitle(selection.title, for: .normal)
        selectedRepeatRule = selection.rule
        repeatPickerTextField.resignFirstResponder()
    }
    
    @objc private func repeatPickerCancelTapped() {
        repeatPickerTextField.resignFirstResponder()
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource

extension AlarmView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return repeatOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return repeatOptions[row].title
    }
}
