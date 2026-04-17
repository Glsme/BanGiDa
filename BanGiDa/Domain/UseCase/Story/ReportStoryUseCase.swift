//
//  ReportStoryUseCase.swift
//  BanGiDa
//
//  Created by 홍석준 on 1/4/26.
//

import Foundation

public protocol ReportStoryUseCase {
    func execute(imageURL: String, reason: String) async throws
}

public final class ReportStoryUseCaseImpl: ReportStoryUseCase {
    private let storyRepository: StoryRepository
    private let userRepository: UserRepository
    
    public init(storyRepository: StoryRepository, userRepository: UserRepository) {
        self.storyRepository = storyRepository
        self.userRepository = userRepository
    }
    
    public func execute(imageURL: String, reason: String) async throws {
        guard let uid = userRepository.loadUID() else { throw UserError.emptyUID }
        guard let imageURL = URL(string: imageURL) else { throw WriteStoryError.emptyURL }
        
        let imageID = cacheKey(for: imageURL)
        try await storyRepository.report(imageID: imageID, uid: uid, reason: reason)
    }
    
    // MARK: - Private
    
    private func cacheKey(for url: URL) -> String {
        let absolute = url.absoluteString
        guard let range = absolute.range(of: "images%2F") else {
            return url.absoluteString
        }

        let idStart = range.upperBound
        let remaining = absolute[idStart...]
        let uid = remaining.split(separator: "?").first.map(String.init) ?? url.absoluteString
        return uid.isEmpty ? url.absoluteString : uid
    }
}
