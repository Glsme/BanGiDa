//
//  WriteViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/10.
//

import Combine
import UIKit
import PhotosUI
import CropViewController

final class WriteViewController: BaseViewController {
    let viewModel = WriteViewModel()
    let memoView = MemoView()
    
    var category: Category = .memo
    
    private var cancelBag = Set<AnyCancellable>()
    
    private lazy var saveButton = UIBarButtonItem(title: "저장",
                                                  style: .done,
                                                  target: self,
                                                  action: #selector(saveButtonClicked))

    //MARK: - Life Cycle
    
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
        memoView.imageButton.addTarget(self,
                                       action: #selector(imageButtonClicked),
                                       for: .touchUpInside)
        memoView.dateTextField.tintColor = .clear
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    //MARK: - Private
    
    private func setNavigationStyle() {
        let currentColor = category.color
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = .systemTintColor
        navigationItem.title = category.title
        navigationController?.navigationBar.topItem?.title = ""
        navigationItem.title = category.title
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
        let edgeGesture = UIScreenEdgePanGestureRecognizer(target: self,
                                                           action: #selector(leftSwipeGesture(_ :)))
        edgeGesture.edges = .left
        edgeGesture.view?.becomeFirstResponder()
        self.view.addGestureRecognizer(edgeGesture)
    }
    
    @objc private func leftSwipeGesture(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        recognizer.state = .cancelled
        if recognizer.edges == .left, recognizer.state == .cancelled {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func bindValue() {
        viewModel.diaryContent
            .sink { [weak self] text in
                guard let self = self else { return }
                if !self.memoView.textView.text.isEmpty {
                    self.memoView.textView.textColor = .systemTintColor
                } else {
                    self.memoView.textView.text = self.category.placeHolder
                    self.memoView.textView.textColor = .lightGray
                }
            }
            .store(in: &cancelBag)
        
        viewModel.dateText
            .sink { [weak self] text in
                guard let self = self else { return }
                if self.memoView.dateTextField.text!.isEmpty {
                    let text = self.viewModel.dateFormatter.string(from: Date())
                    self.memoView.dateTextField.text = text
                }
            }
            .store(in: &cancelBag)
    }
    
    @objc func saveButtonClicked() {
        guard let dateText = memoView.dateTextField.text else {
            showAlert(message: "날짜를 선택해주세요.")
            return
        }
        
        guard let contentText = memoView.textView.text, memoView.textView.textColor != .lightGray
        else {
            showAlert(message: "텍스트를 입력해주세요")
            return
        }
        
        if dateText.toDate() == nil {
            showAlert(message: "날짜 형식을 맞춰주세요.")
            return
        }
        
        guard let image = memoView.imageView.image,
              let imageData = convertImageToData(image: image) else { return }
        
        viewModel.saveData(image: imageData, content: contentText, dateText: dateText)
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func imageButtonClicked() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .any(of: [.images])
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
    }
    
    //MARK: - Private
    
    private func convertImageToData(image: UIImage) -> Data? {
        return image.jpegData(compressionQuality: 0.5)
    }
}

//MARK: - UITextViewDelegate

extension WriteViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        checkTextViewPlaceHolder(textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        checkTextViewIsEmpty(textView)
    }
    
    private func checkTextViewPlaceHolder(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.systemTintColor
        }
    }
    
    private func checkTextViewIsEmpty(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = .lightGray
            textView.text = category.placeHolder
        }
    }
}

//MARK: - Image Load & Crop

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
    func cropViewController(_ cropViewController: CropViewController,
                            didCropToImage image: UIImage,
                            withRect cropRect: CGRect,
                            angle: Int) {
        memoView.imageView.image = image
        memoView.imageButton.setTitle("이미지 편집", for: .normal)
        dismiss(animated: true)
    }
}

extension WriteViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK: - UICollectionViewDelegate & UICollectionDataSource

extension WriteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        let currentColor = category.color
        
        if sender.backgroundColor == currentColor {
            sender.backgroundColor = .memoDarkGray
        } else {
            sender.backgroundColor = currentColor
        }
    }
}
