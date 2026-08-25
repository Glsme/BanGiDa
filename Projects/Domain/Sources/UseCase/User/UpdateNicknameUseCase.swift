//
//  UpdateNicknameUseCase.swift
//  BanGiDa
//
//  Created by 홍석준 on 12/29/25.
//

import Foundation

public protocol UpdateNicknameUseCase {
    func execute(_ nickname: String) async throws
}

public final class UpdateNicknameUseCaseImpl: UpdateNicknameUseCase {
    private let userRepository: UserRepository
    
    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    public func execute(_ nickname: String) async throws {
        try await userRepository.update(nickname: nickname)
    }
}
