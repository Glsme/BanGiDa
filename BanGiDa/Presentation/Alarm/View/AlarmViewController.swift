//
//  AlarmViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/19.
//

import UIKit

class AlarmViewController: BaseViewController {
    
    let alarmView = AlarmView()
    let viewModel = AlarmViewModel()
    
    lazy var saveButton = UIBarButtonItem(title: "저장", style: .done, target: self, action: #selector(saveButtonClicked))
    
    override func loadView() {
        self.view = alarmView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bindValue()
    }
    
    override func configureUI() {
        
        let currentColor = viewModel.selectButtonList[1].color
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.topItem?.title = ""
        navigationItem.rightBarButtonItem = saveButton
        navigationController?.navigationBar.backgroundColor = currentColor
        view.backgroundColor = .white
        
        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithDefaultBackground()
             navigationBarAppearance.backgroundColor = currentColor
            
            navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
            alarmView.memoTextView.delegate = self
        }
    }
    
    @objc func saveButtonClicked() {
        print(#function)
        
        guard let dateText = alarmView.dateTextField.text else {
            showAlert(message: "날짜를 선택해주세요.")
            return
        }
        
        guard let contentText = alarmView.memoTextView.text, alarmView.memoTextView.textColor != .lightGray else {
            showAlert(message: "메모를 입력해주세요")
            return
        }
        
        guard let titleText = alarmView.titleTextField.text else {
            showAlert(message: "제목을 입력해주세요.")
            return
        }
        
        viewModel.saveData(content: contentText, dateText: dateText, titleText: titleText)

        navigationController?.popViewController(animated: true)
    }

    func bindValue() {
        viewModel.diaryContent.bind { text in
            if !self.alarmView.memoTextView.text.isEmpty {
                self.alarmView.memoTextView.textColor = .black
            } else {
                self.alarmView.memoTextView.text = self.viewModel.selectButtonList[1].placeholder
                self.alarmView.memoTextView.textColor = .lightGray
            }
        }
        
        viewModel.dateText.bind { text in
            if self.alarmView.dateTextField.text!.isEmpty {
                self.alarmView.dateTextField.text = self.viewModel.dateFormatter.string(from: Date())
            }
        }
    }
}

extension AlarmViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        viewModel.checkTextViewPlaceHolder(textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        viewModel.checkTextViewIsEmpty(textView)
    }
}
