import Foundation

enum BuildStatus: String, Codable {
    case queued, running, success, failed
}

struct Build: Identifiable, Codable {
    let id: UUID
    var name: String
    var date: Date
    var status: BuildStatus
    var logPreview: String?

    init(id: UUID = UUID(), name: String, date: Date = Date(), status: BuildStatus = .queued, logPreview: String? = nil) {
        self.id = id
        self.name = name
        self.date = date
        self.status = status
        self.logPreview = logPreview
    }
}
