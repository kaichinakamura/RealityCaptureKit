import Foundation
import Testing
@testable import RealityCaptureKit

@Suite struct WineCaptureModuleTests {
    @Test func extractsVintageAndAlcoholFromOCRText() async throws {
        let module = WineCaptureModule()
        let metadata = try await module.buildMetadata(
            from: wineContext(ocrText: "Chateau Example\nBordeaux\n2018\n13.5%")
        )

        #expect(metadata.fields["wine_name"]?.value == "Chateau Example")
        #expect(metadata.fields["vintage"]?.value == "2018")
        #expect(metadata.fields["region"]?.value == "Bordeaux")
        #expect(metadata.fields["alcohol"]?.value == "13.5%")
    }

    @Test func generatesWineSpecificQuestions() async throws {
        let module = WineCaptureModule()
        let questions = try await module.makeQuestions(
            from: wineContext(ocrText: "Wine"),
            metadata: MetadataResult(title: "Wine")
        )

        #expect(
            questions.map(\.id) == ["taste_rating", "drink_again", "sweetness", "acidity", "tannin", "note"]
        )
        #expect(questions[0].isRequired)
        #expect(questions[1].isRequired)
        #expect(!questions[2].isRequired)
    }

    @Test func buildsRecordWithWineTag() async throws {
        let module = WineCaptureModule()
        let record = try await module.buildRecord(
            from: wineContext(ocrText: "Wine"),
            metadata: MetadataResult(title: "Wine"),
            answers: [UserAnswer(questionId: "note", value: .text("Cherry and spice."))]
        )

        #expect(record.moduleId == "wine")
        #expect(record.tags == ["wine"])
        #expect(record.note == "Cherry and spice.")
    }

    @Test func handlesMissingOCRTextGracefully() async throws {
        let module = WineCaptureModule()
        let metadata = try await module.buildMetadata(from: wineContext(ocrText: nil))

        #expect(metadata.title == "Unknown Wine")
        #expect(metadata.fields["wine_name"]?.value == "Unknown")
        #expect(metadata.fields["vintage"]?.value == "Unknown")
        #expect(metadata.fields["alcohol"]?.value == "Unknown")
    }

    @Test func vintageExtractionHelper() {
        #expect(WineCaptureModule.extractVintage(from: "Bottle 2019 Reserve") == "2019")
        #expect(WineCaptureModule.extractVintage(from: "Lot 3021") == nil)
    }

    private func wineContext(ocrText: String?) -> CaptureContext {
        let date = Date(timeIntervalSince1970: 1_704_067_200)
        return CaptureContext(
            image: CapturedImage(data: Data([1]), fileName: "wine.jpg", createdAt: date, uti: "public.jpeg"),
            capturedAt: date,
            ocr: ocrText.map { OCRResult(fullText: $0) },
            imageMetadata: [:],
            location: nil,
            sensors: nil,
            weather: nil,
            searchResults: [
                ExternalSearchResult(
                    title: "Chateau Example",
                    snippet: "Mock wine information.",
                    source: "MockExternalSearchService"
                )
            ]
        )
    }
}
