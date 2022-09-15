//
//  WriteViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/10.
//

import UIKit
import SnapKit

class WriteViewModel: CommonViewModel {
    
    let memoView = MemoView()
    var currentIndex: Observable<Int> = Observable(0)
    
    func setCurrentMemoType() -> SelectButtonModel {
        return selectButtonList[self.currentIndex.value]
    }
    

}
