//
//  StoryRepositoryImpl.swift
//  BanGiDa
//
//  Created by 홍석준 on 1/2/26.
//

import Foundation

import FirebaseFirestore
import FirebaseStorage
import Domain

public final class StoryRepositoryImpl: StoryRepository {
    private let db: Firestore
    private let storage: Storage
    
    public init(db: Firestore = Firestore.firestore(), storage: Storage = Storage.storage()) {
        self.db = db
        self.storage = storage
    }
    
    public func fetchStories(after cursor: StoryCursor?, uid: String) async throws -> StoryPage {
        if cursor == nil {
            let topSnapshot = try await fetchTopStoriesSnapshot(limit: 3)
            let likedIDs: Set<String> = try await fetchLikedIDs(
                for: topSnapshot.documents.map { $0.documentID },
                uid: uid
            )

            let stories = parseStory(topSnapshot, likedIDs: likedIDs)
            let isEnd = topSnapshot.documents.isEmpty
            let nextCursor = isEnd ? nil : StoryCursor.initialTopStories()

            return StoryPage(stories: stories, nextCursor: nextCursor, isEnd: isEnd)
        }

        var query = db.collection("images")
            .order(by: "createdAt", descending: true)
            .order(by: FieldPath.documentID(), descending: true)
            .limit(to: 10)

        if let cursor = cursor, !cursor.isInitialTopStories {
            let createdAt = Timestamp(date: cursor.createdAt)
            query = query.start(after: [createdAt, cursor.id])
        }

        let snapshot = try await query.getDocuments()
        let likedIDs: Set<String> = try await fetchLikedIDs(
            for: snapshot.documents.map { $0.documentID },
            uid: uid
        )
        
        let stories = parseStory(snapshot, likedIDs: likedIDs)
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
    
    public func toggleLike(storyID: String, uid: String) async throws {
        let imageRefrerence = db.collection("images").document(storyID)
        let likeRefrerence = imageRefrerence.collection("likes").document(uid)

        // Firestore's runTransaction expects a non-throwing closure with an NSErrorPointer.
        // Use the error pointer instead of throwing inside the closure.
        _ = try await db.runTransaction { transaction, errorPointer in
            do {
                let likeSnapshot = try transaction.getDocument(likeRefrerence)

                if likeSnapshot.exists {
                    transaction.deleteDocument(likeRefrerence)
                    transaction.updateData(
                        ["likeCount": FieldValue.increment(Int64(-1))],
                        forDocument: imageRefrerence
                    )
                } else {
                    transaction.setData(
                        ["createdAt": FieldValue.serverTimestamp()],
                        forDocument: likeRefrerence
                    )

                    transaction.updateData(
                        ["likeCount": FieldValue.increment(Int64(1))],
                        forDocument: imageRefrerence
                    )
                }
            } catch {
                // Assign the error to the provided error pointer and return nil
                errorPointer?.pointee = error as NSError
                return nil
            }

            return nil
        }
    }
    
    public func report(
        storyID: String,
        uid: String,
        reason: String,
        targetAuthorUID: String,
        contentSnapshot: String
    ) async throws {
        let reportReference = db.collection("images")
            .document(storyID)
            .collection("reports")
            .document(uid)

        var data: [String: Any] = ["createdAt": FieldValue.serverTimestamp()]

        if !reason.isEmpty {
            data["reason"] = reason
        }

        try await reportReference.setData(data, merge: false)

        // §8.6(D11): 스토리 신고도 댓글 신고와 같은 최상위 reports 컬렉션에 스냅샷을 남겨
        // 운영자가 한 곳만 보면 되게 통일한다.
        let topLevelReference = db.collection("reports").document()
        var topLevelData: [String: Any] = [
            "targetType": "story",
            "targetPath": "images/\(storyID)",
            "storyID": storyID,
            "targetAuthorUID": targetAuthorUID,
            "reporterUID": uid,
            "contentSnapshot": contentSnapshot,
            "createdAt": FieldValue.serverTimestamp()
        ]

        if !reason.isEmpty {
            topLevelData["reason"] = reason
        }

        try await topLevelReference.setData(topLevelData)
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
            "createdAt": FieldValue.serverTimestamp(),
            "text": text,
            "likeCount": 0,
            "commentCount": 0
        ]

        try await postReference.setData(data)
    }
    
    private func parseStory(_ snapshot: QuerySnapshot, likedIDs: Set<String>) -> [Story] {
        return snapshot.documents.compactMap { document in
            let data = document.data()

            guard let writerUID = data["writerUUID"] as? String,
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

            let isHearted = likedIDs.contains(document.documentID)

            return Story(
                id: document.documentID,
                writerUID: writerUID,
                imageURL: imageURL,
                time: RelativeTimeFormatter.formattedTime(from: createdAt),
                nickname: writerNickname,
                text: text,
                isHearted: isHearted,
                heartCount: likeCount,
                commentCount: data["commentCount"] as? Int ?? 0,
                previewComments: []
            )
        }
    }

    private func fetchLikedIDs(for imageIDs: [String], uid: String) async throws -> Set<String> {
        return try await withThrowingTaskGroup(of: String?.self) { group in
            for imageID in imageIDs {
                group.addTask {
                    let likeRef = self.db
                        .collection("images")
                        .document(imageID)
                        .collection("likes")
                        .document(uid)

                    let snap = try await likeRef.getDocument()
                    return snap.exists ? imageID : nil
                }
            }

            var liked: Set<String> = []
            for try await id in group {
                if let id = id {
                    liked.insert(id)
                }
            }
            return liked
        }
    }

    private func fetchTopStoriesSnapshot(limit: Int) async throws -> QuerySnapshot {
        let query = db.collection("images")
            .order(by: "likeCount", descending: true)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)

        return try await query.getDocuments()
    }
    
}
