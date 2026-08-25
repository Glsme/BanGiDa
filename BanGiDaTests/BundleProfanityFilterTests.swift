import Foundation
import Testing
import Data

@testable import BanGiDa

struct BundleProfanityFilterTests {
    @Test func detectsProhibitedWordInNormalizedText() {
        let filter = BundleProfanityFilter(wordLoader: { Set(["씨발"]) })

        #expect(filter.containsProhibitedWord("씨 발") == true)
        #expect(filter.containsProhibitedWord("씨!발") == true)
    }

    @Test func allowsNormalSentence() {
        let filter = BundleProfanityFilter(wordLoader: { Set(["씨발"]) })

        #expect(filter.containsProhibitedWord("우리 강아지와 산책했어요.") == false)
    }

    @Test func allowsAllTextWhenDictionaryIsEmpty() {
        let filter = BundleProfanityFilter(wordLoader: { Set<String>() })

        #expect(filter.containsProhibitedWord("씨 발") == false)
        #expect(filter.containsProhibitedWord("우리 강아지는 정말 귀여워요.") == false)
    }

    @Test func loadsDictionaryOnlyOnceOnFirstUse() {
        var loadCount = 0
        let filter = BundleProfanityFilter(wordLoader: {
            loadCount += 1
            return Set(["씨발"])
        })

        #expect(filter.containsProhibitedWord("씨발") == true)
        #expect(filter.containsProhibitedWord("정상 댓글") == false)
        #expect(loadCount == 1)
    }
}
