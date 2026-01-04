//
//  StoryViewModel.swift
//  BanGiDa
//
//  Created by Codex on 1/??/26.
//

import Foundation

import FirebaseAnalytics
import FirebaseCrashlytics

@MainActor
final class StoryViewModel: ObservableObject {
    @Injected private var fetchStoriesUseCase: FetchStoriesUseCase
    @Injected private var toggleStoryLikeUseCase: ToggleStoryLikeUseCase
    
    @Published var stories: [Story] = []
    @Published private(set) var isEnd = false
    @Published private(set) var isLoading = false
    
    private var cursor: StoryCursor?
    private var hasLoadedOnce = false
    
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
        await fetchStories(reset: true)
    }
    
    func toggleStoryLike(index: Int) {
        guard stories.indices.contains(index) else { return }
        let storyID = stories[index].id
        let imageURL = stories[index].imageURL

        Task {
            do {
                try await toggleStoryLikeUseCase.execute(imageURL: imageURL)
                guard let currentIndex = self.stories.firstIndex(where: { $0.id == storyID }) else {
                    return
                }
                
                let wasHearted = self.stories[currentIndex].isHearted
                self.stories[currentIndex].isHearted.toggle()
                let delta = wasHearted ? -1 : 1
                self.stories[currentIndex].heartCount = max(0, self.stories[currentIndex].heartCount + delta)
                Analytics.logEvent("Toggle_Heart", parameters: nil)
            } catch {
                Crashlytics.crashlytics().record(error: error, userInfo: ["function": "\(#function)"])
            }
        }
    }
    
    // MARK: - Private
    
    private func fetchStories(reset: Bool) async {
        guard !isLoading else { return }
        isLoading = true
        
        defer { isLoading = false }
        
        do {
            let page = try await fetchStoriesUseCase.execute(after: reset ? nil : cursor)
            if reset {
                stories = page.stories
            } else {
                stories.append(contentsOf: page.stories)
            }
            cursor = page.nextCursor
            isEnd = page.isEnd
        } catch {
            Crashlytics.crashlytics().record(error: error, userInfo: ["function": "\(#function)"])
        }
    }
}
