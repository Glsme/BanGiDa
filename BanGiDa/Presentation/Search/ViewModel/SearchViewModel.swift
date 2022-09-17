//
//  SearchViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/13.
//

import UIKit

class SearchViewModel: CommonViewModel {
    
    var isFiltering: Observable<Bool> = Observable(false)
    var currentIndex: Observable<Int> = Observable(0)
    
    func setSection(section: Int) -> CGFloat {
        let height: CGFloat = 66
        var value: CGFloat = 0
        
        if isFiltering.value {
            switch section {
            case 0:
                value = height
            case 1:
                value = height
            case 2:
                value = height
            case 3:
                value = height
            case 4:
                value = height
            case 5:
                value = height
            default:
                break
            }
        } else {
            value = height
        }
        
        return value
    }
}
