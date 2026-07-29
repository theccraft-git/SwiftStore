import Foundation

public enum BuildStatus: String, Codable {
    case queued, running, success, failed
}

public struct Build: Identifiable, Codable {
    public let id: UUID
    public var name: String
    public var date: Date
    public var status: BuildStatus
    public var logPreview: String?

    public init(id: UUID = UUID(), name: String, date: Date = Date(), status: BuildStatus = .queued, logPreview: String? = nil) {
        self.id = id
        self.name = name
        self.date = date
        self.status = status
        self.logPreview = logPreview
    }
}
