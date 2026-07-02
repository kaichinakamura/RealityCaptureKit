import Foundation

public struct CaptureSession: Identifiable, Sendable {
    public let id: UUID
    public let moduleId: String
    public let context: CaptureContext
    public let metadata: MetadataResult
    public let questions: [UserQuestion]

    public init(
        id: UUID = UUID(),
        moduleId: String,
        context: CaptureContext,
        metadata: MetadataResult,
        questions: [UserQuestion]
    ) {
        self.id = id
        self.moduleId = moduleId
        self.context = context
        self.metadata = metadata
        self.questions = questions
    }
}
