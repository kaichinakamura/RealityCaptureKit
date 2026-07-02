import Foundation

public struct MetadataResult: Codable, Sendable, Equatable {
    public let title: String?
    public let summary: String?
    public let fields: [String: MetadataField]
    public let source: String?

    public init(
        title: String?,
        summary: String? = nil,
        fields: [String: MetadataField] = [:],
        source: String? = nil
    ) {
        self.title = title
        self.summary = summary
        self.fields = fields
        self.source = source
    }
}

public struct MetadataField: Codable, Sendable, Equatable {
    public let key: String
    public let displayName: String
    public let value: String
    public let confidence: Double?
    public let source: String?

    public init(
        key: String,
        displayName: String,
        value: String,
        confidence: Double? = nil,
        source: String? = nil
    ) {
        self.key = key
        self.displayName = displayName
        self.value = value
        self.confidence = confidence
        self.source = source
    }
}
