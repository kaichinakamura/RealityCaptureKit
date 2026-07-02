import Foundation

public protocol SensorService: Sendable {
    func currentSnapshot() async throws -> SensorSnapshot
}

public struct DeviceSensorService: SensorService {
    public init() {}

    public func currentSnapshot() async throws -> SensorSnapshot {
        SensorSnapshot(capturedAt: Date())
    }
}

public struct MockSensorService: SensorService {
    public var snapshot: SensorSnapshot
    public var error: Error?

    public init(
        snapshot: SensorSnapshot = SensorSnapshot(
            capturedAt: Date(timeIntervalSince1970: 1_704_067_200),
            pressureHpa: 1013.25,
            altitudeMeters: 40,
            headingDegrees: 180,
            deviceOrientation: "portrait",
            brightness: 0.5
        ),
        error: Error? = nil
    ) {
        self.snapshot = snapshot
        self.error = error
    }

    public func currentSnapshot() async throws -> SensorSnapshot {
        if let error {
            throw error
        }
        return snapshot
    }
}
