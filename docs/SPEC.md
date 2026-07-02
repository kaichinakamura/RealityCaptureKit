# RealityCaptureKit MVP Specification

## 1. Overview

RealityCaptureKit is a Swift Package SDK for iOS apps that capture real-world experiences, objects, and observations.

It combines automatic data capture with minimal human input.

The SDK should help apps answer this question:

> What can the iPhone automatically know about this moment, and what does only the user know?

Examples of possible future apps built on this SDK:

- WineLogger
- CoffeeLogger
- MineralLogger
- InsectLogger
- BirdLogger
- TravelLogger
- CampLogger
- NatureObservationLogger
- ArtMuseumLogger
- FieldResearchLogger

The MVP includes a generic module and a sample wine module.

---

## 2. Core Philosophy

The SDK should automate objective capture and minimize subjective input.

### Automatically captured information

Examples:

- image data
- OCR text
- EXIF metadata
- timestamp
- GPS location
- altitude
- heading
- device orientation
- barometric pressure, if available
- weather, mocked in MVP
- external search result, mocked in MVP

### User-provided information

Only ask for information that cannot be reliably sensed.

Examples:

- satisfaction
- taste
- subjective impression
- whether they want to repeat the experience
- note
- field-specific observation

For example, in a wine app:

- App can infer label text, vintage, date, place, and weather.
- User only answers how it tasted and whether they would drink it again.

---

## 3. Platform

- Language: Swift
- Package manager: Swift Package Manager
- Platform: iOS
- Minimum version: iOS 17.0
- Concurrency: async/await
- UI framework: SDK should be UI-independent
- Example app: SwiftUI

---

## 4. Repository Structure

Use this structure as the target.

```text
RealityCaptureKit/
├── Package.swift
├── README.md
├── AGENTS.md
├── docs/
│   └── SPEC.md
├── Sources/
│   └── RealityCaptureKit/
│       ├── RealityCaptureKit.swift
│       ├── Core/
│       │   ├── CaptureEngine.swift
│       │   ├── CaptureModule.swift
│       │   ├── CaptureSession.swift
│       │   ├── CaptureContext.swift
│       │   ├── CaptureResult.swift
│       │   └── CaptureError.swift
│       ├── Models/
│       │   ├── CapturedImage.swift
│       │   ├── SensorSnapshot.swift
│       │   ├── LocationSnapshot.swift
│       │   ├── WeatherSnapshot.swift
│       │   ├── OCRResult.swift
│       │   ├── MetadataResult.swift
│       │   ├── UserQuestion.swift
│       │   ├── UserAnswer.swift
│       │   ├── ExperienceRecord.swift
│       │   └── ExternalSearchResult.swift
│       ├── Services/
│       │   ├── OCR/
│       │   │   ├── OCRService.swift
│       │   │   ├── VisionOCRService.swift
│       │   │   └── MockOCRService.swift
│       │   ├── Location/
│       │   │   ├── LocationService.swift
│       │   │   ├── CoreLocationService.swift
│       │   │   └── MockLocationService.swift
│       │   ├── Sensors/
│       │   │   ├── SensorService.swift
│       │   │   ├── DeviceSensorService.swift
│       │   │   └── MockSensorService.swift
│       │   ├── Weather/
│       │   │   ├── WeatherService.swift
│       │   │   └── MockWeatherService.swift
│       │   ├── Metadata/
│       │   │   ├── ImageMetadataService.swift
│       │   │   ├── DefaultImageMetadataService.swift
│       │   │   └── MockImageMetadataService.swift
│       │   ├── Search/
│       │   │   ├── ExternalSearchService.swift
│       │   │   └── MockExternalSearchService.swift
│       │   └── Storage/
│       │       ├── RecordStore.swift
│       │       └── InMemoryRecordStore.swift
│       ├── Modules/
│       │   ├── GenericCaptureModule.swift
│       │   └── WineCaptureModule.swift
│       └── Utilities/
│           ├── DateProvider.swift
│           ├── CGRectCodable.swift
│           └── JSONCodableHelper.swift
└── Tests/
    └── RealityCaptureKitTests/
        ├── CaptureEngineTests.swift
        ├── GenericCaptureModuleTests.swift
        └── WineCaptureModuleTests.swift
```

An `Examples/` directory may be added if feasible.

---

## 5. Main Capture Flow

The SDK should support this flow:

