import Foundation

public struct UserAnswer: Codable, Sendable, Equatable {
    public let questionId: String
    public let value: UserAnswerValue

    public init(questionId: String, value: UserAnswerValue) {
        self.questionId = questionId
        self.value = value
    }
}

public enum UserAnswerValue: Codable, Sendable, Equatable {
    case rating(Int)
    case text(String)
    case singleChoice(String)
    case multipleChoice([String])
    case boolean(Bool)
    case number(Double)
}
