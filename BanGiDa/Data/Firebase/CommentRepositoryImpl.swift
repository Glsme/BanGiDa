//
//  CommentRepositoryImpl.swift
//  BanGiDa
//

import Foundation

import FirebaseFirestore
import Domain

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

    public func deleteComment(storyID: String, commentID: String) async throws {
        let storyReference = db.collection("images").document(storyID)
        let commentReference = storyReference.collection("comments").document(commentID)

        // writeComment와 동일한 트랜잭션 + errorPointer 관례. 삭제와 commentCount 보정을
        // 한 트랜잭션으로 묶어 카운터가 문서 삭제와 어긋나지 않게 한다.
        _ = try await db.runTransaction { transaction, errorPointer in
            do {
                _ = try transaction.getDocument(storyReference)

                transaction.deleteDocument(commentReference)
                transaction.updateData(
                    ["commentCount": FieldValue.increment(Int64(-1))],
                    forDocument: storyReference
                )
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }

            return nil
        }
    }

    public func reportComment(
        storyID: String,
        commentID: String,
        reporterUID: String,
        targetAuthorUID: String,
        contentSnapshot: String,
        reason: String
    ) async throws {
        // §8.6(D11): 중복 신고 방지용 서브컬렉션과 운영 추적용 최상위 컬렉션에 모두 남긴다.
        // 댓글은 하드 삭제라, 신고당한 사람이 스스로 지우면 서브컬렉션 기록도 함께 사라지므로
        // 최상위 문서는 대상이 삭제돼도 남도록 별도로 쓴다.
        let subReportReference = db.collection("images")
            .document(storyID)
            .collection("comments")
            .document(commentID)
            .collection("reports")
            .document(reporterUID)

        var subReportData: [String: Any] = ["createdAt": FieldValue.serverTimestamp()]
        if !reason.isEmpty {
            subReportData["reason"] = reason
        }

        let topLevelReference = db.collection("reports").document()
        var topLevelData: [String: Any] = [
            "targetType": "comment",
            "targetPath": "images/\(storyID)/comments/\(commentID)",
            "storyID": storyID,
            "commentID": commentID,
            "targetAuthorUID": targetAuthorUID,
            "reporterUID": reporterUID,
            "contentSnapshot": contentSnapshot,
            "createdAt": FieldValue.serverTimestamp()
        ]
        if !reason.isEmpty {
            topLevelData["reason"] = reason
        }

        try await subReportReference.setData(subReportData, merge: false)
        try await topLevelReference.setData(topLevelData)
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
