import Foundation

public struct OCRResult: Codable, Sendable, Equatable {
    public let fullText: String
    public let observations: [OCRObservation]

    public init(fullText: String, observations: [OCRObservation] = []) {
        self.fullText = fullText
        self.observations = observations
    }
}

public struct OCRObservation: Codable, Sendable, Equatable {
    public let text: String
    public let confidence: Float?
    public let boundingBox: CGRectCodable?

    public init(
        text: String,
        confidence: Float? = nil,
        boundingBox: CGRectCodable? = nil
    ) {
        self.text = text
        self.confidence = confidence
        self.boundingBox = boundingBox
    }
}
