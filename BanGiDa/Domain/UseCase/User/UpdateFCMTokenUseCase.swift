//
//  UpdateFCMTokenUseCase.swift
//  BanGiDa
//

import Foundation

public protocol UpdateFCMTokenUseCase {
    func execute(token: String) async throws
    func flushPendingToken() async throws
}

public final class UpdateFCMTokenUseCaseImpl: UpdateFCMTokenUseCase {
    private enum StorageKey {
        static let pendingToken = "pendingFCMToken"
        static let storedTokensByUID = "storedFCMTokensByUID"
    }

    private let userRepository: UserRepository
    private let userDefaults: UserDefaults

    public init(
        userRepository: UserRepository,
        userDefaults: UserDefaults = .standard
    ) {
        self.userRepository = userRepository
        self.userDefaults = userDefaults
    }

    public func execute(token: String) async throws {
        guard !token.isEmpty else { return }

        guard let uid = userRepository.loadUID(), !uid.isEmpty else {
            userDefaults.set(token, forKey: StorageKey.pendingToken)
            return
        }

        try await saveIfNeeded(token, for: uid)
    }

    public func flushPendingToken() async throws {
        guard let token = userDefaults.string(forKey: StorageKey.pendingToken), !token.isEmpty,
              let uid = userRepository.loadUID(), !uid.isEmpty else {
            return
        }

        try await saveIfNeeded(token, for: uid)
        userDefaults.removeObject(forKey: StorageKey.pendingToken)
    }
}

private extension UpdateFCMTokenUseCaseImpl {
    func saveIfNeeded(_ token: String, for uid: String) async throws {
        guard storedToken(for: uid) != token else { return }

        try await userRepository.updateFCMToken(token)
        store(token, for: uid)
    }

    func storedToken(for uid: String) -> String? {
        let tokens = userDefaults.dictionary(forKey: StorageKey.storedTokensByUID) as? [String: String]
        return tokens?[uid]
    }

    func store(_ token: String, for uid: String) {
        var tokens = userDefaults.dictionary(forKey: StorageKey.storedTokensByUID) as? [String: String] ?? [:]
        tokens[uid] = token
        userDefaults.set(tokens, forKey: StorageKey.storedTokensByUID)
    }
}
