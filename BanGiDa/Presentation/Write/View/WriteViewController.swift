//
//  WriteViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/10.
//

import UIKit
import PhotosUI
import CropViewController

class WriteViewController: BaseViewController {
    
    let viewModel = WriteViewModel()
    let memoView = MemoView()
    
    lazy var saveButton = UIBarButtonItem(title: "저장", style: .done, target: self, action: #selector(saveButtonClicked))

    override func loadView() {
        self.view = memoView
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("writeView", #function)

        bindValue()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("writeView", #function)
//        if memoView.imageView.image != nil {
//            memoView.imageView.layer.borderWidth = 0
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("writeView", #function)
        
        print(#function)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("writeView", #function)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        print("writeView", #function)

    }
    
    override func configureUI() {
        
        let currentColor = viewModel.setCurrentMemoType().color
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = .systemTintColor
        navigationController?.navigationBar.topItem?.title = ""
        navigationItem.rightBarButtonItem = saveButton
        navigationController?.navigationBar.backgroundColor = currentColor

        
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
                self.memoView.textView.textColor = .systemTintColor
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
        
        viewModel.saveData(image: memoView.imageView.image, content: contentText, dateText: dateText)

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
                    guard let image = image as? UIImage else { return }
                    let cropVC = CropViewController(image: image)
                    cropVC.delegate = self
                    cropVC.doneButtonTitle = "완료"
                    cropVC.cancelButtonTitle = "취소"
                    self.transViewController(ViewController: cropVC, type: .present)
                }
            }
        }
    }
}

extension WriteViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        memoView.imageView.image = image
        memoView.imageButton.setTitle("이미지 편집", for: .normal)
        dismiss(animated: true)
    }
}
