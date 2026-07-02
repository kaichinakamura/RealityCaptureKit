import Foundation

public struct ExperienceRecord: Codable, Identifiable, Sendable, Equatable {
    public let id: UUID
    public let moduleId: String
    public let createdAt: Date
    public let imageFileName: String?
    public let ocr: OCRResult?
    public let location: LocationSnapshot?
    public let sensors: SensorSnapshot?
    public let weather: WeatherSnapshot?
    public let metadata: MetadataResult
    public let answers: [UserAnswer]
    public let tags: [String]
    public let note: String?

    public init(
        id: UUID = UUID(),
        moduleId: String,
        createdAt: Date,
        imageFileName: String?,
        ocr: OCRResult?,
        location: LocationSnapshot?,
        sensors: SensorSnapshot?,
        weather: WeatherSnapshot?,
        metadata: MetadataResult,
        answers: [UserAnswer],
        tags: [String] = [],
        note: String? = nil
    ) {
        self.id = id
        self.moduleId = moduleId
        self.createdAt = createdAt
        self.imageFileName = imageFileName
        self.ocr = ocr
        self.location = location
        self.sensors = sensors
        self.weather = weather
        self.metadata = metadata
        self.answers = answers
        self.tags = tags
        self.note = note
    }
}