```text
1. App provides a CapturedImage.
2. CaptureEngine starts capture.
3. OCRService extracts text.
4. ImageMetadataService extracts image metadata.
5. LocationService gets current location.
6. SensorService gets current sensor snapshot.
7. WeatherService gets weather for location and date.
8. ExternalSearchService performs optional mock search.
9. CaptureModule builds domain-specific metadata.
10. CaptureModule generates user questions.
11. App presents questions to user.
12. User provides answers.
13. CaptureEngine completes capture.
14. CaptureModule builds final ExperienceRecord.
15. RecordStore saves the record.
16. CaptureEngine returns the final ExperienceRecord.
```

---

## 6. Core Types

### 6.1 CapturedImage

Represents image data passed from the host app into the SDK.

```swift
public struct CapturedImage: Sendable {
    public let data: Data
    public let fileName: String?
    public let createdAt: Date?
    public let uti: String?

    public init(
        data: Data,
        fileName: String? = nil,
        createdAt: Date? = nil,
        uti: String? = nil
    )
}
```

Avoid requiring UIKit in this model.  
Host apps can convert `UIImage` or `PhotosPickerItem` data before creating this value.

---

### 6.2 OCRResult

```swift
public struct OCRResult: Codable, Sendable {
    public let fullText: String
    public let observations: [OCRObservation]

    public init(fullText: String, observations: [OCRObservation] = [])
}

public struct OCRObservation: Codable, Sendable {
    public let text: String
    public let confidence: Float?
    public let boundingBox: CGRectCodable?

    public init(
        text: String,
        confidence: Float? = nil,
        boundingBox: CGRectCodable? = nil
    )
}
```

---

### 6.3 CGRectCodable

Create a small codable representation of a rectangle.

```swift
public struct CGRectCodable: Codable, Sendable {
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double
}
```

---

### 6.4 LocationSnapshot

```swift
public struct LocationSnapshot: Codable, Sendable {
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
    )
}
```

If permission is denied or location is unavailable, return a snapshot with nil coordinate fields where possible.

---

### 6.5 SensorSnapshot

```swift
public struct SensorSnapshot: Codable, Sendable {
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
    )
}
```

Simulator and unsupported devices may return nil values.

---

### 6.6 WeatherSnapshot

```swift
public struct WeatherSnapshot: Codable, Sendable {
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
    )
}
```

MVP uses `MockWeatherService`.

---

### 6.7 MetadataResult

Represents domain-specific automatically inferred metadata.

```swift
public struct MetadataResult: Codable, Sendable {
    public let title: String?
    public let summary: String?
    public let fields: [String: MetadataField]
    public let source: String?

    public init(
        title: String?,
        summary: String? = nil,
        fields: [String: MetadataField] = [:],
        source: String? = nil
    )
}

public struct MetadataField: Codable, Sendable {
    public let key: String
    public let displayName: String
    public let value: String
    public let confidence: Double?
    public let source: String?

    public init(
        key: String,
        displayName: String,
        value: String,
        confidence: Double? = nil,
        source: String? = nil
    )
}
```

---

### 6.8 UserQuestion

Represents a question that the SDK asks the user.

```swift
public struct UserQuestion: Codable, Identifiable, Sendable {
    public let id: String
    public let prompt: String
    public let kind: UserQuestionKind
    public let isRequired: Bool
    public let reason: String?

    public init(
        id: String,
        prompt: String,
        kind: UserQuestionKind,
        isRequired: Bool,
        reason: String? = nil
    )
}
```

```swift
public enum UserQuestionKind: Codable, Sendable {
    case rating(min: Int, max: Int)
    case text
    case singleChoice([String])
    case multipleChoice([String])
    case boolean
    case number(unit: String?)
}
```

If automatic Codable synthesis is difficult for associated values, implement manual Codable.

---

### 6.9 UserAnswer

```swift
public struct UserAnswer: Codable, Sendable {
    public let questionId: String
    public let value: UserAnswerValue

    public init(questionId: String, value: UserAnswerValue)
}
```

```swift
public enum UserAnswerValue: Codable, Sendable {
    case rating(Int)
    case text(String)
    case singleChoice(String)
    case multipleChoice([String])
    case boolean(Bool)
    case number(Double)
}
```

If automatic Codable synthesis is difficult for associated values, implement manual Codable.

---

### 6.10 ExperienceRecord

The final result of a completed capture.

```swift
public struct ExperienceRecord: Codable, Identifiable, Sendable {
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
    )
}
```

---

### 6.11 ExternalSearchResult

```swift
public struct ExternalSearchResult: Codable, Sendable {
    public let title: String
    public let url: URL?
    public let snippet: String?
    public let source: String?

    public init(
        title: String,
        url: URL? = nil,
        snippet: String? = nil,
        source: String? = nil
    )
}
```

