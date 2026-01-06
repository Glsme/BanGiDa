//
//  CachedAsyncImage.swift
//  BanGiDa
//
//  Created by 홍석준 on 1/2/26.
//

import SwiftUI
import UIKit

enum CachedAsyncImagePhase {
    case empty
    case success(Image)
    case failure
}

private final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()

    private init() { }

    subscript(key: String) -> UIImage? {
        get { cache.object(forKey: key as NSString) }
        set {
            if let image = newValue {
                cache.setObject(image, forKey: key as NSString)
            } else {
                cache.removeObject(forKey: key as NSString)
            }
        }
    }
}

private func cacheKey(for url: URL) -> String {
    let absolute = url.absoluteString
    guard let range = absolute.range(of: "images%2F") else {
        return url.absoluteString
    }

    let idStart = range.upperBound
    let remaining = absolute[idStart...]
    let uid = remaining.split(separator: "?").first.map(String.init) ?? url.absoluteString
    return uid.isEmpty ? url.absoluteString : uid
}

final class ImagePrefetcher {
    static let shared = ImagePrefetcher()
    private let queue = DispatchQueue(label: "CachedAsyncImage.prefetch", qos: .utility)
    private let lock = DispatchQueue(label: "CachedAsyncImage.prefetch.lock")
    private var inFlight: Set<String> = []

    private init() { }

    func prefetch(urls: [URL]) {
        guard !urls.isEmpty else { return }
        queue.async {
            urls.forEach { self.prefetch(url: $0) }
        }
    }

    private func prefetch(url: URL) {
        let key = cacheKey(for: url)
        if ImageCache.shared[key] != nil {
            return
        }

        let cacheFileName = "\(key).jpg"
        let documentManager = DocumentManager()
        if let cachedData = documentManager.loadImageDataFromDocument(fileName: cacheFileName),
           let uiImage = UIImage(data: cachedData) {
            ImageCache.shared[key] = uiImage
            return
        }

        guard startInFlight(key) else { return }
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            defer { self?.finishInFlight(key) }
            guard let data = data, let uiImage = UIImage(data: data) else {
                return
            }
            documentManager.saveImageDataFromDocument(fileName: cacheFileName, image: data)
            ImageCache.shared[key] = uiImage
        }
        task.resume()
    }

    private func startInFlight(_ key: String) -> Bool {
        lock.sync {
            if inFlight.contains(key) {
                return false
            }
            inFlight.insert(key)
            return true
        }
    }

    private func finishInFlight(_ key: String) {
        lock.async {
            self.inFlight.remove(key)
        }
    }
}

private final class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false

    private let url: URL?
    private var task: URLSessionDataTask?

    init(url: URL?) {
        self.url = url
    }

    func load() {
        guard !isLoading else { return }
        guard let url = url else { return }

        let cacheKey = cacheKey(for: url)
        let cacheFileName = "\(cacheKey).jpg"
        let documentManager = DocumentManager()
        
        if let cached = ImageCache.shared[cacheKey] {
//            print("CachedAsyncImage: memory cache hit - \(cacheKey)")
            if Thread.isMainThread {
                image = cached
            } else {
                DispatchQueue.main.async {
                    self.image = cached
                }
            }
            return
        }

        if Thread.isMainThread {
            isLoading = true
        } else {
            DispatchQueue.main.async {
                self.isLoading = true
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            if let cachedData = documentManager.loadImageDataFromDocument(fileName: cacheFileName),
               let uiImage = UIImage(data: cachedData) {
//                print("CachedAsyncImage: disk cache hit - \(cacheKey)")
                ImageCache.shared[cacheKey] = uiImage
                DispatchQueue.main.async {
                    self.image = uiImage
                    self.isLoading = false
                }
                return
            }

//            print("CachedAsyncImage: cache miss - \(cacheKey)")
            let request = URLRequest(url: url)
            self.task = URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
                guard let self = self else { return }
                
                defer {
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }

                guard let data = data, let uiImage = UIImage(data: data) else {
                    return
                }

                documentManager.saveImageDataFromDocument(fileName: cacheFileName, image: data)
                ImageCache.shared[cacheKey] = uiImage
                DispatchQueue.main.async {
                    self.image = uiImage
                }
            }
            self.task?.resume()
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}

struct CachedAsyncImage<Content: View>: View {
    private let url: URL?
    private let content: (CachedAsyncImagePhase) -> Content

    @StateObject private var loader: ImageLoader

    init(url: URL?, @ViewBuilder content: @escaping (CachedAsyncImagePhase) -> Content) {
        self.url = url
        self.content = content
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
    }

    var body: some View {
        content(phase)
            .onAppear {
                loader.load()
            }
//            .onDisappear {
//                loader.cancel()
//            }
    }

    private var phase: CachedAsyncImagePhase {
        if let image = loader.image {
            return .success(Image(uiImage: image))
        }

        if loader.isLoading {
            return .empty
        }

        return .failure
    }
}
