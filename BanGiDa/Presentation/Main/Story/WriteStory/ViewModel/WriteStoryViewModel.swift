//
//  WriteStoryViewModel.swift
//  BanGiDa
//
//  Created by 홍석준 on 1/2/26.
//

import Foundation

@MainActor
final class WriteStoryViewModel: ObservableObject {
    @Injected private var analyticsRepository: AnalyticsRepository
    @Injected private var writeStoryUseCase: WriteStoryUseCase
    
    @Published var selectedImageData: Data?
    @Published var storyText = ""
    @Published var isSharing = false
    @Published var didFinish = false

    var isShareEnabled: Bool {
        !isSharing
            && selectedImageData != nil
            && !storyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func writeStory() {
        Task {
            do {
                guard let selectedImageData, !storyText.isEmpty else {
                    throw WriteStoryError.emptyImage
                }
                
                isSharing = true
                
                defer {
                    isSharing = false
                }
                
                try await writeStoryUseCase.execute(image: selectedImageData, text: storyText)
                didFinish = true
                analyticsRepository.logEvent("Write_Story", parameters: nil)
            } catch {
                analyticsRepository.recordError(error, userInfo: ["function": "\(#function)"])
            }
        }
    }
}
