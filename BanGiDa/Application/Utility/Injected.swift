//
//  Injected.swift
//  BanGiDa
//
//  Created by 홍석준 on 12/26/25.
//

import Foundation

import Swinject

@propertyWrapper
final class Injected<T> {
    public let wrappedValue: T

    public init() {
        guard let object = AppDIContainer.shared.container.resolve(T.self) else {
            assertionFailure("\(T.self) is not registered in DIContainer.")
            self.wrappedValue = AppDIContainer.shared.container.resolve(T.self)!
            return
        }

        self.wrappedValue = object
    }
}
