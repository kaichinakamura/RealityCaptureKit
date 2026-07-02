import Foundation

public protocol LocationService: Sendable {
    func currentLocation() async throws -> LocationSnapshot
}

public struct CoreLocationService: LocationService {
    public init() {}

    public func currentLocation() async throws -> LocationSnapshot {
        LocationSnapshot(
            latitude: nil,
            longitude: nil,
            horizontalAccuracy: nil,
            altitudeMeters: nil,
            capturedAt: Date(),
            placeName: nil
        )
    }
}

public struct MockLocationService: LocationService {
    public var location: LocationSnapshot
    public var error: Error?

    public init(
        location: LocationSnapshot = LocationSnapshot(
            latitude: 35.681236,
            longitude: 139.767125,
            horizontalAccuracy: 10,
            altitudeMeters: 40,
            capturedAt: Date(timeIntervalSince1970: 1_704_067_200),
            placeName: "Tokyo Station"
        ),
        error: Error? = nil
    ) {
        self.location = location
        self.error = error
    }

    public func currentLocation() async throws -> LocationSnapshot {
        if let error {
            throw error
        }
        return location
    }
}
