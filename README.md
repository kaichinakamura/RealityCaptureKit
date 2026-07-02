# RealityCaptureKit

RealityCaptureKit is a Swift Package SDK for semi-automatic real-world capture on iOS.

RealityCaptureKit は、iOSアプリで現実世界の体験・物・観察を半自動で記録するためのSwift Package SDKです。

## Philosophy / 哲学

Automatically capture everything the iPhone can observe, and ask the user only for information that cannot be sensed.

iPhoneが観測できる情報は自動で取得し、ユーザーにはセンサーでは分からない主観的な情報だけを尋ねます。

## Installation / インストール

Add the package with Swift Package Manager:

Swift Package Managerで追加します。

```swift
.package(url: "https://github.com/monsterangler/RealityCaptureKit.git", from: "0.1.0")
```

## Minimal Usage / 最小利用例

```swift
import Foundation
import RealityCaptureKit

let store = InMemoryRecordStore()

let engine = CaptureEngine(
    module: WineCaptureModule(),
    ocrService: MockOCRService(),
    locationService: MockLocationService(),
    sensorService: MockSensorService(),
    weatherService: MockWeatherService(),
    metadataService: MockImageMetadataService(),
    searchService: MockExternalSearchService(),
    recordStore: store
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

`startCapture` creates a `CaptureSession` with OCR, metadata, location, sensor, mock weather/search data, module metadata, and generated questions. `completeCapture` produces and saves an `ExperienceRecord`.

`startCapture` はOCR、画像メタデータ、位置情報、センサー、モック天気・検索、モジュール固有メタデータ、質問を含む `CaptureSession` を生成します。`completeCapture` は `ExperienceRecord` を生成して保存します。

## Module Architecture / モジュール構成

Domain-specific behavior lives in types conforming to `CaptureModule`.

ドメイン固有の処理は `CaptureModule` に準拠する型に閉じ込めます。

- `CaptureEngine` orchestrates services and modules.
- `CaptureModule` builds metadata, questions, and final records.
- Services are protocol-based and injected.
- The SDK core is UI-independent.

- `CaptureEngine` がサービスとモジュールを統合します。
- `CaptureModule` がメタデータ、質問、最終レコードを生成します。
- サービスはプロトコルベースでDIできます。
- SDKコアはUIに依存しません。

## MVP Modules / MVPモジュール

- `GenericCaptureModule`: generic captures with satisfaction and note questions.
- `WineCaptureModule`: sample wine capture with simple OCR heuristics for wine name, vintage, region, and alcohol.

- `GenericCaptureModule`: 汎用記録。満足度とメモを質問します。
- `WineCaptureModule`: ワイン記録のサンプル。OCRテキストからワイン名、ヴィンテージ、地域、アルコール度数を簡易推定します。

## MVP Services / MVPサービス

- `OCRService` / `MockOCRService` / `VisionOCRService` stub
- `LocationService` / `MockLocationService` / `CoreLocationService` safe stub
- `SensorService` / `MockSensorService` / `DeviceSensorService` safe stub
- `WeatherService` / `MockWeatherService`
- `ImageMetadataService` / `MockImageMetadataService` / `DefaultImageMetadataService`
- `ExternalSearchService` / `MockExternalSearchService`
- `RecordStore` / `InMemoryRecordStore`

All MVP mock services run locally and do not require network access or API keys.

MVPのモックサービスはすべてローカルで動作し、ネットワークアクセスやAPIキーを必要としません。

## Limitations / 制限

- No real WeatherKit, Open-Meteo, web search, wine database, scraping, LLM, cloud sync, or analytics.
- `VisionOCRService`, `CoreLocationService`, and `DeviceSensorService` are safe compile-time stubs in the MVP.
- Persistence is in-memory only.
- Wine extraction uses simple heuristics and is not production-grade recognition.

- 実WeatherKit、Open-Meteo、Web検索、ワインDB、スクレイピング、LLM、クラウド同期、分析機能はありません。
- `VisionOCRService`、`CoreLocationService`、`DeviceSensorService` はMVPでは安全なスタブです。
- 永続化はインメモリのみです。
- ワイン情報の抽出は簡易ヒューリスティックで、本番品質の認識ではありません。

## Privacy / プライバシー

RealityCaptureKit may handle sensitive data such as photos, location, timestamps, notes, preferences, and experience history. The MVP does not upload user data, add analytics, make network calls, or store API keys.

Apps using this SDK are responsible for permission prompts, privacy disclosures, data retention policy, and any future external integrations.

RealityCaptureKitは、写真、位置情報、タイムスタンプ、メモ、好み、体験履歴などの機微なデータを扱う可能性があります。MVPではユーザーデータのアップロード、分析、ネットワーク通信、APIキー保存は行いません。

このSDKを利用するアプリ側が、権限リクエスト、プライバシー表示、データ保持方針、将来の外部連携について責任を持つ必要があります。

## Roadmap / ロードマップ

- Real optional service implementations, such as WeatherKit or local OCR.
- Persistent stores such as file storage or SwiftData.
- More modules: coffee, minerals, insects, birds, travel, camping, field research.
- Export tools for JSON, CSV, GPX, or KML.
- Privacy-first local intelligence and preference analysis.

- WeatherKitやローカルOCRなど、実サービス実装の追加。
- ファイル保存やSwiftDataなどの永続ストア。
- コーヒー、鉱物、昆虫、鳥、旅行、キャンプ、フィールド調査などの追加モジュール。
- JSON、CSV、GPX、KMLなどのエクスポート。
- プライバシー優先のローカル分析や嗜好分析。
