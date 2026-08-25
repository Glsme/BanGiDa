//
//  BlockUserUseCase.swift
//  BanGiDa
//

import Foundation

public protocol BlockUserUseCase {
    func execute(targetUID: String, nickname: String) async throws
}

public final class BlockUserUseCaseImpl: BlockUserUseCase {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute(targetUID: String, nickname: String) async throws {
        // 기존 WriteCommentUseCase와 동일한 UID 확보 절차.
        if userRepository.loadUID()?.isEmpty ?? true {
            try await userRepository.createUser()
        }

        guard userRepository.loadUID() != nil else { throw UserError.emptyUID }

        try await userRepository.block(uid: targetUID, nickname: nickname)
    }
}
