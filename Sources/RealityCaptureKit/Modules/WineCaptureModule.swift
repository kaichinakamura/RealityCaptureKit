import Foundation

public struct WineCaptureModule: CaptureModule {
    public let id = "wine"
    public let displayName = "Wine Capture"

    public init() {}

    public func buildMetadata(from context: CaptureContext) async throws -> MetadataResult {
        let text = context.ocr?.fullText ?? ""
        let wineName = firstMeaningfulLine(in: text) ?? "Unknown"
        let vintage = Self.extractVintage(from: text) ?? "Unknown"
        let alcohol = Self.extractAlcohol(from: text) ?? "Unknown"
        let region = Self.extractLikelyRegion(from: text) ?? "Unknown"
        let source = context.searchResults.first?.source ?? "OCR heuristics"

        return MetadataResult(
            title: wineName == "Unknown" ? "Unknown Wine" : wineName,
            summary: text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : text,
            fields: [
                "wine_name": field("wine_name", "Wine Name", wineName, confidence: wineName == "Unknown" ? 0.0 : 0.6, source: "OCR"),
                "vintage": field("vintage", "Vintage", vintage, confidence: vintage == "Unknown" ? 0.0 : 0.8, source: "OCR"),
                "producer": field("producer", "Producer", wineName, confidence: wineName == "Unknown" ? 0.0 : 0.4, source: "OCR"),
                "region": field("region", "Region", region, confidence: region == "Unknown" ? 0.0 : 0.4, source: "OCR"),
                "grape_variety": field("grape_variety", "Grape Variety", "Unknown", confidence: 0.0, source: "MVP"),
                "alcohol": field("alcohol", "Alcohol", alcohol, confidence: alcohol == "Unknown" ? 0.0 : 0.8, source: "OCR"),
                "source": field("source", "Source", source, source: "RealityCaptureKit")
            ],
            source: "WineCaptureModule"
        )
    }

    public func makeQuestions(
        from context: CaptureContext,
        metadata: MetadataResult
    ) async throws -> [UserQuestion] {
        [
            UserQuestion(id: "taste_rating", prompt: "How good was this wine?", kind: .rating(min: 1, max: 5), isRequired: true),
            UserQuestion(id: "drink_again", prompt: "Would you drink it again?", kind: .boolean, isRequired: true),
            UserQuestion(id: "sweetness", prompt: "How sweet did it taste?", kind: .rating(min: 1, max: 5), isRequired: false),
            UserQuestion(id: "acidity", prompt: "How acidic did it taste?", kind: .rating(min: 1, max: 5), isRequired: false),
            UserQuestion(id: "tannin", prompt: "How tannic did it taste?", kind: .rating(min: 1, max: 5), isRequired: false),
            UserQuestion(id: "note", prompt: "Any tasting notes?", kind: .text, isRequired: false)
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
            tags: ["wine"],
            note: noteAnswer(in: answers)
        )
    }

    public static func extractVintage(from text: String) -> String? {
        let currentYear = Calendar.current.component(.year, from: Date())
        let pattern = #"\b(19[0-9]{2}|20[0-9]{2})\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.matches(in: text, range: range)
            .compactMap { match -> String? in
                guard let matchRange = Range(match.range(at: 1), in: text) else {
                    return nil
                }
                let candidate = String(text[matchRange])
                guard let year = Int(candidate), year >= 1900, year <= currentYear + 1 else {
                    return nil
                }
                return candidate
            }
            .first
    }

    public static func extractAlcohol(from text: String) -> String? {
        let pattern = #"\b([0-9]{1,2}(?:\.[0-9])?)\s?%"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard
            let match = regex.firstMatch(in: text, range: range),
            let matchRange = Range(match.range(at: 0), in: text)
        else {
            return nil
        }
        return String(text[matchRange]).replacingOccurrences(of: " ", with: "")
    }

    private static func extractLikelyRegion(from text: String) -> String? {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return lines.dropFirst().first { line in
            extractVintage(from: line) == nil && extractAlcohol(from: line) == nil
        }
    }
}
