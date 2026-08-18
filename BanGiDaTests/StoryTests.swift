import Testing

@testable import BanGiDa

struct StoryTests {
    @Test func retainsFirestoreDocumentID() {
        let story = Story(
            id: "firestore-document-id",
            writerUID: "writer-uid",
            imageURL: "https://example.com/story.jpg",
            time: "방금 전",
            nickname: "닉네임",
            text: "스토리",
            isHearted: false,
            heartCount: 0
        )

        #expect(story.id == "firestore-document-id")
    }

    @Test func mockStoryIDsAreUnique() {
        let ids = Story.mock.map(\.id)

        #expect(Set(ids).count == ids.count)
    }
}
