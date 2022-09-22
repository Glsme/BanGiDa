//
//  WalkTroughViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/22.
//

import UIKit

class WalkThroughViewController: BaseViewController {
    let walkThroughView = WalkThroughView()
    let viewModel = WalkthroughViewModel()
    
    override func loadView() {
        self.view = walkThroughView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.backgroundColor = .clear
    }
}
