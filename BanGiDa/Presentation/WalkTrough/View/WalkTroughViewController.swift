//
//  WalkTroughViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/22.
//

import UIKit

final class WalkThroughViewController: BaseViewController {
    let walkThroughView = WalkThroughView()
    let viewModel = WalkthroughViewModel()
    
    var isNameChanged: (() -> Void)?
    
    override func loadView() {
        self.view = walkThroughView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.backgroundColor = .clear
    }
    
    override func configureUI() {
        walkThroughView.userSaveButton.addTarget(self, action: #selector(saveButtonClicked), for: .touchUpInside)
    }
    
    @objc func saveButtonClicked() {
        if let text = walkThroughView.userTextField.text {
            if text.count == 0 {
                showAlert(message: "반려 동물 이름을 입력해주세요!")
            } else {
                UserDefaults.standard.set(text, forKey: UserDefaultsKey.name.rawValue)
                UserDefaults.standard.set(true, forKey: UserDefaultsKey.first.rawValue)
                viewModel.saveDescriptionData()
                isNameChanged?()
//                print(UserDefaults.standard.string(forKey: UserDefaultsKey.name.rawValue))
                dismiss(animated: true)
            }
        } else {
            showAlert(message: "반려 동물 이름을 입력해주세요!")
        }
    }
}
