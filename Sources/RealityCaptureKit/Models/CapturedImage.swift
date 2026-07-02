import Foundation

public struct CapturedImage: Sendable {
    public let data: Data
    public let fileName: String?
    public let createdAt: Date?
    public let uti: String?

    public init(
        data: Data,
        fileName: String? = nil,
        createdAt: Date? = nil,
        uti: String? = nil
    ) {
        self.data = data
        self.fileName = fileName
        self.createdAt = createdAt
        self.uti = uti
    }
}
