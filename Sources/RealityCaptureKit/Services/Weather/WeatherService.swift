import Foundation

public protocol WeatherService: Sendable {
    func weather(for location: LocationSnapshot?, at date: Date) async throws -> WeatherSnapshot
}

public struct MockWeatherService: WeatherService {
    public var snapshot: WeatherSnapshot?
    public var error: Error?

    public init(snapshot: WeatherSnapshot? = nil, error: Error? = nil) {
        self.snapshot = snapshot
        self.error = error
    }

    public func weather(for location: LocationSnapshot?, at date: Date) async throws -> WeatherSnapshot {
        if let error {
            throw error
        }
        return snapshot ?? WeatherSnapshot(
            temperatureCelsius: 22.0,
            humidity: 0.55,
            pressureHpa: 1013.25,
            condition: "Clear",
            windSpeedMps: 2.0,
            cloudCover: 0.1,
            capturedAt: date,
            source: "MockWeatherService"
        )
    }
}
