//
//  WriteViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/10.
//

import UIKit

class WriteViewController: BaseViewController {
    
    let viewModel = WriteViewModel()
    let memoView = MemoView()
    
    lazy var saveButton = UIBarButtonItem(title: "저장", style: .done, target: self, action: #selector(saveButtonClicked))
    
    override func loadView() {
        self.view = memoView
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }
    
    @objc func saveButtonClicked() {
        print(#function)
        self.navigationController?.popViewController(animated: true)
    }
}

extension WriteViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = .lightGray
            textView.text = viewModel.setCurrentMemoType().placeholder
        }
    }
}
