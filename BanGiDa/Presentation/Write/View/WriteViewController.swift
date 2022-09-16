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
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationController?.navigationBar.backgroundColor = currentColor
        self.view.backgroundColor = currentColor
        
        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithDefaultBackground()
            // navigationBarAppearance.backgroundColor = currentColor
            
            self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        }
        
        memoView.textView.delegate = self
        memoView.imageButton.addTarget(self, action: #selector(imageButtonClicked), for: .touchUpInside)
    }
    
    func bindValue() {
        viewModel.diaryContent.bind { text in
            self.memoView.textView.text = self.viewModel.setCurrentMemoType().placeholder
            self.memoView.textView.textColor = .lightGray
        }
        
        viewModel.dateText.bind { text in
            self.memoView.dateTextField.text = self.viewModel.dateFormatter.string(from: Date())
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
        self.navigationController?.popViewController(animated: true)
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
