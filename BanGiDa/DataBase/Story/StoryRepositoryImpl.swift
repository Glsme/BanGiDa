//
//  StoryRepositoryImpl.swift
//  BanGiDa
//
//  Created by 홍석준 on 1/2/26.
//

import Foundation

import FirebaseFirestore
import FirebaseStorage

public final class StoryRepositoryImpl: StoryRepository {
    private let db: Firestore
    private let storage: Storage
    
    public init(db: Firestore = Firestore.firestore(), storage: Storage = Storage.storage()) {
        self.db = db
        self.storage = storage
    }
    
    public func writeStory(image: Data, text: String, nickname: String, uid: String) async throws {
        let (postReference, id) = createImageID()
        let url = try await uploadImage(image, imageID: id)
        try await createStory(
            postReference: postReference,
            imageURL: url,
            text: text,
            nickname: nickname,
            uid: uid
        )
    }
    
    private func createImageID() -> (postReference: DocumentReference, id: String) {
        let postRefrence = db.collection("images").document()
        let imageID = postRefrence.documentID
        
        return (postRefrence, imageID)
    }
    
    private func uploadImage(_ image: Data, imageID: String) async throws -> URL {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let firebaseReference = storage.reference().child("images/\(imageID)")
        _ = try await firebaseReference.putDataAsync(image)
        let url = try await firebaseReference.downloadURL()
        
        return url
    }
    
    private func createStory(
        postReference: DocumentReference,
        imageURL: URL,
        text: String,
        nickname: String,
        uid: String
    ) async throws {
        let data: [String: Any] = [
            "writerUUID": uid,
            "writerNickname": nickname,
            "imageURL": imageURL.absoluteString,
            "createdAt": Date(),
            "text": text,
            "likeCount": 0
        ]
        
        try await postReference.setData(data)
    }
}
