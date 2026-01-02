//
//  WriteStoryViewModel.swift
//  BanGiDa
//
//  Created by 홍석준 on 1/2/26.
//

import Foundation

@MainActor
final class WriteStoryViewModel: ObservableObject {
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
                #warning("추후 이미지 없을 경우, 비어있는 텍스트에 대한 error 처리 필요")
                guard let selectedImageData, !storyText.isEmpty else {
                    return
                }
                
                isSharing = true
                
                defer {
                    Task { @MainActor in
                        isSharing = false
                    }
                }
                
                try await writeStoryUseCase.execute(image: selectedImageData, text: storyText)
                didFinish = true
            } catch {
                print(error)
            }
        }
    }
}
