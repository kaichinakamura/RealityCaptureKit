# AGENTS.md

## Project Name

RealityCaptureKit

## Project Summary

RealityCaptureKit is an iOS Swift Package SDK for semi-automatic real-world capture.

The SDK helps apps record real-world objects, experiences, and observations by combining:

- image input
- OCR
- image metadata
- location
- device sensor snapshots
- weather/search metadata
- minimal user-provided subjective input

The core philosophy is:

> Automatically capture everything the iPhone can observe, and ask the user only for information that cannot be sensed.

This SDK should remain generic and reusable. It must not become a wine-only, coffee-only, or nature-only app. Domain-specific behavior should be implemented through modules.

---

## Primary Goal for MVP

Build the first MVP of RealityCaptureKit as a Swift Package.

The MVP should provide:

- A buildable Swift Package
- Core SDK types
- Protocol-based services
- Mock/default service implementations
- A generic capture module
- A sample wine capture module
- An in-memory record store
- Unit tests
- README
- A simple SwiftUI example app or example target demonstrating basic SDK usage

The MVP does not need real external API integrations.

---

## Development Rules

### General

- Use Swift.
- Use Swift Package Manager.
- Target iOS 17.0 or later.
- Prefer async/await.
- Prefer protocol-oriented design.
- Prefer dependency injection.
- Keep the SDK UI-independent.
- Keep public APIs clean and usable from external apps.
- Keep the package buildable at every major step.
- Keep the implementation simple and practical.

### Architecture

- The SDK must be module-based.
- Domain-specific behavior must live in types conforming to `CaptureModule`.
- The core SDK must not depend on a specific domain such as wine, coffee, insects, minerals, or travel.
- Services should be defined as protocols.
- Real implementations and mock implementations should be swappable.
- Avoid tightly coupling services to concrete implementations.
- Avoid global singleton dependencies unless strongly justified.

### MVP Scope

Implement the following for MVP:

- `CaptureEngine`
- `CaptureModule`
- `CaptureSession`
- `CaptureResult` or equivalent
- `CaptureContext`
- `ExperienceRecord`
- `CapturedImage`
- `OCRResult`
- `LocationSnapshot`
- `SensorSnapshot`
- `WeatherSnapshot`
- `MetadataResult`
- `UserQuestion`
- `UserAnswer`
- `RecordStore`
- `GenericCaptureModule`
- `WineCaptureModule`
- Mock/default services necessary for tests and example usage

### Out of Scope for MVP

Do not implement these in the MVP:

- Real WeatherKit integration
- Real Open-Meteo integration
- Real web search
- Real wine database integration
- Vivino scraping
- Paid API integrations
- API keys
- LLM or AI API calls
- SwiftData persistence
- Cloud sync
- Account system
- Social features
- Complex UI
- Production-grade image recognition beyond OCR

Use protocols and mocks so these can be added later.

---

## Privacy and Safety Rules

RealityCaptureKit may handle sensitive user data such as:

- photos
- GPS location
- timestamps
- subjective user notes
- personal preferences
- experience history

Therefore:

- Do not upload user data anywhere in the MVP.
- Do not add analytics.
- Do not add network calls unless explicitly requested later.
- Do not hardcode external endpoints.
- Do not store API keys.
- Make it clear in README that apps using this SDK are responsible for privacy disclosures.
- Location permission failures must not crash the capture flow.
- Sensor unavailability must not crash the capture flow.
- OCR failure must not crash the capture flow.

---

## Error Handling

The SDK should be fault-tolerant.

If an optional service fails, the capture should continue where reasonable.

Examples:

- OCR fails → continue with empty OCR result
- Location unavailable → continue with nil location
- Sensor unavailable → continue with nil sensor snapshot
- Weather unavailable → continue with nil weather
- Search unavailable → continue with empty search results

Only unrecoverable failures, such as invalid image data, should stop the capture.

---

## Testing Rules

Add unit tests for the MVP.

At minimum, test:

- `CaptureEngine.startCapture`
- `CaptureEngine.completeCapture`
- `GenericCaptureModule`
- `WineCaptureModule`
- OCR failure tolerance
- Record saving through `RecordStore`
- Wine vintage extraction from OCR text
- Question generation

Tests should use mock services and should not require:

- network access
- real GPS
- real camera
- real sensors
- API keys

---

## Example App Rules

Provide a minimal example app or example target if feasible.

The example should demonstrate:

1. selecting or providing an image
2. choosing `GenericCaptureModule` or `WineCaptureModule`
3. starting a capture
4. displaying OCR, metadata, sensor, location, and mock weather/search results
5. answering generated questions
6. completing the capture
7. displaying the resulting `ExperienceRecord` as JSON

The example UI can be simple. Functionality matters more than design.

---

## File Organization

Use the structure described in `docs/SPEC.md`.

If implementation details require small adjustments, keep the overall architecture intact.

Recommended top-level structure:

```text
RealityCaptureKit/
├── AGENTS.md
├── README.md
├── Package.swift
├── docs/
│   └── SPEC.md
├── Sources/
│   └── RealityCaptureKit/
├── Tests/
│   └── RealityCaptureKitTests/
└── Examples/
    └── RealityCaptureKitExample/
```

---

## Documentation Rules

Update README with:

- project overview
- philosophy
- installation example
- minimal usage example
- module concept
- MVP limitations
- privacy notes
- future roadmap

Keep `docs/SPEC.md` as the source of truth for the MVP specification.

---

## Implementation Priority

Work in this order:

1. Create the Swift Package structure.
2. Define core models.
3. Define service protocols.
4. Implement mock/default services.
5. Implement `CaptureModule`.
6. Implement `GenericCaptureModule`.
7. Implement `WineCaptureModule`.
8. Implement `CaptureEngine`.
9. Implement `InMemoryRecordStore`.
10. Add unit tests.
11. Add README.
12. Add simple example app or example target.

Do not overbuild.

The first success condition is:

> The package builds, tests pass, and the SDK can produce an `ExperienceRecord` from an image and user answers.

---

## Codex Task Instruction

When asked to implement the MVP, read this file and `docs/SPEC.md` first.

Then implement the MVP without adding out-of-scope features.

If there is ambiguity, choose the simpler implementation that preserves the SDK architecture.