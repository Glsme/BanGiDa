//
//  WriteViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/10.
//

import UIKit

class WriteViewController: BaseViewController {
    
    let viewModel = WriteViewModel()
    
    lazy var saveButton = UIBarButtonItem(title: "저장", style: .done, target: self, action: #selector(saveButtonClicked))

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func configureUI() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc func saveButtonClicked() {
        print(#function)
        self.navigationController?.popViewController(animated: true)
    }
}
