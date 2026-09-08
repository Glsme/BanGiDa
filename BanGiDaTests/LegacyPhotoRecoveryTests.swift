//
//  LegacyPhotoRecoveryTests.swift
//  BanGiDaTests
//
//  v1.x~2.0.0이 남긴 `photo == ""` 레코드가 2.0.1에서 사진을 못 찾고,
//  삭제 시 `images/` 폴더를 통째로 지우던 회귀를 막는다.
//

import Foundation
import Testing

@testable import BanGiDa

struct LegacyPhotoRecoveryTests {

    // MARK: - Realm → Domain 매핑

    @Test func emptyPhotoFallsBackToLegacyObjectIdFileName() {
        let diary = makeDiary(photo: "")

        let entry = diary.toDomain()

        #expect(entry.photoFileName == "\(entry.id).jpg")
        // v1.x는 "\(objectId)" 문자열 보간으로 파일명을 만들었다. 같은 값이어야 기존 파일을 찾는다.
        #expect(entry.photoFileName == "\(diary.objectId).jpg")
    }

    @Test func nilPhotoFallsBackToLegacyObjectIdFileName() {
        let entry = makeDiary(photo: nil).toDomain()

        #expect(entry.photoFileName == "\(entry.id).jpg")
    }

    @Test func storedPhotoFileNameIsPreserved() {
        let entry = makeDiary(photo: "stored.jpg").toDomain()

        #expect(entry.photoFileName == "stored.jpg")
    }

    // MARK: - DocumentManager 가드

    @Test func removingEmptyFileNameKeepsImagesDirectoryIntact() throws {
        let sandbox = try Sandbox(files: ["a.jpg", "b.jpg"])
        defer { sandbox.tearDown() }
        let manager = DocumentManager(baseDirectory: sandbox.root)

        manager.removeImageFromDocument(fileName: "")

        #expect(sandbox.exists("a.jpg"))
        #expect(sandbox.exists("b.jpg"))
    }

    @Test func removingNamedFileDeletesOnlyThatFile() throws {
        let sandbox = try Sandbox(files: ["a.jpg", "b.jpg"])
        defer { sandbox.tearDown() }
        let manager = DocumentManager(baseDirectory: sandbox.root)

        manager.removeImageFromDocument(fileName: "a.jpg")

        #expect(!sandbox.exists("a.jpg"))
        #expect(sandbox.exists("b.jpg"))
    }

    @Test func loadingEmptyFileNameReturnsNil() throws {
        let sandbox = try Sandbox(files: ["a.jpg"])
        defer { sandbox.tearDown() }
        let manager = DocumentManager(baseDirectory: sandbox.root)

        #expect(manager.loadImageDataFromDocument(fileName: "") == nil)
    }

    @Test func legacyRecordLoadsItsPhotoThroughFallbackName() throws {
        let entry = makeDiary(photo: "").toDomain()
        let sandbox = try Sandbox(files: ["\(entry.id).jpg"])
        defer { sandbox.tearDown() }
        let manager = DocumentManager(baseDirectory: sandbox.root)

        let data = entry.photoFileName.flatMap { manager.loadImageDataFromDocument(fileName: $0) }

        #expect(data == Sandbox.payload)
    }

    // MARK: - DeleteDiaryUseCase

    @Test func deleteSkipsImageRemovalForEmptyFileName() throws {
        let images = ImageRepositorySpy()
        let useCase = DeleteDiaryUseCaseImpl(diaryRepository: DiaryRepositoryStub(), imageRepository: images)

        try useCase.execute(entry: makeEntry(photoFileName: ""))

        #expect(images.removedFileNames.isEmpty)
    }

    @Test func deleteRemovesNamedImage() throws {
        let images = ImageRepositorySpy()
        let useCase = DeleteDiaryUseCaseImpl(diaryRepository: DiaryRepositoryStub(), imageRepository: images)

        try useCase.execute(entry: makeEntry(photoFileName: "photo.jpg"))

        #expect(images.removedFileNames == ["photo.jpg"])
    }
}

// MARK: - Helpers

private func makeDiary(photo: String?) -> Diary {
    Diary(type: .memo, date: Date(), regDate: Date(), animalName: "콩이", content: "산책", photo: photo, alarmTitle: nil)
}

private func makeEntry(photoFileName: String?) -> DiaryEntry {
    DiaryEntry(
        id: "entry",
        type: .memo,
        date: Date(),
        registeredDate: Date(),
        animalName: "콩이",
        content: "산책",
        photoFileName: photoFileName,
        alarmTitle: nil,
        repeatRule: .none
    )
}

/// 임시 디렉터리 아래에 `images/`와 파일 몇 개를 만들어 DocumentManager의 Documents 역할을 대신한다.
private struct Sandbox {
    static let payload = Data("photo".utf8)

    let root: URL
    let images: URL

    init(files: [String]) throws {
        root = FileManager.default.temporaryDirectory
            .appendingPathComponent("LegacyPhotoRecoveryTests-\(UUID().uuidString)")
        images = root.appendingPathComponent("images")
        try FileManager.default.createDirectory(at: images, withIntermediateDirectories: true)
        for file in files {
            try Self.payload.write(to: images.appendingPathComponent(file))
        }
    }

    func exists(_ file: String) -> Bool {
        FileManager.default.fileExists(atPath: images.appendingPathComponent(file).path)
    }

    func tearDown() {
        try? FileManager.default.removeItem(at: root)
    }
}

private final class ImageRepositorySpy: ImageRepository {
    var removedFileNames: [String] = []

    func loadImageData(fileName: String) -> Data? { nil }
    func saveImageData(fileName: String, data: Data) throws {}
    func removeImage(fileName: String) { removedFileNames.append(fileName) }
    func removeAll() {}
}

private struct DiaryRepositoryStub: DiaryRepository {
    func fetchAll() -> [DiaryEntry] { [] }
    func fetchByDate(_ date: Date) -> [DiaryEntry] { [] }
    func fetchByType(_ type: DiaryType) -> [DiaryEntry] { [] }
    func fetchByDateAndType(date: Date, type: DiaryType) -> [DiaryEntry] { [] }
    func save(_ entry: DiaryEntry) throws -> DiaryEntry { entry }
    func update(_ entry: DiaryEntry) throws {}
    func delete(_ entry: DiaryEntry) throws {}
    func deleteAll() throws {}
    func findByID(_ id: String) -> DiaryEntry? { nil }
}
