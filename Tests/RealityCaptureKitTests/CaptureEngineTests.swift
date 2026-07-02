import Foundation
import Testing
@testable import RealityCaptureKit

@Suite struct CaptureEngineTests {
    @Test func startCaptureCreatesSessionWithMetadataAndQuestions() async throws {
        let store = InMemoryRecordStore()
        let engine = makeEngine(module: GenericCaptureModule(), store: store)
        let session = try await engine.startCapture(with: makeImage())

        #expect(session.moduleId == "generic")
        #expect(session.metadata.title == "Chateau Example")
        #expect(session.questions.map(\.id) == ["satisfaction", "note"])
        #expect(session.context.location != nil)
        #expect(session.context.sensors != nil)
        #expect(session.context.weather != nil)
        #expect(!session.context.searchResults.isEmpty)
    }

    @Test func completeCaptureCreatesAndSavesRecord() async throws {
        let store = InMemoryRecordStore()
        let engine = makeEngine(module: WineCaptureModule(), store: store)
        let session = try await engine.startCapture(with: makeImage())

        let record = try await engine.completeCapture(
            session: session,
            answers: [
                UserAnswer(questionId: "taste_rating", value: .rating(5)),
                UserAnswer(questionId: "drink_again", value: .boolean(true)),
                UserAnswer(questionId: "note", value: .text("Rich and memorable."))
            ]
        )

        #expect(record.moduleId == "wine")
        #expect(record.tags == ["wine"])
        #expect(record.note == "Rich and memorable.")

        let saved = try await store.fetchAll()
        #expect(saved == [record])
    }

    @Test func ocrFailureDoesNotAbortCapture() async throws {
        let store = InMemoryRecordStore()
        let engine = CaptureEngine(
            module: GenericCaptureModule(),
            ocrService: MockOCRService(error: CaptureError.ocrFailed("boom")),
            locationService: MockLocationService(),
            sensorService: MockSensorService(),
            weatherService: MockWeatherService(),
            metadataService: MockImageMetadataService(),
            searchService: MockExternalSearchService(),
            recordStore: store,
            dateProvider: FixedDateProvider(Date(timeIntervalSince1970: 1_704_067_200))
        )

        let session = try await engine.startCapture(with: makeImage())

        #expect(session.context.ocr == nil)
        #expect(session.metadata.title == "Untitled Capture")
    }

    @Test func invalidImageThrows() async throws {
        let engine = makeEngine(module: GenericCaptureModule(), store: InMemoryRecordStore())

        do {
            _ = try await engine.startCapture(with: CapturedImage(data: Data()))
            Issue.record("Expected invalidImage")
        } catch CaptureError.invalidImage {
            // Expected.
        }
    }

    private func makeEngine(
        module: any CaptureModule,
        store: InMemoryRecordStore
    ) -> CaptureEngine {
        CaptureEngine(
            module: module,
            ocrService: MockOCRService(),
            locationService: MockLocationService(),
            sensorService: MockSensorService(),
            weatherService: MockWeatherService(),
            metadataService: MockImageMetadataService(),
            searchService: MockExternalSearchService(),
            recordStore: store,
            dateProvider: FixedDateProvider(Date(timeIntervalSince1970: 1_704_067_200))
        )
    }

    private func makeImage() -> CapturedImage {
        CapturedImage(
            data: Data([0x01, 0x02, 0x03]),
            fileName: "wine.jpg",
            createdAt: Date(timeIntervalSince1970: 1_704_067_200),
            uti: "public.jpeg"
        )
    }
}
