import Foundation

public enum CaptureError: Error, LocalizedError, Sendable, Equatable {
    case invalidImage
    case ocrFailed(String)
    case locationUnavailable
    case sensorUnavailable
    case weatherUnavailable
    case searchFailed(String)
    case storageFailed(String)
    case moduleFailed(String)
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .invalidImage:
            "Image data is empty or invalid."
        case .ocrFailed(let message):
            "OCR failed: \(message)"
        case .locationUnavailable:
            "Location is unavailable."
        case .sensorUnavailable:
            "Sensor data is unavailable."
        case .weatherUnavailable:
            "Weather is unavailable."
        case .searchFailed(let message):
            "Search failed: \(message)"
        case .storageFailed(let message):
            "Storage failed: \(message)"
        case .moduleFailed(let message):
            "Capture module failed: \(message)"
        case .unknown(let message):
            "Unknown capture error: \(message)"
        }
    }
}
