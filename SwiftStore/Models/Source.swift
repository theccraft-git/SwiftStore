import Foundation

struct Source: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var url: URL
    var enabled: Bool

    init(id: UUID = UUID(), name: String, url: URL, enabled: Bool = true) {
        self.id = id
        self.name = name
        self.url = url
        self.enabled = enabled
    }
}
