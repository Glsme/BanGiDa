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
    private let cache = NSCache<NSURL, UIImage>()

    private init() { }

    subscript(url: NSURL) -> UIImage? {
        get { cache.object(forKey: url) }
        set {
            if let image = newValue {
                cache.setObject(image, forKey: url)
            } else {
                cache.removeObject(forKey: url)
            }
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

        let cacheKey = url as NSURL
        if let cached = ImageCache.shared[cacheKey] {
            if Thread.isMainThread {
                image = cached
            } else {
                DispatchQueue.main.async {
                    self.image = cached
                }
            }
            return
        }

        let request = URLRequest(url: url)
        if let cachedResponse = URLCache.shared.cachedResponse(for: request),
           let uiImage = UIImage(data: cachedResponse.data) {
            ImageCache.shared[cacheKey] = uiImage
            if Thread.isMainThread {
                image = uiImage
            } else {
                DispatchQueue.main.async {
                    self.image = uiImage
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
        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, _ in
            guard let self = self else { return }
            defer {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }

            guard let data = data, let uiImage = UIImage(data: data) else {
                return
            }

            if let response = response {
                let cachedResponse = CachedURLResponse(response: response, data: data)
                URLCache.shared.storeCachedResponse(cachedResponse, for: request)
            }
            ImageCache.shared[cacheKey] = uiImage
            DispatchQueue.main.async {
                self.image = uiImage
            }
        }
        task?.resume()
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
            .onDisappear {
                loader.cancel()
            }
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
