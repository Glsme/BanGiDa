//
//  WriteStoryView.swift
//  BanGiDa
//
//  Created by 홍석준 on 12/24/25.
//

import SwiftUI
import PhotosUI
import UIKit
import Photos
import CropViewController

struct WriteStoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = WriteStoryViewModel()
    
    let onFinish: () -> Void
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var isPhotoPickerPresented = false
    @State private var isCropPresented = false
    @State private var cropImage: UIImage?
    @State private var photoAlert: PhotoAlert?
    @State private var photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    @State private var isVerticalBarPresented = false
    
    @FocusState private var isTextEditorFocused: Bool
    
    init(onFinish: @escaping () -> Void = {}) {
        self.onFinish = onFinish
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 12) {
                        // Duo에서는 사진 높이를 제한해 첫 화면에서 입력 칸까지 보이게 한다.
                        photoSection(maxImageHeight: usesDuoLayout ? geometry.size.height * 0.4 : .infinity)
                        formSection
                    }
                    .padding(.horizontal, 16)
                }
            }
            .background {
                if #available(iOS 27.1, *) {
                    VerticalBarObserver(isPresented: $isVerticalBarPresented)
                }
            }
            .simultaneousGesture(
                DragGesture().onChanged { _ in
                    isTextEditorFocused = false
                }
            )
            .background(Color.backgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 닫기는 시스템 툴바의 취소 위치에 둔다. iPhone Duo에서는 측면 세로 바 맨 위로 자동 배치된다.
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("닫기", systemImage: "xmark")
                    }
                    .tint(Color.systemTintColor)
                }

                // Duo에서는 공유하기를 내비게이션 바(측면 세로 바)로 옮긴다. 세로 바에 들어가려면 심볼이 필요하다.
                ToolbarItem(placement: sharePlacement) {
                    if usesDuoLayout {
                        Button {
                            viewModel.writeStory()
                        } label: {
                            Label("공유하기", systemImage: "paperplane")
                        }
                        .tint(Color.greenblue)
                        .disabled(!viewModel.isShareEnabled)
                    }
                }
            }
        }
        .alert(item: $photoAlert) { alert in
            switch alert {
            case .denied:
                return Alert(
                    title: Text("사진 접근 권한 필요"),
                    message: Text("설정에서 사진 접근을 허용해 주세요."),
                    primaryButton: .default(Text("설정으로 이동")) {
                        openAppSettings()
                    },
                    secondaryButton: .cancel(Text("취소"))
                )
            }
        }
        .onChange(of: selectedItem) { newItem in
            guard let newItem else { return }
            
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    cropImage = uiImage
                    isCropPresented = true
                }
            }
        }
        .sheet(isPresented: $isCropPresented) {
            if let cropImage {
                CropViewControllerRepresentable(
                    image: cropImage,
                    onCropped: { croppedImage in
                        viewModel.selectedImageData = croppedImage.jpegData(compressionQuality: 0.7)
                        self.cropImage = nil
                        selectedItem = nil
                        isCropPresented = false
                    },
                    onCancelled: {
                        self.cropImage = nil
                        selectedItem = nil
                        isCropPresented = false
                    }
                )
                .ignoresSafeArea()
            }
        }
        .onChange(of: viewModel.storyText) { newValue in
            if newValue.count > 100 {
                viewModel.storyText = String(newValue.prefix(100))
            }
        }
        .onChange(of: viewModel.didFinish) { didFinish in
            guard didFinish else { return }
            onFinish()
            dismiss()
        }
        .onAppear {
            updatePhotoAuthorizationStatus()
        }
        .onChange(of: scenePhase) { phase in
            guard phase == .active else { return }
            updatePhotoAuthorizationStatus()
        }
    }
}

private extension WriteStoryView {
    // 측면 세로 바가 있거나(Duo 바깥 화면·안쪽 가로) 넓은 화면(Duo 안쪽 화면)이면 Duo 배치를 쓴다.
    // iPhone은 둘 다 아니라 기존 배치 그대로다.
    var usesDuoLayout: Bool {
        isVerticalBarPresented || horizontalSizeClass == .regular
    }

