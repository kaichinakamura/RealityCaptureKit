import Foundation

public protocol OCRService: Sendable {
    func recognizeText(in image: CapturedImage) async throws -> OCRResult
}

public struct VisionOCRService: OCRService {
    public init() {}

    public func recognizeText(in image: CapturedImage) async throws -> OCRResult {
        OCRResult(fullText: "")
    }
}

public struct MockOCRService: OCRService {
    public var result: OCRResult
    public var error: Error?

    public init(
        text: String = "Chateau Example\nBordeaux\n2018\n13.5%",
        observations: [OCRObservation] = [],
        error: Error? = nil
    ) {
        self.result = OCRResult(fullText: text, observations: observations)
        self.error = error
    }

    public init(result: OCRResult, error: Error? = nil) {
        self.result = result
        self.error = error
    }

    public func recognizeText(in image: CapturedImage) async throws -> OCRResult {
        if let error {
            throw error
        }
        return result
    }
}
