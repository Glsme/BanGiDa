//
//  WriteView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/13.
//

import UIKit

import SnapKit

final class MemoView: BaseView {
    let memoView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundColor
        return view
    }()
    
    let imageCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: imageCollectionViewLayout())
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
    
    let firstLine = LineView()
    let secondLine = LineView()
    let thirdLine = LineView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    override func configureUI() {
        self.addSubview(memoView)
        [imageCollectionView, imageView, imageButton, dateTextField, dateLabel, textView, firstLine, secondLine, thirdLine].forEach {
            memoView.addSubview($0)
        }
        
        dateTextField.inputView = configureDatePicker()
        dateTextField.inputAccessoryView = configureDateToolbar()
    }
    
    override func setConstraints() {
        memoView.snp.makeConstraints { make in
            make.edges.equalTo(self.safeAreaLayoutGuide)
        }
        
        // iamge CollectionView Temp View Layout
        imageCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(10)
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(20)
            make.height.equalTo(self.safeAreaLayoutGuide.snp.width).multipliedBy(0.45)
        }
        
        imageButton.snp.makeConstraints { make in
            make.centerX.equalTo(imageCollectionView.snp.centerX)
            make.top.equalTo(imageCollectionView.snp.bottom).offset(8)
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
            make.top.equalTo(secondLine.snp.bottom).offset(20)
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
    
    static func imageCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 10
        let width = UIScreen.main.bounds.width / 2.5
//        let width = imageCollectionView.bounds.height
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = 0
        
        return layout
    }
    
    func updateImageCollectionViewLayout(_ imageCount: Int) {
        switch imageCount {
        case 1:
            imageCollectionView.snp.remakeConstraints { make in
                make.centerX.equalToSuperview()
                make.width.equalTo(self.safeAreaLayoutGuide.snp.width).multipliedBy(0.425)
                make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(20)
                make.height.equalTo(self.safeAreaLayoutGuide.snp.width).multipliedBy(0.45)
            }
        case 2:
            imageCollectionView.snp.remakeConstraints { make in
                make.centerX.equalToSuperview()
                make.width.equalTo(self.safeAreaLayoutGuide.snp.width).multipliedBy(0.85)
                make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(20)
                make.height.equalTo(self.safeAreaLayoutGuide.snp.width).multipliedBy(0.45)
            }
        default:
            imageCollectionView.snp.remakeConstraints { make in
                make.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(10)
                make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(20)
                make.height.equalTo(self.safeAreaLayoutGuide.snp.width).multipliedBy(0.45)
            }
        }
    }
}
