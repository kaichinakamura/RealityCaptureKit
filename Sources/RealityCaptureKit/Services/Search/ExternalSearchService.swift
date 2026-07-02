import Foundation

public protocol ExternalSearchService: Sendable {
    func search(query: String) async throws -> [ExternalSearchResult]
}

public struct MockExternalSearchService: ExternalSearchService {
    public var results: [ExternalSearchResult]?
    public var error: Error?

    public init(results: [ExternalSearchResult]? = nil, error: Error? = nil) {
        self.results = results
        self.error = error
    }

    public func search(query: String) async throws -> [ExternalSearchResult] {
        if let error {
            throw error
        }
        if let results {
            return results
        }
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }
        return [
            ExternalSearchResult(
                title: "Mock result for \(query.components(separatedBy: .newlines).first ?? query)",
                url: nil,
                snippet: "A local mock result generated without network access.",
                source: "MockExternalSearchService"
            )
        ]
    }
}
