import Foundation

public final class CaptureEngine: Sendable {
    private let module: any CaptureModule
    private let ocrService: any OCRService
    private let locationService: any LocationService
    private let sensorService: any SensorService
    private let weatherService: any WeatherService
    private let metadataService: any ImageMetadataService
    private let searchService: any ExternalSearchService
    private let recordStore: any RecordStore
    private let dateProvider: any DateProvider

    public init(
        module: any CaptureModule,
        ocrService: any OCRService,
        locationService: any LocationService,
        sensorService: any SensorService,
        weatherService: any WeatherService,
        metadataService: any ImageMetadataService,
        searchService: any ExternalSearchService,
        recordStore: any RecordStore,
        dateProvider: any DateProvider = SystemDateProvider()
    ) {
        self.module = module
        self.ocrService = ocrService
        self.locationService = locationService
        self.sensorService = sensorService
        self.weatherService = weatherService
        self.metadataService = metadataService
        self.searchService = searchService
        self.recordStore = recordStore
        self.dateProvider = dateProvider
    }

    public func startCapture(with image: CapturedImage) async throws -> CaptureSession {
        guard !image.data.isEmpty else {
            throw CaptureError.invalidImage
        }

        let capturedAt = image.createdAt ?? dateProvider.now()
        let ocr = try? await ocrService.recognizeText(in: image)
        let imageMetadata = (try? await metadataService.extractMetadata(from: image)) ?? [:]
        let location = try? await locationService.currentLocation()
        let sensors = try? await sensorService.currentSnapshot()
        let weather = try? await weatherService.weather(for: location, at: capturedAt)
        let searchResults = try? await searchService.search(query: searchQuery(from: ocr))

        let context = CaptureContext(
            image: image,
            capturedAt: capturedAt,
            ocr: ocr,
            imageMetadata: imageMetadata,
            location: location,
            sensors: sensors,
            weather: weather,
            searchResults: searchResults ?? []
        )

        do {
            let metadata = try await module.buildMetadata(from: context)
            let questions = try await module.makeQuestions(from: context, metadata: metadata)
            return CaptureSession(
                moduleId: module.id,
                context: context,
                metadata: metadata,
                questions: questions
            )
        } catch {
            throw CaptureError.moduleFailed(String(describing: error))
        }
    }

    public func completeCapture(
        session: CaptureSession,
        answers: [UserAnswer]
    ) async throws -> ExperienceRecord {
        do {
            let record = try await module.buildRecord(
                from: session.context,
                metadata: session.metadata,
                answers: answers
            )
            try await recordStore.save(record)
            return record
        } catch let captureError as CaptureError {
            throw captureError
        } catch {
            throw CaptureError.unknown(String(describing: error))
        }
    }

    private func searchQuery(from ocr: OCRResult?) -> String {
        firstMeaningfulLine(in: ocr?.fullText) ?? ""
    }
}
