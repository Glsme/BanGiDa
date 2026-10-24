//
//  CropGeometry.swift
//  BanGiDa
//
//  크롭 박스 계산을 UI와 분리해 단위 테스트할 수 있게 둔다.
//

import CoreGraphics

enum CropGeometry {

    /// 크롭 박스에서 사용자가 잡은 변. 두 변이 함께 있으면 모서리다.
    struct Edges: OptionSet {
        let rawValue: Int

        static let left = Edges(rawValue: 1 << 0)
        static let right = Edges(rawValue: 1 << 1)
        static let top = Edges(rawValue: 1 << 2)
        static let bottom = Edges(rawValue: 1 << 3)

        var isCorner: Bool {
            !intersection([.left, .right]).isEmpty && !intersection([.top, .bottom]).isEmpty
        }
    }

    /// `rect` 안에 `aspectRatio`(가로/세로) 비율로 들어가는 가장 큰 사각형을 가운데 정렬해 돌려준다.
    static func aspectFit(aspectRatio: CGFloat, in rect: CGRect) -> CGRect {
        guard aspectRatio > 0, rect.width > 0, rect.height > 0 else { return rect }

        var size = CGSize(width: rect.width, height: rect.width / aspectRatio)
        if size.height > rect.height {
            size = CGSize(width: rect.height * aspectRatio, height: rect.height)
        }

        return CGRect(
            x: rect.midX - size.width / 2,
            y: rect.midY - size.height / 2,
            width: size.width,
            height: size.height
        )
    }

    /// `point`가 `rect`의 어느 변(또는 모서리) 근처인지 찾는다. 해당 없으면 빈 값.
    static func edges(at point: CGPoint, of rect: CGRect, hitSlop: CGFloat) -> Edges {
        guard rect.insetBy(dx: -hitSlop, dy: -hitSlop).contains(point) else { return [] }

        var edges: Edges = []

        let leftDistance = abs(point.x - rect.minX)
        let rightDistance = abs(point.x - rect.maxX)
        if min(leftDistance, rightDistance) <= hitSlop {
            edges.insert(leftDistance <= rightDistance ? .left : .right)
        }

        let topDistance = abs(point.y - rect.minY)
        let bottomDistance = abs(point.y - rect.maxY)
        if min(topDistance, bottomDistance) <= hitSlop {
            edges.insert(topDistance <= bottomDistance ? .top : .bottom)
        }

        return edges
    }

    /// 잡은 변을 `translation`만큼 옮긴 크롭 박스. 반대편 변은 고정되고, 결과는 `bounds` 안에 머문다.
    /// `aspectRatio`가 있으면 모서리를 잡았을 때 비율을 유지한다.
    static func resize(
        _ rect: CGRect,
        edges: Edges,
        translation: CGPoint,
        aspectRatio: CGFloat?,
        bounds: CGRect,
        minimumSize: CGFloat
    ) -> CGRect {
        let directionX: CGFloat = edges.contains(.left) ? -1 : (edges.contains(.right) ? 1 : 0)
        let directionY: CGFloat = edges.contains(.top) ? -1 : (edges.contains(.bottom) ? 1 : 0)

        let maxWidth: CGFloat = {
            if directionX > 0 { return bounds.maxX - rect.minX }
            if directionX < 0 { return rect.maxX - bounds.minX }
            return rect.width
        }()
        let maxHeight: CGFloat = {
            if directionY > 0 { return bounds.maxY - rect.minY }
            if directionY < 0 { return rect.maxY - bounds.minY }
            return rect.height
        }()

        var width = rect.width + directionX * translation.x
        var height = rect.height + directionY * translation.y

        if let aspectRatio, aspectRatio > 0, edges.isCorner {
            // 가로/세로 중 더 많이 움직인 쪽을 기준으로 비율을 맞춘다.
            let widthFromHeight = height * aspectRatio
            if abs(widthFromHeight - rect.width) > abs(width - rect.width) {
                width = widthFromHeight
            }

            let minimumWidth = max(minimumSize, minimumSize * aspectRatio)
            let maximumWidth = min(maxWidth, maxHeight * aspectRatio)
            width = min(max(width, minimumWidth), maximumWidth)
            height = width / aspectRatio
        } else {
            width = min(max(width, minimumSize), maxWidth)
            height = min(max(height, minimumSize), maxHeight)
        }

        return CGRect(
            x: directionX < 0 ? rect.maxX - width : rect.minX,
            y: directionY < 0 ? rect.maxY - height : rect.minY,
            width: width,
            height: height
        )
    }

    /// 화면 좌표의 크롭 박스를 이미지 좌표(포인트)로 바꾼다. `imageFrame`은 화면에 그려진 이미지 영역이다.
    static func imageCropRect(cropRect: CGRect, imageFrame: CGRect, imageSize: CGSize) -> CGRect {
        guard imageFrame.width > 0, imageFrame.height > 0 else { return .zero }

        let scaleX = imageSize.width / imageFrame.width
        let scaleY = imageSize.height / imageFrame.height
        let rect = CGRect(
            x: (cropRect.minX - imageFrame.minX) * scaleX,
            y: (cropRect.minY - imageFrame.minY) * scaleY,
            width: cropRect.width * scaleX,
            height: cropRect.height * scaleY
        )

        return rect.intersection(CGRect(origin: .zero, size: imageSize))
    }

    /// 이미지를 반시계 방향으로 90도 돌렸을 때 `rect`가 옮겨 가는 위치. `imageSize`는 돌리기 전 크기다.
    static func rotatedCounterClockwise(_ rect: CGRect, in imageSize: CGSize) -> CGRect {
        CGRect(
            x: rect.minY,
            y: imageSize.width - rect.maxX,
            width: rect.height,
            height: rect.width
        )
    }
}
