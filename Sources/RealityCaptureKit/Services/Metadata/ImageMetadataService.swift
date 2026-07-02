import Foundation

public protocol ImageMetadataService: Sendable {
    func extractMetadata(from image: CapturedImage) async throws -> [String: String]
}

public struct DefaultImageMetadataService: ImageMetadataService {
    public init() {}

    public func extractMetadata(from image: CapturedImage) async throws -> [String: String] {
        var metadata: [String: String] = [:]
        metadata["byte_count"] = String(image.data.count)
        if let fileName = image.fileName {
            metadata["file_name"] = fileName
        }
        if let uti = image.uti {
            metadata["uti"] = uti
        }
        return metadata
    }
}

public struct MockImageMetadataService: ImageMetadataService {
    public var metadata: [String: String]
    public var error: Error?

    public init(metadata: [String: String] = ["source": "mock"], error: Error? = nil) {
        self.metadata = metadata
        self.error = error
    }

    public func extractMetadata(from image: CapturedImage) async throws -> [String: String] {
        if let error {
            throw error
        }
        return metadata
    }
}
