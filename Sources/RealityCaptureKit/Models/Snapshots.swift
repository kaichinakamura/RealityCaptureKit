import Foundation

public struct LocationSnapshot: Codable, Sendable, Equatable {
    public let latitude: Double?
    public let longitude: Double?
    public let horizontalAccuracy: Double?
    public let altitudeMeters: Double?
    public let capturedAt: Date
    public let placeName: String?

    public init(
        latitude: Double?,
        longitude: Double?,
        horizontalAccuracy: Double?,
        altitudeMeters: Double?,
        capturedAt: Date,
        placeName: String? = nil
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.horizontalAccuracy = horizontalAccuracy
        self.altitudeMeters = altitudeMeters
        self.capturedAt = capturedAt
        self.placeName = placeName
    }
}

public struct SensorSnapshot: Codable, Sendable, Equatable {
    public let capturedAt: Date
    public let pressureHpa: Double?
    public let altitudeMeters: Double?
    public let headingDegrees: Double?
    public let deviceOrientation: String?
    public let brightness: Double?

    public init(
        capturedAt: Date,
        pressureHpa: Double? = nil,
        altitudeMeters: Double? = nil,
        headingDegrees: Double? = nil,
        deviceOrientation: String? = nil,
        brightness: Double? = nil
    ) {
        self.capturedAt = capturedAt
        self.pressureHpa = pressureHpa
        self.altitudeMeters = altitudeMeters
        self.headingDegrees = headingDegrees
        self.deviceOrientation = deviceOrientation
        self.brightness = brightness
    }
}

public struct WeatherSnapshot: Codable, Sendable, Equatable {
    public let temperatureCelsius: Double?
    public let humidity: Double?
    public let pressureHpa: Double?
    public let condition: String?
    public let windSpeedMps: Double?
    public let cloudCover: Double?
    public let capturedAt: Date
    public let source: String

    public init(
        temperatureCelsius: Double?,
        humidity: Double?,
        pressureHpa: Double?,
        condition: String?,
        windSpeedMps: Double?,
        cloudCover: Double?,
        capturedAt: Date,
        source: String
    ) {
        self.temperatureCelsius = temperatureCelsius
        self.humidity = humidity
        self.pressureHpa = pressureHpa
        self.condition = condition
        self.windSpeedMps = windSpeedMps
        self.cloudCover = cloudCover
        self.capturedAt = capturedAt
        self.source = source
    }
}
