//
//  StoryViewModel.swift
//  BanGiDa
//
//  Created by Codex on 1/??/26.
//

import Foundation

@MainActor
final class StoryViewModel: ObservableObject {
    @Injected private var fetchStoriesUseCase: FetchStoriesUseCase
    
    @Published var stories: [Story] = []
    @Published private(set) var isEnd = false
    @Published private(set) var isLoading = false
    
    private var cursor: StoryCursor?
    private var hasLoadedOnce = false
    
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
            print(error)
        }
    }
    
    private var isRunningForPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
