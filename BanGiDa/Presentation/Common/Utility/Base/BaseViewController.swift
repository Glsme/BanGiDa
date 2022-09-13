//
//  BaseViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        view.backgroundColor = .white
    }
    
    func configureUI() { }
}
