//
//  UserRepository.swift
//  BanGiDa
//
//  Created by 홍석준 on 12/26/25.
//

import Foundation

public protocol UserRepository {
    func signIn() async throws
    func createUser() async throws
    func updateLastSeenAt() async throws
    func update(nickname: String) async throws
    func readNickname() -> String?
    func checkRegistration(uid: String) async throws -> Bool
    func loadUID() -> String?
    func fetchBlockedUIDs() async throws -> Set<String>
    func fetchBlockedUsers() async throws -> [BlockedUser]
    func block(uid: String, nickname: String) async throws
    func unblock(uid: String) async throws
}
