//
//  CropOverlayView.swift
//  BanGiDa
//
//  크롭 박스 바깥을 어둡게 덮고, 테두리·모서리 핸들·3분할 격자를 그린다. 터치는 받지 않는다.
//

import UIKit

final class CropOverlayView: UIView {

    private enum Metric {
        static let cornerLength: CGFloat = 20
        static let cornerLineWidth: CGFloat = 3
        static let animationDuration: CFTimeInterval = 0.25
    }

    private(set) var cropRect: CGRect = .zero

    var isGridVisible = false {
        didSet { gridLayer.opacity = isGridVisible ? 1 : 0 }
    }

    private let dimmingLayer = CAShapeLayer()
    private let gridLayer = CAShapeLayer()
    private let borderLayer = CAShapeLayer()
    private let cornerLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        isUserInteractionEnabled = false

        dimmingLayer.fillRule = .evenOdd
        dimmingLayer.fillColor = UIColor.black.withAlphaComponent(0.6).cgColor

        gridLayer.strokeColor = UIColor.white.withAlphaComponent(0.5).cgColor
        gridLayer.lineWidth = 0.5
        gridLayer.fillColor = nil
        gridLayer.opacity = 0

        borderLayer.strokeColor = UIColor.white.cgColor
        borderLayer.lineWidth = 1
        borderLayer.fillColor = nil

        cornerLayer.strokeColor = UIColor.white.cgColor
        cornerLayer.lineWidth = Metric.cornerLineWidth
        cornerLayer.fillColor = nil

        [dimmingLayer, gridLayer, borderLayer, cornerLayer].forEach { layer.addSublayer($0) }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        [dimmingLayer, gridLayer, borderLayer, cornerLayer].forEach { $0.frame = bounds }
        CATransaction.commit()

        updatePaths(animated: false)
    }

    func setCropRect(_ rect: CGRect, animated: Bool) {
        cropRect = rect
        updatePaths(animated: animated)
    }

    // MARK: - Private

    private func updatePaths(animated: Bool) {
        let paths: [(CAShapeLayer, CGPath)] = [
            (dimmingLayer, dimmingPath()),
            (gridLayer, gridPath()),
            (borderLayer, UIBezierPath(rect: cropRect).cgPath),
            (cornerLayer, cornerPath()),
        ]

        for (shapeLayer, path) in paths {
            if animated {
                let animation = CABasicAnimation(keyPath: "path")
                animation.fromValue = shapeLayer.presentation()?.path ?? shapeLayer.path
                animation.toValue = path
                animation.duration = Metric.animationDuration
                animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                shapeLayer.add(animation, forKey: "path")
            }

            CATransaction.begin()
            CATransaction.setDisableActions(true)
            shapeLayer.path = path
            CATransaction.commit()
        }
    }

    private func dimmingPath() -> CGPath {
        let path = UIBezierPath(rect: bounds)
        path.append(UIBezierPath(rect: cropRect))
        return path.cgPath
    }

    private func gridPath() -> CGPath {
        let path = UIBezierPath()
        for index in 1...2 {
            let x = cropRect.minX + cropRect.width * CGFloat(index) / 3
            path.move(to: CGPoint(x: x, y: cropRect.minY))
            path.addLine(to: CGPoint(x: x, y: cropRect.maxY))

            let y = cropRect.minY + cropRect.height * CGFloat(index) / 3
            path.move(to: CGPoint(x: cropRect.minX, y: y))
            path.addLine(to: CGPoint(x: cropRect.maxX, y: y))
        }
        return path.cgPath
    }

    private func cornerPath() -> CGPath {
        // 테두리 바깥쪽에 겹치도록 선 두께의 절반만큼 밀어 그린다.
        let rect = cropRect.insetBy(dx: -Metric.cornerLineWidth / 2, dy: -Metric.cornerLineWidth / 2)
        let length = Metric.cornerLength
        let path = UIBezierPath()

        path.move(to: CGPoint(x: rect.minX, y: rect.minY + length))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + length, y: rect.minY))

        path.move(to: CGPoint(x: rect.maxX - length, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + length))

        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - length))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX - length, y: rect.maxY))

        path.move(to: CGPoint(x: rect.minX + length, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - length))

        return path.cgPath
    }
}
