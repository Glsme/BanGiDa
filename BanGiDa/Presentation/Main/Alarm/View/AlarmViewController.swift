//
//  AlarmViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/19.
//

import Combine
import UIKit

final class AlarmViewController: BaseViewController {
    let alarmView = AlarmView()
    private let viewModel = AlarmViewModel()
    
    private var cancelBag = Set<AnyCancellable>()
    
    private lazy var saveButton = UIBarButtonItem(title: "저장", style: .done, target: self, action: #selector(saveButtonClicked))
    
    //MARK: - Life Sycle
    
    override func loadView() {
        self.view = alarmView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bindValue()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavigationStyle()
    }
    
    deinit {
        print("alarm view deinit")
    }
    
    override func configureUI() {
        alarmView.memoTextView.delegate = self
        alarmView.dateTextField.tintColor = .clear
    }
    
    //MARK: - Private
    
    private func setNavigationStyle() {
        let currentColor = viewModel.selectButtonList[1].color
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = .systemTintColor
        navigationItem.rightBarButtonItem = saveButton
        navigationController?.navigationBar.backgroundColor = currentColor
        view.backgroundColor = .backgroundColor
        
        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithDefaultBackground()
             navigationBarAppearance.backgroundColor = currentColor
            
            navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        }
    }
    
    @objc private func saveButtonClicked() {
        guard let dateText = alarmView.dateTextField.text else {
            showAlert(message: "날짜를 선택해주세요.")
            return
        }
        
        guard let titleText = alarmView.titleTextField.text, !alarmView.titleTextField.text!.isEmpty
        else {
            showAlert(message: "제목을 입력해주세요.")
            return
        }
        
        guard let contentText = alarmView.memoTextView.text, alarmView.memoTextView.textColor != .lightGray
        else {
            showAlert(message: "메모를 입력해주세요")
            return
        }
        
        if dateText.toDateAlarm() == nil {
            showAlert(message: "날짜 형식을 맞춰주세요.")
            return
        }
        
        if viewModel.alarmPrivacy.value {
            showAlert(message: "알람 사용을 위해 알람 권한을 허용해주세요.")
            return
        }
        
        viewModel.saveData(content: contentText, dateText: dateText, titleText: titleText)

        navigationController?.popViewController(animated: true)
    }

    private func bindValue() {
        viewModel.diaryContent
            .sink { [weak self] text in
                guard let self = self else { return }
                if !self.alarmView.memoTextView.text.isEmpty {
                    self.alarmView.memoTextView.textColor = .systemTintColor
                } else {
                    self.alarmView.memoTextView.text = self.viewModel.selectButtonList[1].placeholder
                    self.alarmView.memoTextView.textColor = .lightGray
                }
            }
            .store(in: &cancelBag)
        
        viewModel.dateText
            .sink { [weak self] text in
                guard let self = self else { return }
                if self.alarmView.dateTextField.text!.isEmpty {
                    self.alarmView.dateTextField.text = self.viewModel.dateFormatter.string(from: Date())
                }
            }
            .store(in: &cancelBag)
    }
}

//MARK: - UITextviewDelegate

extension AlarmViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.systemTintColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = .lightGray
            textView.text = viewModel.selectButtonList[1].placeholder
        }
    }
}
