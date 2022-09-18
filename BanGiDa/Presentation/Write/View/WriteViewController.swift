//
//  WriteViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/10.
//

import UIKit
import PhotosUI

class WriteViewController: BaseViewController {
    
    let viewModel = WriteViewModel()
    let memoView = MemoView()
    
    lazy var saveButton = UIBarButtonItem(title: "저장", style: .done, target: self, action: #selector(saveButtonClicked))
    
    override func loadView() {
        self.view = memoView
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindValue()
    }
    
    override func configureUI() {
        
        let currentColor = viewModel.setCurrentMemoType().color
        
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
        }
        
        memoView.textView.delegate = self
        memoView.imageButton.addTarget(self, action: #selector(imageButtonClicked), for: .touchUpInside)
    }
    
    func bindValue() {
        viewModel.diaryContent.bind { text in
            if !self.memoView.textView.text.isEmpty {
                self.memoView.textView.textColor = .black
            } else {
                self.memoView.textView.text = self.viewModel.setCurrentMemoType().placeholder
                self.memoView.textView.textColor = .lightGray
            }
        }
        
        viewModel.dateText.bind { text in
            if self.memoView.dateTextField.text!.isEmpty {
                self.memoView.dateTextField.text = self.viewModel.dateFormatter.string(from: Date())
            }
        }
    }
    
    @objc func saveButtonClicked() {
        print(#function)
        
        guard let dateText = memoView.dateTextField.text else {
            showAlert(message: "날짜를 선택해주세요.")
            return
        }
        
        guard let contentText = memoView.textView.text, memoView.textView.textColor != .lightGray else {
            showAlert(message: "텍스트를 입력해주세요")
            return
        }
        
        viewModel.saveData(image: nil, content: contentText, dateText: dateText)

        navigationController?.popViewController(animated: true)
    }
    
    @objc func imageButtonClicked() {
        print(#function)
        var configuration = PHPickerConfiguration()
        configuration.filter = .any(of: [.images])
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
    }
}

extension WriteViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        viewModel.checkTextViewPlaceHolder(textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        viewModel.checkTextViewIsEmpty(textView)
    }
}

extension WriteViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    self.memoView.imageView.image = image as? UIImage
                }
            }
        }
    }
}
