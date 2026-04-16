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
    
    func report(text: String, imageURL: String) {
        Task {
            do {
                try await reportStoryUseCase.execute(imageURL: imageURL, reason: text)
                analyticsRepository.logEvent("Report_Story", parameters: ["text": text])
            } catch {
                analyticsRepository.recordError(error, userInfo: ["function": "\(#function)"])
            }
        }
    }
}