---

## 7. Capture Context and Session

### 7.1 CaptureContext

`CaptureContext` contains all automatically collected data for a capture.

```swift
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
    )
}
```

---

### 7.2 CaptureSession

`CaptureSession` represents an in-progress capture before user answers are submitted.

```swift
public struct CaptureSession: Identifiable, Sendable {
    public let id: UUID
    public let moduleId: String
    public let context: CaptureContext
    public let metadata: MetadataResult
    public let questions: [UserQuestion]

    public init(
        id: UUID = UUID(),
        moduleId: String,
        context: CaptureContext,
        metadata: MetadataResult,
        questions: [UserQuestion]
    )
}
```

---

## 8. CaptureModule

`CaptureModule` defines domain-specific behavior.

```swift
public protocol CaptureModule: Sendable {
    var id: String { get }
    var displayName: String { get }

    func buildMetadata(
        from context: CaptureContext
    ) async throws -> MetadataResult

    func makeQuestions(
        from context: CaptureContext,
        metadata: MetadataResult
    ) async throws -> [UserQuestion]

    func buildRecord(
        from context: CaptureContext,
        metadata: MetadataResult,
        answers: [UserAnswer]
    ) async throws -> ExperienceRecord
}
```

MVP modules:

- `GenericCaptureModule`
- `WineCaptureModule`

---

## 9. CaptureEngine

`CaptureEngine` orchestrates the SDK.

```swift
public final class CaptureEngine {
    public init(
        module: CaptureModule,
        ocrService: OCRService,
        locationService: LocationService,
        sensorService: SensorService,
        weatherService: WeatherService,
        metadataService: ImageMetadataService,
        searchService: ExternalSearchService,
        recordStore: RecordStore
    )

    public func startCapture(with image: CapturedImage) async throws -> CaptureSession

    public func completeCapture(
        session: CaptureSession,
        answers: [UserAnswer]
    ) async throws -> ExperienceRecord
}
```

### startCapture behavior

1. Validate image data is not empty.
2. Run OCR.
3. Extract image metadata.
4. Get location.
5. Get sensor snapshot.
6. Get weather.
7. Create a search query from OCR text when available.
8. Run mock external search.
9. Build `CaptureContext`.
10. Ask module to build metadata.
11. Ask module to create questions.
12. Return `CaptureSession`.

Optional service failures should not abort capture.

### completeCapture behavior

1. Pass context, metadata, and answers to module.
2. Receive `ExperienceRecord`.
3. Save record in `RecordStore`.
4. Return record.

---

## 10. Service Protocols

### 10.1 OCRService

```swift
public protocol OCRService: Sendable {
    func recognizeText(in image: CapturedImage) async throws -> OCRResult
}
```

Implement:

- `VisionOCRService`
- `MockOCRService`

`VisionOCRService` should use Apple Vision where possible.  
If platform constraints make this difficult in the first pass, create a stub that compiles and document the limitation.

---

### 10.2 LocationService

```swift
public protocol LocationService: Sendable {
    func currentLocation() async throws -> LocationSnapshot
}
```

Implement:

- `CoreLocationService`
- `MockLocationService`

`CoreLocationService` should be safe when permission is unavailable.  
It should not crash.

---

### 10.3 SensorService

```swift
public protocol SensorService: Sendable {
    func currentSnapshot() async throws -> SensorSnapshot
}
```

Implement:

- `DeviceSensorService`
- `MockSensorService`

`DeviceSensorService` can return nil values for unavailable sensors.

---

### 10.4 WeatherService

```swift
public protocol WeatherService: Sendable {
    func weather(for location: LocationSnapshot?, at date: Date) async throws -> WeatherSnapshot
}
```

Implement:

- `MockWeatherService`

Do not implement real WeatherKit or Open-Meteo in MVP.

---

### 10.5 ImageMetadataService

```swift
public protocol ImageMetadataService: Sendable {
    func extractMetadata(from image: CapturedImage) async throws -> [String: String]
}
```

Implement:

- `DefaultImageMetadataService`
- `MockImageMetadataService`

`DefaultImageMetadataService` should attempt to extract EXIF-style metadata if practical.  
If not practical in the first pass, return an empty dictionary and keep the type ready for future implementation.

---

### 10.6 ExternalSearchService

```swift
public protocol ExternalSearchService: Sendable {
    func search(query: String) async throws -> [ExternalSearchResult]
}
```

Implement:

- `MockExternalSearchService`

Do not perform real web search in MVP.

---

### 10.7 RecordStore

