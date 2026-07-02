import Foundation
import Testing
@testable import RealityCaptureKit

@Suite struct GenericCaptureModuleTests {
    @Test func buildsTitleFromFirstOCRLine() async throws {
        let module = GenericCaptureModule()
        let metadata = try await module.buildMetadata(
            from: context(ocrText: "\n  Mountain View\nA quiet morning")
        )

        #expect(metadata.title == "Mountain View")
        #expect(metadata.fields["location_available"]?.value == "true")
        #expect(metadata.fields["weather_available"]?.value == "true")
    }

    @Test func fallsBackToUntitledCapture() async throws {
        let module = GenericCaptureModule()
        let metadata = try await module.buildMetadata(from: context(ocrText: ""))

        #expect(metadata.title == "Untitled Capture")
        #expect(metadata.summary == nil)
    }

    @Test func generatesSatisfactionAndNoteQuestions() async throws {
        let module = GenericCaptureModule()
        let questions = try await module.makeQuestions(
            from: context(ocrText: "Anything"),
            metadata: MetadataResult(title: "Anything")
        )

        #expect(questions.map(\.id) == ["satisfaction", "note"])
        #expect(questions[0].isRequired)
        #expect(!questions[1].isRequired)
    }

    @Test func buildsRecordWithGenericTag() async throws {
        let module = GenericCaptureModule()
        let record = try await module.buildRecord(
            from: context(ocrText: "Anything"),
            metadata: MetadataResult(title: "Anything"),
            answers: [UserAnswer(questionId: "note", value: .text("A small note"))]
        )

        #expect(record.moduleId == "generic")
        #expect(record.tags == ["generic"])
        #expect(record.note == "A small note")
    }

    private func context(ocrText: String?) -> CaptureContext {
        let date = Date(timeIntervalSince1970: 1_704_067_200)
        return CaptureContext(
            image: CapturedImage(data: Data([1]), fileName: "image.jpg", createdAt: date, uti: "public.jpeg"),
            capturedAt: date,
            ocr: ocrText.map { OCRResult(fullText: $0) },
            imageMetadata: ["source": "test"],
            location: LocationSnapshot(latitude: 1, longitude: 2, horizontalAccuracy: 3, altitudeMeters: 4, capturedAt: date),
            sensors: SensorSnapshot(capturedAt: date, pressureHpa: 1013.25),
            weather: WeatherSnapshot(
                temperatureCelsius: 22,
                humidity: 0.5,
                pressureHpa: 1013.25,
                condition: "Clear",
                windSpeedMps: 1,
                cloudCover: 0.2,
                capturedAt: date,
                source: "test"
            ),
            searchResults: []
        )
    }
}
