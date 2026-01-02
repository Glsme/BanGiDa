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
    
    public func fetchStories(after cursor: StoryCursor?) async throws -> StoryPage {
        var query = db.collection("images")
            .order(by: "createdAt", descending: true)
            .order(by: FieldPath.documentID(), descending: true)
            .limit(to: 10)
        
        if let cursor = cursor {
            let createdAt = Timestamp(date: cursor.createdAt)
            query = query.start(after: [createdAt, cursor.id])
        }
        
        let snapshot = try await query.getDocuments()
        let stories = parseStory(snapshot)
        let lastDocument = snapshot.documents.last
        let nextCursor: StoryCursor?
        
        if let lastDocument = lastDocument,
           let createdAtValue = lastDocument.data()["createdAt"] {
            let createdAt: Date
            
            if let timestamp = createdAtValue as? Timestamp {
                createdAt = timestamp.dateValue()
            } else if let date = createdAtValue as? Date {
                createdAt = date
            } else {
                createdAt = Date()
            }
            
            nextCursor = StoryCursor(createdAt: createdAt, id: lastDocument.documentID)
        } else {
            nextCursor = nil
        }
        
        let isEnd = snapshot.documents.count < 10
        
        return StoryPage(stories: stories, nextCursor: nextCursor, isEnd: isEnd)
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
    
    // MARK: - Private
    
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
    
    private func parseStory(_ snapshot: QuerySnapshot) -> [Story] {
        return snapshot.documents.compactMap { document in
            let data = document.data()
            
            guard let writerUUID = data["writerUUID"] as? String,
                  let writerNickname = data["writerNickname"] as? String,
                  let imageURL = data["imageURL"] as? String,
                  let text = data["text"] as? String,
                  let likeCount = data["likeCount"] as? Int
            else { return nil }
            
            let createdAt: Date
            
            if let timestamp = data["createdAt"] as? Timestamp {
                createdAt = timestamp.dateValue()
            } else if let date = data["createdAt"] as? Date {
                createdAt = date
            } else {
                createdAt = Date()
            }
            
            return Story(
                imageURL: imageURL,
                time: "\(createdAt)",
                nickname: writerNickname,
                text: text,
                isHearted: false,
                heartCount: likeCount
            )
        }
    }
}
