//
//  ImageCropViewController.swift
//  BanGiDa
//
//  사진 크롭 화면. 이미지를 확대·이동하고, 크롭 박스의 변/모서리를 끌어 영역을 고른다.
//  비율 고정, 90도 회전, 초기화를 지원한다.
//

import UIKit

import SnapKit

final class ImageCropViewController: UIViewController {

    private enum Metric {
        static let toolbarHeight: CGFloat = 56
        static let canvasInset: CGFloat = 16
        static let edgeHitSlop: CGFloat = 22
        static let minimumCropSize: CGFloat = 60
        static let maximumZoomMultiplier: CGFloat = 10
        static let animationDuration: TimeInterval = 0.25
    }

    private let onCropped: (UIImage) -> Void
    private let onCancelled: () -> Void

    private let originalImage: UIImage
    private var image: UIImage
    private var aspectRatioOption: AspectRatioOption = .free
    private var cropRect: CGRect = .zero

    private var activeEdges: CropGeometry.Edges = []
    private var panStartCropRect: CGRect = .zero
    private var laidOutBoundsSize: CGSize = .zero

    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private let overlayView = CropOverlayView()
    private let toolbar = UIView()

    private lazy var cropPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCropPan))

    private lazy var cancelButton = makeTextButton(title: "취소", color: .white, action: #selector(cancelButtonTapped))
    private lazy var doneButton = makeTextButton(title: "완료", color: .systemYellow, action: #selector(doneButtonTapped))
    private lazy var rotateButton = makeIconButton(systemName: "rotate.left", action: #selector(rotateButtonTapped))
    private lazy var resetButton = makeIconButton(systemName: "arrow.counterclockwise", action: #selector(resetButtonTapped))
    private lazy var aspectRatioButton: UIButton = {
        let button = self.makeIconButton(systemName: "aspectratio", action: nil)
        button.showsMenuAsPrimaryAction = true
        return button
    }()

    /// 현재 고정된 비율(가로/세로). `nil`이면 자유 비율.
    private var aspectRatio: CGFloat? {
        aspectRatioOption.ratio(for: image.size)
    }

    /// 크롭 박스가 움직일 수 있는 화면 영역.
    private var canvasRect: CGRect {
        let safeArea = view.safeAreaInsets
        let top = safeArea.top + Metric.canvasInset
        let bottom = view.bounds.height - safeArea.bottom - Metric.toolbarHeight - Metric.canvasInset
        return CGRect(
            x: safeArea.left + Metric.canvasInset,
            y: top,
            width: view.bounds.width - safeArea.left - safeArea.right - Metric.canvasInset * 2,
            height: bottom - top
        )
    }

    /// 화면에 그려진 이미지 영역(뷰 좌표).
    private var imageFrame: CGRect {
        imageView.convert(imageView.bounds, to: view)
    }

    /// 크롭 박스 안에 보이는 이미지 영역(이미지 좌표).
    private var visibleImageRect: CGRect {
        CropGeometry.imageCropRect(cropRect: cropRect, imageFrame: imageFrame, imageSize: image.size)
    }

    // MARK: - Init

    init(
        image: UIImage,
        onCropped: @escaping (UIImage) -> Void,
        onCancelled: @escaping () -> Void
    ) {
        self.originalImage = image
        self.image = image
        self.onCropped = onCropped
        self.onCancelled = onCancelled
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .fullScreen
        overrideUserInterfaceStyle = .dark
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        laidOutBoundsSize = .zero
        view.setNeedsLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        overlayView.frame = view.bounds

        guard view.bounds.size != laidOutBoundsSize,
              canvasRect.width > 0,
              canvasRect.height > 0 else { return }

        laidOutBoundsSize = view.bounds.size
        scrollView.frame = view.bounds
        setImage(image)
        layoutInitialCrop(animated: false)
    }

    // MARK: - Configure

    private func configureUI() {
        view.backgroundColor = .black

        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.decelerationRate = .fast
        scrollView.clipsToBounds = false

        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(overlayView)
        view.addSubview(toolbar)

        toolbar.backgroundColor = .black
        toolbar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-Metric.toolbarHeight)
        }

        let iconStackView = UIStackView(arrangedSubviews: [rotateButton, aspectRatioButton, resetButton])
        iconStackView.axis = .horizontal
        iconStackView.spacing = 24

        let toolbarStackView = UIStackView(arrangedSubviews: [cancelButton, iconStackView, doneButton])
        toolbarStackView.axis = .horizontal
        toolbarStackView.alignment = .center
        toolbarStackView.distribution = .equalSpacing

        toolbar.addSubview(toolbarStackView)
        toolbarStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(Metric.toolbarHeight)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Metric.canvasInset)
        }

        cropPanGesture.maximumNumberOfTouches = 1
        cropPanGesture.delegate = self
        view.addGestureRecognizer(cropPanGesture)
        // 크롭 박스의 변을 잡은 게 아닐 때만 이미지가 움직이도록 한다.
        scrollView.panGestureRecognizer.require(toFail: cropPanGesture)

        updateAspectRatioMenu()
    }

    private func makeTextButton(title: String, color: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(color, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func makeIconButton(systemName: String, action: Selector?) -> UIButton {
        let button = UIButton(type: .system)
        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        button.setImage(UIImage(systemName: systemName, withConfiguration: configuration), for: .normal)
        button.tintColor = .white
        if let action {
            button.addTarget(self, action: action, for: .touchUpInside)
        }
        return button
    }

    private func updateAspectRatioMenu() {
        let actions = AspectRatioOption.allCases.map { option in
            UIAction(title: option.title, state: option == aspectRatioOption ? .on : .off) { [weak self] _ in
                self?.selectAspectRatio(option)
            }
        }
        aspectRatioButton.menu = UIMenu(title: "비율", children: actions)
    }

    // MARK: - Layout

    /// 회전 등으로 이미지가 바뀌면 줌을 초기화하고 이미지 뷰를 새 크기로 맞춘다.
    private func setImage(_ newImage: UIImage) {
        image = newImage

        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 1
        scrollView.zoomScale = 1

        imageView.image = newImage
        imageView.frame = CGRect(origin: .zero, size: newImage.size)
        scrollView.contentSize = newImage.size
    }

    /// 이미지 전체(비율 고정 시 그 비율의 가장 큰 영역)를 크롭 박스로 잡는다.
    private func layoutInitialCrop(animated: Bool) {
        let imageBounds = CGRect(origin: .zero, size: image.size)
        let visibleRect = aspectRatio.map { CropGeometry.aspectFit(aspectRatio: $0, in: imageBounds) } ?? imageBounds
        applyLayout(imageRect: visibleRect, animated: animated)
    }

    /// 이미지 좌표의 `imageRect`가 캔버스 가운데 크롭 박스에 꽉 차도록 크롭 박스와 줌·스크롤 위치를 맞춘다.
    private func applyLayout(imageRect: CGRect, animated: Bool) {
        guard imageRect.width > 0, imageRect.height > 0 else { return }

        let newCropRect = CropGeometry.aspectFit(aspectRatio: imageRect.width / imageRect.height, in: canvasRect)
        let zoomScale = newCropRect.width / imageRect.width
        let minimumZoomScale = min(
            max(newCropRect.width / image.size.width, newCropRect.height / image.size.height),
            zoomScale
        )

        cropRect = newCropRect
        overlayView.setCropRect(newCropRect, animated: animated)

        let updates = {
            self.scrollView.contentInset = UIEdgeInsets(
                top: newCropRect.minY,
                left: newCropRect.minX,
                bottom: self.scrollView.bounds.height - newCropRect.maxY,
                right: self.scrollView.bounds.width - newCropRect.maxX
            )
            self.scrollView.maximumZoomScale = max(minimumZoomScale * Metric.maximumZoomMultiplier, zoomScale)
            self.scrollView.minimumZoomScale = minimumZoomScale
            self.scrollView.zoomScale = zoomScale
            self.scrollView.contentOffset = CGPoint(
                x: imageRect.minX * zoomScale - newCropRect.minX,
                y: imageRect.minY * zoomScale - newCropRect.minY
            )
        }

        if animated {
            UIView.animate(
                withDuration: Metric.animationDuration,
                delay: 0,
                options: [.curveEaseInOut, .beginFromCurrentState],
                animations: updates
            )
        } else {
            updates()
        }
    }

    // MARK: - Actions

    @objc private func handleCropPan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            panStartCropRect = cropRect
            overlayView.isGridVisible = true
        case .changed:
            cropRect = CropGeometry.resize(
                panStartCropRect,
                edges: activeEdges,
                translation: gesture.translation(in: view),
                aspectRatio: aspectRatio,
                bounds: canvasRect.intersection(imageFrame),
                minimumSize: Metric.minimumCropSize
            )
            overlayView.setCropRect(cropRect, animated: false)
        case .ended, .cancelled, .failed:
            overlayView.isGridVisible = false
            activeEdges = []
            applyLayout(imageRect: visibleImageRect, animated: true)
        default:
            break
        }
    }

    @objc private func cancelButtonTapped() {
        onCancelled()
    }

    @objc private func doneButtonTapped() {
        let rect = visibleImageRect
        guard rect.width > 0, rect.height > 0 else { return }

        onCropped(image.cropped(to: rect))
    }

    @objc private func rotateButtonTapped() {
        let rotatedRect = CropGeometry.rotatedCounterClockwise(visibleImageRect, in: image.size)

        aspectRatioOption = aspectRatioOption.rotated
        updateAspectRatioMenu()

        setImage(image.rotatedCounterClockwise())
        applyLayout(imageRect: rotatedRect, animated: false)
    }

    @objc private func resetButtonTapped() {
        aspectRatioOption = .free
        updateAspectRatioMenu()

        setImage(originalImage)
        layoutInitialCrop(animated: true)
    }

    private func selectAspectRatio(_ option: AspectRatioOption) {
        aspectRatioOption = option
        updateAspectRatioMenu()

        // 자유 비율은 지금 크롭 박스를 그대로 두고, 고정 비율은 지금 보이는 영역 안에서 그 비율로 맞춘다.
        guard let aspectRatio else { return }
        applyLayout(
            imageRect: CropGeometry.aspectFit(aspectRatio: aspectRatio, in: visibleImageRect),
            animated: true
        )
    }
}

