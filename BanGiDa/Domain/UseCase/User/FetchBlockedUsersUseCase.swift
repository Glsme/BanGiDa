//
//  FetchBlockedUsersUseCase.swift
//  BanGiDa
//

import Foundation

public protocol FetchBlockedUsersUseCase {
    func execute() async throws -> [BlockedUser]
}

public final class FetchBlockedUsersUseCaseImpl: FetchBlockedUsersUseCase {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute() async throws -> [BlockedUser] {
        if userRepository.loadUID()?.isEmpty ?? true {
            try await userRepository.createUser()
        }

        guard userRepository.loadUID() != nil else { throw UserError.emptyUID }

        let users = try await userRepository.fetchBlockedUsers()

        return users.map { user in
            guard user.nickname.isEmpty else { return user }

            return BlockedUser(
                id: user.id,
                nickname: "알 수 없는 사용자",
                blockedAt: user.blockedAt,
                displayTime: user.displayTime
            )
        }
    }
}
