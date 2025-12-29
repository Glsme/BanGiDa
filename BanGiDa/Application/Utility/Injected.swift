//
//  Injected.swift
//  BanGiDa
//
//  Created by 홍석준 on 12/26/25.
//

import Foundation

import Swinject

@propertyWrapper
class Injected<T> {
    public let wrappedValue: T
    
    public init() {
        guard let object = AppDIContainer.shared.container.resolve(T.self) else {
            fatalError("\(T.self) is not registered in DIContainer.")
        }
        
        self.wrappedValue = object
    }
}
