import Foundation

public struct UserQuestion: Codable, Identifiable, Sendable, Equatable {
    public let id: String
    public let prompt: String
    public let kind: UserQuestionKind
    public let isRequired: Bool
    public let reason: String?

    public init(
        id: String,
        prompt: String,
        kind: UserQuestionKind,
        isRequired: Bool,
        reason: String? = nil
    ) {
        self.id = id
        self.prompt = prompt
        self.kind = kind
        self.isRequired = isRequired
        self.reason = reason
    }
}

public enum UserQuestionKind: Codable, Sendable, Equatable {
    case rating(min: Int, max: Int)
    case text
    case singleChoice([String])
    case multipleChoice([String])
    case boolean
    case number(unit: String?)
}
