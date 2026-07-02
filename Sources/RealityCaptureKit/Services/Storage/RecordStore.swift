import Foundation

public protocol RecordStore: Sendable {
    func save(_ record: ExperienceRecord) async throws
    func fetchAll() async throws -> [ExperienceRecord]
    func delete(id: UUID) async throws
}

public actor InMemoryRecordStore: RecordStore {
    private var records: [UUID: ExperienceRecord]

    public init(records: [ExperienceRecord] = []) {
        self.records = Dictionary(uniqueKeysWithValues: records.map { ($0.id, $0) })
    }

    public func save(_ record: ExperienceRecord) async throws {
        records[record.id] = record
    }

    public func fetchAll() async throws -> [ExperienceRecord] {
        records.values.sorted { $0.createdAt < $1.createdAt }
    }

    public func delete(id: UUID) async throws {
        records[id] = nil
    }
}
