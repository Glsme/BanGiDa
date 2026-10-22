//
//  ImageCropView.swift
//  BanGiDa
//
//  SwiftUI 화면에서 ImageCropViewController를 띄우기 위한 래퍼.
//

import SwiftUI
import UIKit

struct ImageCropView: UIViewControllerRepresentable {
    let image: UIImage
    let onCropped: (UIImage) -> Void
    let onCancelled: () -> Void

    func makeUIViewController(context: Context) -> ImageCropViewController {
        ImageCropViewController(image: image, onCropped: onCropped, onCancelled: onCancelled)
    }

    func updateUIViewController(_ uiViewController: ImageCropViewController, context: Context) {}
}
