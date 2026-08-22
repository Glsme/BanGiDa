//
//  CommentRepositoryImpl.swift
//  BanGiDa
//

import Foundation

import FirebaseFirestore

public final class CommentRepositoryImpl: CommentRepository {
    private let db: Firestore

    public init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    public func fetchComments(
        storyID: String,
        after cursor: CommentCursor?,
        limit: Int
    ) async throws -> CommentPage {
        var query = db.collection("images")
            .document(storyID)
            .collection("comments")
            .order(by: "createdAt", descending: true)
            .order(by: FieldPath.documentID(), descending: true)
            .limit(to: limit)

        if let cursor {
            query = query.start(after: [Timestamp(date: cursor.createdAt), cursor.id])
        }

        let snapshot = try await query.getDocuments()
        let comments = snapshot.documents.compactMap { parseComment($0, storyID: storyID) }
        let nextCursor = snapshot.documents.last.flatMap { document -> CommentCursor? in
            guard let createdAt = createdAt(from: document.data()["createdAt"]) else {
                return nil
            }

            return CommentCursor(createdAt: createdAt, id: document.documentID)
        }

        return CommentPage(
            comments: comments,
            nextCursor: nextCursor,
            isEnd: snapshot.documents.count < limit
        )
    }

    public func fetchPreviewComments(
        storyIDs: [String],
        limit: Int
    ) async throws -> [String: [Comment]] {
        guard !storyIDs.isEmpty else { return [:] }

        return try await withThrowingTaskGroup(of: (String, [Comment]).self) { group in
            for storyID in storyIDs {
                group.addTask {
                    let snapshot = try await self.db.collection("images")
                        .document(storyID)
                        .collection("comments")
                        .order(by: "createdAt", descending: true)
                        .limit(to: limit)
                        .getDocuments()
                    let comments = snapshot.documents.compactMap {
                        self.parseComment($0, storyID: storyID)
                    }

                    return (storyID, comments)
                }
            }

            var previews: [String: [Comment]] = [:]
            for try await (storyID, comments) in group {
                previews[storyID] = comments
            }
            return previews
        }
    }

    public func writeComment(
        storyID: String,
        text: String,
        authorUID: String,
        authorNickname: String
    ) async throws -> Comment {
        let storyReference = db.collection("images").document(storyID)
        let commentReference = storyReference.collection("comments").document()

        _ = try await db.runTransaction { transaction, errorPointer in
            do {
                _ = try transaction.getDocument(storyReference)

                transaction.setData(
                    [
                        "authorUID": authorUID,
                        "authorNickname": authorNickname,
                        "text": text,
                        "createdAt": FieldValue.serverTimestamp()
                    ],
                    forDocument: commentReference
                )
                transaction.updateData(
                    ["commentCount": FieldValue.increment(Int64(1))],
                    forDocument: storyReference
                )
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }

            return nil
        }

        let createdAt = Date()
        // serverTimestamp is unresolved immediately after a write, so the local value is replaced on the next refresh.
        return Comment(
            id: commentReference.documentID,
            storyID: storyID,
            authorUID: authorUID,
            authorNickname: authorNickname,
            text: text,
            createdAt: createdAt,
            displayTime: "방금 전"
        )
    }

    // MARK: - Private

    private func parseComment(_ document: QueryDocumentSnapshot, storyID: String) -> Comment? {
        let data = document.data()

        guard let authorUID = data["authorUID"] as? String,
              let authorNickname = data["authorNickname"] as? String,
              let text = data["text"] as? String,
              let createdAt = createdAt(from: data["createdAt"])
        else { return nil }

        return Comment(
            id: document.documentID,
            storyID: storyID,
            authorUID: authorUID,
            authorNickname: authorNickname,
            text: text,
            createdAt: createdAt,
            displayTime: RelativeTimeFormatter.formattedTime(from: createdAt)
        )
    }

    private func createdAt(from value: Any?) -> Date? {
        if let timestamp = value as? Timestamp {
            return timestamp.dateValue()
        }

        return value as? Date
    }
}
