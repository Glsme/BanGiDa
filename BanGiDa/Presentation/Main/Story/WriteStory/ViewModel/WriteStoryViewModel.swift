//
//  WriteStoryViewModel.swift
//  BanGiDa
//
//  Created by 홍석준 on 1/2/26.
//

import Foundation

final class WriteStoryViewModel: ObservableObject {
    @Injected private var writeStoryUseCase: WriteStoryUseCase
    
    @Published var selectedImageData: Data?
    @Published var storyText = ""

    var isShareEnabled: Bool {
        selectedImageData != nil
        && !storyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func writeStory() {
        Task {
            do {
                #warning("추후 이미지 없을 경우, 비어있는 텍스트에 대한 error 처리 필요")
                guard let selectedImageData, !storyText.isEmpty else {
                    return
                }
                
                try await writeStoryUseCase.execute(image: selectedImageData, text: storyText)
            } catch {
                print(error)
            }
        }
    }
}
