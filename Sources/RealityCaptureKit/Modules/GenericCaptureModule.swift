import Foundation

public struct GenericCaptureModule: CaptureModule {
    public let id = "generic"
    public let displayName = "Generic Capture"

    public init() {}

    public func buildMetadata(from context: CaptureContext) async throws -> MetadataResult {
        let ocrText = context.ocr?.fullText.trimmingCharacters(in: .whitespacesAndNewlines)
        let title = firstMeaningfulLine(in: ocrText) ?? "Untitled Capture"

        return MetadataResult(
            title: title,
            summary: ocrText?.isEmpty == false ? ocrText : nil,
            fields: [
                "ocr_text": field("ocr_text", "OCR Text", ocrText?.isEmpty == false ? ocrText! : ""),
                "captured_at": field("captured_at", "Captured At", ISO8601DateFormatter().string(from: context.capturedAt)),
                "location_available": field("location_available", "Location Available", context.location == nil ? "false" : "true"),
                "weather_available": field("weather_available", "Weather Available", context.weather == nil ? "false" : "true")
            ],
            source: "GenericCaptureModule"
        )
    }

    public func makeQuestions(
        from context: CaptureContext,
        metadata: MetadataResult
    ) async throws -> [UserQuestion] {
        [
            UserQuestion(
                id: "satisfaction",
                prompt: "How satisfying was this experience?",
                kind: .rating(min: 1, max: 5),
                isRequired: true,
                reason: "Subjective satisfaction cannot be sensed automatically."
            ),
            UserQuestion(
                id: "note",
                prompt: "Any notes?",
                kind: .text,
                isRequired: false,
                reason: "Optional context from the user."
            )
        ]
    }

    public func buildRecord(
        from context: CaptureContext,
        metadata: MetadataResult,
        answers: [UserAnswer]
    ) async throws -> ExperienceRecord {
        ExperienceRecord(
            moduleId: id,
            createdAt: context.capturedAt,
            imageFileName: context.image.fileName,
            ocr: context.ocr,
            location: context.location,
            sensors: context.sensors,
            weather: context.weather,
            metadata: metadata,
            answers: answers,
            tags: ["generic"],
            note: noteAnswer(in: answers)
        )
    }
}
