//
//  StoryViewModel.swift
//  BanGiDa
//
//  Created by Codex on 1/??/26.
//

import Foundation

@MainActor
final class StoryViewModel: ObservableObject {
    @Injected private var analyticsRepository: AnalyticsRepository
    @Injected private var fetchStoriesUseCase: FetchStoriesUseCase
    @Injected private var toggleStoryLikeUseCase: ToggleStoryLikeUseCase
    
    @Published var stories: [Story] = []
    @Published private(set) var isEnd = false
    @Published private(set) var isLoading = false
    
    private var cursor: StoryCursor?
    private var hasLoadedOnce = false
    private var loadedStoryIDs: Set<String> = []
    
    private var isRunningForPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    func loadInitialIfNeeded() {
        guard !hasLoadedOnce else { return }
        hasLoadedOnce = true
        
        if isRunningForPreviews {
            stories = Story.mock
            isEnd = true
            return
        }
        
        Task { await fetchStories(reset: true) }
    }
    
    func loadMoreIfNeeded(currentStoryID: Story.ID) {
        guard currentStoryID == stories.last?.id else { return }
        guard !isEnd else { return }
        Task { await fetchStories(reset: false) }
    }

    func prefetchImages(from index: Int, count: Int = 5) {
        let startIndex = index + 1
        guard startIndex < stories.count else { return }
        let endIndex = min(startIndex + count, stories.count)
        let urls = stories[startIndex..<endIndex]
            .compactMap { URL(string: $0.imageURL) }
            .filter { $0.scheme != nil }
        ImagePrefetcher.shared.prefetch(urls: urls)
    }

    func refresh() async {
        cursor = nil
        isEnd = false
        loadedStoryIDs.removeAll()
        await fetchStories(reset: true)
    }
    
    func toggleStoryLike(index: Int) {
        guard stories.indices.contains(index) else { return }
        let storyID = stories[index].id

        Task {
            do {
                try await toggleStoryLikeUseCase.execute(storyID: storyID)
                guard let currentIndex = self.stories.firstIndex(where: { $0.id == storyID }) else {
                    return
                }
                
                let wasHearted = self.stories[currentIndex].isHearted
                self.stories[currentIndex].isHearted.toggle()
                let delta = wasHearted ? -1 : 1
                self.stories[currentIndex].heartCount = max(0, self.stories[currentIndex].heartCount + delta)
                analyticsRepository.logEvent("Toggle_Heart", parameters: nil)
            } catch {
                analyticsRepository.recordError(error, userInfo: ["function": "\(#function)"])
            }
        }
    }

    func updateCommentCount(storyID: String, count: Int) {
        guard let index = stories.firstIndex(where: { $0.id == storyID }) else { return }
        stories[index].commentCount = max(0, count)
    }
    
    // MARK: - Private
    
    private func fetchStories(reset: Bool) async {
        guard !isLoading else { return }
        isLoading = true
        
        defer { isLoading = false }
        
        do {
            if reset {
                loadedStoryIDs.removeAll()
            }
            let page = try await fetchStoriesUseCase.execute(after: reset ? nil : cursor)
            let uniqueStories = page.stories.filter { loadedStoryIDs.insert($0.id).inserted }
            if reset {
                stories = uniqueStories
            } else {
                stories.append(contentsOf: uniqueStories)
            }
            cursor = page.nextCursor
            isEnd = page.isEnd
        } catch {
            analyticsRepository.recordError(error, userInfo: ["function": "\(#function)"])
        }
    }
}
