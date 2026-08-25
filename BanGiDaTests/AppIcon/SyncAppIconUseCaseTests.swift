//
//  SyncAppIconUseCaseTests.swift
//  BanGiDaTests
//
//  Created by Seokjune Hong on 2026/08/10.
//

import Foundation
import Testing
import Domain

@testable import BanGiDa

@MainActor
struct SyncAppIconUseCaseTests {

    private func makeSUT(
        currentIcon: AppIcon = .default,
        remoteIcon: AppIcon = .default,
        supportsAlternateIcons: Bool = true
    ) -> (SyncAppIconUseCaseImpl, MockAppIconRepository, MockAppIconRemoteRepository) {
        let iconRepository = MockAppIconRepository()
        iconRepository.currentIcon = currentIcon
        iconRepository.supportsAlternateIcons = supportsAlternateIcons

        let remoteRepository = MockAppIconRemoteRepository()
        remoteRepository.iconToActivate = remoteIcon

        let sut = SyncAppIconUseCaseImpl(
            appIconRepository: iconRepository,
            appIconRemoteRepository: remoteRepository
        )

        return (sut, iconRepository, remoteRepository)
    }

    @Test("원격 아이콘이 현재와 다르면 교체한다")
    func appliesRemoteIconWhenDifferent() async throws {
        let (sut, iconRepository, _) = makeSUT(currentIcon: .default, remoteIcon: .winter)

        try await sut.execute()

        #expect(iconRepository.appliedIcons == [.winter])
    }

    @Test("원격 아이콘이 현재와 같으면 교체하지 않는다")
    func skipsWhenIconUnchanged() async throws {
        // 같은 아이콘에 재적용하면 화면은 그대로인 채 시스템 알림만 노출된다.
        let (sut, iconRepository, _) = makeSUT(currentIcon: .winter, remoteIcon: .winter)

        try await sut.execute()

        #expect(iconRepository.appliedIcons.isEmpty)
    }

    @Test("계절이 끝나면 기본 아이콘으로 되돌린다")
    func revertsToDefaultIcon() async throws {
        let (sut, iconRepository, _) = makeSUT(currentIcon: .winter, remoteIcon: .default)

        try await sut.execute()

        #expect(iconRepository.appliedIcons == [.default])
    }

    @Test("대체 아이콘을 지원하지 않는 기기에서는 아무 작업도 하지 않는다")
    func doesNothingWhenAlternateIconsUnsupported() async throws {
        let (sut, iconRepository, remoteRepository) = makeSUT(
            currentIcon: .default,
            remoteIcon: .winter,
            supportsAlternateIcons: false
        )

        try await sut.execute()

        #expect(iconRepository.appliedIcons.isEmpty)
        #expect(remoteRepository.activateCallCount == 0)
        #expect(remoteRepository.fetchForNextLaunchCallCount == 0)
    }

    @Test("아이콘을 교체한 뒤 다음 실행에 쓸 값을 내려받는다")
    func fetchesValueForNextLaunch() async throws {
        let (sut, _, remoteRepository) = makeSUT(currentIcon: .default, remoteIcon: .autumn)

        try await sut.execute()

        #expect(remoteRepository.activateCallCount == 1)
        #expect(remoteRepository.fetchForNextLaunchCallCount == 1)
    }

    @Test("교체가 없어도 다음 실행용 값은 내려받는다")
    func fetchesForNextLaunchEvenWithoutChange() async throws {
        let (sut, _, remoteRepository) = makeSUT(currentIcon: .autumn, remoteIcon: .autumn)

        try await sut.execute()

        #expect(remoteRepository.fetchForNextLaunchCallCount == 1)
    }

    @Test("아이콘 교체 실패는 호출부로 전파한다")
    func propagatesApplyFailure() async {
        let (sut, iconRepository, _) = makeSUT(currentIcon: .default, remoteIcon: .winter)
        iconRepository.applyError = NSError(domain: "AppIcon", code: -1)

        await #expect(throws: (any Error).self) {
            try await sut.execute()
        }
    }
}
