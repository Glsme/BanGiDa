//
//  CreateAuthUserUseCase.swift
//  BanGiDa
//
//  Created by 홍석준 on 12/26/25.
//

import Foundation

public protocol CreateAuthUserUseCase {
    func execute() async throws
}

public final class CreateAuthUserUseCaseImpl: CreateAuthUserUseCase {
    private let userRepository: UserRepository
    
    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    public func execute() async throws {
        try await userRepository.signIn()
        try await userRepository.createUser()
    }
}