```swift
public protocol RecordStore: Sendable {
    func save(_ record: ExperienceRecord) async throws
    func fetchAll() async throws -> [ExperienceRecord]
    func delete(id: UUID) async throws
}
```

Implement:

- `InMemoryRecordStore`

Because `InMemoryRecordStore` has mutable state, make it concurrency-safe.  
Use an `actor` if appropriate.

---

## 11. Error Model

Create `CaptureError`.

```swift
public enum CaptureError: Error, LocalizedError, Sendable {
    case invalidImage
    case ocrFailed(String)
    case locationUnavailable
    case sensorUnavailable
    case weatherUnavailable
    case searchFailed(String)
    case storageFailed(String)
    case moduleFailed(String)
    case unknown(String)
}
```

Only `invalidImage` should normally stop the capture in MVP.

Other errors should be swallowed or converted to nil/empty values in `CaptureEngine.startCapture`.

---

## 12. GenericCaptureModule

`GenericCaptureModule` is the default reusable module.

### Behavior

- `id`: `"generic"`
- `displayName`: `"Generic Capture"`
- Metadata title:
  - first non-empty OCR line if available
  - otherwise `"Untitled Capture"`
- Metadata summary:
  - OCR full text if available
  - otherwise nil
- Metadata fields:
  - `ocr_text`
  - `captured_at`
  - `location_available`
  - `weather_available`

### Questions

Generate:

1. Required rating question:
   - id: `"satisfaction"`
   - prompt: `"How satisfying was this experience?"`
   - kind: `.rating(min: 1, max: 5)`

2. Optional text question:
   - id: `"note"`
   - prompt: `"Any notes?"`
   - kind: `.text`

### Record

Build an `ExperienceRecord` with:

- moduleId: `"generic"`
- metadata
- answers
- tags: `["generic"]`
- note: value of `"note"` answer if present

---

## 13. WineCaptureModule

`WineCaptureModule` is a sample domain module.

It demonstrates how a future app can use RealityCaptureKit for a specific category.

### Behavior

- `id`: `"wine"`
- `displayName`: `"Wine Capture"`

### Metadata extraction

From OCR text:

- Extract a 4-digit vintage candidate.
- Use a likely first meaningful OCR line as `wine_name`.
- Use mock search results if available.
- Unknown fields should be represented as `"Unknown"` rather than crashing.

### Metadata fields

Include:

- `wine_name`
- `vintage`
- `producer`
- `region`
- `grape_variety`
- `alcohol`
- `source`

MVP can use simple heuristics.

Example:

```text
Chateau Example
Bordeaux
2018
13.5%
```

Should result in:

- wine_name: `Chateau Example`
- vintage: `2018`
- alcohol: `13.5%`

### Questions

Generate:

1. Required rating:
   - id: `"taste_rating"`
   - prompt: `"How good was this wine?"`
   - kind: `.rating(min: 1, max: 5)`

2. Required boolean:
   - id: `"drink_again"`
   - prompt: `"Would you drink it again?"`
   - kind: `.boolean`

3. Optional sweetness rating:
   - id: `"sweetness"`
   - prompt: `"How sweet did it taste?"`
   - kind: `.rating(min: 1, max: 5)`

4. Optional acidity rating:
   - id: `"acidity"`
   - prompt: `"How acidic did it taste?"`
   - kind: `.rating(min: 1, max: 5)`

5. Optional tannin rating:
   - id: `"tannin"`
   - prompt: `"How tannic did it taste?"`
   - kind: `.rating(min: 1, max: 5)`

6. Optional text:
   - id: `"note"`
   - prompt: `"Any tasting notes?"`
   - kind: `.text`

### Record

Build an `ExperienceRecord` with:

- moduleId: `"wine"`
- metadata
- answers
- tags: `["wine"]`
- note: value of `"note"` answer if present

---

## 14. Mock Services

### MockOCRService

Should allow configuring returned text.

Example default text:

```text
Chateau Example
Bordeaux
2018
13.5%
```

### MockLocationService

Return a fixed optional location.

Example:

- latitude: `35.681236`
- longitude: `139.767125`
- placeName: `"Tokyo Station"`

### MockSensorService

Return a fixed sensor snapshot.

Example:

- pressureHpa: `1013.25`
- altitudeMeters: `40`
- headingDegrees: `180`
- brightness: `0.5`

### MockWeatherService

Return a fixed weather snapshot.

Example:

- temperatureCelsius: `22.0`
- humidity: `0.55`
- pressureHpa: `1013.25`
- condition: `"Clear"`
- source: `"MockWeatherService"`

