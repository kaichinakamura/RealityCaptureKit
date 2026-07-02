import Foundation

public struct ExternalSearchResult: Codable, Sendable, Equatable {
    public let title: String
    public let url: URL?
    public let snippet: String?
    public let source: String?

    public init(
        title: String,
        url: URL? = nil,
        snippet: String? = nil,
        source: String? = nil
    ) {
        self.title = title
        self.url = url
        self.snippet = snippet
        self.source = source
    }
}
