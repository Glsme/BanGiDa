//
//  CropGeometryTests.swift
//  BanGiDaTests
//
//  자체 크롭 화면(ImageCropViewController)의 크롭 박스 계산을 검증한다.
//

import CoreGraphics
import Testing

@testable import BanGiDa

struct CropGeometryTests {

    // MARK: - aspectFit

    @Test func aspectFitUsesFullWidthForWideRatio() {
        let rect = CropGeometry.aspectFit(aspectRatio: 2, in: CGRect(x: 0, y: 0, width: 100, height: 100))

        #expect(rect == CGRect(x: 0, y: 25, width: 100, height: 50))
    }

    @Test func aspectFitUsesFullHeightForTallRatio() {
        let rect = CropGeometry.aspectFit(aspectRatio: 0.5, in: CGRect(x: 10, y: 10, width: 100, height: 100))

        #expect(rect == CGRect(x: 35, y: 10, width: 50, height: 100))
    }

    // MARK: - edges

    @Test func edgesDetectsCorner() {
        let rect = CGRect(x: 100, y: 100, width: 200, height: 200)

        let edges = CropGeometry.edges(at: CGPoint(x: 105, y: 295), of: rect, hitSlop: 22)

        #expect(edges == [.left, .bottom])
        #expect(edges.isCorner)
    }

    @Test func edgesDetectsSingleEdge() {
        let rect = CGRect(x: 100, y: 100, width: 200, height: 200)

        let edges = CropGeometry.edges(at: CGPoint(x: 310, y: 200), of: rect, hitSlop: 22)

        #expect(edges == [.right])
        #expect(!edges.isCorner)
    }

    @Test func edgesIgnoresInsideAndFarOutside() {
        let rect = CGRect(x: 100, y: 100, width: 200, height: 200)

        #expect(CropGeometry.edges(at: CGPoint(x: 200, y: 200), of: rect, hitSlop: 22).isEmpty)
        #expect(CropGeometry.edges(at: CGPoint(x: 10, y: 10), of: rect, hitSlop: 22).isEmpty)
    }

    // MARK: - resize

    @Test func resizeRightEdgeKeepsLeftEdgeAndClampsToBounds() {
        let rect = CGRect(x: 100, y: 100, width: 100, height: 100)

        let resized = CropGeometry.resize(
            rect,
            edges: [.right],
            translation: CGPoint(x: 500, y: 40),
            aspectRatio: nil,
            bounds: CGRect(x: 0, y: 0, width: 300, height: 300),
            minimumSize: 60
        )

        #expect(resized == CGRect(x: 100, y: 100, width: 200, height: 100))
    }

    @Test func resizeTopLeftCornerRespectsMinimumSize() {
        let rect = CGRect(x: 100, y: 100, width: 100, height: 100)

        let resized = CropGeometry.resize(
            rect,
            edges: [.left, .top],
            translation: CGPoint(x: 90, y: 90),
            aspectRatio: nil,
            bounds: CGRect(x: 0, y: 0, width: 300, height: 300),
            minimumSize: 60
        )

        #expect(resized == CGRect(x: 140, y: 140, width: 60, height: 60))
    }

    @Test func resizeCornerWithAspectRatioKeepsRatioAndStaysInBounds() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)

        let resized = CropGeometry.resize(
            rect,
            edges: [.right, .bottom],
            translation: CGPoint(x: 10, y: 200),
            aspectRatio: 2,
            bounds: CGRect(x: 0, y: 0, width: 400, height: 120),
            minimumSize: 60
        )

        #expect(resized.width / resized.height == 2)
        #expect(resized == CGRect(x: 0, y: 0, width: 240, height: 120))
    }

    // MARK: - imageCropRect

    @Test func imageCropRectConvertsScreenRectToImageCoordinates() {
        // 1000x500 이미지가 화면에 (50, 100)부터 절반 크기로 그려져 있다.
        let rect = CropGeometry.imageCropRect(
            cropRect: CGRect(x: 100, y: 150, width: 100, height: 50),
            imageFrame: CGRect(x: 50, y: 100, width: 500, height: 250),
            imageSize: CGSize(width: 1000, height: 500)
        )

        #expect(rect == CGRect(x: 100, y: 100, width: 200, height: 100))
    }

    @Test func imageCropRectIsClippedToImageBounds() {
        let rect = CropGeometry.imageCropRect(
            cropRect: CGRect(x: -10, y: 0, width: 110, height: 100),
            imageFrame: CGRect(x: 0, y: 0, width: 100, height: 100),
            imageSize: CGSize(width: 100, height: 100)
        )

        #expect(rect == CGRect(x: 0, y: 0, width: 100, height: 100))
    }

    // MARK: - rotatedCounterClockwise

    @Test func rotatedCounterClockwiseMovesTopRightToTopLeft() {
        // 400x300 이미지의 오른쪽 위 100x50 영역은 반시계 회전 후 왼쪽 위 50x100 영역이 된다.
        let rect = CropGeometry.rotatedCounterClockwise(
            CGRect(x: 300, y: 0, width: 100, height: 50),
            in: CGSize(width: 400, height: 300)
        )

        #expect(rect == CGRect(x: 0, y: 0, width: 50, height: 100))
    }
}