### MockExternalSearchService

Return fixed search results based on the query.

For wine-like text, return a plausible fake result.

Do not call network.

---

## 15. Example Usage

README should include an example like this.

```swift
let engine = CaptureEngine(
    module: WineCaptureModule(),
    ocrService: MockOCRService(),
    locationService: MockLocationService(),
    sensorService: MockSensorService(),
    weatherService: MockWeatherService(),
    metadataService: MockImageMetadataService(),
    searchService: MockExternalSearchService(),
    recordStore: InMemoryRecordStore()
)

let image = CapturedImage(
    data: Data([0x01, 0x02, 0x03]),
    fileName: "wine.jpg",
    createdAt: Date(),
    uti: "public.jpeg"
)

let session = try await engine.startCapture(with: image)

let answers = [
    UserAnswer(questionId: "taste_rating", value: .rating(5)),
    UserAnswer(questionId: "drink_again", value: .boolean(true)),
    UserAnswer(questionId: "note", value: .text("Rich, sweet, and memorable."))
]

let record = try await engine.completeCapture(
    session: session,
    answers: answers
)
```

---

## 16. Unit Tests

Add tests for the MVP.

### CaptureEngineTests

Test cases:

1. `startCapture` creates a session.
2. `startCapture` includes module metadata.
3. `startCapture` includes generated questions.
4. `completeCapture` creates a record.
5. `completeCapture` saves record to store.
6. OCR failure does not abort capture.

### GenericCaptureModuleTests

Test cases:

1. Builds title from first OCR line.
2. Falls back to `"Untitled Capture"`.
3. Generates satisfaction and note questions.
4. Builds record with generic tag.

### WineCaptureModuleTests

Test cases:

1. Extracts vintage from OCR text.
2. Extracts alcohol percentage when present.
3. Generates wine-specific questions.
4. Builds record with wine tag.
5. Handles missing OCR text gracefully.

---

## 17. README Requirements

Create or update `README.md` with:

1. Project name
2. Overview
3. Philosophy
4. Installation

```swift
.package(url: "https://github.com/monsterangler/RealityCaptureKit.git", from: "0.1.0")
```

5. Minimal usage example
6. Module architecture
7. Available MVP modules
8. Available MVP services
9. Limitations
10. Privacy notes
11. Future roadmap

---

## 18. Example App

If feasible, create a minimal SwiftUI example app.

The app should:

1. Let the user choose module:
   - Generic
   - Wine

2. Let the user provide/select an image.

3. Start capture.

4. Display:
   - OCR text
   - metadata title
   - metadata fields
   - location
   - sensor snapshot
   - weather snapshot
   - generated questions

5. Allow simple answers.

6. Complete capture.

7. Display final `ExperienceRecord` as pretty JSON.

If creating a full example app is too much for the first pass, create README sample code and tests first.

---

## 19. MVP Completion Criteria

MVP is complete when:

- `swift build` succeeds.
- Unit tests pass.
- Core SDK types are public and usable.
- `CaptureEngine` can produce a `CaptureSession`.
- `CaptureEngine` can produce an `ExperienceRecord`.
- `GenericCaptureModule` works.
- `WineCaptureModule` works.
- All services are protocol-based.
- Mock services work without network.
- README explains basic usage.
- No external API keys are required.
- No real network access is required.
- Optional service failures do not crash the capture flow.

---

## 20. Future Roadmap

Do not implement these now, but keep the architecture open for them.

### Services

- `AIService`
- `WeatherKitWeatherService`
- `OpenMeteoWeatherService`
- `WebSearchService`
- `WineDatabaseService`
- `SwiftDataRecordStore`
- `FileRecordStore`

### Modules

- `CoffeeCaptureModule`
- `MineralCaptureModule`
- `InsectCaptureModule`
- `BirdCaptureModule`
- `MushroomCaptureModule`
- `TravelCaptureModule`
- `CampCaptureModule`

### Features

- automatic module routing from image
- information gain based question engine
- only ask the single most valuable question
- JSON export
- CSV export
- GPX/KML export
- map display
- timeline view
- personal preference analysis
- similar experience recommendations
- local-only AI analysis
- cloud sync
- privacy-first encrypted storage

---

## 21. Important Non-Goals

The MVP must not become a production app.

It is an SDK foundation.

Avoid:

- app-specific business logic in the core
- hardcoded wine-only behavior in `CaptureEngine`
- real API dependencies
- secret keys
- scraping
- complex persistence
- complex UI
- premature optimization
- overengineering

The first version should be boring, stable, testable, and extensible.