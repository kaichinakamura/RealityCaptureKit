import Foundation

func firstMeaningfulLine(in text: String?) -> String? {
    text?
        .components(separatedBy: .newlines)
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .first { !$0.isEmpty }
}

func noteAnswer(in answers: [UserAnswer]) -> String? {
    answers.compactMap { answer -> String? in
        guard answer.questionId == "note" else {
            return nil
        }
        if case .text(let note) = answer.value {
            let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }
        return nil
    }.first
}

func field(
    _ key: String,
    _ displayName: String,
    _ value: String,
    confidence: Double? = nil,
    source: String? = nil
) -> MetadataField {
    MetadataField(
        key: key,
        displayName: displayName,
        value: value,
        confidence: confidence,
        source: source
    )
}
