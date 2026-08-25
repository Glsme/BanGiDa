//
//  CheckUserRegistrationUseCase.swift
//  BanGiDa
//
//  Created by 홍석준 on 12/26/25.
//

import Foundation

public protocol CheckUserRegistrationUseCase {
    func execute() async throws -> Bool
}

public final class CheckUserRegistrationUseCaseImpl: CheckUserRegistrationUseCase {
    private let userRepository: UserRepository
    
    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    public func execute() async throws -> Bool {
        guard let uid = userRepository.loadUID() else { return false }
        
        let result = try await userRepository.checkRegistration(uid: uid)
        
        if result {
            try await userRepository.updateLastSeenAt()
        }
        
        return result
    }
}
