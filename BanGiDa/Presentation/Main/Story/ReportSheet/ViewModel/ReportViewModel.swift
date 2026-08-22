//
//  ReportViewModel.swift
//  BanGiDa
//
//  Created by 홍석준 on 1/4/26.
//

import Foundation

final class ReportViewModel: ObservableObject {
    @Injected private var analyticsRepository: AnalyticsRepository
    @Injected private var reportStoryUseCase: ReportStoryUseCase
    @Injected private var reportCommentUseCase: ReportCommentUseCase

    func report(
        target: ReportTarget,
        reason: String,
        targetAuthorUID: String,
        contentSnapshot: String
    ) {
        Task {
            do {
                switch target {
                case .story(let storyID):
                    try await reportStoryUseCase.execute(
                        storyID: storyID,
                        reason: reason,
                        targetAuthorUID: targetAuthorUID,
                        contentSnapshot: contentSnapshot
                    )
                    analyticsRepository.logEvent("Report_Story", parameters: ["text": reason])

                case .comment(let storyID, let commentID):
                    try await reportCommentUseCase.execute(
                        storyID: storyID,
                        commentID: commentID,
                        targetAuthorUID: targetAuthorUID,
                        contentSnapshot: contentSnapshot,
                        reason: reason
                    )
                    analyticsRepository.logEvent("Report_Comment", parameters: ["text": reason])
                }
            } catch {
                analyticsRepository.recordError(error, userInfo: ["function": "\(#function)"])
            }
        }
    }
}
