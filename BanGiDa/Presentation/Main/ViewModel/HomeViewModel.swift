//
//  HomeViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/09.
//

import UIKit
import FSCalendar
import RealmSwift

//MARK: - Home ViewModel

class HomeViewModel: CommonViewModel {
    
    let homeView = HomeView()
    
    var tasks: Results<Diary>! {
        didSet {
            print("Tasks Changed")
        }
    }
    
    var memoArray: Observable<[Diary]> = Observable([])
    var alarmArray: Observable<[Diary]> = Observable([])
    var hospitalArray: Observable<[Diary]> = Observable([])
    var showerArray: Observable<[Diary]> = Observable([])
    var pillArray: Observable<[Diary]> = Observable([])
    var abnormalArray: Observable<[Diary]> = Observable([])
    
    func pushViewController(completion: @escaping () -> Void ) {
        completion()
    }
    
    func fetchData() {
        tasks = UserMemoRepository.shared.fetch()
    }
    
    func inputDataIntoArray() {
        
    }
}
