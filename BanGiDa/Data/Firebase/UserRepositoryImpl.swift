//
//  UserRepositoryImpl.swift
//  BanGiDa
//
//  Created by 홍석준 on 12/26/25.
//

import Foundation

import FirebaseAuth
import FirebaseFirestore

public final class UserRepositoryImpl: UserRepository {
    private let db: Firestore
    
    public init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }
    
    public func signIn() async throws {
        let result = try await Auth.auth().signInAnonymously()
        let isAnonymous = result.user.isAnonymous
        let uid = result.user.uid
        print("isAnonymous: ", isAnonymous)
        print("uid: ", uid)
    }
    
    public func createUser() async throws {
        guard let uid = loadUID() else { throw UserError.emptyUID }

        let reference = db.collection("users").document(uid)
        let snapshot = try await reference.getDocument()

        // setData는 문서를 통째로 대체한다. 이미 있는 문서에 그대로 쓰면 가입 시각인
        // createAt이 매번 갱신될 뿐 아니라 fcmToken과 commentNotificationEnabled까지
        // 지워져 푸시가 끊기고 알림 설정이 초기화된다. 기존 문서는 접속 시각만 갱신한다.
        guard !snapshot.exists else {
            try await reference.updateData(["lastSeenAt": Date()])
            return
        }

        let nickname = UserDefaults.standard.string(forKey: UserDefaultsKey.name.rawValue) ?? ""
        let data: [String: Any] = [
            "nickname": nickname,
            "createAt": Date(),
            "lastSeenAt": Date(),
            "commentNotificationEnabled": true
        ]

        try await reference.setData(data)
    }
    
    public func updateLastSeenAt() async throws {
        guard let uid = loadUID() else { throw UserError.emptyUID }
        
        print("lastSeenAt update \(Date())")
        try await db.collection("users").document(uid).updateData(["lastSeenAt": Date()])
    }
    
    public func update(nickname: String) async throws {
        guard let uid = loadUID() else { throw UserError.emptyUID }
        
        try await db.collection("users").document(uid).updateData(["nickname": nickname])
    }

    public func updateFCMToken(_ token: String) async throws {
        guard let uid = loadUID() else { throw UserError.emptyUID }

        try await db.collection("users").document(uid).setData([
            "fcmToken": token,
            "fcmTokenUpdatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }

    public func updateCommentNotificationEnabled(_ isEnabled: Bool) async throws {
        guard let uid = loadUID() else { throw UserError.emptyUID }

        try await db.collection("users").document(uid).setData([
            "commentNotificationEnabled": isEnabled
        ], merge: true)
    }

    public func fetchCommentNotificationEnabled() async throws -> Bool {
        guard let uid = loadUID() else { throw UserError.emptyUID }

        let snapshot = try await db.collection("users").document(uid).getDocument()

        // 기존 사용자 문서에 필드가 없으면 알림을 켠 것으로 취급한다.
        return snapshot.data()?["commentNotificationEnabled"] as? Bool ?? true
    }
    
    public func checkRegistration(uid: String) async throws -> Bool {
        let userRef = db.collection("users").document(uid)
        let snapShot = try await userRef.getDocument()
        
        return snapShot.data() != nil
    }
    
    public func loadUID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    public func readNickname() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultsKey.name.rawValue)
    }

    public func fetchBlockedUIDs() async throws -> Set<String> {
        guard let uid = loadUID() else { throw UserError.emptyUID }

        let snapshot = try await db.collection("users")
            .document(uid)
            .collection("blocks")
            .getDocuments()

        return Set(snapshot.documents.map { $0.documentID })
    }

    public func fetchBlockedUsers() async throws -> [BlockedUser] {
        guard let uid = loadUID() else { throw UserError.emptyUID }

        let snapshot = try await db.collection("users")
            .document(uid)
            .collection("blocks")
            .order(by: "createdAt", descending: true)
            .getDocuments()

        return snapshot.documents.map { document in
            let data = document.data()
            let blockedAt = blockedAt(from: data["createdAt"])
            let nickname = data["nickname"] as? String ?? "알 수 없는 사용자"

            return BlockedUser(
                id: document.documentID,
                nickname: nickname.isEmpty ? "알 수 없는 사용자" : nickname,
                blockedAt: blockedAt,
                displayTime: RelativeTimeFormatter.formattedTime(from: blockedAt)
            )
        }
    }

    public func block(uid: String, nickname: String) async throws {
        guard let currentUID = loadUID() else { throw UserError.emptyUID }

        let blockReference = db.collection("users")
            .document(currentUID)
            .collection("blocks")
            .document(uid)

        try await blockReference.setData([
            "nickname": nickname,
            "createdAt": FieldValue.serverTimestamp()
        ])
    }

    public func unblock(uid: String) async throws {
        guard let currentUID = loadUID() else { throw UserError.emptyUID }

        let blockReference = db.collection("users")
            .document(currentUID)
            .collection("blocks")
            .document(uid)

        try await blockReference.delete()
    }

    // MARK: - Private

    private func blockedAt(from value: Any?) -> Date {
        if let timestamp = value as? Timestamp {
            return timestamp.dateValue()
        }

        if let date = value as? Date {
            return date
        }

        return Date()
    }
}
