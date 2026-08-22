import Foundation
import Testing

@testable import BanGiDa

struct StoryGuidePolicyTests {
    @Test func promotesLegacyAgreementToVersionOne() throws {
        let defaults = try makeIsolatedDefaults(#function)
        defaults.set(true, forKey: UserDefaultsKey.storyAgreement.rawValue)

        StoryGuidePolicy.migrateLegacyAgreementIfNeeded(defaults: defaults)

        // 버전 1로 올라가야 currentVersion(2)과 비교해 재동의 안내가 뜬다.
        #expect(defaults.integer(forKey: UserDefaultsKey.storyAgreementVersion.rawValue) == 1)
        #expect(StoryGuidePolicy.currentVersion > 1)
    }

    @Test func keepsExistingVersionUntouched() throws {
        let defaults = try makeIsolatedDefaults(#function)
        defaults.set(true, forKey: UserDefaultsKey.storyAgreement.rawValue)
        defaults.set(StoryGuidePolicy.currentVersion, forKey: UserDefaultsKey.storyAgreementVersion.rawValue)

        StoryGuidePolicy.migrateLegacyAgreementIfNeeded(defaults: defaults)

        // 이미 동의한 사용자를 1로 되돌리면 안내가 무한히 다시 뜬다.
        #expect(
            defaults.integer(forKey: UserDefaultsKey.storyAgreementVersion.rawValue)
                == StoryGuidePolicy.currentVersion
        )
    }

    @Test func leavesFirstTimeUserAtVersionZero() throws {
        let defaults = try makeIsolatedDefaults(#function)

        StoryGuidePolicy.migrateLegacyAgreementIfNeeded(defaults: defaults)

        #expect(defaults.object(forKey: UserDefaultsKey.storyAgreementVersion.rawValue) == nil)
    }
}

private func makeIsolatedDefaults(_ name: String) throws -> UserDefaults {
    let suiteName = "StoryGuidePolicyTests.\(name)"
    UserDefaults().removePersistentDomain(forName: suiteName)

    let defaults = try #require(UserDefaults(suiteName: suiteName))
    return defaults
}
