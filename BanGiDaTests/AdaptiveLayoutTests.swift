import CoreGraphics
import Testing

@testable import BanGiDa

struct AdaptiveLayoutTests {
    // iPhone 17 세로 화면(402 × 874pt). 컨테이너가 화면 전체일 때 기존 UIScreen 기반 값과 같아야 한다.
    private let iPhoneScreen = CGSize(width: 402, height: 874)
    private let categoryRowHeight: CGFloat = 60

    @Test func calendarHeightMatchesLegacyScreenRatio() {
        let height = AdaptiveLayout.calendarHeight(containerHeight: iPhoneScreen.height)

        #expect(isClose(height, iPhoneScreen.height * 0.42))
    }

    @Test func calendarHeightFollowsContainerResize() {
        let folded = AdaptiveLayout.calendarHeight(containerHeight: 678)
        let unfolded = AdaptiveLayout.calendarHeight(containerHeight: 951)

        #expect(unfolded > folded)
        #expect(isClose(unfolded, 951 * 0.42))
    }

    @Test func calendarHeightIsZeroForEmptyContainer() {
        #expect(AdaptiveLayout.calendarHeight(containerHeight: 0) == 0)
        #expect(AdaptiveLayout.calendarHeight(containerHeight: -10) == 0)
    }

    @Test func categoryMetricsMatchLegacyLayoutOnIPhone() {
        let containerWidth = iPhoneScreen.width * 0.95
        let metrics = AdaptiveLayout.categoryItemMetrics(
            containerSize: CGSize(width: containerWidth, height: categoryRowHeight)
        )

        // 기존 계산식: ((화면 폭 × 0.95) − 간격 10 × 5) / 6
        let legacySide = (iPhoneScreen.width * 0.95 - 10 * 5) / 6
        #expect(isClose(metrics.itemSide, legacySide))
        #expect(isClose(metrics.spacing, 10))
    }

    @Test func categoryItemNeverExceedsContainerHeightOnWideContainer() {
        let containerSize = CGSize(width: 635, height: categoryRowHeight)
        let metrics = AdaptiveLayout.categoryItemMetrics(containerSize: containerSize)

        #expect(metrics.itemSide == categoryRowHeight)
        // 넓어진 폭은 간격으로 흡수해 6개가 여전히 컨테이너 폭을 채운다.
        #expect(isClose(metrics.itemSide * 6 + metrics.spacing * 5, containerSize.width))
    }

    @Test func categorySpacingNeverShrinksBelowMinimum() {
        let metrics = AdaptiveLayout.categoryItemMetrics(containerSize: CGSize(width: 200, height: 10))

        #expect(metrics.itemSide == 10)
        #expect(metrics.spacing >= 10)
    }

    @Test func categoryMetricsAreZeroForEmptyContainer() {
        let metrics = AdaptiveLayout.categoryItemMetrics(containerSize: .zero)

        #expect(metrics.itemSide == 0)
        #expect(metrics.spacing == 10)
    }

    private func isClose(_ lhs: CGFloat, _ rhs: CGFloat) -> Bool {
        abs(lhs - rhs) < 0.001
    }
}
