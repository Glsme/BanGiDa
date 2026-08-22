//
//  CommentNotificationSettingsUseCase.swift
//  BanGiDa
//

import Foundation

public protocol CommentNotificationSettingsUseCase {
    func fetchEnabled() async throws -> Bool
    func update(isEnabled: Bool) async throws
}

public final class CommentNotificationSettingsUseCaseImpl: CommentNotificationSettingsUseCase {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func fetchEnabled() async throws -> Bool {
        try await ensureUser()
        return try await userRepository.fetchCommentNotificationEnabled()
    }

    public func update(isEnabled: Bool) async throws {
        try await ensureUser()
        try await userRepository.updateCommentNotificationEnabled(isEnabled)
    }
}

private extension CommentNotificationSettingsUseCaseImpl {
    func ensureUser() async throws {
        if userRepository.loadUID()?.isEmpty ?? true {
            try await userRepository.createUser()
        }

        guard userRepository.loadUID() != nil else { throw UserError.emptyUID }
    }
}
