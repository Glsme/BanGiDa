import Foundation
import Testing

/// 모듈 경계 규칙 중 **컴파일러가 강제하지 못하는 것**을 지킨다.
///
/// Phase 1 파일럿에서 실측으로 확인한 사실이 배경이다.
/// - 시스템 프레임워크(UIKit·SwiftUI 등) import는 어떤 빌드 설정으로도 막을 수 없다.
///   의존성을 선언하지 않아도 `import UIKit`은 항상 컴파일된다.
/// - first-party 모듈 간 암묵 의존은 `tuist inspect dependencies`가 잡지만,
///   그건 `xcodebuild test`와 별개 명령이라 놓치기 쉽다.
///
/// 그래서 소스를 직접 훑어 금지 import를 잡는다. 새 도구를 들이지 않고
/// 기존 테스트 스위트 안에서 돌게 하려는 의도다.
struct ArchitectureBoundaryTests {
    @Test func domainImportsOnlyFoundation() throws {
        let violations = try importViolations(
            in: "Projects/Domain/Sources",
            allowing: ["Foundation"]
        )

        #expect(
            violations.isEmpty,
            "Domain은 Foundation 외 어떤 것도 import하지 않아야 한다: \(violations.joined(separator: ", "))"
        )
    }

    @Test func coreKitImportsOnlyFoundation() throws {
        let violations = try importViolations(
            in: "Projects/Core/CoreKit/Sources",
            allowing: ["Foundation"]
        )

        #expect(
            violations.isEmpty,
            "CoreKit은 Foundation 전용이어야 한다: \(violations.joined(separator: ", "))"
        )
    }

    // 프로젝트 규칙: Presentation에서 Realm·Firebase를 직접 import하지 않는다.
    // Data 모듈을 거치는 것은 허용한다.
    @Test func presentationDoesNotImportPersistenceOrBackendFrameworks() throws {
        let forbidden = ["Realm", "RealmSwift", "Zip"]
        let sources = try swiftFiles(in: "BanGiDa/Presentation")
        var violations: [String] = []

        for file in sources {
            for module in try imports(of: file) where forbidden.contains(module) || module.hasPrefix("Firebase") {
                violations.append("\(file.lastPathComponent): \(module)")
            }
        }

        #expect(
            violations.isEmpty,
            "Presentation은 영속·백엔드 프레임워크를 직접 import하지 않아야 한다: \(violations.joined(separator: ", "))"
        )
    }

    // Application(조립 루트)은 Data를 알아도 되지만, 그 아래 구체 프레임워크까지
    // 직접 만질 이유는 없다. Firebase 링크를 Data 하나로 모은 결정을 지키는 가드다.
    @Test func applicationDoesNotImportBackendFrameworks() throws {
        let sources = try swiftFiles(in: "BanGiDa/Application")
        var violations: [String] = []

        for file in sources {
            for module in try imports(of: file) where module.hasPrefix("Firebase") || module.hasPrefix("Realm") {
                violations.append("\(file.lastPathComponent): \(module)")
            }
        }

        #expect(
            violations.isEmpty,
            "Application은 Firebase·Realm을 직접 import하지 않아야 한다: \(violations.joined(separator: ", "))"
        )
    }
}

// MARK: - 소스 스캔

private let repositoryRoot: URL = {
    // <root>/BanGiDaTests/Architecture/ArchitectureBoundaryTests.swift
    URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
}()

private func swiftFiles(in relativePath: String) throws -> [URL] {
    let directory = repositoryRoot.appendingPathComponent(relativePath)

    // 경로를 못 찾으면 조용히 통과시키지 않는다. 통과했다는 착각이 규칙 부재보다 나쁘다.
    var isDirectory: ObjCBool = false
    let exists = FileManager.default.fileExists(atPath: directory.path, isDirectory: &isDirectory)
    try #require(exists && isDirectory.boolValue, "소스 경로를 찾지 못했다: \(directory.path)")

    guard let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: nil) else {
        return []
    }

    let files = enumerator.compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" }
    try #require(!files.isEmpty, "\(relativePath)에서 Swift 파일을 찾지 못했다")

    return files
}

private func imports(of file: URL) throws -> [String] {
    let contents = try String(contentsOf: file, encoding: .utf8)

    return contents.split(separator: "\n").compactMap { line in
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard trimmed.hasPrefix("import ") else { return nil }

        // `import struct Foo.Bar` 같은 형태도 모듈명만 뽑는다.
        let parts = trimmed.dropFirst("import ".count).split(separator: " ")
        guard let last = parts.last else { return nil }

        return String(last.split(separator: ".").first ?? last)
    }
}

private func importViolations(in relativePath: String, allowing allowed: Set<String>) throws -> [String] {
    var violations: [String] = []

    for file in try swiftFiles(in: relativePath) {
        for module in try imports(of: file) where !allowed.contains(module) {
            violations.append("\(file.lastPathComponent): \(module)")
        }
    }

    return violations
}
