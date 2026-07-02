import Foundation

public struct CaptureResult: Sendable {
    public let session: CaptureSession
    public let record: ExperienceRecord

    public init(session: CaptureSession, record: ExperienceRecord) {
        self.session = session
        self.record = record
    }
}
