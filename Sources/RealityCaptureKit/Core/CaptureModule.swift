import Foundation

public protocol CaptureModule: Sendable {
    var id: String { get }
    var displayName: String { get }

    func buildMetadata(from context: CaptureContext) async throws -> MetadataResult

    func makeQuestions(
        from context: CaptureContext,
        metadata: MetadataResult
    ) async throws -> [UserQuestion]

    func buildRecord(
        from context: CaptureContext,
        metadata: MetadataResult,
        answers: [UserAnswer]
    ) async throws -> ExperienceRecord
}