// MARK: - UIScrollViewDelegate

extension ImageCropViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        overlayView.isGridVisible = true
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            overlayView.isGridVisible = false
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        overlayView.isGridVisible = false
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        overlayView.isGridVisible = true
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        overlayView.isGridVisible = false
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ImageCropViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard gestureRecognizer === cropPanGesture, let touchedView = touch.view else { return true }
        return !touchedView.isDescendant(of: toolbar)
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === cropPanGesture else { return true }
        guard !scrollView.isDragging, !scrollView.isZooming, !scrollView.isDecelerating else { return false }

        let edges = CropGeometry.edges(
            at: gestureRecognizer.location(in: view),
            of: cropRect,
            hitSlop: Metric.edgeHitSlop
        )
        // 비율이 고정돼 있으면 모서리로만 크기를 바꾼다.
        guard !edges.isEmpty, aspectRatio == nil || edges.isCorner else { return false }

        activeEdges = edges
        return true
    }
}

// MARK: - AspectRatioOption

private extension ImageCropViewController {
    enum AspectRatioOption: CaseIterable {
        case free
        case original
        case square
        case fourByThree
        case threeByFour
        case sixteenByNine
        case nineBySixteen

        var title: String {
            switch self {
            case .free: return "자유"
            case .original: return "원본"
            case .square: return "1:1"
            case .fourByThree: return "4:3"
            case .threeByFour: return "3:4"
            case .sixteenByNine: return "16:9"
            case .nineBySixteen: return "9:16"
            }
        }

