//
//  SearchViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/13.
//

import Foundation

class SearchViewModel {
    let selectButtonList = [
        SelectButtonModel(title: "메모", imageString: "note.text", r: 133, g: 204, b: 204, alpha: 1, placeholder: "오늘 있었던 일을 적어주세요."),
        SelectButtonModel(title: "알람", imageString: "alarm", r: 252, g: 200, b: 141, alpha: 1, placeholder: ""),
        SelectButtonModel(title: "병원 기록", imageString: "cross.case", r: 169, g: 223, b: 225, alpha: 1, placeholder: "병원 진료를 적어주세요."),
        SelectButtonModel(title: "목욕", imageString: "drop", r: 250, g: 227, b: 175, alpha: 1, placeholder: "오늘 목욕할 때 있었던 일을 적어주세요."),
        SelectButtonModel(title: "약", imageString: "pills", r: 168, g: 215, b: 177, alpha: 1, placeholder: "약 복용 기록을 적어주세요."),
        SelectButtonModel(title: "이상 증상", imageString: "bandage", r: 228, g: 167, b: 180, alpha: 1, placeholder: "이상 증상을 적어주세요.")
    ]
    
}
