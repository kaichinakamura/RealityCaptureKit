import Foundation

public protocol DateProvider: Sendable {
    func now() -> Date
}

public struct SystemDateProvider: DateProvider {
    public init() {}

    public func now() -> Date {
        Date()
    }
}

public struct FixedDateProvider: DateProvider {
    private let fixedDate: Date

    public init(_ fixedDate: Date) {
        self.fixedDate = fixedDate
    }

    public func now() -> Date {
        fixedDate
    }
}