        /// 이미지를 90도 돌렸을 때 같은 모양을 유지하는 비율.
        var rotated: AspectRatioOption {
            switch self {
            case .fourByThree: return .threeByFour
            case .threeByFour: return .fourByThree
            case .sixteenByNine: return .nineBySixteen
            case .nineBySixteen: return .sixteenByNine
            case .free, .original, .square: return self
            }
        }

        func ratio(for imageSize: CGSize) -> CGFloat? {
            switch self {
            case .free: return nil
            case .original: return imageSize.height > 0 ? imageSize.width / imageSize.height : nil
            case .square: return 1
            case .fourByThree: return 4 / 3
            case .threeByFour: return 3 / 4
            case .sixteenByNine: return 16 / 9
            case .nineBySixteen: return 9 / 16
            }
        }
    }
}

// MARK: - UIImage

extension UIImage {
    /// 이미지 좌표(포인트)의 `rect` 영역만 잘라낸다. 원본 해상도(scale)와 방향을 유지한다.
    func cropped(to rect: CGRect) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale

        return UIGraphicsImageRenderer(size: rect.size, format: format).image { _ in
            draw(at: CGPoint(x: -rect.minX, y: -rect.minY))
        }
    }

    /// 반시계 방향으로 90도 돌린 이미지.
    func rotatedCounterClockwise() -> UIImage {
        let rotatedSize = CGSize(width: size.height, height: size.width)
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale

        return UIGraphicsImageRenderer(size: rotatedSize, format: format).image { context in
            context.cgContext.translateBy(x: 0, y: rotatedSize.height)
            context.cgContext.rotate(by: -.pi / 2)
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
