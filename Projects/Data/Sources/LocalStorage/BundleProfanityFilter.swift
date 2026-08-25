//
//  BundleProfanityFilter.swift
//  BanGiDa
//

import Foundation
import Domain

public final class BundleProfanityFilter: ProfanityFilter {
    private let wordLoader: () -> Set<String>
    private lazy var prohibitedWords = wordLoader()

    public init(bundle: Bundle = .main) {
        wordLoader = { BundleProfanityFilter.loadWords(from: bundle) }
    }

    package init(wordLoader: @escaping () -> Set<String>) {
        self.wordLoader = wordLoader
    }

    public func containsProhibitedWord(_ text: String) -> Bool {
        let normalizedText = Self.normalized(text)

        guard !normalizedText.isEmpty, !prohibitedWords.isEmpty else { return false }

        return prohibitedWords.contains { normalizedText.contains($0) }
    }
}

private extension BundleProfanityFilter {
    package static func loadWords(from bundle: Bundle) -> Set<String> {
        guard let url = bundle.url(forResource: "profanity-ko", withExtension: "txt"),
              let contents = try? String(contentsOf: url, encoding: .utf8)
        else { return [] }

        return Set(
            contents
                .split(whereSeparator: \.isNewline)
                .map(String.init)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty && !$0.hasPrefix("#") }
                .map(normalized)
                .filter { !$0.isEmpty }
        )
    }

    package static func normalized(_ text: String) -> String {
        text
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .joined()
    }
}
