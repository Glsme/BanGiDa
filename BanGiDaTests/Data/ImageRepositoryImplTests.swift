import Foundation
import Testing
import Data

@testable import BanGiDa

struct ImageRepositoryImplTests {
    @Test func loadImageDataDelegatesToDocumentManagerAndReturnsValueUnchanged() {
        let (sut, documentManager) = makeSUT()
        let expectedData = Data([0x01, 0x02, 0x03])
        documentManager.imageDataByFileName["dog.jpg"] = expectedData

        let result = sut.loadImageData(fileName: "dog.jpg")

        #expect(result == expectedData)
        #expect(documentManager.loadedFileNames == ["dog.jpg"])
    }

    @Test func loadImageDataReturnsNilWhenDocumentManagerHasNoData() {
        let (sut, documentManager) = makeSUT()

        let result = sut.loadImageData(fileName: "missing.jpg")

        #expect(result == nil)
        #expect(documentManager.loadedFileNames == ["missing.jpg"])
    }

    @Test func removeImagePassesFileNameUnchangedToDocumentManager() {
        let (sut, documentManager) = makeSUT()

        sut.removeImage(fileName: "cat.jpg")

        #expect(documentManager.removedFileNames == ["cat.jpg"])
    }

    @Test func removeAllDelegatesToDocumentManager() {
        let (sut, documentManager) = makeSUT()

        sut.removeAll()

        #expect(documentManager.removeAllCallCount == 1)
    }

    @Test func saveImageDataThrowsFetchDirectoryPathErrorWhenDocumentDirectoryPathIsNil() {
        let (sut, documentManager) = makeSUT()
        documentManager.documentDirectoryPathToReturn = nil

        do {
            try sut.saveImageData(fileName: "dog.jpg", data: Data())
            Issue.record("saveImageData가 에러를 던지지 않았습니다.")
        } catch DocumentError.fetchDirectoryPathError {
            // 기대한 에러
        } catch {
            Issue.record("DocumentError.fetchDirectoryPathError를 기대했지만 \(error)를 받았습니다.")
        }
    }

    // 캡처: saveImageData는 images 디렉터리가 이미 있다는 전제에 의존한다.
    // createImagesDirectoryPath()는 생성 실패를 print로 삼키고 throw하지 않으므로
    // (DocumentManager.swift:196-198), 디렉터리가 없으면 data.write(to:)가 대신
    // 불투명한 Foundation 에러를 던진다. DocumentError가 아니다.
    // 자세한 내용은 CHARACTERIZATION-NOTES.md 참고.
    @Test func saveImageDataThrowsOpaqueFoundationErrorWhenImagesDirectoryIsAbsent() throws {
        let (sut, documentManager) = makeSUT()
        let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        // images 하위 디렉터리는 일부러 만들지 않는다.
        documentManager.documentDirectoryPathToReturn = tempDirectory

        do {
            try sut.saveImageData(fileName: "dog.jpg", data: Data("hello".utf8))
            Issue.record("saveImageData가 에러를 던지지 않았습니다.")
        } catch is DocumentError {
            Issue.record("DocumentError가 아니라 파일 쓰기 에러를 기대했습니다.")
        } catch {
            // 기대한 경로: DocumentError로 감싸지지 않은 파일 쓰기 실패가 그대로 전파된다.
            #expect(documentManager.createImagesDirectoryPathCallCount == 1)
        }
    }

    @Test func saveImageDataWritesFileUnderImagesDirectory() throws {
        let (sut, documentManager) = makeSUT()
        let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        // documentManager는 스텁이라 createImagesDirectoryPath 호출이 실제로 디스크에
        // "images" 폴더를 만들지 않는다. 프로덕션에서는 그 호출이 폴더를 만들어 두므로
        // 여기서는 테스트가 대신 그 전제 조건을 만들어 둔다.
        let imagesDirectory = tempDirectory.appendingPathComponent("images")
        try FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        documentManager.documentDirectoryPathToReturn = tempDirectory
        let data = Data("hello".utf8)

        try sut.saveImageData(fileName: "dog.jpg", data: data)

        let expectedFileURL = tempDirectory
            .appendingPathComponent("images")
            .appendingPathComponent("dog.jpg")
        let writtenData = try Data(contentsOf: expectedFileURL)

        #expect(writtenData == data)
        #expect(documentManager.createImagesDirectoryPathCallCount == 1)
    }
}

private func makeSUT() -> (ImageRepositoryImpl, DocumentManagingStub) {
    let documentManager = DocumentManagingStub()
    let sut = ImageRepositoryImpl(documentManager: documentManager)

    return (sut, documentManager)
}
