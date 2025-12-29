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
        
        let nickname = UserDefaults.standard.string(forKey: UserDefaultsKey.name.rawValue) ?? ""
        let data: [String: Any] = [
            "nickname": nickname,
            "createAt": Date(),
            "lastSeenAt": Date()
        ]
        
        try await db.collection("users").document(uid).setData(data)
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
    
    public func checkRegistration(uid: String) async throws -> Bool {
        let userRef = db.collection("users").document(uid)
        let snapShot = try await userRef.getDocument()
        
        return snapShot.data() != nil
    }
    
    public func loadUID() -> String? {
        return Auth.auth().currentUser?.uid
    }
}
