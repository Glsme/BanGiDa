//
//  WriteViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/10.
//

import UIKit
import PhotosUI
import CropViewController

final class WriteViewController: BaseViewController {
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavigationStyle()
    }
    
    override func configureUI() {
        memoView.textView.delegate = self
        memoView.imageButton.addTarget(self, action: #selector(imageButtonClicked), for: .touchUpInside)
        memoView.dateTextField.tintColor = .clear
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
//        memoView.nameCollectionView.delegate = self
//        memoView.nameCollectionView.dataSource = self
//        memoView.nameCollectionView.register(AnimalNameCollectionViewCell.self, forCellWithReuseIdentifier: AnimalNameCollectionViewCell.reuseIdentifier)
    }
    
    func setNavigationStyle() {
        let currentColor = viewModel.setCurrentMemoType().color
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = .systemTintColor
        navigationItem.title = viewModel.setCurrentMemoType().title
        navigationController?.navigationBar.topItem?.title = ""
        navigationItem.title = viewModel.setCurrentMemoType().title
        navigationItem.rightBarButtonItem = saveButton
        navigationController?.navigationBar.backgroundColor = currentColor
        
        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithDefaultBackground()
             navigationBarAppearance.backgroundColor = currentColor
            
            navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        }
    }
    
    private func configureEdgeGesture() {
        let edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(leftSwipeGesture(_ :)))
        edgeGesture.edges = .left
        edgeGesture.view?.becomeFirstResponder()
        self.view.addGestureRecognizer(edgeGesture)
    }
    
    @objc func leftSwipeGesture(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        recognizer.state = .cancelled
        if recognizer.edges == .left, recognizer.state == .cancelled {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func bindValue() {
        viewModel.diaryContent.bind { [weak self] text in
            guard let self = self else { return }
            if !self.memoView.textView.text.isEmpty {
                self.memoView.textView.textColor = .systemTintColor
            } else {
                self.memoView.textView.text = self.viewModel.setCurrentMemoType().placeholder
                self.memoView.textView.textColor = .lightGray
            }
        }
        
        viewModel.dateText.bind { [weak self] text in
            guard let self = self else { return }
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
        
        if dateText.toDate() == nil {
            showAlert(message: "날짜 형식을 맞춰주세요.")
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

extension WriteViewController: ObservableObject, UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        print("?????")
        return true
    }
}

extension WriteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AnimalNameCollectionViewCell.reuseIdentifier, for: indexPath) as? AnimalNameCollectionViewCell else { return UICollectionViewCell() }
        
        cell.nameButton.tag = indexPath.item
        cell.nameButton.addTarget(self, action: #selector(nameButtonClicked(_ :)), for: .touchUpInside)
        cell.contentView.frame = cell.bounds
        cell.nameButton.layoutIfNeeded()
        cell.nameButton.layer.masksToBounds = true
        cell.nameButton.layer.cornerRadius = cell.nameButton.frame.height / 2
        
        
        return cell
    }
    
    @objc func nameButtonClicked(_ sender: UIButton) {
        print(sender.tag)
        let currentColor = viewModel.setCurrentMemoType().color
        
        if sender.backgroundColor == currentColor {
            sender.backgroundColor = .memoDarkGray
        } else {
            sender.backgroundColor = currentColor
        }
    }
}
