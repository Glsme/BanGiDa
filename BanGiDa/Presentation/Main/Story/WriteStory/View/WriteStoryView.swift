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

struct WriteStoryView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var isPhotoPickerPresented = false
    @State private var photoAlert: PhotoAlert?
    @State private var photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    @State private var storyText = ""

    var body: some View {
        ScrollView {
            VStack {
                Group {
                    if let selectedImage {
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
                
                textInputSection
                    .padding(.top, 12)
            }
            .padding(.horizontal, 16)
        }
        .background(Color.backgroundColor)
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
                    selectedImage = uiImage
                }
            }
        }
        .onChange(of: storyText) { newValue in
            if newValue.count > 100 {
                storyText = String(newValue.prefix(100))
            }
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
    var textInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextEditor(text: $storyText)
                .frame(minHeight: 120)
                .padding(8)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black.opacity(0.2), lineWidth: 1)
                )
            
            HStack {
                Spacer()
                Text("\(storyText.count)/100")
                    .font(.custom("HelveticaNeue-Medium", size: 12))
                    .foregroundColor(.black.opacity(0.6))
            }
        }
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

#Preview {
    WriteStoryView()
}
