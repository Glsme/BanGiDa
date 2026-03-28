//
//  UpdateLastSeenAtUseCase.swift
//  BanGiDa
//
//  Created by 홍석준 on 3/28/26.
//

import Foundation

public protocol UpdateLastSeenAtUseCase {
    func execute() async throws
}

public final class UpdateLastSeenAtUseCaseImpl: UpdateLastSeenAtUseCase {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute() async throws {
        guard userRepository.loadUID() != nil else { return }
        try await userRepository.updateLastSeenAt()
    }
}