    var sharePlacement: ToolbarItemPlacement {
        if #available(iOS 27.0, *) {
            return .topBarPinnedTrailing
        } else {
            return .confirmationAction
        }
    }

    func photoSection(maxImageHeight: CGFloat) -> some View {
        VStack(spacing: 0) {
            Group {
                if let imageData = viewModel.selectedImageData,
                   let selectedImage = UIImage(data: imageData) {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image("BasicDog")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            // 넓은 화면에서 세로 사진이 화면보다 길어지지 않도록 높이를 제한한다.
            .frame(maxHeight: maxImageHeight)

            Button {
                handlePhotoTap()
            } label: {
                capsuleActionLabel(
                    title: "앨범에서 선택",
                    systemImage: "photo.on.rectangle"
                )
                .frame(maxWidth: .infinity)
            }
            .disabled(isPhotoAccessDenied)
            .opacity(isPhotoAccessDenied ? 0.5 : 1)
            .photosPicker(
                isPresented: $isPhotoPickerPresented,
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            )
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity)
    }

    var formSection: some View {
        VStack(spacing: 0) {
            textInputSection

            if !usesDuoLayout {
                Button {
                    viewModel.writeStory()
                } label: {
                    shareCapsuleLabel
                }
                .disabled(!viewModel.isShareEnabled)
                .opacity(viewModel.isShareEnabled ? 1 : 0.5)
                .padding(.top, 12)
            }
        }
        .frame(maxWidth: .infinity)
    }

    var textInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextEditor(text: $viewModel.storyText)
                .scrollContentBackground(.hidden)
                .focused($isTextEditorFocused)
                .font(.custom("HelveticaNeue-Medium", size: 12))
                .frame(minHeight: usesDuoLayout ? 200 : 120)
                .padding(8)
                .background(Color.memoBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
            
            HStack {
                Spacer()
                Text("\(viewModel.storyText.count)/100")
                    .font(.custom("HelveticaNeue-Medium", size: 12))
                    .foregroundColor(Color.systemTintColor.opacity(0.5))
            }
        }
    }

    var shareCapsuleLabel: some View {
        Text("공유하기")
            .font(.custom("HelveticaNeue-Bold", size: 16))
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(viewModel.isShareEnabled ? Color.greenblue : Color.gray)
            .clipShape(Capsule())
    }
    
    enum PhotoAlert: Identifiable {
        case denied
        
        var id: Int { 0 }
    }
    
    var isPhotoAccessDenied: Bool {
        photoAuthorizationStatus == .denied || photoAuthorizationStatus == .restricted
    }

    
    func handlePhotoTap() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            isPhotoPickerPresented = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    photoAuthorizationStatus = newStatus
                    switch newStatus {
                    case .authorized, .limited:
                        isPhotoPickerPresented = true
                    case .denied, .restricted:
                        photoAlert = .denied
                    default:
                        photoAlert = .denied
                    }
                }
            }
        case .denied, .restricted:
            photoAlert = .denied
        @unknown default:
            photoAlert = .denied
        }
    }
    
    func updatePhotoAuthorizationStatus() {
        photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    @ViewBuilder
    func capsuleActionLabel(
        title: String,
        systemImage: String
    ) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
            Text(title)
                .font(.custom("HelveticaNeue-Medium", size: 12))
        }
        .foregroundColor(.black)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.white)
        .overlay(
            Capsule()
                .stroke(Color.black.opacity(0.2), lineWidth: 1)
        )
        .clipShape(Capsule())
    }
}

private struct CropViewControllerRepresentable: UIViewControllerRepresentable {
    let image: UIImage
    let onCropped: (UIImage) -> Void
    let onCancelled: () -> Void

    func makeUIViewController(context: Context) -> CropViewController {
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = context.coordinator
        cropViewController.doneButtonTitle = "완료"
        cropViewController.cancelButtonTitle = "취소"
        return cropViewController
    }

    func updateUIViewController(_ uiViewController: CropViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onCropped: onCropped, onCancelled: onCancelled)
    }

    final class Coordinator: NSObject, CropViewControllerDelegate {
        private let onCropped: (UIImage) -> Void
        private let onCancelled: () -> Void

        init(onCropped: @escaping (UIImage) -> Void, onCancelled: @escaping () -> Void) {
            self.onCropped = onCropped
            self.onCancelled = onCancelled
        }

        func cropViewController(
            _ cropViewController: CropViewController,
            didCropToImage image: UIImage,
            withRect cropRect: CGRect,
            angle: Int
        ) {
            onCropped(image)
        }

        func cropViewController(
            _ cropViewController: CropViewController,
            didFinishCancelled cancelled: Bool
        ) {
            if cancelled {
                onCancelled()
            }
        }
    }
}

/// 시스템이 바를 측면 세로 축에 놓았는지 읽어 상위 뷰에 알린다.
/// toolbarVerticalEdge는 iOS 27.1부터라 배포 타깃(iOS 16)의 뷰에 직접 둘 수 없어 별도 뷰로 분리한다.
@available(iOS 27.1, *)
private struct VerticalBarObserver: View {
    @Environment(\.toolbarVerticalEdge) private var toolbarVerticalEdge
    @Binding var isPresented: Bool

    var body: some View {
        Color.clear
            .onAppear {
                isPresented = toolbarVerticalEdge != nil
            }
            .onChange(of: toolbarVerticalEdge) { _, edge in
                isPresented = edge != nil
            }
    }
}

#Preview {
    WriteStoryView()
}
