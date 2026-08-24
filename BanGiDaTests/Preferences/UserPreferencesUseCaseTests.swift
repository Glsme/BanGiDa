import Foundation
import Testing

@testable import BanGiDa

struct UserPreferencesUseCaseTests {
    @Test func getPetNameDelegatesToRepository() {
        let (sut, userPreferencesRepository) = makeSUT()
        userPreferencesRepository.petNameToReturn = "댕댕이"

        #expect(sut.getPetName() == "댕댕이")
    }

    // 캡처: 저장소가 nil을 돌려주면 UseCase도 nil을 가공 없이 그대로 돌려준다.
    @Test func getPetNameReturnsNilWhenRepositoryReturnsNil() {
        let (sut, userPreferencesRepository) = makeSUT()
        userPreferencesRepository.petNameToReturn = nil

        #expect(sut.getPetName() == nil)
    }

    @Test func setPetNamePassesValueToRepositoryUnchanged() {
        let (sut, userPreferencesRepository) = makeSUT()

        sut.setPetName("초코")

        #expect(userPreferencesRepository.requestedSetPetNameValues == ["초코"])
    }

    @Test func isFirstLaunchCompletedDelegatesToRepository() {
        let (sut, userPreferencesRepository) = makeSUT()
        userPreferencesRepository.isFirstLaunchCompletedToReturn = true

        #expect(sut.isFirstLaunchCompleted() == true)
    }

    @Test func setFirstLaunchCompletedDelegatesToRepository() {
        let (sut, userPreferencesRepository) = makeSUT()

        sut.setFirstLaunchCompleted()

        #expect(userPreferencesRepository.setFirstLaunchCompletedCallCount == 1)
    }
}

private func makeSUT() -> (UserPreferencesUseCaseImpl, MockUserPreferencesRepository) {
    let userPreferencesRepository = MockUserPreferencesRepository()
    let sut = UserPreferencesUseCaseImpl(userPreferencesRepository: userPreferencesRepository)

    return (sut, userPreferencesRepository)
}
