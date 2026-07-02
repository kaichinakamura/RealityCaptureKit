import Foundation

public struct CaptureContext: Sendable {
    public let image: CapturedImage
    public let capturedAt: Date
    public let ocr: OCRResult?
    public let imageMetadata: [String: String]
    public let location: LocationSnapshot?
    public let sensors: SensorSnapshot?
    public let weather: WeatherSnapshot?
    public let searchResults: [ExternalSearchResult]

    public init(
        image: CapturedImage,
        capturedAt: Date,
        ocr: OCRResult?,
        imageMetadata: [String: String],
        location: LocationSnapshot?,
        sensors: SensorSnapshot?,
        weather: WeatherSnapshot?,
        searchResults: [ExternalSearchResult]
    ) {
        self.image = image
        self.capturedAt = capturedAt
        self.ocr = ocr
        self.imageMetadata = imageMetadata
        self.location = location
        self.sensors = sensors
        self.weather = weather
        self.searchResults = searchResults
    }
}
